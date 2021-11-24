//
//  WebViewViewController.swift
//  Ambassador Education
//
//  Created by Veena on 26/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit
import QuickLook

class WebViewViewController: UIViewController,UIWebViewDelegate,URLSessionDownloadDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var downLoadLabel: UILabel!
    @IBOutlet weak var downLoadButton: UIButton!
    @IBOutlet weak var progressBar: ProgressViewBar!

    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()

    var url : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrlToWebView()
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSessioWebView")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        videoDownload.delegate = self

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUrlToWebView(){
        webView.scalesPageToFit = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal

       // DispatchQueue.main.async {
            if let value = self.url as? String{
                
                    if value.contains(".pdf"){
                        downLoadLabel.isHidden = false
                        downLoadButton.isHidden = false
                    }
                    else{
                        downLoadLabel.isHidden = true
                        downLoadButton.isHidden = true
                    }
                if let urlValue = URL(string: value){
                    let loadRequest = NSURLRequest(url: urlValue)
                    self.webView.loadRequest(loadRequest as URLRequest)
                }
            }

       // }
           }

    
    func loadPDFAndShare(url: String){
        let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        _ = URL(string: urlString!)
        addBlurEffectToTableView(inputView: self.view, hide: false)
        progressBar.isHidden = false
        progressBar.progressBar.setProgress(1.0, animated: true)
        progressBar.titleText = "Downloading,Please wait"
        videoDownload.startDownloadingUrls(urlToDowload:[url],type:"")

        //downloadTask = backgroundSession.downloadTask(with: urls!)
       // downloadTask.resume()
    
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
       // self.stopLoadingAnimation()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/file.pdf"))
        
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            
            showFileWithPath(path: destinationURLForFile.path)
        }
        else{
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                // show file
                showFileWithPath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    
    
    func showFileWithPath(path: String){
        self.stopLoadingAnimation()
        let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
        if isFileFound == true{
            SweetAlert().showAlert(kAppName, subTitle:  "Download Success", style: AlertStyle.success)
            presentAllDownLoadPage(vcs: self)
        }
        else{
            SweetAlert().showAlert(kAppName, subTitle:  "Error took place while downloading a file", style: AlertStyle.error)
        }
    }
    
    @IBAction func downloadButtonAction(_ sender: UIButton) {
        if let urlValue  = url as? String{
            loadPDFAndShare(url: urlValue)
        }
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
         self.dismiss(animated: true, completion: nil)
    }

}


extension WebViewViewController:VideoDownloadDelegate{
    
    func loadingStarted(){
        self.startLoadingAnimation()
    }
    
    func loadingEnded(){
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    
    func filesDownloadComplete(filePath:String,fileToDelT:String) {
        fileURLs = []
        fileURLs.append(NSURL(string:filePath)!)
        quickLookController.dataSource = nil
        quickLookController.delegate = nil
        
        quickLookController.dataSource = self
        quickLookController.delegate = self
        
        if QLPreviewController.canPreview(NSURL(string:filePath)!) {
            quickLookController.currentPreviewItemIndex = 0
            present(quickLookController, animated: true, completion: nil)
        }
    }
    
}

extension WebViewViewController : QLPreviewControllerDataSource ,QLPreviewControllerDelegate{
    
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
