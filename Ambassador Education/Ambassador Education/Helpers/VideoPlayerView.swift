//
//  VideoPlayerView.swift
//  OrisonSchool V2
//
//  Created by IE Mac 05 on 11/01/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit
import AVFoundation

public enum VideoFormateType: String {
    case mp4 = "mp4"
    case mov = "mov"
    case m4v = "m4v"
    case flv = "flv"
}

public class VideoPlayerView: UIView {

    var avPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    @IBInspectable var playerBGColor: UIColor = .white {
        didSet {
            playerLayer?.backgroundColor = playerBGColor.cgColor
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.videoGravity = .resize
        playerLayer?.frame = self.bounds
    }
    
    public func setupToPlay(videoPath: String) {
        let videoURL = URL.init(fileURLWithPath: videoPath)
        playVideo(videoURL: videoURL)
    }

    public func setupToPlay(url: String) {
        if let videoURL = URL(string: url) {
            playVideo(videoURL: videoURL)
        }
    }

    public func setupToPlay(videoName: String, type: VideoFormateType = .mov) {
        guard let videoPath = Bundle.init(for: VideoPlayerView.self).path(forResource: videoName, ofType: type.rawValue) else {
            return
        }
        let videoURL = URL(fileURLWithPath: videoPath)
        playVideo(videoURL: videoURL)
    }
    
    private func playVideo(videoURL: URL) {
        avPlayer = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: avPlayer)
        layer.addSublayer(playerLayer!)
        avPlayer?.play()
        
        //To suffle
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem, queue: nil) { [weak self] _ in
            self?.avPlayer?.seek(to: CMTime.zero)
            self?.avPlayer?.play()
        }
    }
    
    private var currentItemDuration: CMTime? {
        return avPlayer?.currentItem?.asset.duration
    }
    
    public func stopPlayer() {
        if avPlayer != nil {
            avPlayer?.pause()
            avPlayer = nil
        }
    }
    
}
