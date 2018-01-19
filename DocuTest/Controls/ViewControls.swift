//
//  ViewControls.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 10/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit
import WebKit

class ControlImageView: DraggabeViewControl<UIImageView> {

    lazy var image:UIImage? = {
        UIImage.init(named: "checkboard")
    }()

    override func iconName() -> String {
        return "MKImageView_iOS7_"
    }

    override func dragItemName() -> String {
        return "MKImageView_drag"
    }

    override func configure(view: UIImageView) -> CGSize? {
        view.image = image
        return nil
    }

}

class ControlButtonView: DraggabeViewControl<UIButton> {

    override func iconName() -> String {
        return "MKButton_iOS7_"
    }

    override func dragItemName() -> String {
        return "MKButton_drag"
    }

    override func configure(view: UIButton) -> CGSize? {
        view.setTitle("Button", for: .normal)
        return nil
    }

}

class ControlLabelView: DraggabeViewControl<UILabel> {

    override func iconName() -> String {
        return "MKLabel_iOS7_"
    }

    override func dragItemName() -> String {
        return "MKLabel_drag"
    }

    override func configure(view: UILabel) -> CGSize? {
        view.text = "Label"
        return nil
    }

}

class ControlWebView: DraggabeViewControl<WKWebView> {

    override func iconName() -> String {
        return "MKWebView_iOS7_"
    }

    override func dragItemName() -> String {
        return "MKWebView_drag"
    }

    override func configure(view: WKWebView) -> CGSize? {
        let url = URL.init(string: "https://www.creolabs.com")
        let req = URLRequest.init(url: url!)
        view.load(req)
        return CGSize.init(width: 400, height: 400)
    }

}
