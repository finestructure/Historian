//
//  Transceiver.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import Foundation
import MultipeerKit


let serviceType = "Historian"


enum Transceiver {
    static public func resume() { transceiver.resume() }
    static public func send<T: Encodable>(_ payload: T, to peers: [Peer]) {
        transceiver.send(payload, to: peers)
    }
    static public func broadcast<T: Encodable>(_ payload: T) { transceiver.broadcast(payload) }
    static var availablePeers: [Peer] { dataSource.availablePeers }
    static func receive<T: Codable>(_ type: T.Type, using closure: @escaping (_ payload: T) -> Void) {
        transceiver.receive(type, using: closure)
    }

    static private var transceiver: MultipeerTransceiver = {
        var config = MultipeerConfiguration.default
        config.serviceType = "Historian"
        config.security.encryptionPreference = .required
        return MultipeerTransceiver(configuration: config)
    }()

    static public var dataSource: MultipeerDataSource = {
        MultipeerDataSource(transceiver: transceiver)
    }()
}


public func broadcast<Value: Encodable, Action>(_ reducer: @escaping Reducer<Value, Action>) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [.fireAndForget {
            if let data = try? JSONEncoder().encode(newValue) {
                print("📡 Broadcasting state ...")
                let msg = Message(kind: .record, action: "\(action)", state: data)
                Transceiver.broadcast(msg)
            }
            }] + effects
    }
}
