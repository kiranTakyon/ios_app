//
//  NoticeBoardTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 21/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

class NoticeBoardTableViewCell: UITableViewCell {
    
    //MARK: -IBOutlet's -
    
    @IBOutlet weak var collectionView: UICollectionView!
    var NoticeBoardItems = [TNNoticeBoardDetail]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "NoticeBoardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoticeBoardCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource -

extension NoticeBoardTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NoticeBoardItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoticeBoardCollectionViewCell", for: indexPath) as? NoticeBoardCollectionViewCell else { return UICollectionViewCell() }
        let noticeBoard = NoticeBoardItems[indexPath.row]
        
        cell.labelTitle.text = noticeBoard.category
        cell.labelDescription.text = noticeBoard.title
        
        return cell
    }
    
    
}

extension NoticeBoardTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 270, height: 90)
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
