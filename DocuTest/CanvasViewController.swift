//
//  CanvasViewController.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 10/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit
import SnapKit
import MobileCoreServices

class CanvasViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var contentView: UIView!
    var canvasView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0

        scrollView = UIScrollView.init()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.minimumZoomScale = 0.2
        scrollView.maximumZoomScale = 5.0
        contentView = UIView.init()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView);
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(2000)
            make.height.equalTo(2000)
        }
        canvasView = UIView.init()
        contentView.addSubview(canvasView)
        canvasView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(ConstraintInsets.init(top: 20, left: 20, bottom: 20, right: 20))
        }

        canvasView.backgroundColor = .gray
        contentView.backgroundColor = .red
        scrollView.delegate = self

        let label = UILabel.init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 40)
        label.text = "Zio Pinolo"
        canvasView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(50)
            make.top.equalToSuperview().offset(50)
        }

        let dropInteraction = UIDropInteraction(delegate: self)
        canvasView.addInteraction(dropInteraction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}

extension CanvasViewController: UIDropInteractionDelegate {

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        debugPrint("session did update")
        let operation: UIDropOperation
        operation = .copy
        return UIDropProposal(operation: operation)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        debugPrint("perform drop")
        session.loadObjects(ofClass: UIImage.self){ [weak self](imageItems) in
            guard let wself = self else { return }
            let dropLocation = session.location(in: wself.canvasView)
            let images = imageItems as! [UIImage]
            for image in images {
                let iv = UIImageView.init(image: image)
                wself.canvasView.addSubview(iv)
                iv.snp.makeConstraints({ (make) in
                    make.left.equalToSuperview().offset(dropLocation.x - image.size.width/2)
                    make.top.equalToSuperview().offset(dropLocation.y - image.size.height/2)
                })
            }
            debugPrint("load object")
        }
    }
}
