//
//  SnipPodcastViewController.swift
//  CastSnip
//
//  Created by Eric Wuehler on 10/13/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import SwiftOverlays
import SoundWave

class SnipPodcastViewController: UIViewController, URLSessionDownloadDelegate, SnipAdjustmentViewDelegate {

    let fineStep: Double = 0.1
    let haptic: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    var podcast: Podcast? = nil
    var feedURL: String = ""
    var episode: Episode? = nil
    var coverArt: UIImage? = nil
    var snipStart: Double = 0
    var snipEnd: Double = 0
    var episodeDuration: Double = 0
    
    var draggingSlider: Bool = false
    
    enum PlaybackEdit: Int {
        case play = 0, start, end
    }
    enum PlaybackMode: Int {
        case pause = 1, play, fineAdjustStart, fineAdjustEnd
    }
    var currentPlaybackMode = PlaybackMode.pause
    let playbackLength = 3.0
    
    private var audioTimer: Timer? = nil
    
    var episodeURL: URL!
    var episodeLocalURL: URL!
    var episodePlayer: AVAudioPlayer!
    
    var destinationEpisodeURL: URL?
    
    
    @IBOutlet weak var recordingTextView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var snipView: UIView!
    @IBOutlet weak var podcastImage: UIImageView!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var snipTimeInfoLabel: UILabel!
    @IBOutlet weak var watermarkView: UIView!
    @IBOutlet weak var watermarkLabel: UILabel!
    
    @IBOutlet weak var startAdjustment: SnipAdjustmentView!
    @IBOutlet weak var endAdjustment: SnipAdjustmentView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var deltaTimeLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skipBackwardButton: UIButton!
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet var doubleTapSkipBackward: UITapGestureRecognizer!
    @IBOutlet var doubleTapSkipForward: UITapGestureRecognizer!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var waveform: AudioVisualizationView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        playButton.isEnabled = false
        skipBackwardButton.isEnabled = false
        skipForwardButton.isEnabled = false
        saveButton.isEnabled = false
        
        currentTimeLabel.isEnabled = false
        timeSlider.isEnabled = false
        startAdjustment.isEnabled = false
        endAdjustment.isEnabled = false
        startAdjustment.delegate = self
        endAdjustment.delegate = self
        startAdjustment.setTitle("SET START")
        startAdjustment.setDefaultTitle("SET START")
        endAdjustment.setTitle("SET FINISH")
        endAdjustment.setDefaultTitle("SET FINISH")
        deltaTimeLabel.isHidden = true
        
        recordingTextView.isHidden = Select.setting.hideDetail()
        watermarkView.isHidden = Select.setting.hideWatermark()
        if (recordingTextView.isHidden && !watermarkView.isHidden) {
            watermarkView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        } else {
            watermarkView.backgroundColor = UIColor.clear
        }
        
        waveform.meteringLevelBarWidth = 3.0
        waveform.meteringLevelBarInterItem = 1.0
        waveform.meteringLevelBarCornerRadius = 1.5
        waveform.gradientStartColor = self.playButton.tintColor
        waveform.gradientEndColor = self.playButton.tintColor
        
        recordingTextView.backgroundColor = UIColor(white: 0, alpha: 0.8)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        if (podcast == nil) {
            showAlertMessage(title: "Error", message: "Podcast was not found!", button: "OK")
        }

        if (episode == nil) {
            showAlertMessage(title: "Error", message: "Episode was not found!", button: "OK")
        }

        episodeNameLabel.text = episode?.title
        snipTimeInfoLabel.text = " "
        podcastImage.image = podcast?.cover
        feedURL = (podcast?.feedURL)!
        episodeDuration = (episode?.duration) ?? 0

        recordingTextView.isHidden = Select.setting.hideDetail()
        watermarkView.isHidden = Select.setting.hideWatermark()
        if (recordingTextView.isHidden && !watermarkView.isHidden) {
            watermarkView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        } else {
            watermarkView.backgroundColor = UIColor.clear
        }

