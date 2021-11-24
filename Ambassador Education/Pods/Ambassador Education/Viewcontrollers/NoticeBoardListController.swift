//
//  NoticeBoardListController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 11/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class NoticeBoardListController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var listTableVIew: UITableView!
    
    var listValues : [TNNoticeBoardDetail]?
    var tempValue : [TNNoticeBoardDetail]?
    var titleValue : String?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var searchIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewProporties()
        setTitle()
        setUi()
        tempValue = listValues
        // Do any additional setup after loading the view.
    }
    
    func tableViewProporties(){
        self.automaticallyAdjustsScrollViewInsets = false
        self.listTableVIew.estimatedRowHeight = 60
        self.listTableVIew.rowHeight = UITableView.automaticDimension
        self.listTableVIew.tableFooterView = UIView()
    }
    
    
    func setTitle(){
        if let  _ = titleValue{
            self.titleLabel.text = titleValue!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTF.text != ""{
            searchTF.resignFirstResponder()
            getListSearch(text: searchTF.text!)
        }
        return true
    }
    
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = listValues{
            return listValues!.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardListCell", for: indexPath) as! NoticeBoardListCell
        cell.selectionStyle = .none
        let item = listValues?[indexPath.row]
        cell.titleLabel.text = item?.title
        cell.shortDesc.text = item?.shortDesc
        cell.dateLabel.text = item?.date
       
        if let _ = item?.thumbnail{
            cell.titleImageView.loadImageWithUrl(item!.thumbnail!)
        }
        
        return cell

    }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){

            if let item = self.listValues?[indexPath.row]{
            self.navigateToDetails(item:item)
            }
            
        }
    
    func navigateToDetails(item:TNNoticeBoardDetail){
        
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "NoticeboardDetailController") as! NoticeboardDetailController
        vc.detail = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setUi(){
        searchTF.delegate = self
        searchTF.isHidden = true
        titleLabel.isHidden = false
        searchIcon.image = #imageLiteral(resourceName: "Search")
        logOutButton.isUserInteractionEnabled = true
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func searchButtonAction(_ sender: UIButton) {
        if searchIcon.image == #imageLiteral(resourceName: "Search"){
            searchTF.isHidden = false
            setBorderAtBottom()
            titleLabel.isHidden = true
            searchIcon.image = #imageLiteral(resourceName: "Close")
            logOutButton.isUserInteractionEnabled = true
        }
        else if searchIcon.image == #imageLiteral(resourceName: "Close"){
            searchTF.isHidden = true
            searchTF.text = ""
            titleLabel.isHidden = false
            searchIcon.image = #imageLiteral(resourceName: "Search")
            getListSearch(text: "")
        }
    }
    
    func getListSearch(text : String){
        self.startLoadingAnimation()
        listValues?.removeAll()
        if text != ""{
            if let value = tempValue{
                if value.count > 0{
                for each in tempValue!{
                    if (each.title?.lowercased().contains(text.lowercased()))!{
                       listValues?.append(each)
                    }
                }
                    listTableVIew.reloadData()
                }
            }
        }else{
            listValues = tempValue
            listTableVIew.reloadData()
        }
        if listValues?.count == 0{
            SweetAlert().showAlert(kAppName, subTitle: "No items available", style: .warning)//self.removeNoDataLabel()
        }
        else{
        }
        self.stopLoadingAnimation()
    }

    func setBorderAtBottom(){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: searchTF.frame.size.height - width, width:  searchTF.frame.size.width, height: searchTF.frame.size.height)
        
        border.borderWidth = width
        searchTF.layer.addSublayer(border)
        searchTF.layer.masksToBounds = true
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

    class NoticeBoardListCell:UITableViewCell{
        
        @IBOutlet weak var dateLabel: UILabel!
        @IBOutlet weak var shortDesc: UILabel!
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var titleImageView: ImageLoader!
}
