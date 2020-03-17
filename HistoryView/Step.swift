//
//  Step.swift
//  
//
//  Created by Sven A. Schmidt on 16/03/2020.
//

import CasePaths
import Foundation


public enum Step: Hashable {
    case initial
    case step(Value)

    public struct Value: Hashable {
        var index: Int
        var action: String
        var resultingState: Data
    }

    public init(index: Int, action: String, resultingState: Data) {
        self = .step(.init(index: index, action: action, resultingState: resultingState))
    }
}


extension Step {
    var value: Value? { (/Step.step).extract(from: self) }

    var resultingState: Data? {
        switch self {
            case .initial: return nil
            case .step(let step): return step.resultingState
        }
    }
}


extension Step: Identifiable {
    public var id: Step { self }
}


extension Step: Equatable {
    public static func == (lhs: Step, rhs: Step) -> Bool {
        switch (lhs, rhs) {
            case (.initial, .initial):
                return true
            case let (.step(a), .step(b)):
                return a.index == b.index
            default:
                return false
        }
    }
}
