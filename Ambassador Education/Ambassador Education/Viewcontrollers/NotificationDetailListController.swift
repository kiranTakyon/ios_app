//
//  NotificationDetailListController.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit


class NotificationDetailListController: UIViewController {
    @IBOutlet weak var listTableVIew: UITableView!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    var catId = 0
    
    var digitalList = [TNDigitalResourceSubList]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewProporties()
        topHeaderView.delegate = self
        topHeaderView.title = "Digital Resource List"
        self.getDigitalResources()
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableViewProporties(){
        
        self.listTableVIew.estimatedRowHeight = 60
        self.listTableVIew.rowHeight = UITableView.automaticDimension
    }
    
    
    
    func getDigitalResources(){
        
        self.startLoadingAnimation()
        
        let url = APIUrls().getDigitalResourceDetails
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = ""
        dictionary[GalleryCategory.paginationNumber] = 1
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            guard let categryValues = result["CategoryItems"] as? NSArray else{ return }
            
            let cetgories = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNDigitalResourceSubList) as! [TNDigitalResourceSubList]
            
            self.digitalList = cetgories
            
            DispatchQueue.main.async {
                self.listTableVIew.reloadData()
                self.stopLoadingAnimation()
                if self.digitalList.count == 0{
                    self.addNoDataFoundLabel()
                }
            }
        }
        
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
        detailVc.isFromNotification = false
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

extension NotificationDetailListController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func backButtonClicked(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
