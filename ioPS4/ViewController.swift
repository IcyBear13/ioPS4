//
//  ViewController.swift
//  iops4
//
//  Created by Brandon Plank on 12/28/21.
//

import UIKit
import Socket
import SwiftEntryKit

class ViewController: UIViewController {
    @IBOutlet weak var ipOutlet: UITextField!
    @IBOutlet weak var portOutlet: UITextField!
    @IBOutlet weak var payloadLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var sendPayloadOutlet: UIButton!
    
    let ipKey = "IP"
    let portKey = "PORT"
    
    let defaults = UserDefaults.standard
    
    func readKey(key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    func writeKey(key: String, value: String) {
        defaults.set(value, forKey: key)
    }
    
    var payloadURL: URL?
    
    func showPopup(msg: String?, sucess: Bool) {
        DispatchQueue.main.async { [self] in
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: EKColor(red: 34, green: 35, blue: 35))
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 10), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.statusBar = .dark
            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
            attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)

            let title = EKProperty.LabelContent(text: sucess ? "Success" : "Error", style: .init(font: .systemFont(ofSize: 12), color: .white))
            let description = EKProperty.LabelContent(text: msg ?? "No message", style: .init(font: .systemFont(ofSize: 12), color: .white))
            let image = EKProperty.ImageContent(image: UIImage(systemName: "info.circle")!.withTintColor(UIColor.white), size: CGSize(width: 35, height: 35))
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
            sendPayloadOutlet.isEnabled = true
            sendPayloadOutlet.setTitle("Send Payload", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .dark
        super.viewDidLoad()
        if let ip = readKey(key: ipKey) {
            ipOutlet.text = ip
        }
        
        if let port = readKey(key: portKey) {
            portOutlet.text = port
        }
        
        if readKey(key: portKey) == nil || readKey(key: portKey)?.isEmpty ?? true {
            portOutlet.text = "9090"
        }
    }
    
    @IBAction func selectPayload(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func ipEndEdit(_ sender: Any) {
        if !ipOutlet.text!.isEmpty {
            writeKey(key: ipKey, value: ipOutlet.text!)
        }
    }
    
    @IBAction func portEndEdit(_ sender: Any) {
        if !portOutlet.text!.isEmpty {
            writeKey(key: portKey, value: portOutlet.text!)
        }
    }
    
    @IBAction func sendPayload(_ sender: Any) {
        sendPayloadOutlet.isEnabled = false
        sendPayloadOutlet.setTitle("Sending Payload", for: .normal)
        guard let ip = ipOutlet.text else {
            showPopup(msg: "Please input a IP adress", sucess: false)
            return
        }
        
        guard let port = portOutlet.text else {
            showPopup(msg: "Please input a port", sucess: false)
            return
        }
        
        if ip.isEmpty {
            showPopup(msg: "Please input a IP", sucess: false)
            return
        }
        
        if port.isEmpty{
            showPopup(msg: "Please input a port", sucess: false)
            return
        }
        
        guard let payloadURL = payloadURL else {
            showPopup(msg: "Please add a payload", sucess: false)
            return
        }
        
        guard let portInt = Int32(port) else {
            showPopup(msg: "Please input a valid port number", sucess: false)
            return
        }

        DispatchQueue.global(qos: .background).async(execute: { [self] in
            let ret = Payload.Payload(addr: ip, port: portInt, payload: try! Data(contentsOf: payloadURL))
            if let returnStr = ret.str {
                showPopup(msg: returnStr, sucess: ret.sucess)
            }
        })
    }
    @IBAction func infoButton(_ sender: Any) {
        let alert = UIAlertController(title: "Credits", message: "ioPS4 by Brandon Plank", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let payloadURL = urls.first else {
            return
        }
        self.payloadURL = payloadURL
        payloadLabel.text = "Payload: \(payloadURL.lastPathComponent)"
    }

    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}
