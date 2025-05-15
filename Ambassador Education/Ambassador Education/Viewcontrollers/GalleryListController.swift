//
//  GalleryListController.swift
//  Ambassador Education
//
//  Created by    Kp on 25/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class GalleryListController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var categoryId : String?
    var categoryName:String?
    var imageArray = [String]()
    var paginationNumber = 0
    var searchText = ""
    private var debounceDelay: TimeInterval { 0.3 }
    private var lastQuery = ""
     private var debouncedDelegate: DebouncedTextFieldDelegate!
    
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    var galleryItems = [TNGallery]()
    var loadMoreControl:LoadMoreControl!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        if let  _ = categoryName{
            self.topHeaderView.title = categoryName!
        }
        hideKeyboardWhenTappedAround()
        topHeaderView.delegate = self
        getGalleryImages(searchTextValue: searchText)
        loadMoreControl = LoadMoreControl(scrollView: galleryCollectionView, spacingFromLastCell: 10, indicatorHeight: 60)
        loadMoreControl.delegate = self
        debouncedDelegate = DebouncedTextFieldDelegate(handler: self)
        topHeaderView.searchTextField.delegate = debouncedDelegate 
        self.navigationController?.navigationBar.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    func getGalleryImages(searchTextValue : String){
        
        self.startLoadingAnimation()
        let url = APIUrls().getGallery
        
        //let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        //{"UserId":"98189","SearchText":""}
        dictionary[GalleryCategory.categoryId] = categoryId
        dictionary[GalleryCategory.searchText] = searchTextValue
        dictionary[GalleryCategory.paginationNumber] = paginationNumber + 1
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            guard let categryValues = result["GalleryItems"] as? NSArray else{return}
            
            let galleries = ModelClassManager.sharedManager.createModelArray(data: categryValues, modelType: ModelType.TNGallery) as! [TNGallery]
            self.paginationNumber = result["PaginationNumber"] as? Int ?? 0
            
            
            //filter image by image id
            let newItems = galleries.filter({ (item) -> Bool in
                for i in self.galleryItems {
                    if i.galleryId == item.galleryId{
                        return false
                    }else {
                        return true
                    }
                }
                return true
            })
            if newItems.isEmpty{
                // show toast for no new image
            }
            self.galleryItems.append(contentsOf: newItems)
            
            DispatchQueue.main.async {
                self.loadMoreControl.stop()
                self.removeNoDataLabel()
                self.fetchAllImageUrls(array: galleries)
                self.galleryCollectionView.reloadData()
                self.stopLoadingAnimation()
                if self.galleryItems.count == 0{
                    self.galleryCollectionView.isHidden = true
                    self.addNoDataFoundLabel()
                }
                else{
                    self.removeNoDataLabel()
                    self.galleryCollectionView.isHidden = false
                    self.galleryCollectionView.reloadData()
                    self.removeNoDataLabel()
                }
            }
        }
        
    }
    
    func fetchAllImageUrls(array : [TNGallery]) -> [String]{
        if array.count != 0{
            for each in array{
                if let imageUrl = each.thumbnail as? String{
                    imageArray.append(imageUrl)
                }
            }
        }
        return imageArray
    }
    
    
    func downloadImage(url: URL) -> UIImage{
        var image  = UIImage()
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                image = UIImage(data: data)!
            }
        }
        return image
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.galleryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthValue = (self.view.frame.size.width - 30 )/2 - 3
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
        
        let item = galleryItems[indexPath.row]
        
        //cell.titleLabel.text = item.galleryTitle
        if let url = item.thumbnail{
            cell.imageView.loadImageWithUrl(url)
        }
        if let name = item.galleryTitle{
            if name.contains("&quot") || name.contains(";"){
                let htmlDecode = name.replacingHTMLEntities
                cell.nameLabel.attributedText = htmlDecode?.htmlToAttributedString           }
            else{
                cell.nameLabel.text = name
            }
        }
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        //        cell.myLabel.text = self.items[indexPath.item]
        //        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        
        let item = galleryItems[indexPath.row]
        
        self.navigateToGallery(url: item.media!, title: item.galleryTitle!,indexPath : indexPath.row)
    }
    
    
    func navigateToGallery(url:String,title:String,indexPath: Int){
        let galleryDetail = ImagePreviewController.instantiate(from: .gallery)
        galleryDetail.imageUrl = url
        galleryDetail.pageTitle  = "Gallery"
        galleryDetail.titleValue = title == "" ? self.topHeaderView.title : title
        galleryDetail.imageArr = imageArray
        galleryDetail.position = indexPath
        self.navigationController?.pushViewController(galleryDetail, animated: true)
        
    }
    
    @IBAction func backAction(_ sender: Any) {
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

class GalleryListCell : UICollectionViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: ImageLoader!
    @IBOutlet weak var titleLabel: UILabel!
}

extension GalleryListController: LoadMoreControlDelegate {
    func loadMoreControl(didStartAnimating loadMoreControl: LoadMoreControl) {
        print("didStartAnimating")
        getGalleryImages(searchTextValue: "")
    }
    
    func loadMoreControl(didStopAnimating loadMoreControl: LoadMoreControl) {
        print("didStopAnimating")
    }
}

extension GalleryListController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreControl.didScroll()
    }
}


extension GalleryListController: TopHeaderDelegate {
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
            getGalleryImages(searchTextValue: "")
        }
    }
    
}


extension GalleryListController: DebouncedSearchHandling {
    
    func performSearchIfNeeded(query: String) {
        if query.isEmpty {
            lastQuery = ""
            searchText = lastQuery
            getGalleryImages(searchTextValue: searchText)
            return
        }
        
        guard query != lastQuery else {
            print("Skipping API – same query")
            return
        }
        
        lastQuery = query
        searchText = lastQuery
        getGalleryImages(searchTextValue: searchText)
    }
    
}

