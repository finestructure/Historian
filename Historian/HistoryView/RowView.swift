//
//  RowView.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import SwiftUI


struct RowView: View {
    var row: Step
    var selected = false
    var body: some View {
        let button =
            Button(action: { historyStore.send(.selection(self.row)) },
                   label: {
                    HStack {
                        #if os(iOS)
                        Image(systemName: "arrowtriangle.right.fill")
                            .foregroundColor(selected ? .blue : .clear)
                        #endif
                        Text("\(row.index)")
                            .frame(width: 30, alignment: .trailing)
                        Text(row.action)
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


