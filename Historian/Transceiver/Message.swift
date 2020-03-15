//
//  Message.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import Foundation

struct Message: Hashable, Codable {
    enum Command: String, Codable {
        case record
        case reset
    }

    let kind: Command
    let action: String
    let state: Data
}
