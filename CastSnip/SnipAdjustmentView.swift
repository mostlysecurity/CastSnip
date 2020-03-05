//
//  SnipAdjustmentView.swift
//  CastSnip
//
//  Created by Eric Wuehler on 3/23/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit
import QuartzCore


protocol SnipAdjustmentViewDelegate: class {
    
    func forwardButtonPressed(_ sender: SnipAdjustmentView)
    func backwardButtonPressed(_ sender: SnipAdjustmentView)
    func setButtonPressed(_ sender: SnipAdjustmentView)
}


@IBDesignable
class SnipAdjustmentView: UIView {

    let nibName = "SnipAdjustmentView"
    
    var contentView: UIView?
    weak var delegate: SnipAdjustmentViewDelegate?
    
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var centerBarView: UIView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    
    var defaultTitle: String = "SET"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
        centerBarView.layer.cornerRadius = 1
        centerBarView.clipsToBounds = true
        centerBarView.layer.borderWidth = 0
        forwardButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        backwardButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @IBInspectable open var isEnabled: Bool = true {
        didSet {
            setButton.isEnabled = isEnabled
            forwardButton.isEnabled = isEnabled
            backwardButton.isEnabled = isEnabled
        }
    }
    
    @IBInspectable open var isSelected: Bool = false {
        didSet {
            setButton.isSelected = isSelected
        }
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
//        print("forward pressed")
        delegate?.forwardButtonPressed(self)
    }
    
    @IBAction func backwardPressed(_ sender: Any) {
//        print("backward pressed")
        delegate?.backwardButtonPressed(self)
    }
    
    @IBAction func setPressed(_ sender: Any) {
        delegate?.setButtonPressed(self)
    }
    
    func setTitle(_ title: String) {
        setButton.setTitle(title, for: .normal)
    }
    
    func setDefaultTitle(_ title: String) {
        defaultTitle = title
    }
    
    func reset() {
        setTitle(defaultTitle)
        isSelected = false
    }
}
