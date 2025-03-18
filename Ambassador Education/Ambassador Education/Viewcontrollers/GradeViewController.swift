//
//  GradeViewController.swift
//  Ambassador Education
//
//  Created by Veena on 07/03/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit
import QuickLook

class GradeViewController: UIViewController,WKUIDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressBar: ProgressViewBar!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var header = String()
    var hashkey = String()
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        setNavigationBar()
        loadUrlToWebView()
        topHeaderView.title = header
        setDelegates()
    }

    func setNavigationBar() {
        if hashkey == "T0052" {
            topHeaderView.setLeftButtonImage = #imageLiteral(resourceName: "Back2")
            topHeaderView.backButton.addTarget(self, action: #selector(self.backAction), for: UIControl.Event.touchUpInside)
        } else {
            topHeaderView.setLeftButtonImage =  UIImage(named:"Back2") ?? UIImage()
       }
    }
    
    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setDelegates() {
        videoDownload.delegate = self
        quickLookController.dataSource = self
        quickLookController.delegate = self
        quickLookController.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeTheVisibilityOfDownLoadButton()
        progressBar.isHidden = true
        addBlurEffectToTableView(inputView: self.view, hide: true)
    }
    
    func changeTheVisibilityOfDownLoadButton(){
        if hashkey == "T0012" {
            topHeaderView.shouldShowFirstRightButtons(true)
        } else {
            topHeaderView.shouldShowFirstRightButtons(false)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    private func webView(_ webView: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: WKNavigationType) -> Bool {
        print("request: \(request.description)")
        if request.description == "http://exitme/" {
            //do close window magic here!!
            print("url matches...")
            stopLoading()
            return false
        }
        return true
    }
    
    private func webViewDidFinishLoad(_ webView: WKWebView) {
        print("webview Success ")

    }
    
    private func webView(_ webView: WKWebView, didFailLoadWithError error: Error) {
        
        print("webview failed : - ",error.localizedDescription)
    }
    

    func stopLoading() {
        self.dismiss(animated: true, completion: nil)
    }
    

    func loadUrlToWebView() {
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
  
        if let value = gradeBookLink {
            if value != "" {
                var str = ""
                if hashkey == "T0039" || hashkey == "T0058" {
                    let md5Data = MD5(string:currentPassword)
                    let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
                    if hashkey == "T0039"{
                        str  = value + "?name1=" + currentUserName + "&pass1=" + md5Hex
                    }
                    else if hashkey == "T0058"{
                        str  = value + "?user_name=" + currentUserName + "&password=" + md5Hex
                    }
                }
                else{
                    str = value
                }
                gradeBookLink = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                if let urlValue = URL(string: gradeBookLink!)?.absoluteURL{
                    print("loading= \(urlValue)" )

                let loadRequest = NSURLRequest(url: urlValue)
                    self.webView.load(loadRequest as URLRequest)
            }
            }
        }
        
    }
    
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            } else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
        
    }
    @IBAction func downLoadButtonAction(_ sender: UIButton) {
        if hashkey == "T0012" {
            if let value = gradeBookLink{
                if value != ""{
 //                   let currentURL = webView.request?.url?.absoluteString
                    let currentURL = webView.url?.absoluteString
                    let fileName=""
                    downloadPdf(attachmentUrl: currentURL ?? value, fileName: fileName)
                }
            }
        }
    }
    func downloadPdf(attachmentUrl : String, fileName: String){
        let urlvalue = URL(string: attachmentUrl)//URL(fileURLWithPath: attachmentUrl)
        self.loadPDFAndShare(url: attachmentUrl, fileName: fileName)
    }
    
    func loadPDFAndShare(url: String, fileName: String){
        addBlurEffectToTableView(inputView: self.view, hide: false)
        progressBar.isHidden = false
        progressBar.progressBar.setProgress(1.0, animated: true)
        progressBar.titleText = "Downloading,Please wait"
        
        videoDownload.startDownloadingUrls(urlToDowload:[url],type:"", fileName: fileName)
        
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
extension GradeViewController : QLPreviewControllerDataSource ,QLPreviewControllerDelegate{
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        //
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.stopLoadingAnimation()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURLs[index]
    }
}

extension GradeViewController:VideoDownloadDelegate{
    
    func loadingStarted(){
        // self.startLoadingAnimation()
    }
    
    func loadingEnded(){
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    
    func filesDownloadComplete(filePath:String,fileToDelT:String) {
        fileURLs = []
         let file = NSURL(string: filePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        fileURLs.append(file!)
        quickLookController.dataSource = nil
        quickLookController.delegate = nil
        
        quickLookController.dataSource = self
        quickLookController.delegate = self
        
        if QLPreviewController.canPreview(file!) {
            quickLookController.currentPreviewItemIndex = 0
            present(quickLookController, animated: true, completion: nil)
        }
    }
    
}

extension GradeViewController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
        
    }
    
    func searchButtonClicked(_ button: UIButton) {
        if hashkey == "T0012" {
            if let value = gradeBookLink{
                if value != ""{
                    //                   let currentURL = webView.request?.url?.absoluteString
                    let currentURL = webView.url?.absoluteString
                    let fileName=""
                    downloadPdf(attachmentUrl: currentURL ?? value, fileName: fileName)
                }
            }
        }
    }
    
}
