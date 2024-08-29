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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    var notification: TNotification?

    override func viewDidLoad() {
        super.viewDidLoad()
        activity.startAnimating()
        activity.isHidden = false
        if let video = notification?.url {
            videoView.setupToPlay(url: video)
        }
        titleLabel.text = notification?.title
        descriptionLabel.text = notification?.details
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            self.activity.stopAnimating()
            self.activity.isHidden = true
        })
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
