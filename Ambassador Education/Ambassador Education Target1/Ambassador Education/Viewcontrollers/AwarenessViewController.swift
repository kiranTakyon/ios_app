//
//  AwarenessViewController.swift
//  Ambassador Education
//
//  Created by Veena on 19/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class AwarenessViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,UITextFieldDelegate{

    @IBOutlet weak var logoutImagWidth: NSLayoutConstraint!
    @IBOutlet weak var logoutButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var searchIcom: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    
    
    var articleList = [TNAwarnessArticleDetail]()
    var searchText = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSlideMenuProporties()
        tableViewProporties()
        self.setUi()
        getArticleList()
    
        // Do any additional setup after loading the view.
    }

    func setUi(){
        searchTf.returnKeyType = .search
        logoutButtonWidth.constant = 50
        logoutImagWidth.constant = 20
        searchText = ""
        searchTf.delegate = self
        searchTf.isHidden = true
        headLabel.isHidden = false
        searchIcom.image = #imageLiteral(resourceName: "Search")
        logOutButton.isUserInteractionEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTf.text != ""{
            searchText = searchTf.text!
            searchTf.resignFirstResponder()
            getArticleList()
        }
        return true
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

    
    func setSlideMenuProporties(){
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func searchTextFieldAction(_ sender: UIButton) {
        if searchIcom.image == #imageLiteral(resourceName: "Search"){
            searchTf.isHidden = false
            headLabel.isHidden = true
            searchIcom.image = #imageLiteral(resourceName: "Close")
            logoutButtonWidth.constant = 0
            logoutImagWidth.constant = 0
            logOutButton.isUserInteractionEnabled = true
            self.setBorderAtBottom()
        }
        else if searchIcom.image == #imageLiteral(resourceName: "Close"){
            searchTf.isHidden = true
            searchTf.text = ""
            searchText = ""
            logoutButtonWidth.constant = 50
            logoutImagWidth.constant = 20
            headLabel.isHidden = false
            searchIcom.image = #imageLiteral(resourceName: "Search")
            getArticleList()
        }
        
    }
    func tableViewProporties(){
      //  let listNib = UINib(nibName: "ArticleCategoryList", bundle: nil)
      //  self.articleTableView.register(listNib, forCellReuseIdentifier: "ArticleCategoryList")
        self.articleTableView.tableFooterView = UIView()
        self.articleTableView.estimatedRowHeight = 60
        self.articleTableView.rowHeight = UITableViewAutomaticDimension
    }

    
    func getArticleList(){
        
        self.startLoadingAnimation()
        
        let url = APIUrls().articleCode
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = searchText
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            guard let categryValues = result["ArticleCategories"] as? NSArray else{return}
            print("digita categories ",categryValues)
            
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                if categryValues.count > 0{
                let articles = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNAwarnessArticleDetail) as! [TNAwarnessArticleDetail]
                self.articleList.removeAll()
                self.articleList = articles
                }
                else{
                   self.articleList.removeAll()
                }
                self.headLabel.text = result["ArticleLabel"] as? String
                self.articleTableView.reloadData()
                if self.articleList.count == 0{
                    self.articleTableView.isHidden = true
                  //  self.addNoDataFoundLabel()
                }
                else{
                    self.articleTableView.isHidden = false
                    self.removeNoDataLabel()
                }
            }
        }
    }
    
    
    
    
    //MARK:- TableView Delegates and Datasources

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleList.count
    }
    
    // create a cell for each table view row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCategoryList", for: indexPath) as? ArticleCategoryList
        
        let category = articleList[indexPath.row]
        
        if let title = category.category{
            cell?.titleLabel.text = title.replacingHTMLEntities
        }
        if let tag = category.id{
            cell?.titleLabel.tag = Int(tag)!
        }
        
        //        if let catId = category.categoryId{
        //            cell.tag = catId
        //        }
        
        cell?.selectionStyle = .none
        
        // create a new cell if needed or reuse an old one
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
                guard let cell = tableView.cellForRow(at: indexPath) as? ArticleCategoryList else { return }
        if let tag = cell.titleLabel.tag as? Int{
            if let tilesVal = cell.titleLabel.text as? String{
            self.navigateToArticleDetail(catId: tag,title: tilesVal)
            }
        }
        
        
        
        
       // let cat = categoryList[indexPath.row]
        
        
        //self.navigateTodigitalResourceDetail(category: cat)
        
    }
    
    func navigateToArticleDetail(catId : Int,title: String){
          var page = mainStoryBoard.instantiateViewController(withIdentifier: "AwarenessDetailViewController") as? AwarenessDetailViewController
        page?.id = catId
        page?.titleName = title
        self.navigationController?.pushViewController(page!, animated: true)
        
       
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logOutButtonAction(_ sender: UIButton) {
        
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


class ArticleCategoryList : UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageIconView: ImageLoader!
    
}
