//
//  ControlsViewController.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 03/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit
import SnapKit

protocol DraggableControl {
    func createCanvasView() -> UIView
    func icon() -> UIImageView
    func dragItems() -> [UIDragItem]
}

class DraggabeViewControl<T:UIView>: DraggableControl {

    func iconName() -> String {
        fatalError("iconName() has not been implemented")
    }

    func dragItemName() -> String {
        fatalError("dragItemName() has not been implemented")
    }

    func configure(view: T) {
    }

    func createCanvasView() -> UIView {
        let instance = T.init()
        instance.translatesAutoresizingMaskIntoConstraints = false
        return instance
    }

    func icon() -> UIImageView {
        let img = UIImage.animatedImageNamed(iconName(), duration: 1.0)
        let icon = UIImageView.init(image: img)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        return icon
    }

    func dragItems() -> [UIDragItem] {
        let img = UIImage.init(named: dragItemName())!

        let itemProvider = NSItemProvider(object: img)
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        dragItem.localObject = self

        let preview = UIImageView.init(image: img)
        let previewParameters = UIDragPreview.init(view: preview)

        dragItem.previewProvider = { () -> UIDragPreview? in
            return previewParameters
        }
        return [dragItem]
    }
}

class ControlImageView: DraggabeViewControl<UIImageView> {

    var image:UIImage?

    override func iconName() -> String {
        return "MKImageView_iOS7_"
    }

    override func dragItemName() -> String {
        return "MKImageView_drag"
    }

    override func configure(view: UIImageView) {
        view.image = image
    }

}

class ControlButtonView: DraggabeViewControl<UIButton> {

    override func iconName() -> String {
        return "MKButton_iOS7_"
    }

    override func dragItemName() -> String {
        return "MKButton_drag"
    }

    override func configure(view: UIButton) {
        view.setTitle("Button", for: .normal)
    }

}

class ControlLabelView: DraggabeViewControl<UILabel> {

    override func iconName() -> String {
        return "MKLabel_iOS7_"
    }

    override func dragItemName() -> String {
        return "MKLabel_drag"
    }

    override func configure(view: UILabel) {
        view.text = "Label"
    }

}

class RectCollectionViewCell: UICollectionViewCell {

    var icon: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .lightGray
    }

    func build(control: DraggableControl) {
        if icon != nil { return }
        icon = control.icon()
        if let icon = icon {
            contentView.addSubview(icon)
            icon.snp.makeConstraints { (make) -> Void in
                let w = (200.0/2.0)-6
                make.width.equalTo(w)
                make.height.equalTo(w)
                make.edges.equalToSuperview().inset(1)
            }
        }
    }

    override func prepareForReuse() {
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
        cv.backgroundColor = .clear
        cv.register(RectCollectionViewCell.self, forCellWithReuseIdentifier: "rect")
        return cv
    }()

    lazy var datasource: [DraggableControl] = {
        let ds: [DraggableControl] = [
            ControlImageView.init(),
            ControlButtonView.init(),
            ControlLabelView.init()
        ]
        return ds
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collection)
        collection.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rect", for: indexPath)
        if let cell = cell as? RectCollectionViewCell {
            cell.build(control: datasource[indexPath.row])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return datasource[indexPath.row].dragItems()
    }

}
