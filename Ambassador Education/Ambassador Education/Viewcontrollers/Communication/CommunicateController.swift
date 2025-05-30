//
//  CommunicateController.swift
//  Ambassador Education
//
//  Created by    Kp on 23/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
var typeValue = Int()



enum CommunicationType : String{
    
    case inbox = "INBOX"
    case sent  = "SENT"
    case WP = "WEEKLYPLAN"
    case draft = "Draft"
}

class CommunicateController: UIViewController,TaykonProtocol{
    
    
    // MARK: - IBOutlet -
    
    @IBOutlet weak var buttonSideArrow: UIButton!
    @IBOutlet weak var communicateTable: UITableView!
    @IBOutlet weak var sideView: UIView!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var inboxView: UIView!
    @IBOutlet weak var sentView: UIView!
    @IBOutlet weak var wpView: UIView!
    @IBOutlet weak var draftView: UIView!
    @IBOutlet weak var templatesView: UIView!
    
    // MARK: - Propertie's -
    
    var delegate : TaykonProtocol?
    
    var type : CommunicationType?
    var templates: TemplateResponse?
    var templateList = [Template]()
    var paginationNumber = 1
    
    var inboxMessages = [TinboxMessage]()
    private var lastQuery = ""
    private var debouncedDelegate: DebouncedTextFieldDelegate!
    let refreshControl = UIRefreshControl()
    var searchText = ""
    var isForDraft: Bool = false
    var buttonOrigin : CGPoint = CGPoint(x: 0, y: 0)
    private var isLoadMore: Bool = false
    
