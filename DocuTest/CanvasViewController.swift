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

public enum CanvasGuideViewGesture {
    case none
    case drag
    case resize
}

class CanvasGuideView: UIView {
    // DO NOT SET THE BACKGROUNDCOLOR
    var borderColor = UIColor.blue
    var borderWidth: CGFloat = 2.0
    var controlSize: CGFloat = 15.0
    private var moveSize: CGSize!
    private var movePoint: CGPoint!
    private var gesture: CanvasGuideViewGesture = .none
    private lazy var controlLayers = {
        [CALayer.init(), CALayer.init(), CALayer.init()]
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        clipsToBounds = false
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        for cl in controlLayers {
            cl.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
            cl.bounds = CGRect.init(x: 0, y: 0, width: controlSize, height: controlSize)
            cl.backgroundColor = UIColor.purple.cgColor
            cl.needsDisplayOnBoundsChange = true
            layer.addSublayer(cl)
        }

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(CanvasGuideView.wasDragged(_:)))
        addGestureRecognizer(gesture)
        gesture.delegate = self
    }

    override func layoutSublayers(of layer: CALayer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        controlLayers[0].position = CGPoint.init(x: 0.0, y: frame.size.height)
        controlLayers[1].position = CGPoint.init(x: frame.size.width/2.0, y: frame.size.height)
        controlLayers[2].position = CGPoint.init(x: frame.size.width, y: frame.size.height)
        CATransaction.commit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        borderColor.setFill()
        UIRectFill(rect)
        let inside = frame.insetBy(dx: borderWidth, dy: borderWidth)
        UIColor.clear.setFill()
        UIRectFillUsingBlendMode(inside, .clear)
    }

}

// MARK: - Pan delegate
extension CanvasGuideView: UIGestureRecognizerDelegate {

    @objc func wasDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let p = gestureRecognizer.location(ofTouch: 0, in: self)
            switch p.y {
            case let y where y > (frame.size.height - 30.0):
                moveSize = frame.size
                gesture = .resize
            default:
                movePoint = superview!.frame.origin
                gesture = .drag
            }
        case .changed:
            let translation = gestureRecognizer.translation(in: superview)
            switch gesture {
            case .none: ()
            case .drag:
                superview!.snp.updateConstraints({ (make) in
                    make.left.equalTo(max(movePoint.x + translation.x, 0.0))
                    make.top.equalTo(max(movePoint.y + translation.y, 0.0))
                })
            case .resize:
                superview!.snp.updateConstraints({ (make) in
                    make.width.equalTo(max(moveSize.width + translation.x, 0.0))
                    make.height.equalTo(max(moveSize.height + translation.y, 0.0))
                })
            }
        default: ()
        }
    }

}

// MARK: - Canvas View, contains the board
class CanvasItem: UIView {

    private weak var guideView: UIView!
    private var token: NSKeyValueObservation!
    private var selected: Bool = false {
        didSet {
            guard let canvasScrollView = canvasScrollView else { return }
            let val:CGFloat = selected ? 2.0 : 0.0
            layer.borderWidth = val / canvasScrollView.zoomScale
            setNeedsDisplay()
        }
    }
    private var canvasScrollView: CanvasScrollView!

    init() {
        super.init(frame: .zero)
        isOpaque = false
        backgroundColor = .red
        let gv = CanvasGuideView.init(frame: CGRect.zero)
        super.addSubview(gv)
        guideView = gv
        guideView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        layer.borderColor = UIColor.blue.cgColor
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(CanvasItem.onTap(_:)))
        addGestureRecognizer(tap)

//        let dragInteraction = UIDragInteraction(delegate: self)
//        addInteraction(dragInteraction)
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
            canvasScrollView = sp
            token = sp.observe(\.zoomScaleDelegate, options: [.new, .initial]) { [weak self](scrollView: CanvasScrollView, _) in
                guard let wself = self else { return }
                wself.selected = wself.selected ? true : false
            }
        }
    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        selected = selected ? false : true
    }

}

// MARK: - Drag interaction delegate
extension CanvasItem: UIDragInteractionDelegate {

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object:"CanvasItem" as NSString)
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        dragItem.localObject = self

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        layer.render(in: context!)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        let preview = UIImageView.init(image: snapshotImage)
        let previewParameters = UIDragPreview.init(view: preview)

        dragItem.previewProvider = { () -> UIDragPreview? in
            return previewParameters
        }

        return [dragItem]
    }

    func dragInteraction(_ interaction: UIDragInteraction, prefersFullSizePreviewsFor session: UIDragSession) -> Bool {
        return true
    }

}

// MARK: CanvasViewController and CanvasScrollView child
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

        // INCEPTION
//        if navigationController == nil {
//            let inception = DocumentViewController.init()
//            let nav = UINavigationController.init(rootViewController: inception)
//            addChildViewController(nav)
//            add(view: nav.view, location: CGPoint.init(x: 250, y: 250), size: CGSize.init(width: 500, height: 200))
//            nav.didMove(toParentViewController: self)
//        }
//
//        if tabBarController == nil {
//            let inception = DocumentViewController.init()
//            let tb = UITabBarController.init()
//            tb.viewControllers = [inception]
//            addChildViewController(tb)
//            add(view: tb.view, location: CGPoint.init(x: 250, y: 800), size: CGSize.init(width: 500, height: 200))
//            tb.didMove(toParentViewController: self)
//        }

        let dropInteraction = UIDropInteraction(delegate: self)
        canvasView.addInteraction(dropInteraction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - manage canvas items
extension CanvasViewController {

    func add(view: UIView, location: CGPoint, size: CGSize?) {
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

    func move(canvas: CanvasItem, location: CGPoint) {
        canvas.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(location.x)
            make.top.equalToSuperview().offset(location.y)
        }
    }
}

// MARK: - scroll view delegate
extension CanvasViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CanvasScrollView else { return }
        csv.zoomScaleDelegate = NSNumber.init(value: Float(scrollView.zoomScale))
    }

}

// MARK: - drop interaction  delegate
extension CanvasViewController: UIDropInteractionDelegate {

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // avoid complications
        if session.items.count != 1 { return false }
        guard let item = session.items.first else { return false }

        switch item.localObject {
        case is CanvasItem:
            return true
        case is DraggableControl:
            return true
        default: ()
        }

        // incoming external image
        if item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
            return true
        }

        return false
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        guard let item = session.items.first else { fatalError("UHM") }
        let operation: UIDropOperation
        operation = (item.localObject ?? nil) is CanvasItem ? .move : .copy
        let proposal = UIDropProposal(operation: operation)
        proposal.isPrecise = true
        proposal.prefersFullSizePreview = true
        return proposal
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let item = session.items.first else { return }
        let dropLocation = session.location(in: canvasView)

        switch item.localObject {
        case .some(let lo as CanvasItem):
            move(canvas: lo, location: dropLocation)
        case .some(let lo as DraggableControl):
            let (view, size) = lo.createCanvasView()
            add(view: view, location: dropLocation, size: size)
        default:
            session.loadObjects(ofClass: UIImage.self){ [weak self](imageItems) in
                guard let wself = self else { return }
                DispatchQueue.main.async {
                    let images = imageItems as! [UIImage]
                    for image in images {
                        let iv = UIImageView.init(image: image)
                        let location = CGPoint.init(x: dropLocation.x - image.size.width/2, y: dropLocation.y - image.size.height/2)
                        wself.add(view: iv, location: location, size: nil)
                    }
                }
            }
        }
    }
}
