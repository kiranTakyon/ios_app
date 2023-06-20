//
//  DigitalResourceSecondListController.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class DigitalResourceSecondListController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{

    @IBOutlet weak var listTableVIew: UITableView!
    var catId = ""
    var searchText = ""
    @IBOutlet weak var topHeaderView: TopHeaderView!
    var titleValue : String?
    var digitalList = [TNDigitalResourceSubList]()
    var pageNumber = 1
    let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.searchTextField.delegate = self
        self.tableViewProporties()
        self.getDigitalResources(searcText : searchText)
        self.setTitle()
        self.setRefreshControll()
        // Do any additional setup after loading the view.
    }
    
    
    
    func tableViewProporties(){
        self.listTableVIew.estimatedRowHeight = 60
        self.listTableVIew.rowHeight = UITableView.automaticDimension
        self.listTableVIew.tableFooterView = UIView()
    }
    
    
    func setTitle(){
        if let  _ = titleValue{
            self.topHeaderView.title = titleValue!
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topHeaderView.searchTextField.text != ""{
            searchText = topHeaderView.searchTextField.text!
            topHeaderView.searchTextField.resignFirstResponder()
            getDigitalResources(searcText: searchText)
        }
        return true
    }
    
    
    @objc func clearTextField(){
       getDigitalResources(searcText: "")
    }
    
    func getDigitalResources(searcText : String){
        
        self.startLoadingAnimation()
        
        let url = APIUrls().getDigitalResourceDetails
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = searcText
        dictionary[GalleryCategory.paginationNumber] = pageNumber
        dictionary["CategoryId"] = Int(catId)

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            guard let categryValues = result["CategoryItems"] as? NSArray else{ return }
            let cetgories = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNDigitalResourceSubList) as! [TNDigitalResourceSubList]
            
            self.digitalList = cetgories
            
            DispatchQueue.main.async {
                self.removeNoDataLabel()
                self.checkAndStopBounce(count: cetgories.count)
                self.stopLoadingAnimation()
                if self.digitalList.count == 0{
                    self.listTableVIew.isHidden = true
                    self.addNoDataFoundLabel()
                }
                else{
                    self.removeNoDataLabel()
                    self.listTableVIew.isHidden = false
                    self.listTableVIew.reloadData()
                    self.removeNoDataLabel()

                }
                self.refreshControl.endRefreshing()
            }
        }

    }
    
    func checkAndStopBounce(count:Int){
        
        if count == 0{
            self.listTableVIew.bounces = false
        }
        
    }
    
    func setRefreshControll(){
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(DigitalResourceSecondListController.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.listTableVIew.bottomRefreshControl = refreshControl // not required when using UITableV
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        print("pull to Refresh")
        self.pageNumber += 1
        self.getDigitalResources(searcText : searchText)
    }

    
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return digitalList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunicateCell", for: indexPath) as! CommunicateCell
        
         let item = digitalList[indexPath.row]
        
        
        if let title = item.title{
            cell.firstLabel.text = title
        }
        
        if let date = item.date{
            cell.secondLabel.text = date
        }
        
        if let contenttype = item.contentType{
            cell.thirdLabel.text = contenttype
        }
        
        if let url = item.attachment{
            cell.cImageView.loadImageWithUrl(url)
        }
        
        
        
        cell.selectionStyle = .none
        
        // create a new cell if needed or reuse an old one
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //        guard let cell = tableView.cellForRow(at: indexPath) as? GalleryCategoryList else { return }
        //
        //        self.navigateToGallery(catId: cell.tag)
        
        let item = digitalList[indexPath.row]
        
        self.navigateToDetail(digitalResource: item)
        
    }
    
    
    func navigateToDetail(digitalResource:TNDigitalResourceSubList){
        
        let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceDetailController") as! DigitalResourceDetailController
        
        detailVc.digitalResource = digitalResource
        
        self.navigationController?.pushViewController(detailVc, animated: true)
        
    }
    
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
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


extension DigitalResourceSecondListController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            topHeaderView.titleLabel.isHidden = true
            topHeaderView.searchTextField.isHidden = false
            button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        } else {
            topHeaderView.titleLabel.isHidden = false
            topHeaderView.searchTextField.isHidden = true
            button.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
            topHeaderView.searchTextField.text = ""
            getDigitalResources(searcText: "")
        }
    }
    
}
