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
    var prevcatId = ""
    var searchText = ""
    @IBOutlet weak var topHeaderView: TopHeaderView!
    var titleValue : String?
    var digitalList = [TNDigitalResourceSubList]()
    var categoryList = [TNDigitalResourceCategory]()
    var pageNumber = 1
    let refreshControl = UIRefreshControl()
    var arrCatgoryAndItem: [CategoryAndItem] = []
    var shouldEnableLoadMore: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.searchTextField.delegate = self
        setUpCollectionView()
        getDigitalResources(searcText : searchText)
        setTitle()
    }
    
    func setUpCollectionView() {
        let nib = UINib(nibName: "DigitalResourceCategoryCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "DigitalResourceCategoryCell")
        setRefreshControll()
    }
    
    func setTitle(paginationText: String? = nil) {
        if let title = titleValue {
            if let paginationText = paginationText {
                topHeaderView.title = "\(title) - \(paginationText)"
            } else {
                topHeaderView.title = title
            }
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = topHeaderView.searchTextField.text, !text.isEmpty {
            topHeaderView.searchTextField.resignFirstResponder()
            getDigitalResources(searcText: text)
        }
        return true
    }

    
    @objc func clearTextField() {
       getDigitalResources(searcText: "")
    }
    
    func getDigitalResources(searcText: String) {
        self.startLoadingAnimation()

        let url = APIUrls().getDigitalResourceDetails
        let userId = UserDefaultsManager.manager.getUserId()

        var dictionary = [String: Any]()
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = searcText

        if searchText != searcText || prevcatId != catId {
            searchText = searcText
            prevcatId = catId
            pageNumber = 1
            arrCatgoryAndItem.removeAll()
            digitalList.removeAll()
            categoryList.removeAll()
        }

        dictionary[GalleryCategory.paginationNumber] = pageNumber
        dictionary["CategoryId"] = Int(catId)

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in

            guard let categryValues = result["CategoryItems"] as? NSArray else { return }
            let cetgories = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNDigitalResourceSubList) as! [TNDigitalResourceSubList]

            guard let digitalCategory = result["DigitalCategories"] as? NSArray else { return }
            let digitalCategories = ModelClassManager.sharedManager.createModelArray(data: digitalCategory, modelType: ModelType.TNDigitalResource) as! [TNDigitalResourceCategory]

            // ✅ Append to arrays
            self.digitalList.append(contentsOf: cetgories)
            self.categoryList.append(contentsOf: digitalCategories)

            // ✅ Merge results
            self.mergeCategoryAndItem(categories: digitalCategories, items: cetgories)

            if let totalAvailablePages = result["PaginationTotalNumber"] as? Int {
                self.shouldEnableLoadMore = totalAvailablePages != self.pageNumber
            }

            DispatchQueue.main.async {
                self.checkAndStopBounce()
                self.stopLoadingAnimation()
                self.collectionView.isHidden = self.arrCatgoryAndItem.isEmpty
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()

                // Show pagination only if not on last page
                if let totalPages = result["PaginationTotalNumber"] as? Int,
                   let currentPage = result["PaginationNumber"] as? Int {
                    
                    if currentPage < totalPages {
                        self.topHeaderView.title = "Page \(currentPage) / \(totalPages)"
                    } else {
                        self.setTitle() // fallback to original title
                    }
                }
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
        let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceDetailController") as! DigitalResourceDetailController
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

        // Always dismiss keyboard
        topHeaderView.searchTextField.resignFirstResponder()

        if button.isSelected {
            // Show search mode
            topHeaderView.titleLabel.isHidden = true
            topHeaderView.searchTextField.isHidden = false
            button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        } else {
            // Hide search and reset
            topHeaderView.titleLabel.isHidden = false
            topHeaderView.searchTextField.isHidden = true
            topHeaderView.searchTextField.text = ""
            searchText = ""
            arrCatgoryAndItem.removeAll()
            collectionView.reloadData()
            getDigitalResources(searcText: "")
            button.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
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
        print("here " , indexPath.row)
        print("here1", self.pageNumber)
        if catgoryAndItem.isItem ?? false {
            let item = digitalList[indexPath.row-((self.pageNumber-1)*12)]
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
