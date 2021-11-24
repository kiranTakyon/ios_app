//
//  DigitalResourceDetailController.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
import QuickLook
import RichEditorView

class DigitalResourceDetailController: UIViewController {
    
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelHeight: NSLayoutConstraint!
    @IBOutlet weak var richEditorView: RichEditorView!
    @IBOutlet weak var attachmentsTitleLabel: UILabel!
    @IBOutlet weak var tableViewAttachments: UITableView!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var richEditorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var progressBar: ProgressViewBar!
    
    var weeklyPlan : WeeklyPlanList?
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    var data = [Attachment]()
    var downloadTask: URLSessionDownloadTask!
    var digitalResource : TNDigitalResourceSubList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        richEditorView.isEditingEnabled = false
        richEditorView.clipsToBounds = true
        setUI()
        videoDownload.delegate = self
        setData()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    
    func setUI(){
        quickLookController.dataSource = self
        quickLookController.delegate = self
        self.tableViewAttachments.delegate = self
        self.tableViewAttachments.dataSource = self
        self.tableViewAttachments.separatorStyle = .none
        self.tableViewAttachments.tableFooterView = UIView()
        self.tableViewAttachments.estimatedRowHeight = 150.0
        self.tableViewAttachments.rowHeight = UITableView.automaticDimension
        videoDownload.delegate = self
        
    }
    
    func setUiWithType(top : CGFloat,height : CGFloat,hide: Bool){
        topConstraint.constant = top
        labelHeight.constant = height
        seperatorView.isHidden = hide
    }
    
