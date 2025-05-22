//
//  AwarenessViewController.swift
//  Ambassador Education
//
//  Created by Veena on 19/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class AwarenessViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{


    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    
    var articleList = [TNAwarnessArticleDetail]()
    private var lastQuery = ""
    private var searchText = ""
    private var debouncedDelegate: DebouncedTextFieldDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        debouncedDelegate = DebouncedTextFieldDelegate(handler: self)
        topHeaderView.searchTextField.delegate = debouncedDelegate
        tableViewProporties()
        getArticleList()
    }

    func tableViewProporties() {
      //  let listNib = UINib(nibName: "ArticleCategoryList", bundle: nil)
      //  self.articleTableView.register(listNib, forCellReuseIdentifier: "ArticleCategoryList")
        self.articleTableView.tableFooterView = UIView()
        self.articleTableView.estimatedRowHeight = 60
        self.articleTableView.rowHeight = UITableView.automaticDimension
    }

    
    func getArticleList(isSearch: Bool = false){
        
        isSearch ? topHeaderView.searchTextField.showLoadingIndicator(color: .white) : self.startLoadingAnimation() 
        
        let url = APIUrls().articleCode
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = searchText
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            guard let categryValues = result["ArticleCategories"] as? NSArray else{return}
            print("digita categories ",categryValues)
            
            DispatchQueue.main.async {
                isSearch ? self.topHeaderView.searchTextField.hideLoadingIndicator() :  self.stopLoadingAnimation()
                if categryValues.count > 0{
                let articles = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNAwarnessArticleDetail) as! [TNAwarnessArticleDetail]
                self.articleList.removeAll()
                self.articleList = articles
                }
                else{
                   self.articleList.removeAll()
                }
                self.topHeaderView.title = result["ArticleLabel"] as? String ?? ""
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
        let page = commonStoryBoard.instantiateViewController(withIdentifier: "AwarenessDetailViewController") as? AwarenessDetailViewController
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


extension AwarenessViewController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
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
    
    func searchButtonClicked(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            topHeaderView.titleLabel.isHidden = true
            topHeaderView.searchTextField.isHidden = false
            topHeaderView.shouldShowSecondRightButton(false)
            button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        } else {
            topHeaderView.titleLabel.isHidden = false
            topHeaderView.searchTextField.isHidden = true
            button.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
            topHeaderView.searchTextField.text = ""
            topHeaderView.shouldShowSecondRightButton(true)
            getArticleList()
        }
    }
    
}


extension AwarenessViewController: DebouncedSearchHandling {
    
    func performSearchIfNeeded(query: String) {
        if query.isEmpty {
            if lastQuery != "" {
                lastQuery = ""
                searchText = lastQuery
                getArticleList(isSearch: true)
            }
            return
        }

        guard query != lastQuery else {
            print("Skipping API – same query")
            return
        }

        lastQuery = query
        searchText = lastQuery
        getArticleList(isSearch: true)
    }
}


