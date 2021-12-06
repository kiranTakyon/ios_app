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

class DigitalResourceDetailController: UIViewController, DRDAttechmentCellDelegate,DRDDownLoadDelegate {
    
    @IBOutlet weak var richEditor1ViewHeigh: NSLayoutConstraint!
    @IBOutlet weak var richEditorView1: RichEditorView!
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
    //@IBOutlet weak var progressBar: ProgressViewBar!
    @IBOutlet weak var viewWebDataListBG: UIView!
    @IBOutlet weak var tableViewDataListBG: UITableView!
    @IBOutlet weak var constraintViewWebDataTableHeight: NSLayoutConstraint!
    @IBOutlet weak var attachViewTop: NSLayoutConstraint!
    
    var weeklyPlan : WeeklyPlanList?
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    var data = [Attachment]()
    var downloadTask: URLSessionDownloadTask!
    var digitalResource : TNDigitalResourceSubList?
    var arrDataList : [String] = [String]()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableViewAttachments.register(DRDDownLoadCell.self, forCellReuseIdentifier: "DRDDownLoadCell")
//        self.tableViewAttachments.register(UINib.init(nibName: "DRDAttechmentCell", bundle: nil), forCellReuseIdentifier: "DRDAttechmentCell")
       // richEditorView.editingEnabled = false
      // richEditorView.clipsToBounds = true
        richEditorView1.editingEnabled = false
        richEditorView1.clipsToBounds = true
        setUI()
        videoDownload.delegate = self
        setData()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addBlurEffectToTableView(inputView: self.view, hide: true)
       // progressBar.isHidden = true
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
        
        self.tableViewDataListBG.dataSource = self
        self.tableViewDataListBG.delegate = self
        self.tableViewDataListBG.tableFooterView = UIView()
        self.tableViewDataListBG.rowHeight = 300
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
            self.arrDataList = digital.docLinks!
            
           //self.constraintViewWebDataTableHeight.constant = CGFloat((self.arrDataList.count == 0 ? 0 : ((self.arrDataList.count * 300) + 20)))
          //  self.tableViewDataListBG.reloadData()
            let attach = digital.attachment.safeValue
            if attach.contains("http"){
                let dict = NSMutableDictionary()
                dict["FileName"] = digital.title
                dict["Filelink"] = attach
                data.append(Attachment(values: (dict as? NSDictionary)!))
            }
            self.titleLabel.text = digital.title
            self.topTitleLabel.text = digital.title
            
            if let content = digital.content{
                
                let htmlDecode = content.replacingHTMLEntities
                 print("load text1 :- ",htmlDecode.safeValue)
                //richEditorView.html = htmlDecode.safeValue
                richEditorView1.html = htmlDecode.safeValue
            }
            if arrDataList.count != 0 {
                print("Show")
                print("herem",self.constraintViewWebDataTableHeight.constant)
              //  self.constraintviewBGHeight.constant = CGFloat((self.arrDataList.count * 300) + 20)
              //  self.constraintViewWebDataTableHeight.constant = CGFloat((self.arrDataList.count * 300) + 20)
            }
            else
            {
                //self.constraintViewWebDataTableHeight.constant = 100
            }
            print("here",self.constraintViewWebDataTableHeight.constant)
           
