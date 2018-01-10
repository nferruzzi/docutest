//
//  DocumentViewController.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 02/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit
import SnapKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createMainInterface()
    }

    func createMainInterface() {
        let leftContainer = UIView.init()
        leftContainer.translatesAutoresizingMaskIntoConstraints = false

        let rightContainer = UIView.init()
        rightContainer.translatesAutoresizingMaskIntoConstraints = false

        let mainContainer = UIView.init()
        mainContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainContainer)
        view.addSubview(leftContainer)
        view.addSubview(rightContainer)

        leftContainer.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(50.0)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
        }

        rightContainer.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(200.0)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.right.equalTo(view.snp.right)
        }

        mainContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(leftContainer.snp.right)
            make.right.equalTo(rightContainer.snp.left)
        }

        let leftVC = SidebarViewController.init()
        let rightVC = ControlsViewController.init()
        let mainVC = CanvasViewController.init()

        addChildViewController(leftVC)
        addChildViewController(rightVC)
        addChildViewController(mainVC)

        leftContainer.addSubview(leftVC.view)
        rightContainer.addSubview(rightVC.view)
        mainContainer.addSubview(mainVC.view)

        leftVC.view.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        rightVC.view.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        mainVC.view.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        leftVC.view.backgroundColor = .gray
        rightVC.view.backgroundColor = .gray
        mainVC.view.backgroundColor = .darkGray

        leftVC.didMove(toParentViewController: self)
        rightVC.didMove(toParentViewController: self)
        mainVC.didMove(toParentViewController: self)
    }
}
