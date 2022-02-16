//
//  NoticeboardDetailController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 11/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit
import RichEditorView
import SwiftSoup
import QuickLook

class NoticeboardDetailController: UIViewController {
    @IBOutlet weak var downLoadButton: UIButton!
    @IBOutlet weak var richView: RichEditorView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var progressBar: ProgressViewBar!
    
    let quickLookController = QLPreviewController()
    var fileURLs = [NSURL]()
    let videoDownload  = VideoDownload()
    var detail : TNNoticeBoardDetail?
    var awarnessPlan : TNAwarenessDetail?
    var downLoadLink = ""
    var pdfUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.setVideoDownload()
        self.setTitle()
        self.setHtml()
  
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressBar.isHidden = true
        addBlurEffectToTableView(inputView: self.view, hide: true)
    }
    
    func setVideoDownload(){
        videoDownload.delegate = self
        quickLookController.dataSource = self
        quickLookController.delegate = self
        quickLookController.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem()
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = true
    }
    func setTitle(){
        richView.delegate = self
        if let desc = detail?.title{
        self.mainTitle.text = desc
        }
        else{
            if let descValue = awarnessPlan?.name{
                self.mainTitle.text = descValue
            }
        }
    }
    
  
    @IBAction func downLoadButtonAction(_ sender: UIButton) {
        if downLoadLink != ""{
            addBlurEffectToTableView(inputView: self.view, hide: false)
            progressBar.isHidden = false
            progressBar.progressBar.setProgress(1.0, animated: true)
            progressBar.titleText = "Downloading,Please wait"
            videoDownload.startDownloadingUrls(urlToDowload:[downLoadLink],type:"", fileName: "")
        }
    }
    
    func getHrefLink(string : String){
        if string.contains("http"){
            downLoadButton.isHidden = false
        do {
            let doc: Document = try! SwiftSoup.parse(string)
            if let link: Element = try! doc.select("a").first(){
            let linkHref: String = try! link.attr("href");
            let correctLink = getLink(urlString: linkHref)
            if verifyUrl(urlString:  correctLink){
            downLoadLink = correctLink
            }
            }
            else{
                 downLoadButton.isHidden = true
            }
        }
      catch {
             downLoadButton.isHidden = true
        }
        }
        else{
                downLoadButton.isHidden = true
        }
    }
    
    
    func getLink(urlString : String) -> String{
        if urlString.contains("../"){
            if let components = urlString.components(separatedBy: "../") as? [String]{
                if components.count > 0{
                    return components[1]
                }
            }
        }
        return urlString
    }
    
        func verifyUrl(urlString: String?) -> (Bool){
            var url : URL?
            url = URL(string: urlString.safeValue)
            return UIApplication.shared.canOpenURL(url!)
        }
    
    func setHtml(){
        richView.editingEnabled = false
        //richView.isEditingEnabled = false

        if let _ = detail{
        if let desc = detail?.description{
             let htmlDecode = desc.replacingHTMLEntities
            richView.html = htmlDecode.safeValue
            getHrefLink(string: htmlDecode.safeValue)
//            print(richView.selectedHref)
            }
       }
        else if let _ = awarnessPlan {
            if let desc = awarnessPlan?.description{
                let htmlDecode = desc.replacingHTMLEntities
                richView.html = htmlDecode!
                downLoadButton.isHidden = true
                //getHrefLink(string: htmlDecode.safeValue)
            }
        }
    }
    
    
//    func setActionOnAttributedText(desc : String){
//        print(desc.replacingHTMLEntities)
//        let test = String(desc.filter { !" \n\t\r".contains($0) })
//        print(test)
//        if test != ""{
//            if test.contains("http"){
//                let link = test.components(separatedBy: "http")
//                if link.count > 0{
//                    for each in link{
//                        if each.contains("s://") || each.contains("://") {
//                            pdfUrl = "http" + each
//                        }
//                    }
//                }
//
//            }
//        }
//    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

//    @IBAction func openLinkButtonAction(_ sender: UIButton) {
//        if let url = pdfUrl{
//           print(url.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
//
//            print(url.replacingHTMLEntities)
//            if url != ""{
//                var webView =  mainStoryBoard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
//                webView.url = url
//                self.navigationController?.present(webView, animated: true, completion: nil)
//            }
//        }
//        else{
//        }
//
//    }
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

extension NoticeboardDetailController:VideoDownloadDelegate{
    
    func loadingStarted(){
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

extension NoticeboardDetailController : QLPreviewControllerDataSource ,QLPreviewControllerDelegate{
    
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

extension NoticeboardDetailController: RichEditorDelegate{

   
    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
            if url != nil{
                self.stopLoadingAnimation()
                return true
            }
            else{
                self.stopLoadingAnimation()
                return false
            }
        }
    }
   

