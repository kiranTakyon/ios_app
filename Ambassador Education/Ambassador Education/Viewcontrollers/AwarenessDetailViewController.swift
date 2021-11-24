//
//  AwarenessDetailViewController.swift
//  Ambassador Education
//
//  Created by Veena on 27/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class AwarenessDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var sendImageView: UIImageView!
    
    var searchText = ""
    var articleList = [TNAwarenessDetail]()
    var pageNumber = Int()
    var id : Int?
    var titleName : String?
    var start = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewProporties()
        titleLabel.text = titleName
        start = 0
        self.setUi()
        articleList.removeAll()
        getArticleList(page: start, searchText: "")
        // Do any additional setup after loading the view.
    }

    func setUi(){
        searchTextField.delegate = self
        searchTextField.isHidden = true
        titleLabel.isHidden = false
        sendImageView.image = #imageLiteral(resourceName: "Search")
    }
    
    
    func tableViewProporties(){
        articleTableView.delegate = self
        articleTableView.dataSource  = self
        //  let listNib = UINib(nibName: "ArticleCategoryList", bundle: nil)
        //  self.articleTableView.register(listNib, forCellReuseIdentifier: "ArticleCategoryList")
        self.articleTableView.tableFooterView = UIView()
        self.articleTableView.estimatedRowHeight = 60
        self.articleTableView.rowHeight = UITableView.automaticDimension
    }
    
    func getArticleList(page: Int,searchText : String){
        
        self.startLoadingAnimation()
        
        let url = APIUrls().viewArticleCode
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        dictionary[GalleryCategory.categoryId] = id
        dictionary[GalleryCategory.searchText] = searchText
        dictionary[GalleryCategory.paginationNumber] = page
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
           
            
                guard let categryValues = result["ArticlesItems"] as? NSArray else{
                    DispatchQueue.main.async {

                    self.stopLoadingAnimation()
                    //SweetAlert().showAlert(kAppName, subTitle: result["MSG"] as! String, style: AlertStyle.error)

                    }
                    return
                    
                }
                
                print("digita categories ",categryValues)
                
                let articles = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNAwarenessDetail) as! [TNAwarenessDetail]
                
                for each in articles{
                    self.articleList.append(each)
                }
            DispatchQueue.main.async {

                if let totalCount = result["PaginationTotalNumber"] as? Int{
                    self.pageNumber = totalCount
                }
                self.removeNoDataLabel()
                self.articleTableView.reloadData()
                self.stopLoadingAnimation()
                if self.articleList.count == 0{
                    self.addNoDataFoundLabel()
                }
                
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
    
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardListCell", for: indexPath) as? NoticeBoardListCell
        
        let category = articleList[indexPath.row]
        
        if let title = category.name{
            cell?.titleLabel.text = title
        }
        if let tag = category.id{
            cell?.titleLabel.tag = tag
        }
        
        if let date = category.date{
            cell?.shortDesc.text = date
        }
        cell?.titleImageView.image = #imageLiteral(resourceName: "Default")
        cell?.dateLabel.isHidden = true
        cell?.selectionStyle = .none
        
        // create a new cell if needed or reuse an old one
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //        guard let cell = tableView.cellForRow(at: indexPath) as? GalleryCategoryList else { return }
        //
        //        self.navigateToGallery(catId: cell.tag)
        
        
        
        
         let cat = articleList[indexPath.row]
        
        
        self.navigateTodigitalResourceDetail(category: cat)
        
    }
    
    func setBorderAtBottom(){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: searchTextField.frame.size.height - width, width:  searchTextField.frame.size.width , height: searchTextField.frame.size.height)
        searchTextField.textColor = UIColor.white
        border.borderWidth = width
        searchTextField.layer.addSublayer(border)
        searchTextField.layer.masksToBounds = true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTextField.text != ""{
            //setClaerButton()
            searchText = searchTextField.text!
            searchTextField.resignFirstResponder()
            articleList.removeAll()
            getArticleList(page: start, searchText: searchTextField.text!)
        }
        return true
    }
    
    func navigateTodigitalResourceDetail(category:TNAwarenessDetail){
        var page = mainStoryBoard.instantiateViewController(withIdentifier: "NoticeboardDetailController") as? NoticeboardDetailController
        page?.awarnessPlan = category
        self.navigationController?.pushViewController(page!, animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if pageNumber >= start{
            start = start + 1
            getArticleList(page: start, searchText: "")
        }
    }
    
    @IBAction func searchButtonAcrion(_ sender: UIButton) {
        if sendImageView.image == #imageLiteral(resourceName: "Search"){
            setBorderAtBottom()
            searchTextField.isHidden = false
            titleLabel.isHidden = true
            sendImageView.image = #imageLiteral(resourceName: "Close")
        }
        else if sendImageView.image == #imageLiteral(resourceName: "Close"){
            searchTextField.isHidden = true
            searchTextField.text = ""
            titleLabel.isHidden = false
            sendImageView.image = #imageLiteral(resourceName: "Search")
            articleList.removeAll()
            getArticleList(page: start, searchText: "")
        }
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
