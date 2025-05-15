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
    @IBOutlet weak var searchTextField: UITextField!
    
    private var debounceDelay: TimeInterval { 0.3 }
    private var lastQuery: String = ""
    private var debounceWorkItem: DispatchWorkItem?
    var selectedIndexes: [Int] = []
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        tableViewProporties()
        getCategoryList()
        hideKeyboardWhenTappedAround()
    }
    
    
    func tableViewProporties() {
        categoryTable.register(UINib(nibName: "NoticeboardCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "NoticeboardCategoryTableViewCell")
        categoryTable.estimatedRowHeight = 60
        categoryTable.rowHeight = UITableView.automaticDimension
    }
    
    func getCategoryList() {
        
        self.startLoadingAnimation()
        let url = APIUrls().getNoticeboard
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        //{"UserId":"98189","SearchText":""}
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = searchText
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
                if self.categoryList.count == 0 {
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
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeboardCategoryTableViewCell", for: indexPath) as! NoticeboardCategoryTableViewCell
        
        let category = categoryList[indexPath.row]
        
        cell.index = indexPath.row
        cell.delegate = self
        cell.setUpCell(category: category)
        
        let isSelected = selectedIndexes.contains(indexPath.row)
        cell.tableViewHeight.constant = isSelected ? 150 : 0
        cell.tableView.isHidden = !isSelected
        cell.labelDate.isHidden = !isSelected
        cell.dateView.isHidden = isSelected
        cell.moreButton.isHidden = !isSelected
        let image = isSelected ? "upArrow" : "down_arrow"
        cell.arrowButton.setImage(UIImage(named: image), for: .normal)
        
        cell.selectionStyle = .none
        
        // create a new cell if needed or reuse an old one
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let item = categoryList[indexPath.row]
        if let items = item.Items,let category = item.category {
            self.navigateToDetail(item: items, text: category)
        }
    }
    
    func navigateToDetail(item:[TNNoticeBoardDetail],text: String){
        let galleryListVc = commonStoryBoard.instantiateViewController(withIdentifier: "NoticeBoardListController") as! NoticeBoardListController
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
    
    @IBAction func didTapOnSearchButton(_ sender: UIButton) {
        searchText = searchTextField.text ?? ""
        getCategoryList()
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


extension NoticeboardCategoryController: NoticeboardCategoryTableViewCellDelegate {
    func noticeboardCategoryTableViewCell(_ cell: NoticeboardCategoryTableViewCell, didSelectCellwithIndex index: Int, item: TNNoticeBoardDetail) {
        let vc = NoticeboardDetailController.instantiate(from: .noticeboard)
        vc.detail = item
        vc.NbID = item.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
       
    func noticeboardCategoryTableViewCell(_ cell: NoticeboardCategoryTableViewCell, didTapOnArrowButton button: UIButton, withIndex index: Int) {
        if let index = selectedIndexes.firstIndex(of: index) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(index)
        }
        
        categoryTable.reloadData()
    }
    
}

extension NoticeboardCategoryController: UITextFieldDelegate {
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearchIfNeeded(query: query)
        }
        
        debounceWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    private func performSearchIfNeeded(query: String) {
        if query.isEmpty {
            if lastQuery != "" {
                lastQuery = ""
                searchText = lastQuery
                getCategoryList()
            }
            return
        }

        guard query != lastQuery else {
            print("Skipping API – same query")
            return
        }

        lastQuery = query
        searchText = lastQuery
        getCategoryList()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        debounceWorkItem?.cancel()
        searchText = lastQuery
        getCategoryList()
        return true
    }
    
}
