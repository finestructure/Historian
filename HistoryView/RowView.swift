//
//  RowView.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI


public typealias IdentifiedRow = Identified<RowView.State, RowView.Action>


public struct RowView: View {
    @ObservedObject var store: Store<State, Action>

    var indexLabel: String {
        switch self.store.value.step {
            case .initial: return "0"
            case .step(let step): return "\(step.index)"
        }
    }

    var actionLabel: String {
        switch self.store.value.step {
            case .initial: return "initial"
            case .step(let step): return step.action
        }
    }

    public var body: some View {
        #if os(macOS)
        let view = HStack {
            Text(indexLabel)
                .frame(width: 30, alignment: .trailing)
            Text(actionLabel)
        }
        .onDrag {
            NSItemProvider(object: String(decoding: self.store.value.step.resultingState ?? Data(),
                                          as: UTF8.self) as NSString)
        }
        #else
        let view = HStack {
                Button(action: { self.store.send(.rowTapped) },
                       label: {
                        HStack {
                            #if os(iOS)
                            Image(systemName: "arrowtriangle.right.fill")
                                .foregroundColor(self.store.value.selected ? .blue : .clear)
                            #endif
                            Text(indexLabel)
                                .frame(width: 30, alignment: .trailing)
                            Text(actionLabel)
                        }
                })
        }
        #endif
        return view
    }
}


extension RowView {
    public struct State: Identifiable {
        public var id: Step { step }
        var step: Step
        var selected = false
    }

    public enum Action {
        case rowTapped
    }
}

