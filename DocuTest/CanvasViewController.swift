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

class CanvasItem: UIView {

    private weak var guideView: UIView!
    private var token: NSKeyValueObservation!

    init() {
        super.init(frame: .zero)
        let gv = UIView.init()
        gv.translatesAutoresizingMaskIntoConstraints = false
        gv.isUserInteractionEnabled = false
        gv.backgroundColor = .black
        gv.alpha = 0.2
        super.addSubview(gv)
        guideView = gv
        guideView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.blue.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func addSubview(_ view: UIView) {
        insertSubview(view, belowSubview: guideView)
    }

    override func didMoveToSuperview() {
        var sp = superview
        while !(sp is CanvasScrollView) && sp != nil{
            sp = sp?.superview
        }
        if let sp = sp as? CanvasScrollView {
            token = sp.observe(\.zoomScaleDelegate) { [weak self](scrollView: CanvasScrollView, _) in
                guard let wself = self else { return }
                wself.layer.borderWidth = 2.0 * 1.0 / scrollView.zoomScale
                wself.setNeedsDisplay()
            }
        }
     }

}

class CanvasScrollView: UIScrollView {
    @objc dynamic var zoomScaleDelegate: NSNumber?
}

class CanvasViewController: UIViewController {

    var scrollView: UIScrollView!
    var contentView: UIView!
    var canvasView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0

        scrollView = CanvasScrollView.init()
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

//        if navigationController == nil {
//            let inception = DocumentViewController.init()
//            let nav = UINavigationController.init(rootViewController: inception)
//            addChildViewController(nav)
//            addItem(view: nav.view, location: CGPoint.init(x: 250, y: 250), size: CGSize.init(width: 500, height: 500))
//            nav.didMove(toParentViewController: self)
//        }
//
//        if tabBarController == nil {
//            let inception = DocumentViewController.init()
//            let tb = UITabBarController.init()
//            tb.viewControllers = [inception]
//            addChildViewController(tb)
//            addItem(view: tb.view, location: CGPoint.init(x: 250, y: 800), size: CGSize.init(width: 500, height: 500))
//            tb.didMove(toParentViewController: self)
//        }

        let dropInteraction = UIDropInteraction(delegate: self)
        canvasView.addInteraction(dropInteraction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension CanvasViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let csv = scrollView as? CanvasScrollView {
            csv.zoomScaleDelegate = NSNumber.init(value: Float(scrollView.zoomScale))
        }
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

    func addItem(view: UIView, location: CGPoint, size: CGSize?) {
        let canvasItem = CanvasItem.init()
        canvasItem.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        canvasView.addSubview(canvasItem)
        canvasItem.snp.makeConstraints({ (make) in
            if let size = size {
                make.left.equalToSuperview().offset(location.x - size.width/2)
                make.top.equalToSuperview().offset(location.y - size.height/2)
                make.width.equalTo(size.width)
                make.height.equalTo(size.height)
            } else {
                make.left.equalToSuperview().offset(location.x)
                make.top.equalToSuperview().offset(location.y)
            }
        })
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        debugPrint("perform drop")

        guard let item = session.items.first else { fatalError("UHM") }
        let dropLocation = session.location(in: canvasView)

        if let lo = item.localObject as? DraggableControl {
            let (view, size) = lo.createCanvasView()
            addItem(view: view, location: dropLocation, size: size)
            debugPrint("drop internal object")
        } else {
            session.loadObjects(ofClass: UIImage.self){ [weak self](imageItems) in
                guard let wself = self else { return }
                let images = imageItems as! [UIImage]
                for image in images {
                    let iv = UIImageView.init(image: image)
                    let location = CGPoint.init(x: dropLocation.x - image.size.width/2, y: dropLocation.y - image.size.height/2)
                    wself.addItem(view: iv, location: location, size: nil)
                }
                debugPrint("load external object")
            }
        }
    }
}
