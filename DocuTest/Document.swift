//
//  Document.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 02/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit

class Document: UIDocument {

    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}
