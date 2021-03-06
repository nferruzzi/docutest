//
//  DocumentBrowserViewController.swift
//  DocuTest
//
//  Created by Nicola Ferruzzi on 02/01/2018.
//  Copyright © 2018 Nicola Ferruzzi. All rights reserved.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "document browser"
        delegate = self

        allowsDocumentCreation = true
        allowsPickingMultipleItems = false

        debugPrint(allowedContentTypes)

        // Update the style of the UIDocumentBrowserViewController
         browserUserInterfaceStyle = .dark
         view.tintColor = UIColor(red: 120.0/255.0, green: 52.0/255.0, blue: 118.0/255.0, alpha: 1.0)

        // Specify the allowed content types of your application via the Info.plist.

        // Do any additional setup after loading the view, typically from a nib.
        presentDocument(at: nil)
    }

    // MARK: UIDocumentBrowserViewControllerDelegate

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL = Bundle.main.url(forResource: "EmptyProject", withExtension: "creo")

        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .copy)
        } else {
            importHandler(nil, .none)
        }
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }

        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }

    // MARK: Document Presentation

    func presentDocument(at documentURL: URL?) {

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as? DocumentViewController {
            if let documentURL = documentURL {
                documentViewController.document = Document(fileURL: documentURL)
            }
            present(documentViewController, animated: true, completion: nil)
        }
    }
}
