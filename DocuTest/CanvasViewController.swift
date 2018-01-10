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
        // avoid complications
        if session.items.count != 1 { return false }

        // just 1 for now
        guard let item = session.items.first else { return false }

        // control from the collection view
        if let _ = item.localObject as? DraggableControl {
            return true
        }

        // incoming external image
        if item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
            return true
        }

        return false
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        debugPrint("session did update")
        let operation: UIDropOperation
        operation = .copy
        return UIDropProposal(operation: operation)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        debugPrint("perform drop")

        guard let item = session.items.first else { fatalError("UHM") }
        let dropLocation = session.location(in: canvasView)

        if let lo = item.localObject as? DraggableControl {
            let (view, size) = lo.createCanvasView()
            canvasView.addSubview(view)

            view.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(dropLocation.x - view.frame.size.width/2)
                make.top.equalToSuperview().offset(dropLocation.y - view.frame.size.height/2)
                if let size = size {
                    make.width.equalTo(size.width)
                    make.height.equalTo(size.height)
                }
            })

            debugPrint("drop internal object")
        } else {
            session.loadObjects(ofClass: UIImage.self){ [weak self](imageItems) in
                guard let wself = self else { return }
                let images = imageItems as! [UIImage]
                for image in images {
                    let iv = UIImageView.init(image: image)
                    wself.canvasView.addSubview(iv)
                    iv.snp.makeConstraints({ (make) in
                        make.left.equalToSuperview().offset(dropLocation.x - image.size.width/2)
                        make.top.equalToSuperview().offset(dropLocation.y - image.size.height/2)
                    })
                }
                debugPrint("load external object")
            }
        }
    }
}
