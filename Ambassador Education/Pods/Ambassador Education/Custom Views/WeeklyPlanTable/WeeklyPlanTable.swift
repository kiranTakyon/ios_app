//
//  StatotionIfnoTableView.swift
//  TrainAid
//
//  Created by Sreeshaj  on 04/12/17.
//  Copyright © 2017 InApp. All rights reserved.
//

import UIKit

class WeeklyPlanTable: UIView,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var HourTableHeight: NSLayoutConstraint!

    @IBOutlet var containerView: UIView!
    
 
    var delegate : TaykonProtocol?
    
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var detailTable: UITableView!
    @IBOutlet weak var noDataAlertLabel: UILabel!
    
    var dataArray : [WeeklyPlanList] = [WeeklyPlanList](){
        
        didSet{
            self.setDataArray()
        }
    }
    
    
    
    var isHour : Bool = false
    
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViewForXib()
        self.setTableViewProporties()
        self.setTableViewCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewForXib()
        
    }
    func loadFromNib() ->UIView{
        let bundle = Bundle(for: self.classForCoder)//NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "WeeklyPlanTable", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        //        view.backgroundColor = UIColor.red
        return view
    }
    
    func setupViewForXib(){
        containerView = loadFromNib()
        containerView.frame = bounds
        containerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(containerView)
        
    }
    
    func setTableViewProporties(){
        
        self.detailTable.delegate = self
        self.detailTable.dataSource = self
        
    
        
        self.detailTable.estimatedRowHeight = 60.00
        self.detailTable.rowHeight = UITableView.automaticDimension
        
        
       

    }
    
    func setTableViewCell(){
        let listNib = UINib(nibName: "WeeklyPlanCell", bundle: nil)
        self.detailTable.register(listNib, forCellReuseIdentifier: "WeeklyPlanCell")
    }
    

 
   
    
    func setDataArray(){
        
        
//       let array = self.DataArray.sorted({ $0.sortOrder > $1.sortOrder })
        
        
        if dataArray.count == 0{
            self.noDataLabel.isHidden = false
            detailTable.isHidden = true

        }else{
            self.noDataLabel.isHidden = true
            detailTable.isHidden = false
            self.detailTable.reloadData()
        }
        
        isHour = false
      
      
    }
    
 
    //MARK:- UITableVIew delegate and Data sources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if dataArray.count != 0{
            return self.dataArray.count

        }
         else{
            return 0
        }

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyPlanCell", for: indexPath) as! WeeklyPlanCell
        
        cell.attachmntButtn.setTitle("", for: .normal)

        let weeklyplan = self.dataArray[indexPath.row]
        if let count = weeklyplan.attachIconCount as? Int{
            if count > 0{
               cell.attachmntButtn.isHidden = false

                cell.attachmntButtnHeight.constant = 30.0
            }else{
                cell.attachmntButtn.isHidden = true
                cell.attachmntButtnHeight.constant = 0.0

            }
        }
        if let topic = weeklyplan.topic{
            cell.firstLabel.text = topic
        }
        
        if let desc = weeklyplan.description{
            let htmlDecode = desc.replacingHTMLEntities
              cell.secondLabel.attributedText = htmlDecode?.htmlToAttributedString
        }
        
        if let date = weeklyplan.date{
            cell.thirdLabel.text = date
        }
        
        
        cell.selectionStyle = .none
        
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let weekyPlan = self.dataArray[indexPath.row]
        
        delegate?.getBackToTableView(value: weekyPlan,tagValueInt : -1)
    }
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
