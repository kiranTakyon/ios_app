//
//  BusMessageLandViewController.swift
//  Takyon360Buzz
//
//  Created by Veena on 18/04/18.
//  Copyright © 2018 Sreeshaj Kp. All rights reserved.
//

import UIKit

import MXSegmentedPager
import BIZPopupView


var staffId = String()
var tripId = String()
var branchId = String()

class BusMessageLandViewController: PagerController,PagerDataSource ,BussProtocol{
        
    @IBOutlet weak var headLabel: UILabel!
    var headers = [String]()
    var popUpViewVc : BIZPopupViewController?
    
    
    var headerText : String = ""

        override func viewDidLoad() {
            super.viewDidLoad()
            self.dataSource = self
            self.customizeTab()
            setUpPager(titles: headers)
            headLabel.text =  headerText

            // Do any additional setup after loading the view.
        }


        func customizeTab() {
            indicatorColor = UIColor.white
            tabsViewBackgroundColor = UIColor.appOrangeColor()
            contentViewBackgroundColor = UIColor.gray.withAlphaComponent(0.32)
            startFromSecondTab = false
            centerCurrentTab = true
            fixFormerTabsPositions = true
            tabLocation = PagerTabLocation.top
            tabHeight = 55
            tabOffset = 36
            tabWidth = self.view.frame.size.width/3
            fixFormerTabsPositions = false
            fixLaterTabsPosition = false
            animation = PagerAnimation.during
            selectedTabTextColor = .white
        }
        
    func setUpPager(titles: [String]){
            
            let inBoxVC = mainStoryBoard.instantiateViewController(withIdentifier: "BusMessageViewController") as! BusMessageViewController
            inBoxVC.delegate = self
            inBoxVC.type = CommunicationType.inbox
            
            let sentBoxVC = mainStoryBoard.instantiateViewController(withIdentifier: "BusMessageViewController") as! BusMessageViewController
            sentBoxVC.delegate = self
            sentBoxVC.type = CommunicationType.sent

            
            let mapVC = mainStoryBoard.instantiateViewController(withIdentifier: "MapController") as! MapController
            mapVC.delegate = self
            
            
            self.setupPager(tabNames: titles, tabControllers: [mapVC,inBoxVC,sentBoxVC])
        }
        
        
    func showPopUpView(){
        let popvc = mainStoryBoard.instantiateViewController(withIdentifier: "SendMessageViewController") as! SendMessageViewController
        popvc.delegate = self
        popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width:300,height: CGFloat(250)))
        self.present(popUpViewVc!, animated: true, completion: nil)
        
    }
    
    
    
    func getBackToParentView(value: Any?) {
           let valueReal = value as? String
            showPopUpView()
    
    }
    
        @IBAction func logoutButtonAction(_ sender: UIButton) {
            SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
                }
                else {
                    showLoginPage()
                }
            }
            
        }
        
    @IBAction func backButtonAction(_ sender: UIButton) {
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

