//
//  OnboardViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/21/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class OnboardViewController: UIViewController, UIScrollViewDelegate {

    var backgroundPlayer : BackgroundVideo? // Declare an instance of BackgroundVideo called backgroundPlayer
    let horizontalPageCount = 4
    
    let kTitleFontSize:CGFloat = 23
    let kTitleYOffsetLength:CGFloat = 90
    let kTitleHeight:CGFloat = 30
    
    let kSubtitleFontSize:CGFloat = 18
    let kSubtitleHeight:CGFloat = 80
    let kSubtitleYOffsetLength:CGFloat = 30
    
    @IBOutlet weak var pageControl: UIPageControl!
    let titleArray = ["Wecome", "Create", "Scan", "Connect"]
    let subtitleArray = ["Connecting with friends has never been so easy. Use QNectcodes to quickly exchange info with friends", "Add contact info and other details to easily create your personal QNectcode", "Retreive users' info by quickly scanning their QNectcode. No internet connection required!", "Link different accounts like Twitter to easily follow other users without leaving the app"]
    
 
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        
       
        
        super.viewDidLoad()
     
        backgroundPlayer = BackgroundVideo(on: self, withVideoURL: "login2.mp4") // Passing self and video name with extension
        backgroundPlayer?.setUpBackground()
        
        configureScrollView()
        self.pageControl.numberOfPages = horizontalPageCount
        

       
    }
    
    func configureScrollView()
    {
        
        let size = view.bounds.size
        let contentSize = CGSize(width: size.width * CGFloat(horizontalPageCount), height: size.height)
        
        scrollView.contentSize = contentSize
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        
        scrollView.delegate = self
        configureContentInScrollView()
    }
    
    func configureContentInScrollView()
    {
        
        for i in 0..<horizontalPageCount {
        
            let size = view.bounds.size
            
            let xOffset = (size.width * CGFloat(i))
            let yOffset = size.height / 2.0 + kTitleYOffsetLength
            
            
            let titleFrame = CGRect(x: xOffset, y: yOffset, width: size.width - 10, height: kTitleHeight)
            let titleLabel = UILabel(frame: titleFrame)
            titleLabel.text = titleArray[i]
            titleLabel.textColor = UIColor.white
            
            let normalFont = UIFont(name: "Gill Sans", size: kTitleFontSize)!
            let boldFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!, size: kTitleFontSize)
            
            titleLabel.font = boldFont
            titleLabel.textAlignment = .center
            
            let subtitleFrame = CGRect(x: xOffset + 10, y: yOffset + kSubtitleYOffsetLength, width: size.width - 20, height: kSubtitleHeight)
            let subtitleTextView = UITextView(frame: subtitleFrame)
            subtitleTextView.allowsEditingTextAttributes = false
            subtitleTextView.text = subtitleArray[i]
            subtitleTextView.textAlignment = .center
            
            let subtitleFont = UIFont(name: "Helvetica Neue", size: kSubtitleFontSize)
            subtitleTextView.font = subtitleFont
            subtitleTextView.backgroundColor = UIColor.clear
            subtitleTextView.textColor = UIColor.white
            subtitleTextView.isScrollEnabled = false
            
            
            
            
            scrollView.addSubview(titleLabel)
            scrollView.addSubview(subtitleTextView)
            
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = self.scrollView.frame.size.width;
        let fractionalPage = self.scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage));
        self.pageControl.currentPage = page;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
