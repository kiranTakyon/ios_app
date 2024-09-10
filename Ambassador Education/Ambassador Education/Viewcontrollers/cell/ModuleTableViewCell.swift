//
//  ModuleTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 21/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

class ModuleTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlet -

    @IBOutlet weak var collectionView: UICollectionView!
    
    var moduleList = [TModule]()
    var moduleBgColor = ["FF6666","99CB98","91D0DF","F1BB4E","DDAF84","669ACC"]

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "ModuleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ModuleCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = .clear // Clear any existing color before reuse
    }
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource -

extension ModuleTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moduleList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModuleCollectionViewCell", for: indexPath) as? ModuleCollectionViewCell else { return UICollectionViewCell() }
        let module = moduleList[indexPath.row]
        cell.labelModule.text = module.module
        cell.labelDataCount.text = module.data_count != nil ? String(module.data_count!) : nil
        let index = indexPath.item % moduleBgColor.count
        let color = moduleBgColor[index]
        cell.cellBackgroundView.backgroundColor = UIColor(named: color)
        switch module.module {
            
        case "Notice Board":
            cell.moduleImageView.image = UIImage(named: "module_noticeBoard")
            break
        case "Articles":
            break
        case "Digital Resources":
            break
        case "Gallery":
            cell.moduleImageView.image = UIImage(named: "module_gallery")
            break
        case "Communicate":
            cell.moduleImageView.image = UIImage(named: "module_message")
            break
        case "Weekly Plan":
            cell.moduleImageView.image = UIImage(named: "module_weekly")
            break
        case "Online Payment":
            break
        case .none:
            break
        case .some(_):
            break
        }
        return cell
    }
    
    
}

extension ModuleTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 10
    }
}
