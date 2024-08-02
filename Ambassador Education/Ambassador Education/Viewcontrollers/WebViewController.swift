//
//  WebViewController.swift
//  Ambassador Education
//
//  Created by    Kp on 08/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
import WebKit
class WebViewController: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    internal var strU : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
         self.setWebViewProperties()
        self.loadWebView()
        // Do any additional setup after loading the view.
    }
    
    func setWebViewProperties(){
        self.automaticallyAdjustsScrollViewInsets = false
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func loadWebView(){
        self.startLoadingAnimation()
        if strU == "" {
            showWebUrl = "www.apple.com"
            if let webUrl = showWebUrl{
                if let url = URL (string: webUrl){
                    let requestObj = URLRequest(url:url)
                    self.webView.load(requestObj)
                }
            }
        }
        else {
                if let url = URL (string: strU){
                    print("loading= \(url)" )
                    let requestObj = URLRequest(url:url)
                    self.webView.load(requestObj)
                }
        }
    }
    
    
    // MARK: - WebView Delagates -

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
