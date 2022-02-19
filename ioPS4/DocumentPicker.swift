//
//  DocumentPicker.swift
//  Created by Even for ioPS4 
//  19/02/2022
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    
    @Binding var showPicker: Bool
    var filetypes: [UTType]
    
    typealias finishedAction = (_ path: String)  -> Void
    
    var completion: finishedAction
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
        
        if self.showPicker {
            let controller = UIDocumentPickerViewController(forOpeningContentTypes: filetypes, asCopy: true)
            controller.allowsMultipleSelection = false
            controller.delegate = context.coordinator
            
            DispatchQueue.main.async { 
                uiViewController.present(controller, animated: true, completion: {
                    self.showPicker = false
                })
                
            }
        }
    }
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        DocumentPickerCoordinator(completion: self.completion)
    }
    
    class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        
        typealias finishedAction = (_ path: String)  -> Void
        var completion: finishedAction
        
        init(completion: @escaping finishedAction) {
            self.completion =  completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let filePath = urls[0].path
            if !filePath.isEmpty {
                completion(filePath)
            }
        }
    }
}
