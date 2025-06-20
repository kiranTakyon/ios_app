//
//  AwarenessDetailViewController.swift
//  Ambassador Education
//
//  Created by Veena on 27/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit
import SDWebImage // Import SDWebImage

class AwarenessDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate {

    
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var searchText = ""
    var articleList = [TNAwarenessDetail]()
    var pageNumber = Int()
    var id : Int?
    var titleName : String?
    var start = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.searchTextField.delegate = self
        tableViewProporties()
        topHeaderView.title = titleName ?? ""
        start = 0
        articleList.removeAll()
        getArticleList(page: start, searchText: "")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self as UIGestureRecognizerDelegate
        view.addGestureRecognizer(tapGesture)

    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
                
            let isFreshLoad = page == 0
            if isFreshLoad {
                self.articleList = articles
            } else {
                for each in articles {
                    if !self.articleList.contains(where: { $0.id == each.id }) {
                        self.articleList.append(each)
                    }
                }
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

    func formatDateString(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd-MM-yyyy HH:mm" // Show date and time (no seconds)
            return outputFormatter.string(from: date)
        } else {
            return dateString // fallback
        }
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardListCell", for: indexPath) as? NoticeBoardListCell
        
        let category = articleList[indexPath.row]
        
        if let title = category.name {
            cell?.titleLabel.text = title
        }
        
        if let tag = category.id {
            cell?.titleLabel.tag = tag
        }
        
        if let date = category.date {
            cell?.shortDesc.text = formatDateString(date)
        }

        // Set a default image initially
        cell?.titleImageView.image = #imageLiteral(resourceName: "Default")
        
        // Check if image URL exists
        if let imageURLString = category.image {
            if imageURLString.isEmpty {
                print("No image URL found for article: \(category.name ?? "Unknown")")
                // Use default image when no URL is provided
                cell?.titleImageView.image = #imageLiteral(resourceName: "Default")
            } else {
                print("Image URL: \(imageURLString)")  // Debugging the image URL
                if let imageURL = URL(string: imageURLString) {
                    // Load the image asynchronously
                    cell?.titleImageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "Default"))
                } else {
                    print("Invalid URL: \(imageURLString)")  // If URL is invalid
                    cell?.titleImageView.image = #imageLiteral(resourceName: "Default")
                }
            }
        } else {
            print("No image URL found")  // If no image URL
            cell?.titleImageView.image = #imageLiteral(resourceName: "Default")
        }
        
        cell?.dateLabel.isHidden = true
        cell?.selectionStyle = .none
        
        return cell!
    }


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
         let cat = articleList[indexPath.row]
        self.navigateTodigitalResourceDetail(category: cat)
    }
    
   
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topHeaderView.searchTextField.text != ""{
            //setClaerButton()
            searchText = topHeaderView.searchTextField.text!
            topHeaderView.searchTextField.resignFirstResponder()
            articleList.removeAll()
            start = 0
            getArticleList(page: start, searchText: searchText)

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
            getArticleList(page: start, searchText: searchText)
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}


extension AwarenessDetailViewController: TopHeaderDelegate {
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
            start = 0
            articleList.removeAll()
            getArticleList(page: start, searchText: "")

        }
    }
    
}
