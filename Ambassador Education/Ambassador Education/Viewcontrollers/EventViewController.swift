//
//  EventViewController.swift
//  Ambassador Education
//
//  Created by IE12 on 06/09/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var webView: WKWebView!
    var url : String = ""

    var upcomingEvent: TUpcomingEvent?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        loadWebView()
    }

    @IBAction func buttonCrossDidTap(_ sender: Any) {

        self.dismiss(animated: true)
    }

    func setupView() {
        if let event = upcomingEvent {
            titleLabel.text = event.title ?? ""
        }
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
    }

    func loadWebView(){
        self.startLoadingAnimation()
        if url == "" {
            showWebUrl = "www.apple.com"
            if let webUrl = showWebUrl{
                if let url = URL (string: webUrl){
                    let requestObj = URLRequest(url:url)
                    self.webView.load(requestObj)
                }
            }
        }else {
            if let url = URL (string: url){
                print("loading= \(url)" )
                let requestObj = URLRequest(url:url)
                self.webView.load(requestObj)
            }
        }
    }
}

extension EventViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.stopLoadingAnimation()
    }
}
