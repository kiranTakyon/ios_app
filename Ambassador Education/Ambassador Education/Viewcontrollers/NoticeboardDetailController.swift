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
    @IBOutlet weak var richView: RichEditorView!
    @IBOutlet weak var progressBar: ProgressViewBar!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageUserProfile: ImageLoader!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    let quickLookController = QLPreviewController()
    var fileURLs = [NSURL]()
    let videoDownload  = VideoDownload()
    var detail : TNNoticeBoardDetail?
    var awarnessPlan : TNAwarenessDetail?
    var downLoadLink = ""
    var pdfUrl : String?
    var NbID = ""
    var isFromDashboardNotification = false
    var isPresent: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        if isPresent {
            topHeaderView.isHidden = true
            topHeaderView.viewHeightConstraint.constant = 40
            addCustomTopView()
        }
        topHeaderView.delegate = self
        topHeaderView.shouldShowFirstRightButtons(false)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        setVideoDownload()
        setTitle()
        if(NbID != "") {
            getDetailsbyID()
        } else {
            setHtml()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressBar.isHidden = true
        addBlurEffectToTableView(inputView: self.view, hide: true)
    }
    
    func setVideoDownload() {
        videoDownload.delegate = self
        quickLookController.dataSource = self
        quickLookController.delegate = self
        quickLookController.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem()
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = true
    }
    
    func setTitle() {
        richView.delegate = self
        if let desc = detail?.title{
            self.topHeaderView.title = desc
        }
        else {
            if let descValue = awarnessPlan?.name{
                self.topHeaderView.title = descValue
            }
        }
        
        if let detail = detail {
            labelTitle.text = detail.title ?? ""
            labelDate.text = detail.date ?? ""
            if let image = detail.thumbnail{
                imageUserProfile.loadImageWithUrl(image)
            }
        }
    }
    
    
    @IBAction func downLoadButtonAction(_ sender: UIButton) {
        if downLoadLink != "" {
            addBlurEffectToTableView(inputView: self.view, hide: false)
            progressBar.isHidden = false
            progressBar.progressBar.setProgress(1.0, animated: true)
            progressBar.titleText = "Downloading,Please wait"
            videoDownload.startDownloadingUrls(urlToDowload:[downLoadLink],type:"", fileName: "")
        }
    }
    
    func getHrefLink(string : String) {
        if string.contains("http") {
            topHeaderView.shouldShowFirstRightButtons(true)
            do {
                let doc: Document = try SwiftSoup.parse(string)
                if let link: Element = try! doc.select("a").first() {
                    let linkHref: String = try! link.attr("href");
                    let correctLink = getLink(urlString: linkHref)
                    if verifyUrl(urlString:  correctLink) {
                        downLoadLink = correctLink
                    }
                } else {
                    topHeaderView.shouldShowFirstRightButtons(false)
                }
            }
            catch {
                topHeaderView.shouldShowFirstRightButtons(false)
            }
        } else {
            topHeaderView.shouldShowFirstRightButtons(false)
        }
    }
    
    
    func getLink(urlString : String) -> String{
        if urlString.contains("../") {
            if let components = urlString.components(separatedBy: "../") as? [String] {
                if components.count > 0 {
                    return components[1]
                }
            }
        }
        return urlString
    }
    
    func verifyUrl(urlString: String?) -> (Bool) {
        var url : URL?
        url = URL(string: urlString.safeValue)
        return UIApplication.shared.canOpenURL(url!)
    }
    
    func setHtml() {
        richView.editingEnabled = false
        //richView.isEditingEnabled = false
        
        if let _ = detail {
            if let desc = detail?.description {
                let htmlDecode = desc.replacingHTMLEntities
                richView.html = htmlDecode.safeValue
                getHrefLink(string: htmlDecode.safeValue)
                //            print(richView.selectedHref)
            }
        } else if let _ = awarnessPlan {
            if let desc = awarnessPlan?.description{
                let htmlDecode = desc.replacingHTMLEntities
                richView.html = htmlDecode!
                topHeaderView.shouldShowFirstRightButtons(false)
                //getHrefLink(string: htmlDecode.safeValue)
            }
        }
    }
    
    func getDetailsbyID() {
        // startLoadingAnimation()
        let url = APIUrls().getNBDetails
        let userId = UserDefaultsManager.manager.getUserId()
        var dictionary = [String: Any]()
        dictionary[UserIdKey().id] = userId
        dictionary[DetailsKeys2().itemId] = NbID
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { [self] (result) in
            //   APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                print(result)
                if result["StatusCode"] as? Int == 1 {
                    self.detail = TNNoticeBoardDetail(values: result["item"] as! NSDictionary)
                    // if let messages = result["item"] as? NSArray{
                    // if let messages = result["item"] as? NSArray{
                    // let list = ModelClassManager.sharedManager.createModelArray(data: messages, modelType: ModelType.TNNoticeBoardDetail) as! [TNNoticeBoardDetail]
                    //  print("hh1",messages)
                    //let list = ModelClassManager.sharedManager.createModelArray(data: messages, modelType: ModelType.TNNoticeBoardDetail) as! [TNNoticeBoardDetail]
                    // print("hh2",list[0])
                    // self.detail = list[0]
                    self.setHtml()
                    self.setTitle()
                    // }
                    self.stopLoadingAnimation()
                } else {
                    self.stopLoadingAnimation()
                    SweetAlert().showAlert(kAppName, subTitle: "Not able to get the details", style: .warning)
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        // self.navigationController?.popViewController(animated: true)
        if self.navigationController?.viewControllers.count == 1 {
            let vc = NoticeboardCategoryController.instantiate(from: .noticeboard)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.navigationController!.popViewController(animated: true)
        }
    }
}

extension NoticeboardDetailController:VideoDownloadDelegate {
    
    func loadingStarted() {
    }
    
    func loadingEnded() {
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
        if url != nil {
            self.stopLoadingAnimation()
            return true
        } else {
            self.stopLoadingAnimation()
            return false
        }
    }
}



extension NoticeboardDetailController: TopHeaderDelegate {
    
    func backButtonClicked(_ button: UIButton) {
        if isPresent {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        if downLoadLink != "" {
            addBlurEffectToTableView(inputView: self.view, hide: false)
            progressBar.isHidden = false
            progressBar.progressBar.setProgress(1.0, animated: true)
            progressBar.titleText = "Downloading,Please wait"
            videoDownload.startDownloadingUrls(urlToDowload:[downLoadLink],type:"", fileName: "")
        }
    }
}

extension NoticeboardDetailController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return richView
    }
}
