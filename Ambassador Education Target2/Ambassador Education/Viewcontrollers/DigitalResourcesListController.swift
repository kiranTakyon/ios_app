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
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var widthConstraintLogout: NSLayoutConstraint! //50
    @IBOutlet weak var logOutImgWidth: NSLayoutConstraint! //20
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var tiitleLabel: UILabel!
    
    var categoryList = [TNDigitalResourceCategory]()
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSlideMenuProporties()
        tableViewProporties()
        self.setUi()
        self.getCategoryList()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTf.text != ""{
            //setClaerButton()
            searchText = searchTf.text!
            searchTf.resignFirstResponder()
            self.getCategoryList()
        }
        return true
    }
    
    func setSlideMenuProporties(){
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func tableViewProporties(){
        
        self.categoryTable.estimatedRowHeight = 60
        self.categoryTable.rowHeight = UITableViewAutomaticDimension
    }
   
    func setUi(){
        searchTf.returnKeyType = .search
        widthConstraintLogout.constant = 50
        logOutImgWidth.constant = 20
        searchText = ""
        searchTf.delegate = self
        searchTf.isHidden = true
        tiitleLabel.isHidden = false
        searchIcon.image = #imageLiteral(resourceName: "Search")
        logOutButton.isUserInteractionEnabled = true
    }
    
    func setBorderAtBottom(){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: searchTf.frame.size.height - width, width:  searchTf.frame.size.width + 50, height: searchTf.frame.size.height)
        border.borderWidth = width
        searchTf.layer.addSublayer(border)
        searchTf.textColor = UIColor.white
        searchTf.layer.masksToBounds = true
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
    
    @IBAction func seaqrchButtonAction(_ sender: UIButton) {
        if searchIcon.image == #imageLiteral(resourceName: "Search"){
            searchTf.isHidden = false
            tiitleLabel.isHidden = true
            searchIcon.image = #imageLiteral(resourceName: "Close")
            widthConstraintLogout.constant = 0
            logOutImgWidth.constant = 0
            logOutButton.isUserInteractionEnabled = true
            self.setBorderAtBottom()
        }
        else if searchIcon.image == #imageLiteral(resourceName: "Close"){
            searchTf.isHidden = true
            searchTf.text = ""
            searchText = ""
            widthConstraintLogout.constant = 50
            logOutImgWidth.constant = 20
            tiitleLabel.isHidden = false
            searchIcon.image = #imageLiteral(resourceName: "Search")
            getCategoryList()
            
        }
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
