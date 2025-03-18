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

    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewProporties()
        setTitle()
        tempValue = listValues
        topHeaderView.delegate = self
        topHeaderView.searchTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func tableViewProporties(){
        self.automaticallyAdjustsScrollViewInsets = false
        self.listTableVIew.estimatedRowHeight = 60
        self.listTableVIew.rowHeight = UITableView.automaticDimension
        self.listTableVIew.tableFooterView = UIView()
        navigationController?.navigationBar.isHidden = false
    }
    
    
    func setTitle(){
        if let  _ = titleValue{
            self.topHeaderView.title = titleValue!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topHeaderView.searchTextField.text != ""{
            topHeaderView.searchTextField.resignFirstResponder()
            getListSearch(text: topHeaderView.searchTextField.text!)
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
        
        let vc = NoticeboardDetailController.instantiate(from: .noticeboard)
        vc.NbID = item.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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


extension NoticeBoardListController: TopHeaderDelegate {
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
            getListSearch(text: "")
        }
    }
    
}
