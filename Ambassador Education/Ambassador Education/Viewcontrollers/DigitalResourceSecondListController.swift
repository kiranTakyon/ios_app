//
//  DigitalResourceSecondListController.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

struct CategoryAndItem {
    var id : String?
    var title : String?
    var date : String?
    var isItem : Bool?
}

class DigitalResourceSecondListController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var catId = ""
    var searchText = ""
    @IBOutlet weak var topHeaderView: TopHeaderView!
    var titleValue : String?
    var digitalList = [TNDigitalResourceSubList]()
    var pageNumber = 1
    let refreshControl = UIRefreshControl()
    var arrCatgoryAndItem: [CategoryAndItem] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.searchTextField.delegate = self
        setUpCollectionView()
        self.getDigitalResources(searcText : searchText)
        self.setTitle()
        self.setRefreshControll()
        // Do any additional setup after loading the view.
    }
    
    
    func setUpCollectionView() {
        let nib = UINib(nibName: "DigitalResourceCategoryCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "DigitalResourceCategoryCell")
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
            
            guard let digitalCategory = result["DigitalCategories"] as? NSArray else{return}
            let digitalCategories = ModelClassManager.sharedManager.createModelArray(data: digitalCategory, modelType: ModelType.TNDigitalResource) as! [TNDigitalResourceCategory]
            
            self.digitalList = cetgories
            self.mergeCategoryAndItem(categories: digitalCategories, items: cetgories)
            
            DispatchQueue.main.async {
                self.removeNoDataLabel()
                self.checkAndStopBounce(count: cetgories.count)
                self.stopLoadingAnimation()
                if self.digitalList.count == 0 {
                    self.collectionView.isHidden = true
                    self.addNoDataFoundLabel()
                }
                else {
                    self.removeNoDataLabel()
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                    self.removeNoDataLabel()

                }
                self.refreshControl.endRefreshing()
            }
        }

    }
    
    func checkAndStopBounce(count:Int){
        
        if count == 0{
            self.collectionView.bounces = false
        }
        
    }
    
    func mergeCategoryAndItem(categories: [TNDigitalResourceCategory], items: [TNDigitalResourceSubList] ) {
        for item in items {
            arrCatgoryAndItem.append(CategoryAndItem(title: item.title, date: item.date, isItem: true))
        }
        for category in categories {
            arrCatgoryAndItem.append(CategoryAndItem(id: category.categoryId,title: category.caetgory,isItem: false))
        }
        
    }
    
    func setRefreshControll(){
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(DigitalResourceSecondListController.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.collectionView.bottomRefreshControl = refreshControl // not required when using UITableV
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        print("pull to Refresh")
        self.pageNumber += 1
        self.getDigitalResources(searcText : searchText)
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


// MARK: -UICollectionViewDataSource, UICollectionViewDelegate-

extension DigitalResourceSecondListController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCatgoryAndItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DigitalResourceCategoryCell", for: indexPath) as? DigitalResourceCategoryCell else { return UICollectionViewCell() }
        let catgoryAndItem = arrCatgoryAndItem[indexPath.row]
        if catgoryAndItem.isItem ?? false {
            cell.labelDate.isHidden = false
            cell.labelDate.text = catgoryAndItem.date
            cell.imageViewFolder.image = UIImage(named: "fileFolder_icon")
        } else {
            cell.labelDate.isHidden = true
            cell.imageViewFolder.image = UIImage(named: "folder_icon")
        }
        cell.labelTitle.text = catgoryAndItem.title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let catgoryAndItem = arrCatgoryAndItem[indexPath.row]
        if catgoryAndItem.isItem ?? false {
            let item = digitalList[indexPath.row]
            self.navigateToDetail(digitalResource: item)
        } else {
            arrCatgoryAndItem.removeAll()
            catId = catgoryAndItem.id ?? ""
            getDigitalResources(searcText: "")
        }

    }
    
}


extension DigitalResourceSecondListController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width - 30
        let widthPerItem = availableWidth / 2
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 10
    }
}
