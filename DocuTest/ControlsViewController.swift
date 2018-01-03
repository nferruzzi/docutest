//
//  ControlsViewController.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 03/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit
import SnapKit

class RectCollectionViewCell: UICollectionViewCell {

    open var icon: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .lightGray
    }

    func build() {
        let img = UIImage.animatedImageNamed("MKButton_iOS7_", duration: 1.0)
        icon = UIImageView.init(image: img)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        contentView.addSubview(icon)
        icon.snp.makeConstraints { (make) -> Void in
            let w = (200.0/2.0)-6
            make.width.equalTo(w)
            make.height.equalTo(w)
            make.edges.equalToSuperview().inset(1)
        }
    }

    override func prepareForReuse() {
        contentView.subviews.forEach() { $0.removeFromSuperview() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ControlsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate {

    lazy var collection: UICollectionView = {
        let fl = UICollectionViewFlowLayout.init()
        fl.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        fl.minimumLineSpacing = 2.0
        fl.minimumInteritemSpacing = 2.0
        fl.sectionInset = UIEdgeInsets.init(top: 0.0, left: 2.0, bottom: 0.0, right: 2.0)
        var cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: fl)
        cv.dataSource = self
        cv.delegate = self
        cv.dragDelegate = self
        cv.dragInteractionEnabled = true
        cv.register(RectCollectionViewCell.self, forCellWithReuseIdentifier: "rect")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collection)
        collection.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rect", for: indexPath)
        if let cell = cell as? RectCollectionViewCell {
            cell.build()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let ponso = UIImage.init(named: "MKButton_drag")!
        let itemProvider = NSItemProvider(object: ponso)
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        dragItem.localObject = ponso
        let preview = UIImageView.init(image: UIImage.init(named: "MKButton_drag")!)
        let previewParameters = UIDragPreview.init(view: preview)
        dragItem.previewProvider = { () -> UIDragPreview? in
            return previewParameters
        }
        return [dragItem]
    }

}
