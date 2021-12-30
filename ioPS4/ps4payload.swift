//
//  ps4payload.swift
//  iops4
//
//  Created by Brandon Plank on 12/28/21.
//

import Foundation
import Socket

class Payload {
    static let socket = try! Socket.create()
    
    static func Payload(addr: String, port: Int32, payload: Data) -> (str: String?, sucess: Bool) {
        do {
            try socket.connect(to: addr, port: port)
            print("connected to PS4")
            do {
                print("sending payload to PS4")
                try socket.write(from: payload)
                socket.close()
                return ("Sent payload to PS4", true)
            } catch let error {
                return ("Error sending payload to PS4 \(error)", false)
            }
        } catch let error {
            return ("Cannot connect to PS4 \(error)", false)
        }
    }
}
