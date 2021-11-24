//
//  WebViewController.swift
//  Ambassador Education
//
//  Created by    Kp on 08/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class WebViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.setWebViewProperties()
        self.loadWebView()
        // Do any additional setup after loading the view.
    }
    
    func setWebViewProperties(){
        self.automaticallyAdjustsScrollViewInsets = false
        webView.delegate = self
        webView.scrollView.bounces = false
    }
    
    func loadWebView(){
        self.startLoadingAnimation()
        showWebUrl = "www.apple.com"
        if let webUrl = showWebUrl{
            if let url = URL (string: webUrl){
                let requestObj = URLRequest(url:url)
                self.webView.loadRequest(requestObj)
            }
        }
    }
    
    
    //MARK:- WebView Delagates
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.stopLoadingAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
