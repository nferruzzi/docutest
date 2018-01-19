//
//  SidebarViewController.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 10/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit

class SidebarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0

        let picker = UIButton.init()
        picker.setTitle("Document\npicker", for: .normal)
        picker.titleLabel?.numberOfLines = 0
        picker.titleLabel?.lineBreakMode = .byWordWrapping
        picker.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        picker.titleLabel?.textAlignment = .center
        view.addSubview(picker)
        picker.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        picker.addTarget(self, action: #selector(SidebarViewController.onPicker(sender:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func onPicker(sender: AnyObject?) {
        let p = UIDocumentPickerViewController.init(documentTypes: ["ilwoody.DocuTest3.creo"], in: .import)
        present(p, animated: false, completion: nil)
    }

}