        resetTimeControls()
        coverArt = podcast?.cover
        loadPodcastEpisode(podcast:podcast!, episode:episode!)
    }

    override func viewWillDisappear(_ animated: Bool) {
        playerPause()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func loadingEpisode(_ loading: Bool) {
        playButton.isEnabled = !loading
        skipBackwardButton.isEnabled = !loading
        skipForwardButton.isEnabled = !loading
        timeSlider.isEnabled = !loading
        startAdjustment.isEnabled = !loading
        endAdjustment.isEnabled = !loading
        statusProgressView.progress = 0
        statusProgressView.isHidden = !loading

        if (!loading) {
            statusLabel.isEnabled = true
            statusLabel.text = "READY"
            SwiftOverlays.removeAllOverlaysFromView(self.snipView)
        } else {
            statusLabel.text = "DOWNLOADING EPISODE"
            _ = SwiftOverlays.showCenteredWaitOverlayWithText(self.snipView, text: "Downloading Episode...")
        }
    }
    
    func updateDownloadStatus(_ text: String, _ progress: Float) {
        DispatchQueue.main.async {
            self.currentTimeLabel.text = text
            if (progress >= 0) {
                self.statusProgressView.progress = progress
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Done with download: \(location)")
        guard let destination = destinationEpisodeURL else {
            print("Invalid destination episode URL found")
            return
        }
        do {
            try FileManager.default.copyItem(at: location, to: destination)
        } catch (let writeError) {
            print("Error creating local copy of \(destination) : \(writeError)")
        }
        DispatchQueue.main.async {
            self.loadingEpisode(false)
            self.prepareToPlay(destination)
        }
        session.finishTasksAndInvalidate()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Error: \(String(describing: error))")
        DispatchQueue.main.async {
            self.loadingEpisode(false)
        }
        session.invalidateAndCancel()
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown) {
            let percentf = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            let percent = Int(percentf * 100)
             updateDownloadStatus("\(percent)% COMPLETE", percentf)
        }
    }
    
    func resetTimeControls() {
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(episodeDuration)
        timeSlider.value = 0
        updateCurrentTimeIndicators(Double(0))
        startAdjustment.reset()
        endAdjustment.reset()
        deltaTimeLabel.isHidden = true
        deltaTimeLabel.text = ""
    }
    
    func showAlertMessage(title: String, message: String, button: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: button, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated:true, completion: completion)
    }
    
    func loadPodcastEpisode(podcast: Podcast, episode: Episode) {
        if (episode.audioURL.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            showAlertMessage(title: "Error", message: "No Audio found for Episode", button: "OK")
            return
        }
        
        loadingEpisode(true)
        episodeURL = URL(string: (episode.audioURL))
        destinationEpisodeURL = Util.podcastLocalURL(podcastName: podcast.name, episodeGUID: episode.guid, audioExtension: episodeURL.pathExtension)

        if (Util.localFileExists(destinationEpisodeURL!)) {
            // Use the file
            loadingEpisode(false)
            prepareToPlay(destinationEpisodeURL!)
        } else {
            // Download the file
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            let task = session.downloadTask(with: episodeURL)
            self.statusProgressView.progress = 0
            self.statusProgressView.isHidden = false
            task.resume()
        }
    }
    
    func prepareToPlay(_ localURL: URL) {
        do {
            
            episodeLocalURL = localURL
            episodePlayer = try AVAudioPlayer(contentsOf: episodeLocalURL)
            episodePlayer.currentTime = 0.0
            episodePlayer.isMeteringEnabled = true
            episodePlayer.prepareToPlay()
            episodeDuration = episodePlayer.duration
            resetTimeControls()
            
            waveform.audioVisualizationMode = .write
            
            audioTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateAudioView), userInfo: nil, repeats: true)
        } catch {
            showAlertMessage(title: "Error", message: "Failed to load Audio Player", button: "OK")
            return
        }
    }
    
    func updateWaveform() {
        if (episodePlayer == nil || !episodePlayer.isPlaying) {
            return
        }
        episodePlayer.updateMeters()
        let averagePower = episodePlayer.averagePower(forChannel: 0)
        let percentage: Float = pow(10, (0.05 * averagePower))
        
        waveform.add(meteringLevel: percentage)
    }
    
    @objc func updateAudioView() {
        if (episodePlayer != nil && episodePlayer.isPlaying && episodePlayer.currentTime > 0.01) {
            self.timeSlider.value = Float(episodePlayer.currentTime)
            
            self.updateCurrentTimeIndicators(self.timeSlider.value)
        } else {
//            print("not playing")
        }
    }
    
    func createCurrentTime(_ time: Double) -> String {
        let start = Util.calcTime(time)
        let endtime = Double(timeSlider.maximumValue) - time
        let end = Util.calcTime(endtime, millis: false, negate: false)
        
        return "\(start)/\(end)"
    }
    
    func createStartLockTime(_ time: Double) -> String {
        createStartEndLockDeltaTime()
        return Util.calcTime(time, millis:true)
    }
    
    func createEndLockTime(_ time: Double) -> String {
        createStartEndLockDeltaTime()
        return Util.calcTime(time, millis:true)
    }
    
    func createStartEndLockDeltaTime() {
        if (startAdjustment.isSelected && endAdjustment.isSelected) {
            let deltaTime = (snipEnd > snipStart) ? snipEnd-snipStart : 0.0
            let delta = Util.calcTime(deltaTime, millis:true)
            deltaTimeLabel.isHidden = false
            deltaTimeLabel.text = "\(delta)"
            updateSnipTimeInfo()
        } else {
            deltaTimeLabel.text = " "
            deltaTimeLabel.isHidden = true
            snipTimeInfoLabel.text = " "
        }
        
    }
    
    func updateCurrentTimeIndicators(_ time: Float) {
        updateCurrentTimeIndicators(Double(time))
    }
    
    func updateCurrentTimeIndicators(_ time: Double) {
        currentTimeLabel.text = createCurrentTime(time)
        if (startAdjustment.isSelected && !endAdjustment.isSelected) {
            let deltaTime = (time > snipStart) ? time-snipStart : 0.0
            let delta = Util.calcTime(deltaTime, millis:true)
            deltaTimeLabel.isHidden = false
            deltaTimeLabel.text = "+ \(delta)"
        }
        updateWaveform()
        if (endAdjustment.isSelected && time > snipEnd) {
            playerPause()
        }
    }
    
    
    @IBAction func timeSliderStartedDrag(_ sender: Any?) {
        draggingSlider = true
        waveform.reset()
        episodePlayer.stop()
    }
    
    @IBAction func timeSliderFinished(_ sender: Any?) {
        draggingSlider = false
        updateCurrentTimeIndicators(timeSlider.value)
        episodePlayer.currentTime = Double(timeSlider.value)
        if (episodePlayer.prepareToPlay() && currentPlaybackMode == .play) {
            episodePlayer.play()
        }
        if (snipEnd > snipStart) {
            updateSnipTimeInfo()
        }

    }
    
    @IBAction func timeSliderChanged(_ sender: Any?) {
        if (startAdjustment.isSelected && timeSlider.value < Float(snipStart)) {
            timeSlider.value = Float(snipStart)
            haptic.notificationOccurred(.warning)
        } else if (endAdjustment.isSelected && timeSlider.value > Float(snipEnd)) {
            timeSlider.value = Float(snipEnd)
            haptic.notificationOccurred(.warning)
        } else {
            updateCurrentTimeIndicators(timeSlider.value)
        }
    }
    

     func updateSnipTimeInfo() {
        if (startAdjustment.isSelected && endAdjustment.isSelected) {
            snipTimeInfoLabel.text = "\(Util.calcTimeAsString(snipEnd - snipStart)) @ \(Util.calcTime(snipStart))"
        } else {
            snipTimeInfoLabel.text = " "
        }
    }
    

    func forwardButtonPressed(_ sender: SnipAdjustmentView) {
        if (sender == startAdjustment) {
            print("Forward from Start")
            if (startAdjustment.isSelected) {
                print("increment the current time value by 1")
                let goFwd = snipStart + fineStep
                if (goFwd > (episodeDuration - 1)) {
                    haptic.notificationOccurred(.warning)
                } else {
                    snipStart = goFwd
                    startAdjustment.setTitle(createStartLockTime(snipStart))
                    currentTimeLabel.text = createCurrentTime(snipStart)
                    currentPlaybackMode = .fineAdjustStart
                    pressJumpToStartButton(nil)
                    currentPlaybackMode = .fineAdjustStart
                }
            } else {
                setButtonPressed(sender)
            }
        } else if (sender == endAdjustment){
            print("Forward from Finish")
            if (endAdjustment.isSelected) {
                let goFwd = snipEnd + fineStep
                if (goFwd > episodeDuration) {
                    haptic.notificationOccurred(.warning)
                } else {
                    snipEnd = goFwd
                    endAdjustment.setTitle(createEndLockTime(snipEnd))
                    currentTimeLabel.text = createCurrentTime(snipEnd)
                    currentPlaybackMode = .fineAdjustEnd
                    pressJumpToEndButton(nil)
                    currentPlaybackMode = .fineAdjustEnd
                }
            } else {
                setButtonPressed(sender)
            }
        } else {
            print ("Forward from Unknown")
        }
    }
    
    func backwardButtonPressed(_ sender: SnipAdjustmentView) {
        if (sender == startAdjustment) {
            print("Backward from Start")
            if (startAdjustment.isSelected) {
                let goBack = snipStart - fineStep
                if (goBack < 0) {
                    haptic.notificationOccurred(.warning)
                } else {
                    snipStart = goBack
                    startAdjustment.setTitle(createStartLockTime(snipStart))
                    currentTimeLabel.text = createCurrentTime(snipStart)
                    currentPlaybackMode = .fineAdjustStart
                    pressJumpToStartButton(nil)
                    currentPlaybackMode = .fineAdjustStart
                }
            } else {
                setButtonPressed(sender)
            }
        } else if (sender == endAdjustment){
            print("Forward from Finish")
            if (endAdjustment.isSelected) {
                let goBack = snipEnd - fineStep
                if (goBack < snipStart) {
                    haptic.notificationOccurred(.warning)
                } else {
                    snipEnd = goBack
                    endAdjustment.setTitle(createEndLockTime(snipEnd))
                    currentTimeLabel.text = createCurrentTime(snipStart)
                    currentPlaybackMode = .fineAdjustEnd
                    pressJumpToEndButton(nil)
                    currentPlaybackMode = .fineAdjustEnd
                }

            } else {
                setButtonPressed(sender)
            }
        } else {
            print ("Forward from Unknown")
        }
    }
    
    func setButtonPressed(_ sender: SnipAdjustmentView) {
        print("set pressed")
        
        if (sender == startAdjustment) {
            startAdjustment.isSelected = !startAdjustment.isSelected
            if (startAdjustment.isSelected) {
                snipStart = Double(timeSlider.value)
                startAdjustment.setTitle(createStartLockTime(snipStart))
                deltaTimeLabel.isHidden = false
            } else {
                startAdjustment.setTitle("SET START")
                deltaTimeLabel.isHidden = true
            }
        } else if (sender == endAdjustment) {
            endAdjustment.isSelected = !endAdjustment.isSelected
            if (endAdjustment.isSelected) {
                snipEnd = Double(timeSlider.value)
                endAdjustment.setTitle(createEndLockTime(snipEnd))
                playerPause()
            } else {
                endAdjustment.setTitle("SET FINISH")
            }
            
        } else {
            print("not here...")
        }
        saveButton.isEnabled = startAdjustment.isSelected && endAdjustment.isSelected
        updateSnipTimeInfo()
    }
    

    
    @IBAction func resetButtonTouched(_ sender: Any) {
        resetTimeControls()
    }
    
    
    func createVideoFromAudioSnip(_ audioURL: URL, coverArt: UIImage) {
//        print("Creating Video with screenshot and audio from \(audioURL)")
        
        let outputURL = Util.videoSnipURL("\(Util.uuidString()).mp4")
        
        SnipCreator.createMovieWithSingleImageAndMusic(image: coverArt, audioFileURL: audioURL, assetExportPresetQuality: AVAssetExportPresetHighestQuality, outputVideoFileURL: outputURL, completion: { (error) in
            if (error != nil) {
                print("Error: \(String(describing: error))")
            } else {
//                print("Completed Video")
                // Add the video to the PodcastData SQLite Table
//                print("Adding to table")
                let snipGUID = outputURL.lastPathComponent
                let snip: Snip = Snip()
                snip.guid = snipGUID
                snip.feedURL = self.feedURL
                snip.episodeLink = (self.episode?.link)!
                snip.userNote = (self.podcast?.name)!
                snip.podcastTitle = (self.podcast?.name)!
                snip.episodeName = (self.episode?.title)!
                snip.startTime = self.snipStart
                snip.duration = self.snipEnd - self.snipStart
                snip.filename = snipGUID
                snip.coverData = Util.encodeArtwork(self.coverArt!)
                snip.properties = ""
                
                PodcastData.store.addSnip(snip)

                DispatchQueue.main.async {
                    self.statusLabel.textColor =  self.playButton.tintColor
                    self.statusLabel.text = "SNIP SAVED!"
                    self.saveButton.isSelected = false
                    
                    // Now load the SnipPlayerViewController
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SnipPlayer") as! SnipPlayerViewController
                    vc.episode = self.episode
                    vc.snip = snip
                    vc.feedURL = self.feedURL
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        })
    }
    
    @IBAction func pressRecordButton(_ sender: Any?) {
        let rec = (sender as! UIButton)
        rec.isEnabled = false
        playerPause()
        self.endAdjustment.isEnabled = false
        self.startAdjustment.isEnabled = false
        
        statusLabel.textColor =  UIColor(red: (148/255), green: (17/255), blue: 0, alpha: 1)
        statusLabel.text = "SAVING SNIP"
        
        let options:[String:Any]? = [
            AVURLAssetPreferPreciseDurationAndTimingKey : true
        ]
        let episodeAsset = AVURLAsset(url: episodeLocalURL, options: options)
        let tempAudioURL = Util.tempFileURL("m4a")
        let composition = AVMutableComposition()
        let compositionAudio = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let sourceAudio = episodeAsset.tracks(withMediaType: AVMediaType.audio).first!
        let start = CMTimeMakeWithSeconds(snipStart, preferredTimescale: 1000)
        let snipDuration = snipEnd - snipStart
        let duration = CMTimeMakeWithSeconds(snipDuration, preferredTimescale: 1000)
        let range = CMTimeRangeMake(start: start, duration: duration)
        
        do {
            try compositionAudio!.insertTimeRange(range, of: sourceAudio, at: start)
        } catch {
            print("Error with composition: \(error)")
        }
        
        let coverArt = snipView.imageCapture()
        let exportSession: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        
        exportSession.outputURL = tempAudioURL
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = AVFileType.m4a
        
        exportSession.timeRange = range
        exportSession.exportAsynchronously {
            switch (exportSession.status) {
            case .completed:
                self.createVideoFromAudioSnip(tempAudioURL, coverArt:coverArt)
                break
            case .failed:
                print("failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                self.showAlertMessage(title: "Error", message: "Failed to export: \(exportSession.error?.localizedDescription ?? "(Unknown Error")", button: "Ok")
                break
            case .cancelled:
                print("Cancelled")
                break
            default:
                break
            }
        }
    }
    
    @IBAction func skipBackward(_ sender: Any?) {
        let start = timeSlider.value - Float(Select.setting.seekBackward())
        if (start < 0) {
            timeSlider.value = 0
            haptic.notificationOccurred(.warning)
        } else if (start < Float(snipStart) && startAdjustment.isSelected) {
            timeSlider.value = Float(snipStart)
            haptic.notificationOccurred(.warning)
        } else {
            timeSlider.value = start
        }
        let isPlaying = episodePlayer.isPlaying
        episodePlayer.stop()
        updateCurrentTimeIndicators(timeSlider.value)
        episodePlayer.currentTime = Double(timeSlider.value)
        if (isPlaying) {
            playerPlay()
        }
    }

    @IBAction func skipForward(_ sender: Any?) {
        let end = timeSlider.value + Float(Select.setting.seekForward())
        if (end > timeSlider.maximumValue) {
            timeSlider.value = timeSlider.value
            haptic.notificationOccurred(.warning)
        } else if (end > Float(snipEnd) && endAdjustment.isSelected) {
            timeSlider.value = Float(snipEnd)
            haptic.notificationOccurred(.warning)
        } else {
            timeSlider.value = end
        }
        let isPlaying = episodePlayer.isPlaying
        episodePlayer.stop()
        updateCurrentTimeIndicators(timeSlider.value)
        episodePlayer.currentTime = Double(timeSlider.value)
        if (isPlaying) {
            playerPlay()
        }
    }
    
    
    @IBAction func pressJumpToStartButton(_ sender: Any?) {
        if (startAdjustment.isSelected) {
            timeSlider.value = Float(snipStart)
            let isPlaying = episodePlayer.isPlaying || currentPlaybackMode == .fineAdjustStart
            episodePlayer.stop()
            updateCurrentTimeIndicators(timeSlider.value)
            episodePlayer.currentTime = snipStart
            if (isPlaying) {
                playerPlay()
            }
        }
    }
    
    @IBAction func pressJumpToEndButton(_ sender: Any?) {
        if (endAdjustment.isSelected) {
            timeSlider.value = Float(snipEnd - playbackLength)
            let isPlaying = episodePlayer.isPlaying || currentPlaybackMode == .fineAdjustEnd
            episodePlayer.stop()
            updateCurrentTimeIndicators(timeSlider.value)
            episodePlayer.currentTime = snipEnd-playbackLength
            if (isPlaying) {
                playerPlay()
            }
        }
    }
    
    @IBAction func pressPlayButton(_ sender: Any?) {
        playButton.isSelected = !playButton.isSelected
        if (playButton.isSelected) {
            playerPlay()
        } else {
            playerPause()
        }
    }

    func playerPlay() {
        waveform.reset()
        playButton.isSelected = true
        episodePlayer?.prepareToPlay()
        episodePlayer?.play()
        currentPlaybackMode = .play
        self.statusLabel.text = "PLAY"
    }
    
    func playerPause() {
        playButton.isSelected = false
        episodePlayer?.stop()
        currentPlaybackMode = .pause
        self.statusLabel.text = "PAUSE"
    }

}