    // MARK: - ViewLifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debouncedDelegate = DebouncedTextFieldDelegate(handler: self)
        searchTextField.delegate = debouncedDelegate
        hideKeyboardWhenTappedAround()
        communicateTable.register(UINib(nibName: "CommunicationTableViewCell", bundle: nil), forCellReuseIdentifier: "CommunicationTableViewCell")
        communicateTable.register(UINib(nibName: TemplateTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TemplateTableViewCell.identifier)
        updateImageColors()
        callTemplateListAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(getMsgs(notification:)), name: NSNotification.Name(rawValue: "searchAction"), object: nil)
        tableViewProporties()
        setRefreshControll()
        paginationNumber = 1
        searchText = ""
        paginationNumber = 1
        addGestureOnButton()
        inboxMessages.removeAll()
        getInboxMessages(txt : searchText, types: typeValue)
    }
    
    @objc func getMsgs(notification : NSNotification){
        if let userInfo = notification.object as? NSDictionary {
            let msg = userInfo["text"] as? String
            paginationNumber = 0
            inboxMessages.removeAll()
            UIApplication.shared.cancelAllLocalNotifications()
            getInboxMessages(txt : msg.safeValue, types: typeValue)
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if let text = searchTextField.text, text != "" {
            getInboxMessages(txt : text, types: typeValue)
        }
    }
    
    @IBAction func templateList(_ sender: Any) {
        type = .none
        updateImageColors()
        DispatchQueue.main.async {
            self.communicateTable.reloadData()
        }
    }
    
    
    func addGestureOnButton() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_ :)))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = true
    }
    
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        if sideView.frame.origin.x == 0 {
            UIView.animate(withDuration: 0.5 ) {
                self.sideView.frame.origin = CGPoint(x: -50, y: self.sideView.frame.origin.y)
            }
        }
    }
    
    func setRefreshControll(){
        refreshControl.addTarget(self, action: #selector(CommunicateController.refresh(sender:)), for: UIControl.Event.valueChanged)
        communicateTable.bottomRefreshControl = refreshControl// not required when using UITableV
    }
    
    @objc func refresh(sender:AnyObject) {
        switch type {
        case .inbox, .sent ,.WP, .draft:
            isLoadMore = true
            self.searchText = ""
            self.paginationNumber += 1
            self.getInboxMessages(txt : searchText, types: typeValue)
        case .none:
            isLoadMore = true
            callTemplateListAPI()
        }
    }
    
    func updateImageColors() {
        
        inboxView.backgroundColor = UIColor(named: "AppColor")
        sentView.backgroundColor = UIColor(named: "AppColor")
        wpView.backgroundColor = UIColor(named: "AppColor")
        draftView.backgroundColor = UIColor(named: "AppColor")
        templatesView.backgroundColor = UIColor(named: "AppColor")
        
        switch type {
        case .inbox:
            inboxView.backgroundColor = UIColor(named: "9CDAE7")
        case .sent:
            sentView.backgroundColor = UIColor(named: "9CDAE7")
        case .WP:
            wpView.backgroundColor = UIColor(named: "9CDAE7")
        case .draft:
            draftView.backgroundColor = UIColor(named: "9CDAE7")
        case .none:
            templatesView.backgroundColor = UIColor(named: "9CDAE7")
        }
    }
    
    func getInboxMessages(txt : String,types: Int,isSearch: Bool = false){
        sideView.frame.origin = CGPoint(x: -50, y: sideView.frame.origin.y)
        isSearch ? searchTextField.showLoadingIndicator() : self.startLoadingAnimation()
        var url  = ""
        
        if type == CommunicationType.inbox{
            typeValue = 2
            url = APIUrls().getInBox
        }
        else if type == CommunicationType.WP {
            typeValue = 3
            url = APIUrls().WPCommentList
        } else if type == CommunicationType.draft {
            typeValue = 4
            url = APIUrls().getDrafts
            isForDraft = true
        }
        else {
            typeValue = 1
            url = APIUrls().getSentBox
        }
        
        print("communicate send urk :- ",url)
        
        var dictionary = [String: Any]()
        
        
        dictionary[UserIdKey().id] =  UserDefaultsManager.manager.getUserId()//self.checkSibingsAndGetId()
        dictionary[Communicate().searchText] = txt
        dictionary[Communicate().paginationNumber] = paginationNumber
        if(typeValue == 3)
        {
            dictionary[Communicate().ModuleCode] = "weeklyplan"
        }
        
        if typeValue == 4 {
            dictionary["comm_id"] = ""
        }
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            print("inbox messages",result)
            
            //        if result["StatusCode"] as? Int == 1{
            
            DispatchQueue.main.async {
                if let messageList = result["MessageList"] as? NSArray{
                    let list = ModelClassManager.sharedManager.createModelArray(data: messageList, modelType: ModelType.TinboxMessage) as! [TinboxMessage]
                    var message = [TinboxMessage]()
                    for each in list {
                        message.append(each)
                    }
                    
                    if self.isLoadMore {
                        self.inboxMessages.append(contentsOf: message)
                    } else {
                        self.inboxMessages = message
                    }
                    
                    isSearch ? self.searchTextField.hideLoadingIndicator() :  self.stopLoadingAnimation()
                    DispatchQueue.main.async {
                        self.communicateTable.reloadData()
                    }
                    self.removeNoDataLabel()
                    self.checkAndStopBounce(count: list.count)
                    self.refreshControl.endRefreshing()
                    if self.inboxMessages.count == 0{
                        self.addNoDataFoundLabel()
                    } else {
                        self.removeNoDataLabel()
                    }
                    
                } else {
                    isSearch ? self.searchTextField.hideLoadingIndicator() :  self.stopLoadingAnimation()
                    //   self.addNoDataFoundLabel()
                    self.refreshControl.endRefreshing()
                }
            }
            
        }
    }
    
    
    
    func checkAndStopBounce(count:Int){
        
        if count == 0{
            self.communicateTable.bounces = false
        }
        
    }
    func setCharacterColor(cell:CommunicationTableViewCell,textColr: UIColor){
        //cell.labelHeading.textColor = textColr
        cell.labelMessageType.textColor = textColr
    }
    
    func setReadStatus(message : TinboxMessage,cell: CommunicationTableViewCell){
        if type == CommunicationType.inbox
        {
            cell.ReadStatus.isHidden = true
            
        }
        else
        {
            cell.ReadStatus.isHidden = false
            //cell.ReadStatus.text = String(describing: message.TotalCount)
            
            let ReadCount = Int(message.ReadCount ?? "0")
            let str = message.ReadCount ?? "0"
            let str2 = message.TotalCount ?? "0"
            cell.ReadStatus.text = str + "/" + str2
            if message.TotalCount == message.ReadCount
            {
                cell.ReadIcon.image = UIImage(named : "doubletickwhite")
            }
            else if ReadCount!  > 0
            {
                cell.ReadIcon.image = UIImage(named : "doubletickgrey")
            }
        }
    }
    
    func setTheTableCellElementsTextColorWrtIsRead(message : TinboxMessage,cell: CommunicationTableViewCell){
        if let isUserRead  = message.isRead{
            switch isUserRead {
            case "0":
                setCharacterColor(cell: cell, textColr: UIColor.black)
            case "1":
                setCharacterColor(cell: cell, textColr: UIColor.lightGray)
                cell.ReadIcon.image = UIImage(named: "doubletickwhite")
            default:
                break
            }
        }
    }
    func checkSibingsAndGetId() -> String?{
        
        if studentDetails.count > 0{
            
            let studDetails = studentDetails[indexOfSelectedStudent]
            
            return studDetails.userId
            
        }else{
            let userId = UserDefaultsManager.manager.getUserId()
            
            return userId
        }
    }
    
    func tableViewProporties(){
        self.communicateTable.delegate = self
        self.communicateTable.dataSource = self
        self.communicateTable.estimatedRowHeight = 70
    }
    
    func setHeight(isHide : Bool,const : CGFloat,cell: CommunicationTableViewCell){
        cell.attachButton.isHidden = isHide
    }
    
    func setAttachmentsIcon(msg : TinboxMessage,cell: CommunicationTableViewCell){
        let attachIcon = msg.attachIcon.safeValueOfInt
        switch attachIcon {
        case 0:
            setHeight(isHide: true, const: 0.0,cell: cell)
        case 1:
            setHeight(isHide: false, const: 30.0,cell: cell)
        default:
            break
        }
    }
    
    func deleteTheSelectedAttachment(index: Int) {
        
    }
    
    @IBAction func addTemplate(_ sender: Any) {
        let vc = AddNewTemplateViewController.instantiate(from: .communicateLand)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func composeAction(_ sender: Any) {
        self.delegate?.getBackToParentView(value: "compose", titleValue: nil, isForDraft: false, message: TinboxMessage(values: [:]))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
    
    func getBackToParentView(value: Any?, titleValue: String?, isForDraft: Bool) {
        
    }
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
    }
    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {
        
    }
    
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    
    func popUpDismiss() {
        
    }
    
    func moveToComposeController(titleTxt: String, index: Int,tag: Int) {
        
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        getInboxMessages(txt : searchTxt, types: type)
    }
    
}


