//
//  RowView.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI


typealias IdentifiedRow = Identified<RowView.State, RowView.Action>


struct RowView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        let button =
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

        #if os(macOS)
        return button
            .buttonStyle(PlainButtonStyle())
            .onDrag {
                NSItemProvider(object: String(decoding: self.row.resultingState, as: UTF8.self) as NSString)
        }
        #else
        return button
        #endif
    }
}


extension RowView {
    struct State: Identifiable {
        var id: Int { step.id }
        var step: Step
        var selected = false
    }

    enum Action {
        case rowTapped
    }
}

