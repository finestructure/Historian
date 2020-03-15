//
//  RangeReplaceableCollection+ext.swift
//  Playgrounder
//
//  Created by Sven A. Schmidt on 18/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import Foundation


extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func removeFirst(value: Element) -> Element? {
        guard let idx = firstIndex(of: value) else { return nil }
        return remove(at: idx)
    }
}