            let lHeight : CGFloat = (self.titleLabel.text?.height(withConstrainedWidth: self.titleLabel.frame.width, font: UIFont(name: "HelveticaNeue-Medium", size: 18.0)!))!
            print("herelh",lHeight)
            setUiWithType(top: 20, height: lHeight, hide: !(lHeight > 0))
            
        }else if let weeklyPlanValue = weeklyPlan{
            setUiWithType(top: 20, height: 21, hide: false)
            
            self.topTitleLabel.text = "Weekly Plan Details"
            self.constraintViewWebDataTableHeight.constant = 100
            getAttachments(weeklyPlan: weeklyPlanValue)
            self.titleLabel.text = weeklyPlanValue.topic
            self.topTitleLabel.text = mainTitle
            let htmlDecode = weeklyPlanValue.description.safeValue.replacingHTMLEntities
            //richEditorView.html = htmlDecode.safeValue
            richEditorView1.html = htmlDecode.safeValue
        }
      /* if richEditorView.html == ""{
            richEditorViewHeight.constant =  0 //+ 100*/
        if richEditorView1.html == ""{
            richEditor1ViewHeigh.constant = 0
        }
        else{
            
          //  let labelSize = rectForText(text: richEditorView.html, font: UIFont.systemFont(ofSize: 17.0), maxSize: CGSize(width: richEditorView.frame.width, height: richEditorView.frame.height))
            let labelSize = rectForText(text: richEditorView1.html, font: UIFont.systemFont(ofSize: 17.0), maxSize: CGSize(width: richEditorView1.frame.width, height: richEditorView1.frame.height))
           
            let labelHeight = labelSize.height //here it is!
            richEditor1ViewHeigh.constant =  labelHeight + 10 //+ 100
           // newREVHeight.constant = labelHeight + 10
            print("here11",self.constraintViewWebDataTableHeight.constant)
           // self.constraintViewWebDataTableHeight.constant = CGFloat((self.arrDataList.count * 300) + 20)
            print("here11",self.constraintViewWebDataTableHeight.constant)
            self.constraintViewWebDataTableHeight.constant = CGFloat(self.constraintViewWebDataTableHeight.constant) + richEditor1ViewHeigh.constant;
            print("here22",self.constraintViewWebDataTableHeight.constant)
        }
       // if richEditorViewHeight.constant <= 70.0{s
            //    addBottomLineToView()
       // }
        
        tableViewDataListBG.reloadData()
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
            var urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let urls = NSURL(string: url)
            
            addBlurEffectToTableView(inputView: self.view, hide: false)
            //progressBar.isHidden = false
           // progressBar.progressBar.setProgress(1.0, animated: true)
           // progressBar.titleText = "Downloading,Please wait"
            
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
    func downLoadMylink(index: Int) {
        
    }
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
    
    
    func downLoadMylink(sender: UIButton, index: Int) {
        if let myData = data as? [Attachment]{
            if let value = myData[index] as? Attachment{
                if let downLink = value.fileLink{
                    let downname = value.fileName
                    if sender.accessibilityHint == nil {
                        self.gotoWeb(str: "\(downLink)")
                    }
                    else {
                        downloadPdfButtonAction(url: downLink, fileName: downname ?? "") }
                }
                else{
                    if let downLink = value.linkAddress{
                        let downname = value.linkName
                        if sender.accessibilityHint == nil {
                            self.gotoWeb(str: "\(downLink)")
                        }
                        else {
                            downloadPdfButtonAction(url: downLink, fileName: downname ?? "") }
                    }
                }
            }
        }
    }
    
    func getCorrectFileName(file: String){
        //if let extension = file.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewDataListBG {
           return self.arrDataList.count
        }
        else {
        if data != nil {
            if let count = data.count as? Int{
                return count
            }
            
        }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewDataListBG {
            let cell : DigitalResourceDataListCell = (tableView.dequeueReusableCell(withIdentifier: "DigitalResourceDataListCell", for: indexPath) as? DigitalResourceDataListCell)!
               self.constraintViewWebDataTableHeight.constant = self.constraintViewWebDataTableHeight.constant + CGFloat(((self.arrDataList.count-1) * 300)  + 0)
            cell.richEditorViewBG.load(URLRequest.init(url: URL.init(string: "\(self.arrDataList[indexPath.row])")!))

            //self.attachViewTop.constant = self.constraintViewWebDataTableHeight.constant + 10
            return cell
            }
        else if tableView == self.tableViewAttachments {
            let cell: DRDAttechmentCell = tableView.dequeueReusableCell(withIdentifier: "DRDAttechmentCell") as! DRDAttechmentCell

        if let name = data[indexPath.row].fileName{
            cell.downldLabel.text  = name
        }
        else{
            cell.downldLabel.text  = data[indexPath.row].linkName
        }
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        cell.btnDownload.accessibilityHint = "Download"
        cell.delegate = self
        heightConstraint.constant = tableView.contentSize.height + 20
        return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    
    @IBAction func dropDowwnButtonAction(_ sender: UIButton) {
        // delegate?.getBackToTableView!(value: sender.tag)
    }
    
}
protocol DRDDownLoadDelegate {
//    func downLoadMylink(index: Int)
    func downLoadMylink(sender: UIButton, index: Int)
}

class DRDDownLoadCell: UITableViewCell{

    var delegate : DRDDownLoadDelegate?

    @IBOutlet weak var downldLabel: UILabel!

    @IBAction func dwnloadButtnAction(_ sender: UIButton) {
        if sender.tag == 1 {
            //preview
            DigitalResourceDetailController().gotoWeb(str: "")
            
        }
        else {
            self.delegate?.downLoadMylink(sender: sender, index: self.tag) }
    }
}
extension DigitalResourceDetailController:VideoDownloadDelegate{
    func gotoWeb(str : String) {
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.strU = str
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func loadingStarted(){
        //  self.startLoadingAnimation()
    }
    
    func loadingEnded(){
        DispatchQueue.main.async{
            addBlurEffectToTableView(inputView: self.view, hide: true)
            //self.progressBar.isHidden = true
        }
    }
    
    func filesDownloadComplete(filePath:String,fileToDelT:String) {
        fileURLs = []
       // let file = filePath.replacingOccurrences(of: " ", with: "%20")
        let file = NSURL(string: filePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        fileURLs.append(file! as NSURL)
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


class DigitalResourceDataListCell: UITableViewCell{
    @IBOutlet weak var richEditorViewBG: RichEditorWebView!
}
