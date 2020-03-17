//
//  Message.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import Foundation

public struct Message: Hashable, Codable {
    public enum Command: String, Codable {
        case record
        case reset
    }

    public let kind: Command
    public let action: String
    public let state: Data?
}
