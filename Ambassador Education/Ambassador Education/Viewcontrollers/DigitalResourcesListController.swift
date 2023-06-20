//
//  DigitalResourcesListController.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class DigitalResourcesListController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var categoryTable: UITableView!

    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var categoryList = [TNDigitalResourceCategory]()
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.searchTextField.delegate = self
        topHeaderView.setMenuOnLeftButton()
        setSlideMenuProporties()
        tableViewProporties()
        self.getCategoryList()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topHeaderView.searchTextField.text != ""{
            //setClaerButton()
            searchText = topHeaderView.searchTextField.text!
            topHeaderView.searchTextField.resignFirstResponder()
            self.getCategoryList()
        }
        return true
    }
    
    func setSlideMenuProporties(){
        if self.revealViewController() != nil {
            topHeaderView.backButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControl.Event.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func tableViewProporties(){
        
        self.categoryTable.estimatedRowHeight = 60
        self.categoryTable.rowHeight = UITableView.automaticDimension
    }
   
    
    func getCategoryList(){
        
        self.startLoadingAnimation()
        
        let url = APIUrls().getDigitalResource
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = searchText
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            guard let categryValues = result["DigitalCategories"] as? NSArray else{return}
             guard let title = result["DigitalResourcesLabel"] as? String else{return}
            DispatchQueue.main.async {
                self.topHeaderView.title = title
            }
            
            print("digita categories ",categryValues)
            
            let cetgories = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNDigitalResource) as! [TNDigitalResourceCategory]
            self.categoryList.removeAll()
            self.categoryList = cetgories
            
            DispatchQueue.main.async {
                self.categoryTable.reloadData()
                self.stopLoadingAnimation()
                if self.categoryList.count == 0{
                    self.addNoDataFoundLabel()
                }
                else{
                    self.removeNoDataLabel()
                }
            }
        }
        
    }
    
   

    
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCategoryList", for: indexPath) as! GalleryCategoryList
        
        let category = categoryList[indexPath.row]
        
        
        if let title = category.caetgory{
            cell.titleLabel.text = title
        }
        
//        if let catId = category.categoryId{
//            cell.tag = catId
//        }
        
        cell.selectionStyle = .none
        
        // create a new cell if needed or reuse an old one
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
//        guard let cell = tableView.cellForRow(at: indexPath) as? GalleryCategoryList else { return }
//        
//        self.navigateToGallery(catId: cell.tag)
        
        
        
        
         let cat = categoryList[indexPath.row]
        
        
        self.navigateTodigitalResourceDetail(category: cat)
        
    }
    
    func navigateTodigitalResourceDetail(category:TNDigitalResourceCategory){
        
        let digitalVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceSecondListController") as! DigitalResourceSecondListController
        digitalVc.catId = category.categoryId!
        digitalVc.titleValue = category.caetgory

              self.navigationController?.pushViewController(digitalVc, animated: true)
    }

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logOutButtonAction(_ sender: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                showLoginPage()
                gradeBookLink = ""
            }
        }
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


extension DigitalResourcesListController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                showLoginPage()
                gradeBookLink = ""
            }
        }
    }
    
    func searchButtonClicked(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            topHeaderView.titleLabel.isHidden = true
            topHeaderView.searchTextField.isHidden = false
            button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
            topHeaderView.shouldShowSecondRightButton(false)
        } else {
            topHeaderView.titleLabel.isHidden = false
            topHeaderView.searchTextField.isHidden = true
            button.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
            topHeaderView.searchTextField.text = ""
            topHeaderView.shouldShowSecondRightButton(true)
            getCategoryList()
        }
    }
    
}
