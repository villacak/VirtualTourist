//
//  ActivityIndicatorView.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/6/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit

// Copied part from stackoverflow
// http://stackoverflow.com/questions/32269646/cannot-hide-activity-indicator-at-end-of-api-call
//
// The idea is have a processing modal showing to the user while the request is processed.
class ActivityIndicatorView: UIVisualEffectView {
    
    // Check if the text has been define to set it, may be already set or null
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .Dark)
    let vibrancyView: UIVisualEffectView
    
    
    //
    // Init receiving the message to be displayed
    //
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    
    //
    // Required init
    //
    required init(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    //
    // Setup where it set the view with sub view
    //
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndicator)
        vibrancyView.contentView.addSubview(label)
        activityIndicator.startAnimating()
    }
    
    
    //
    // Function called when the view been displayed is returned to the superview, main view thread
    //
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width: CGFloat = 150
            let height: CGFloat = 50.0
            self.frame = CGRectMake(superview.frame.size.width / 2 - width / 2,
                superview.frame.height / 2 - height,
                width,height)
            
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndicator.frame = CGRectMake(5, height / 2 - activityIndicatorSize / 2,
                activityIndicatorSize,
                activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            
            label.text = text
            label.textAlignment = NSTextAlignment.Center
            label.frame = CGRectMake(activityIndicatorSize + 5, 0, width - activityIndicatorSize - 20, height)
            label.textColor = UIColor.grayColor()
            label.font = UIFont.boldSystemFontOfSize(16)
            
        }
    }
    
    
    //
    // Show the view - Dialog
    //
    func show() {
        self.hidden = false
    }
    
    
    //
    // Hide the view - Dialog
    //
    func hide() {
        self.hidden = true
    }
}