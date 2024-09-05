//
//  UpComingEventViewController.swift
//  Ambassador Education
//
//  Created by Mayur Shrivas on 05/09/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

protocol UpComingEventViewControllerDelegate: AnyObject {
    func didTapOnIconButton()
}

class UpComingEventViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var upcomingEvents = [TUpcomingEvent]()

    weak var delegate: UpComingEventViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "UpcomingEventCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "UpcomingEventCollectionViewCell")
    }

    @IBAction func didTapOnIconButton(_ sender: UIButton) {
        delegate?.didTapOnIconButton()
    }

}


extension UpComingEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingEvents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingEventCollectionViewCell", for: indexPath) as? UpcomingEventCollectionViewCell else { return UICollectionViewCell() }
        let event = upcomingEvents[indexPath.item]
        cell.setupCell(event: event)

        return cell
    }

}

extension UpComingEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height: CGFloat = 200
        return CGSize(width: height - 40, height: height)
    }
}
