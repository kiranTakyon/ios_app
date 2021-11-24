//
//  GalleryCategoryListController.swift
//  Ambassador Education
//
//  Created by    Kp on 25/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class GalleryCategoryListController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var categoryTable: UICollectionView!
    var categoryList = [TNGalleryCategory]()
    var gallaryModel : GalleryItems?
    
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCategoryList()
        self.setSlideMenuProporties()
        // Do any additional setup after loading the view.
    }
    
    func setSlideMenuProporties(){
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControl.Event.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
   


    
    
    func getCategoryList(){
        
        self.startLoadingAnimation()
        
        let url = APIUrls().getGalleryCategory
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        //{"UserId":"98189","SearchText":""}
        dictionary[UserIdKey().id] = userId
        dictionary[GalleryCategory.searchText] = ""
     //   dictionary[GalleryCategory.paginationNumber] = 1

        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            self.gallaryModel = GalleryItems(values: result)
            DispatchQueue.main.async {
                self.headLabel.text = result["HeadLabel"] as? String
            }
            
            guard let categryValues = result["Categories"] as? NSArray else{return}
            
            let cetgories = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNGroupCategory) as! [TNGalleryCategory]
            
            self.categoryList = cetgories
            
             DispatchQueue.main.async {
                self.categoryTable.reloadData()
                self.stopLoadingAnimation()
                if self.categoryList.count == 0{
                    self.addNoDataFoundLabel()
                }
//                self.headLabel.text = self.gallaryModel?.headLabel.safeValue
            }
        }
        
    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthValue = self.view.frame.size.width/2 - 3
        //let heightValue = CGFloat(90.00)
        
        return CGSize(width: widthValue, height: widthValue)
    }
    
    //    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    //    {
    //        var commonRect : CGSize?
    //        if collectionView.tag == 1{
    //            let widthValue = self.view.frame.size.width
    //            let heightValue = CGFloat(144.00)
    //            let rect = CGSizeMake(widthValue,heightValue)
    //            commonRect = rect
    //        }else{
    //            let widthValue = self.view.frame.size.width/3 - 3
    //            let heightValue = CGFloat(90.00)
    //            let rect = CGSizeMake(widthValue,heightValue)
    //            commonRect = rect
    //
    //        }
    //        return commonRect!
    //    }
    
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryListCell", for: indexPath as IndexPath) as! GalleryListCell
        
        let item = categoryList[indexPath.row]
        
        
        if let name = item.category{
            if name.contains("&quot") || name.contains(";"){
                let htmlDecode = name.replacingHTMLEntities
                cell.titleLabel.attributedText = htmlDecode?.htmlToAttributedString           }
            else{
                cell.titleLabel.text = name
            }
        }
        

        
        if let url = item.thumbnail{
            cell.imageView.loadImageWithUrl(url)
        }

        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        
        let item = categoryList[indexPath.row]
        
        self.navigateToGallery(cat: item)//navigateToGallery(url: item.media!, title: item.galleryTitle!)
    }
    

    
  /*  //MARK:- TableView Delegates and Datasources
    
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
        
        if let catId = category.categoryId{
            cell.tag = catId
        }
        
        cell.selectionStyle = .none
        
        // create a new cell if needed or reuse an old one
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        guard let cell = tableView.cellForRow(at: indexPath) as? GalleryCategoryList else { return }
        
        self.navigateToGallery(catId: cell.tag)
        
    } */
    
    func navigateToGallery(cat:TNGalleryCategory){
        let galleryListVc = mainStoryBoard.instantiateViewController(withIdentifier: "GalleryListController") as! GalleryListController
        galleryListVc.categoryId = cat.categoryId
        galleryListVc.categoryName = cat.category

        self.navigationController?.pushViewController(galleryListVc, animated: true)

    }
    @IBAction func logOutAction(_ sender: UIButton) {
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

class GalleryCategoryList : UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImageLoder: ImageLoader!
    
    
}
