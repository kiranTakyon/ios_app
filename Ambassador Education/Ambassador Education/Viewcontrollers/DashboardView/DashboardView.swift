//
//  DashboardView.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 27/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit


class DashboardView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notificationList = [TNotification]()
    var moduleList = [TModule]()
    var NoticeBoardItems = [TNNoticeBoardDetail]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UINib(nibName: "ModuleTableViewCell", bundle: nil), forCellReuseIdentifier: "ModuleTableViewCell")
        tableView.register(UINib(nibName: "NoticeBoardTableViewCell", bundle: nil), forCellReuseIdentifier: "NoticeBoardTableViewCell")
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


//MARK: - TableView Delegates and Datasources -

extension DashboardView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleTableViewCell", for: indexPath) as? ModuleTableViewCell else { return UITableViewCell() }
            cell.moduleList = moduleList
            cell.collectionView.reloadData()
            return cell
            
        } else if indexPath.section == 2 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardTableViewCell", for: indexPath) as? NoticeBoardTableViewCell else { return UITableViewCell() }
            cell.NoticeBoardItems = NoticeBoardItems
            cell.collectionView.reloadData()
            return cell
            
        } else {
            
            // create a new cell if needed or reuse an old one
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else { return UITableViewCell()}
            cell.notificationList = notificationList
            cell.tableView.reloadData()
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        } else  if indexPath.section == 2 {
            return 150
        } else {
            return 330
        }
    }
    
}