//MARK: - TableView Delegates and Datasources

extension CommunicateController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .inbox, .sent ,.WP, .draft:
            return self.inboxMessages.count
        case .none:
            return self.templateList.count
        }
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch type {
        case .inbox, .sent ,.WP, .draft:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommunicationTableViewCell", for: indexPath) as! CommunicationTableViewCell
            if inboxMessages.count > 0 {
                let message = inboxMessages[indexPath.row]
                setReadStatus(message: message, cell: cell)
                setTheTableCellElementsTextColorWrtIsRead(message: message, cell: cell)
                if let userval = message.user {
                    cell.labelHeading.text = userval
                } else if let userBol = message.userBool {
                    cell.labelHeading.text = String(userBol)
                }
                setAttachmentsIcon(msg: message, cell: cell)
                cell.labelMessageType.text = message.subject?.replacingHTMLEntities
                cell.labelDate.text = message.date
                cell.index = indexPath.row
                cell.delegate = self
                cell.setUpSideViewBg()
            }
            return cell
        case .none:
            let cell = tableView.dequeueReusableCell(withIdentifier: TemplateTableViewCell.identifier, for: indexPath) as! TemplateTableViewCell
            let template = templateList[indexPath.row]
            cell.setData(template: template)
            cell.template = template
            cell.delegate = self
            return cell
        }
    }
}


extension CommunicateController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        switch type {
        case .inbox, .sent ,.WP, .draft:
            if inboxMessages.count > 0{
                let message = self.inboxMessages[indexPath.row]
                let messageSub = message.subject.safeValue
                let messageId = message.id.safeValue
                
                delegate?.getBackToParentView(value: messageId,titleValue :messageSub, isForDraft: isForDraft, message: message)
            }
        case .none:
            break
        }
    }
    
}



extension CommunicateController {
    
    @IBAction func buttonArrowAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5 ) {
            self.sideView.frame.origin = CGPoint(x: 0, y: self.sideView.frame.origin.y)
        }
    }
    
    @IBAction func buttonInboxAction(_ sender: Any) {
        type = .inbox
        isLoadMore = false
        updateImageColors()
        getInboxMessages(txt : searchText, types: typeValue)
    }
    
    @IBAction func buttonSentItemAction(_ sender: Any) {
        type = .sent
        isLoadMore = false
        updateImageColors()
        getInboxMessages(txt : searchText, types: typeValue)
    }
    @IBAction func buttonWeekleyPlanAction(_ sender: Any) {
        type = .WP
        isLoadMore = false
        updateImageColors()
        getInboxMessages(txt : searchText, types: typeValue)
    }
    
    @IBAction func buttonDraftAction(_ sender: Any) {
        type = .draft
        isLoadMore = false
        updateImageColors()
        getInboxMessages(txt : searchText, types: typeValue)
    }
}