    func setData(){
        
        if let digital = digitalResource{
            setUiWithType(top: 0, height: 0, hide: true)
            if let attachment = digital.attachments as? [Attachment]{
                
                data = attachment
                if data.count == 0{
                    attachmentsTitleLabel.text = "No Attachments"
                }
                else{
                    attachmentsTitleLabel.text = "Attachments"
                    
                }
            }
            
            let attach = digital.attachment.safeValue
            if attach.contains("http"){
                let dict = NSMutableDictionary()
                dict["FileName"] = digital.title
                dict["Filelink"] = attach
                data.append(Attachment(values: (dict as? NSDictionary)!))
            }
            self.titleLabel.text = digital.title
            self.topTitleLabel.text = digital.title
            
            print("load text :- ",digital.content)
            if let content = digital.content{
                
                let htmlDecode = content.replacingHTMLEntities
                richEditorView.html = htmlDecode.safeValue
            }
            
        }else if let weeklyPlanValue = weeklyPlan{
            setUiWithType(top: 20, height: 21, hide: false)
            
            self.topTitleLabel.text = "Weekly Plan Details"
            
            getAttachments(weeklyPlan: weeklyPlanValue)
            self.titleLabel.text = weeklyPlanValue.topic
            self.topTitleLabel.text = mainTitle
            let htmlDecode = weeklyPlanValue.description.safeValue.replacingHTMLEntities
            richEditorView.html = htmlDecode.safeValue
        }
        if richEditorView.contentHTML == ""{
            richEditorViewHeight.constant =  0 //+ 100
            
        }
        else{
            
            let labelSize = rectForText(text: richEditorView.contentHTML, font: UIFont.systemFont(ofSize: 17.0), maxSize: CGSize(width: richEditorView.frame.width, height: richEditorView.frame.height))
            
            let labelHeight = labelSize.height //here it is!
            print(labelHeight)
            richEditorViewHeight.constant =  labelHeight //+ 100
        }
        if richEditorViewHeight.constant <= 70.0{
            //    addBottomLineToView()
        }
        tableViewAttachments.reloadData()
        
    }
    func rectForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString.init(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]))
        let rect = attrString.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        
        return size
    }
    
    
    
    func addBottomLineToView(){
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: 43.0, width: richEditorView.frame.size.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor.darkGray.cgColor
        richEditorView.layer.addSublayer(bottomBorder)
    }
    
    func getAttachments(weeklyPlan : WeeklyPlanList){
        if let attachmnts = weeklyPlan.attachments{
            if attachmnts.count != 0{
                data = attachmnts
                attachmentsTitleLabel.text = "Attachments"
                self.tableViewAttachments.isHidden = false
            }
            else{
                attachmentsTitleLabel.text = "No Attachments"
                self.tableViewAttachments.isHidden = true
            }
        }
        else{
            attachmentsTitleLabel.text = "No Attachments"
            self.tableViewAttachments.isHidden = true
        }
        setTbHeight()
    }
    
    
    func loadPDFAndShare(url: String,fileName: String){
        if url.contains("http"){
            var urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let urls = URL(string: urlString!)
            
            addBlurEffectToTableView(inputView: self.view, hide: false)
            progressBar.isHidden = false
            progressBar.progressBar.setProgress(1.0, animated: true)
            progressBar.titleText = "Downloading,Please wait"
            
            videoDownload.startDownloadingUrls(urlToDowload:[urlString.safeValue],type:"",fileName:fileName)
        }
        else{
            //  self.stopLoadingAnimation()
            SweetAlert().showAlert("", subTitle: "No link is present", style: .warning)
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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


extension DigitalResourceDetailController : UITableViewDataSource,UITableViewDelegate,MessageDownLoadDelegate{
    
    
    
    //    func setTableViewHeight(){
    //        if let count = data.count as? Int {
    //            TABLEhEIGHT.constant = CGFloat(50.0 * Double(count))
    //        }
    //        else{
    //            TABLEhEIGHT.constant = 0.0
    //        }
    //    }
    
    func downloadPdfButtonAction(url: String,fileName: String) {
        //     self.startLoadingAnimation()
        downloadPdf(attachmentUrl: url,fileName : fileName)
    }
    
    func downloadPdf(attachmentUrl : String,fileName : String){
        
        let urlvalue = URL(fileURLWithPath: attachmentUrl)
        self.loadPDFAndShare(url: attachmentUrl,fileName : fileName)
        
    }
    
    
    
    
    
    func setTbHeight(){
        //  heightConstraint.constant = CGFloat(data.count * 50)
    }
    
    
    func downLoadMylink(index: Int) {
        if let myData = data as? [Attachment]{
            if let value = myData[index] as? Attachment{
                if let downLink = value.fileLink{
                    let downname = value.fileName
                    downloadPdfButtonAction(url: downLink, fileName: downname ?? "")
                }
                else{
                    if let downLink = value.linkAddress{
                         let downname = value.linkName
                        downloadPdfButtonAction(url: downLink, fileName: downname ?? "")
                    }
                }
            }
        }
    }
    
    func getCorrectFileName(file: String){
        //if let extension = file.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data != nil {
            if let count = data.count as? Int{
                return count
            }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDownLoadCell", for: indexPath) as? MessageDownLoadCell
        if let name = data[indexPath.row].fileName{
            cell?.downldLabel.text  = name
            
        }
        else{
            cell?.downldLabel.text  = data[indexPath.row].linkName
        }
        cell?.tag = indexPath.row
        cell?.selectionStyle = .none
        cell?.delegate = self
        heightConstraint.constant = tableView.contentSize.height
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    
    @IBAction func dropDowwnButtonAction(_ sender: UIButton) {
        // delegate?.getBackToTableView!(value: sender.tag)
    }
    
}
extension DigitalResourceDetailController:VideoDownloadDelegate{
    
    func loadingStarted(){
        //  self.startLoadingAnimation()
    }
    
    func loadingEnded(){
        DispatchQueue.main.async{
            addBlurEffectToTableView(inputView: self.view, hide: true)
            self.progressBar.isHidden = true
        }
    }
    
    func filesDownloadComplete(filePath:String,fileToDelT:String) {
        fileURLs = []
       // let file = filePath.replacingOccurrences(of: " ", with: "%20")
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

extension DigitalResourceDetailController : QLPreviewControllerDataSource ,QLPreviewControllerDelegate{
    
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


extension String{
    func convertHtml() -> NSAttributedString{
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do{
            return try NSAttributedString(data: data, options: convertToNSAttributedStringDocumentReadingOptionKeyDictionary([convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType): convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.html), convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.characterEncoding): String.Encoding.utf8.rawValue]), documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringDocumentReadingOptionKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
	return input.rawValue
}
