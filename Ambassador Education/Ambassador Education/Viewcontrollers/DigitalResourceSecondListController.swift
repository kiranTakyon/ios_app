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

class DigitalResourceSecondListController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var catId = ""
    var searchText = ""
    @IBOutlet weak var topHeaderView: TopHeaderView!
    var titleValue : String?
    var digitalList = [TNDigitalResourceSubList]()
    var categoryList = [TNDigitalResourceCategory]()
    var pageNumber = 1
    let refreshControl = UIRefreshControl()
    var arrCatgoryAndItem: [CategoryAndItem] = []
    var shouldEnableLoadMore: Bool = true
    var isPresent: Bool = false
    private var lastQuery = ""
    private var debouncedDelegate: DebouncedTextFieldDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        debouncedDelegate = DebouncedTextFieldDelegate(handler: self)
        topHeaderView.searchTextField.delegate = debouncedDelegate
        setUpCollectionView()
        getDigitalResources(searcText : searchText)
        setTitle()
    }
    
    func setUpCollectionView() {
        let nib = UINib(nibName: "DigitalResourceCategoryCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "DigitalResourceCategoryCell")
        setRefreshControll()
    }
    
    func setTitle() {
        if let title = titleValue {
            topHeaderView.title = title
        }
    }
    
    @objc func clearTextField() {
       getDigitalResources(searcText: "")
    }
    
    func getDigitalResources(searcText : String) {
        
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
            self.categoryList = digitalCategories
            self.digitalList = cetgories
            self.mergeCategoryAndItem(categories: digitalCategories, items: cetgories)
            if let totalAvailablePages = result["PaginationTotalNumber"] as? Int {
                self.shouldEnableLoadMore = totalAvailablePages != self.pageNumber
            }
            
            DispatchQueue.main.async {
                self.removeNoDataLabel()
                self.checkAndStopBounce()
                self.stopLoadingAnimation()
                if self.arrCatgoryAndItem.count == 0 {
                    self.collectionView.isHidden = true
                    self.addNoDataFoundLabel()
                } else {
                    self.removeNoDataLabel()
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                    self.removeNoDataLabel()
                }
                self.refreshControl.endRefreshing()
            }
        }

    }
    
    func checkAndStopBounce() {
        collectionView.bounces = shouldEnableLoadMore
    }
    
    func mergeCategoryAndItem(categories: [TNDigitalResourceCategory], items: [TNDigitalResourceSubList] ) {
        for item in items {
            arrCatgoryAndItem.append(CategoryAndItem(title: item.title, date: item.date, isItem: true))
        }
        for category in categories {
            arrCatgoryAndItem.append(CategoryAndItem(id: category.categoryId, title: category.caetgory, isItem: false))
        }
    }
    
    func setRefreshControll() {
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(DigitalResourceSecondListController.loadMore(sender:)), for: UIControl.Event.valueChanged)
        collectionView.bottomRefreshControl = refreshControl // not required when using UITableV
    }
    
    @objc func loadMore(sender: AnyObject) {
        pageNumber += 1
        getDigitalResources(searcText : searchText)
    }

    func navigateToDetail(digitalResource:TNDigitalResourceSubList) {
        let detailVc = DigitalResourceDetailController.instantiate(from: .digitalResource)
        detailVc.digitalResource = digitalResource
        navigationController?.pushViewController(detailVc, animated: true)
    }
        
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
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
            navigateToDetail(digitalResource: item)
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
        let height = isPresent ? widthPerItem + 15 : widthPerItem
        return CGSize(width: widthPerItem, height: height)
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

extension DigitalResourceSecondListController: DebouncedSearchHandling {
    
    func performSearchIfNeeded(query: String) {
        if query.isEmpty {
            lastQuery = ""
            searchText = lastQuery
            getDigitalResources(searcText: searchText)
            return
        }
        
        guard query != lastQuery else {
            print("Skipping API – same query")
            return
        }
        
        lastQuery = query
        searchText = lastQuery
        getDigitalResources(searcText: searchText)
    }
    
}
