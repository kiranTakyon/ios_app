//
//  NoticeboardCategoryController.swift
//  Ambassador Education
//
//  Created by    Kp on 26/08/17.
//  Copyright © 2017  . All rights reserved.
//

import UIKit

class NoticeboardCategoryController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTable: UITableView!
    var categoryList = [TNNoticeboardCategory]()
    @IBOutlet weak var topHeaderView: TopHeaderView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        setSlideMenuProporties()
        tableViewProporties()
        getCategoryList()

        // Do any additional setup after loading the view.
    }
    
    func setSlideMenuProporties() {
        if self.revealViewController() != nil {
            topHeaderView.setMenuOnLeftButton()
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
        let url = APIUrls().getNoticeboard
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        //{"UserId":"98189","SearchText":""}
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = ""
        //   dictionary[GalleryCategory.paginationNumber] = 1
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            DispatchQueue.main.async {
                self.topHeaderView.title = result["HeadLabel"] as? String ?? ""
            guard let categryValues = result["Categories"] as? NSArray else{
                self.stopLoadingAnimation()
                SweetAlert().showAlert(kAppName, subTitle:  result["MSG"] as! String, style: AlertStyle.error)

                return
                }
            
            let cetgories = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNNoticeboardCategory) as! [TNNoticeboardCategory]
            
            self.categoryList = cetgories
            
                self.categoryTable.reloadData()
                self.stopLoadingAnimation()
                if self.categoryList.count == 0{
                    self.addNoDataFoundLabel()
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
        
        
        if let title = category.category{
            cell.titleLabel.text = title
        }
        if let item = category.Items as? [TNNoticeBoardDetail]{
            if item.count > 0 {
                if let img  = item[0].image{
                cell.categoryImageLoder.loadImageWithUrl(img)
                }
            }
        }
       // cell.categoryImageLoder.image = #imageLiteral(resourceName: "Gallary")
        
        cell.selectionStyle = .none
        
        // create a new cell if needed or reuse an old one
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    
        let item = categoryList[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? GalleryCategoryList{
            self.navigateToDetail(item: item.Items!, text: getTitleOfCell(cell: cell))

     }
        
    }
    
    func getTitleOfCell(cell :GalleryCategoryList) -> String{
        if let text = cell.titleLabel.text{
        var title  = text
            return text
        }
        return ""
    }
    
    func navigateToDetail(item:[TNNoticeBoardDetail],text: String){
        let galleryListVc = mainStoryBoard.instantiateViewController(withIdentifier: "NoticeBoardListController") as! NoticeBoardListController
        galleryListVc.listValues = item
        galleryListVc.titleValue = text
        self.navigationController?.pushViewController(galleryListVc, animated: true)
        
    }

    @IBAction func logoutButtonAction(_ sender: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
                // SweetAlert().showAlert("Cancelled!", subTitle: "Your imaginary file is safe", style: AlertStyle.Error)
            }
            else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
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


extension NoticeboardCategoryController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
    }
    
}
