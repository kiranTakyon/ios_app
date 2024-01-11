//
//  SplashViewController.swift
//  OrisonSchool V2
//
//  Created by IE Mac 05 on 11/01/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    // MARK: - IBOutlet's -
    
    @IBOutlet weak var videoView: VideoPlayerView!
    @IBOutlet weak var splashImageView: UIImageView!
    
    
    // MARK: - Propertie's -
    
    private var isPlayVideo: Bool = false
    private var videoUrl: String = ""
    
    // MARK: - ViewLifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkTarget()
        videoView.isHidden = !isPlayVideo
        splashImageView.isHidden = isPlayVideo
        var dealy = 1.0
        if isPlayVideo {
            playSplashVideo(_with: videoUrl)
            dealy = 5.5   /// current video is 5.5 sec
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dealy) {
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
        
    }
    
    func checkTarget() {
#if ORISONSCHOOL_V2
        isPlayVideo = true
        videoUrl = "OrisonSplashVideo"
#else
        isPlayVideo = false
#endif
    }
    
    func playSplashVideo(_with url: String ) {
        if let filePath = Bundle.main.path(forResource: url, ofType: "mp4") {
            videoView.setupToPlay(videoPath: filePath)
        }
    }
}
