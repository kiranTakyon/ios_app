//
//  DigitalResourcesListController.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class DigitalResourcesListController: UIViewController,UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var categoryList = [TNDigitalResourceCategory]()
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.searchTextField.delegate = self
        setSlideMenuProporties()
        setUpCollectionView()
        getCategoryList()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topHeaderView.searchTextField.text != ""{
            //setClaerButton()
            searchText = topHeaderView.searchTextField.text!
            topHeaderView.searchTextField.resignFirstResponder()
            self.getCategoryList()
        }
        return true
    }
    
    func setSlideMenuProporties() {
        if let revealVC = revealViewController() {
            topHeaderView.setMenuOnLeftButton(reveal: revealVC)
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
   
    
    func setUpCollectionView() {
        let nib = UINib(nibName: "DigitalResourceCategoryCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "DigitalResourceCategoryCell")
    }
    
    func getCategoryList() {
        self.startLoadingAnimation()
        
        let url = APIUrls().getDigitalResource
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = searchText
        dictionary[GalleryCategory.module] = 20

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            guard let categryValues = result["DigitalCategories"] as? NSArray else { return }
            guard let title = result["DigitalResourcesLabel"] as? String else { return }

            DispatchQueue.main.async {
                self.topHeaderView.title = title
            }

            let categories = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNDigitalResource) as! [TNDigitalResourceCategory]
            
            DispatchQueue.main.async {
                self.categoryList.removeAll() // ✅ Clear previous data here
                self.categoryList = categories
                self.collectionView.reloadData()
                self.stopLoadingAnimation()

                if self.categoryList.isEmpty {
                    self.addNoDataFoundLabel()
                } else {
                    self.removeNoDataLabel()
                }
            }
        }
    }

    
    func navigateTodigitalResourceDetail(category:TNDigitalResourceCategory) {
        let digitalVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceSecondListController") as! DigitalResourceSecondListController
        digitalVc.catId = category.categoryId!
        digitalVc.titleValue = category.caetgory
        self.navigationController?.pushViewController(digitalVc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

// MARK: -UICollectionViewDataSource, UICollectionViewDelegate-

extension DigitalResourcesListController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DigitalResourceCategoryCell", for: indexPath) as? DigitalResourceCategoryCell else { return UICollectionViewCell() }
        let category = categoryList[indexPath.row]
        if let title = category.caetgory {
            cell.labelTitle.text = title
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cat = categoryList[indexPath.row]
       self.navigateTodigitalResourceDetail(category: cat)
    }
    
}


extension DigitalResourcesListController: UICollectionViewDelegateFlowLayout {
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

extension DigitalResourcesListController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
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
    
    func searchButtonClicked(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            topHeaderView.titleLabel.isHidden = true
            topHeaderView.searchTextField.isHidden = false
            button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
            topHeaderView.shouldShowSecondRightButton(false)
        } else {
            topHeaderView.titleLabel.isHidden = false
            topHeaderView.searchTextField.isHidden = true
            button.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
            topHeaderView.searchTextField.text = ""
            searchText = "" // <-- Reset the searchText variable
            topHeaderView.shouldShowSecondRightButton(true)
            getCategoryList()

        }
    }
    
}
