//
//  GradeViewController.swift
//  Ambassador Education
//
//  Created by Veena on 07/03/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit
import QuickLook

class GradeViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var dwnLoadButton: UIButton!
    @IBOutlet weak var dwnLoadButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var progressBar: ProgressViewBar!
    @IBOutlet weak var menuImageView: UIImageView!
    
    var header = String()
    var hashkey = String()
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        loadUrlToWebView()
        headerLabel.text = header
        setDelegates()
        // Do any additional setup after loading the view.
    }

    func setNavigationBar(){
        if hashkey == "T0052"{
        menuImageView.image = #imageLiteral(resourceName: "Back2")
        menuButton.addTarget(self, action: #selector(self.backAction), for: UIControl.Event.touchUpInside)
        }
        else{
            menuImageView.image = #imageLiteral(resourceName: "Menu")
             setSlideMenuProporties()
       }
    }
    
    @objc func backAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setDelegates(){
        videoDownload.delegate = self
        quickLookController.dataSource = self
        quickLookController.delegate = self
        quickLookController.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        changeTheVisibilityOfDownLoadButton()
        progressBar.isHidden = true
        addBlurEffectToTableView(inputView: self.view, hide: true)
    }
    
    func changeTheVisibilityOfDownLoadButton(){
        if hashkey == "T0012" {
                dwnLoadButton.isHidden = false
                dwnLoadButtonWidth.constant  = 38
        }
        else{
            dwnLoadButton.isHidden = true
            dwnLoadButtonWidth.constant  = 0
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        print("request: \(request.description)")
        if request.description == "http://exitme/"{
            //do close window magic here!!
            print("url matches...")
            stopLoading()
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webview Success ")

    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        print("webview failed : - ",error.localizedDescription)
    }
    

    func stopLoading() {
        self.dismiss(animated: true, completion: nil)
    }
    

    func loadUrlToWebView(){
        webView.scalesPageToFit = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        webView.delegate = self

        if let value = gradeBookLink{
            if value != ""{
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
                let loadRequest = NSURLRequest(url: urlValue)
                self.webView.loadRequest(loadRequest as URLRequest)
            }
            }
        }
        
    }
    
    
    func setSlideMenuProporties(){
     if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControl.Event.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
      }
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
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
    @IBAction func downLoadButtonAction(_ sender: UIButton) {
        if hashkey == "T0012" {
            if let value = gradeBookLink{
                if value != ""{
                    let currentURL = webView.request?.url?.absoluteString
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