extension CommunicateController: CommunicationTableViewCellDelegate {
    func communicationTableViewCell(_ cell: CommunicationTableViewCell, didTapOnCellWithIndex index: Int) {
        if inboxMessages.count > 0{
            let message = self.inboxMessages[index]
            let messageSub = message.subject.safeValue
            let messageId = message.id.safeValue
            
            delegate?.getBackToParentView(value: messageId,titleValue :messageSub, isForDraft: isForDraft, message: message)
        }
    }
}

extension CommunicateController: DebouncedSearchHandling {
    
    func performSearchIfNeeded(query: String) {
        if query.isEmpty {
            if lastQuery != "" {
                lastQuery = ""
                switch type{
                case .inbox, .sent ,.WP, .draft:
                    getInboxMessages(txt : "", types: typeValue,isSearch: true)
                    
                case .none:
                    callTempaltesFilter(with: query)
                }
            }
            return
        }
        
        guard query != lastQuery else {
            print("Skipping API – same query")
            return
        }
        
        lastQuery = query
        switch type{
        case .inbox, .sent ,.WP, .draft:
            getInboxMessages(txt : "", types: typeValue,isSearch: true)
            
        case .none:
            callTempaltesFilter(with: query)
        }
    }
    
    private func callTempaltesFilter(with query: String) {
        let templates = templates?.templates ?? []
        templateList = filterEvents(byTitle: query, in: templates)
        DispatchQueue.main.async { [weak self] in
            self?.communicateTable.reloadData()
        }
    }
    
    func filterEvents(byTitle searchText: String, in events: [Template]) -> [Template] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return events
        }
        return events.filter { event in
            event.templateName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

extension CommunicateController{
    
    func callTemplateListAPI() {
        let userId = UserDefaultsManager.manager.getUserId()
        let parameters: [String: Any] = [
            "tempname": "Mail Template",
            "UserId": userId,
        ]
        let url = APIUrls().getTemplate
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: parameters) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadMore = false
                if let responseDict = result as? NSDictionary,
                   let message = responseDict["StatusMessage"] as? String,
                   message == "Success" {
                    let progress = TemplateResponse(values: responseDict)
                    self?.templates = progress
                    self?.templateList = progress.templates
                    self?.communicateTable.reloadData()
                }
            }
        }
    }
    
}

extension CommunicateController: TemplateTableViewCellDelegate {
    
    func templateTableViewCellDidTapEdit(_ cell: TemplateTableViewCell) {
        let vc = AddNewTemplateViewController.instantiate(from: .communicateLand)
        vc.isComeForEdit = true
        vc.delegate = self
        vc.templates = cell.template
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func templateTableViewCellDidTapDelete(_ cell: TemplateTableViewCell) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to Delete?", style: AlertStyle.warning, buttonTitle:"Cancel", buttonColor:UIColor.lightGray , otherButtonTitle:  "Delete", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                let id = cell.template?.templateID ?? ""
                self.deleteTemplateData(id)
            }
        }
    }
    
    func deleteTemplateData(_ id:String) {
        let userId  = UserDefaultsManager.manager.getUserId()
        var dictionary = [String:Any]()
        dictionary["UserId"] = userId
        dictionary["TempId"] = id
        let url = APIUrls().deleteTemplate
        startLoadingAnimation()
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { [weak self] result in
            DispatchQueue.main.async {
                self?.stopLoadingAnimation()
                if let status = result["StatusCode"] as? Int,
                   status == 1  {
                    self?.callTemplateListAPI()
                }
                else{
                    self?.showAlert("Error", "Failed to delete template. Please try again.")
                }
            }
        }
    }
    
    func showAlert(_ tittle: String,_ message: String) {
        SweetAlert().showAlert(
            tittle,
            subTitle: message,
            style: .warning,
            buttonTitle: "OK",
            buttonColor: UIColor.systemRed
        )
    }
    
}

extension CommunicateController : AddNewTemplateDelegate{
    
    func refreshTemplates() {
        callTemplateListAPI()
    }
    
}
