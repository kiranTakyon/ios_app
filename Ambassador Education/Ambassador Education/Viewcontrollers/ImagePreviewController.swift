//
//  ImagePreviewController.swift
//  Ambassador Education
//
//  Created by    Kp on 26/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class ImagePreviewController: UIViewController,UIScrollViewDelegate {
    
    
    var imageUrl : String?
    var titleValue : String?
    var imageArr = [String]()
    var position = Int()
    var pageTitle : String?
    
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var imageView: ImageLoader!
    @IBOutlet weak var scrollViewImage: UIScrollView!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setScrollView()
        setData()
        print(imageArr)
        topHeaderView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func setScrollView(){
        scrollViewImage.minimumZoomScale = 1.0
        scrollViewImage.maximumZoomScale = 10.0
        scrollViewImage.flashScrollIndicators()
        scrollViewImage.delegate = self
        imageView.isUserInteractionEnabled = true
    }
    
    
    func setStatesToUIElements(isHide : Bool){
        rightArrow.isHidden = isHide
        leftArrow.isHidden = isHide
        leftButton.isHidden = isHide
        rightButton.isHidden = isHide
    }
    func setData(){
        if pageTitle != "Gallery"{
            topHeaderView.title = pageTitle ?? ""
        }
        else{
            topHeaderView.title = ""
        }
        if pageTitle == ""{
            setStatesToUIElements(isHide: true)
        }else{
            setStatesToUIElements(isHide: false)
        }
        if let imageArrays = imageArr as? [String]{
            
            if imageArrays.count != 0{
                self.imageView.loadImageWithUrl(imageArrays[position])
            }
        }
        
        if let value = titleValue{
            if value.contains("&quot") || value.contains(";"){
                let htmlDecode = value.replacingHTMLEntities
                self.topHeaderView.titleLabel.attributedText = htmlDecode?.htmlToAttributedString           }
            else{
                self.topHeaderView.title = value
            }
        }
        
        
    }
    
    //    //MARK:- Scrollview delegates
    //    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    //        return self.imageView
    //    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
   
    
    @IBAction func backButtonAction(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        //if self.pageTitle == "NOT_TEST"{
        if self.navigationController?.viewControllers.count == 1 {
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    @IBAction func leftButtonScrollAction(_ sender: UIButton) {
        if let imageArrays = imageArr as? [String]{
            
            if position >= 0{
                if position != 0{
                    position -= 1
                    self.imageView.loadImageWithUrl(imageArrays[position])
                    
                }
                else{
                    SweetAlert().showAlert(kAppName, subTitle: "This is the last image", style: .warning)
                }
            }
        }
        
    }
    
    @IBAction func rightButtonScrollAction(_ sender: UIButton) {
        if let imageArrays = imageArr as? [String]{
            
            if position < imageArr.count{
                if position != imageArrays.count - 1{
                    position += 1
                    self.imageView.loadImageWithUrl(imageArrays[position])
                    
                }
                else{
                    SweetAlert().showAlert(kAppName, subTitle: "This is the last image", style: .warning)
                }
                
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

extension ImagePreviewController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        guard let imagestring = imageUrl else  {return}
        
        if let url = URL(string: imagestring),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.showAlertController("Success", message: "Image saved to photos", cancelButton: "Done", isTextFiled: false, otherButtons: [], handler: nil)
        }    }
    
}
