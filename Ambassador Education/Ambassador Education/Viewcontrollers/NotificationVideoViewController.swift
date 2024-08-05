//
//  NotificationVideoViewController.swift
//  Ambassador Education
//
//  Created by IE12 on 05/08/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

class NotificationVideoViewController: UIViewController {

    @IBOutlet weak var videoView: VideoPlayerView!
    var videoUrl: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        videoView.setupToPlay(url: videoUrl)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoView.stopPlayer()
    }


    @IBAction func buttonCrossDidTap(_ sender: Any) {
        videoView.stopPlayer()
        self.dismiss(animated: true)
    }
}
