//
//  DraggableControl.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 10/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit

protocol DraggableControl {
    func createCanvasView() -> (UIView, CGSize?)
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

    func configure(view: T) -> CGSize? {
        return nil
    }

    func createCanvasView() -> (UIView, CGSize?) {
        let instance = T.init()
        instance.translatesAutoresizingMaskIntoConstraints = false
        let size = configure(view: instance)
        return (instance, size)
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
