//
//  SnipCreator.swift
//  CastSnip
//
//  Created by ewuehler on 12/31/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//
//  Adapted from: http://twocentstudios.com/2017/02/20/creating-a-movie-with-an-image-and-audio-on-ios/
//

import UIKit
import AVFoundation


class SnipCreator {

    static func pixelBuffer(fromImage image: CGImage, size: CGSize) throws -> CVPixelBuffer {
        let options: CFDictionary = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true] as CFDictionary
        var pxbuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options, &pxbuffer)
        guard let buffer = pxbuffer, status == kCVReturnSuccess else { throw NSError(domain: "SnipCreator: pixelbuffer", code: 700, userInfo: nil) }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        guard let pxdata = CVPixelBufferGetBaseAddress(buffer) else { throw NSError(domain: "SnipCreator: pixelbuffer", code: 701, userInfo: nil) }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { throw NSError(domain: "SnipCreator: pixelbuffer", code: 702, userInfo: nil) }
        context.concatenate(CGAffineTransform(rotationAngle: 0))
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }

    static func getAVFileType(_ fileURL: URL) -> AVFileType {
        switch (fileURL.pathExtension.lowercased()) {
            case "mp4":
                return AVFileType.mp4
            case "m4v":
                return AVFileType.m4v
            case "mov":
                return AVFileType.mov
            case "mp3":
                return AVFileType.mp3
            case "m4a":
                return AVFileType.m4a
            default:
                return AVFileType.mov
        }
    }
    
    static func writeSingleImageToMovie(image: UIImage, movieLength: TimeInterval, outputFileURL: URL, completion: @escaping (Error?) -> ()) {
        do {
            let imageSize = image.size
            let videoWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: SnipCreator.getAVFileType(outputFileURL))
            let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264,
                                                AVVideoWidthKey: imageSize.width,
                                                AVVideoHeightKey: imageSize.height]
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
            
            if !videoWriter.canAdd(videoWriterInput) { throw NSError(domain: "SnipCreator: image2Movie", code: 600, userInfo: nil) }
            videoWriterInput.expectsMediaDataInRealTime = true
            videoWriter.add(videoWriterInput)
            
            videoWriter.startWriting()
            let timeScale: Int32 = 600 // recommended in CMTime for movies.
            let halfMovieLength = Float64(movieLength/2.0) // videoWriter assumes frame lengths are equal.
            let startFrameTime = CMTimeMake(value: 0, timescale: timeScale)
            let endFrameTime = CMTimeMakeWithSeconds(halfMovieLength, preferredTimescale: timeScale)
            videoWriter.startSession(atSourceTime: startFrameTime)
            
            guard let cgImage = image.cgImage else { throw NSError(domain: "SnipCreator: image2Movie", code: 601, userInfo: nil) }
            let buffer: CVPixelBuffer = try self.pixelBuffer(fromImage: cgImage, size: imageSize)
            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: startFrameTime)
            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: endFrameTime)
            
            videoWriterInput.markAsFinished()
            videoWriter.finishWriting {
                completion(videoWriter.error)
            }
        } catch {
            completion(error)
        }
    }


    static func addAudioToMovie(audioAsset: AVURLAsset, inputVideoAsset: AVURLAsset, outputVideoFileURL: URL, quality: String, completion: @escaping (Error?) -> ()) {
        do {
            let composition = AVMutableComposition()
            
            print("Creating video track")
            guard let videoAssetTrack = inputVideoAsset.tracks(withMediaType: AVMediaType.video).first else { throw NSError(domain: "SnipCreator: audio2movie", code: 650, userInfo: nil) }
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: inputVideoAsset.duration), of: videoAssetTrack, at: CMTime.zero)
            
            print("Creating audio track")
            let audioStartTime = CMTime.zero
            guard let audioAssetTrack = audioAsset.tracks(withMediaType: AVMediaType.audio).first else { throw NSError(domain: "SnipCreator: audio2Movie", code: 651, userInfo: nil) }
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAssetTrack, at: audioStartTime)
            
            print("Exporting video+audio... to \(outputVideoFileURL)")
            guard let assetExport = AVAssetExportSession(asset: composition, presetName: quality) else { throw NSError(domain: "SnipCreator: audio2Movie", code: 652, userInfo: nil) }
            assetExport.outputFileType = SnipCreator.getAVFileType(outputVideoFileURL)
            assetExport.outputURL = outputVideoFileURL
            
            assetExport.exportAsynchronously {
                completion(assetExport.error)
            }
        } catch {
            completion(error)
        }
    }

    
    static func createMovieWithSingleImageAndMusic(image: UIImage, audioFileURL: URL, assetExportPresetQuality: String, outputVideoFileURL: URL, completion: @escaping (Error?) -> ()) {
        let audioAsset = AVURLAsset(url: audioFileURL)
        let length = TimeInterval(audioAsset.duration.seconds)
        let videoOnlyURL = Util.tempFileURL("mp4")
        self.writeSingleImageToMovie(image: image, movieLength: length, outputFileURL: videoOnlyURL) { (error: Error?) in
            if let error = error {
                completion(error)
                return
            }
            let videoAsset = AVURLAsset(url: videoOnlyURL)
            self.addAudioToMovie(audioAsset: audioAsset, inputVideoAsset: videoAsset, outputVideoFileURL: outputVideoFileURL, quality: assetExportPresetQuality) { (error: Error?) in
                completion(error)
            }
        }
    }



}
