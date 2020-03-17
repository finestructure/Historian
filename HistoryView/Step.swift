//
//  Step.swift
//  
//
//  Created by Sven A. Schmidt on 16/03/2020.
//

import Foundation


public struct Step: Identifiable, Hashable {
    public var id: Int { index }
    var index: Int
    var action: String
    var resultingState: Data
}
