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

    public var body: some View {
        #if os(macOS)
        let view = HStack {
            Text("\(self.store.value.step.id)")
                .frame(width: 30, alignment: .trailing)
            Text(self.store.value.step.action)
        }
        .onDrag {
            NSItemProvider(object: String(decoding: self.store.value.step.resultingState,
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
                            Text("\(self.store.value.step.id)")
                                .frame(width: 30, alignment: .trailing)
                            Text(self.store.value.step.action)
                        }
                })
        }
        #endif
        return view
    }
}


extension RowView {
    public struct State: Identifiable {
        public var id: Int { step.id }
        var step: Step
        var selected = false
    }

    public enum Action {
        case rowTapped
    }
}

