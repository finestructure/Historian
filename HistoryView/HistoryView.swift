//
//  HistoryView.swift
//  Playgrounder
//
//  Created by Sven A. Schmidt on 11/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import MultipeerKit
import SwiftUI


struct Config {
    #if os(macOS)
    var minWidth: CGFloat? = 500
    var minHeight: CGFloat? = 300
    var titlePadding: Edge.Set = [.leading, .top]
    var peerListHeight: CGFloat = 100
    #else
    var minWidth: CGFloat? = nil
    var minHeight: CGFloat? = nil
    var titlePadding: Edge.Set = .all
    var peerListHeight: CGFloat = 150
    #endif
}


public struct HistoryView: View {
    @ObservedObject var store: Store<State, Action>
    @EnvironmentObject var dataSource: MultipeerDataSource
    @SwiftUI.State var targeted = false
    var config = Config()

    public var body: some View {
        VStack(alignment: .leading) {
            peerList
            historyList.frame(minWidth: config.minWidth, minHeight: config.minHeight)
        }
    }
    
    var peerList: some View {
        VStack(alignment: .leading) {
            Text("Peers").font(.system(.headline)).padding(config.titlePadding)
            List {
                ForEach(dataSource.availablePeers) { peer in
                    HStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(peer.isConnected ? .green : .gray)
                        Text(peer.name)
                        Spacer()
                    }
                }
            }
            .frame(height: config.peerListHeight)
        }
    }
    
    var historyList: some View {
        VStack(alignment: .leading) {
            Text("History").font(.system(.headline)).padding(config.titlePadding)

            List(selection: store.binding(value: \.selection, action: /Action.selection)) {
                ForEach(store.value.history.reversed(), id: \.self) {
                    self.rowView(for: $0)
                }
            }
            ._onDrop(of: [uti], isTargeted: $targeted, perform: dropHandler)

            HStack {
                Button(action: { self.store.send(.deleteTapped) }, label: {
                    self.buttonLabel(title: "Delete", systemImage: "trash")
                })
                Spacer()
                Button(action: { self.store.send(.backTapped) }, label: {
                    self.buttonLabel(title: "←", systemImage: "backward")
                })
                Button(action: { self.store.send(.forwardTapped) }, label: {
                    self.buttonLabel(title: "→", systemImage: "forward")
                })
            }
            .padding()
        }
    }

    func buttonLabel(title: String, systemImage: String) -> some View {
        #if os(macOS)
        return AnyView(Text(title))
        #else
        return AnyView(Image(systemName: systemImage).padding())
        #endif
    }
    
    func rowView(for step: Step) -> AnyView {
        guard let step = store.value.history.first(where: { $0.id == step.id }) else {
            return AnyView(EmptyView())
        }
        let row = RowView.State(step: step, selected: step.id == store.value.selection?.id)
        return AnyView(
            RowView(store: self.store.view(
                value: { _ in row },
                action: { .row(IdentifiedRow(id: row.id, action: $0)) }))
        )
    }
    
}



// MARK: - Initializers / Setup

extension HistoryView {
    public static func store(history: [Step], broadcastEnabled: Bool) -> Store<State, Action> {
        return Store(initialValue: State(history: history, broadcastEnabled: broadcastEnabled),
                     reducer: reducer)
    }
    
    public init(store: Store<State, Action>) { self.store = store }
    
    public init(history: [Step], broadcastEnabled: Bool) {
        self.store = Self.store(history: history, broadcastEnabled: broadcastEnabled)
    }
}



// MARK: - Drop handling

extension View {
    func _onDrop(of supportedTypes: [String],
                 isTargeted targeted: Binding<Bool>?,
                 perform action: @escaping ([NSItemProvider]) -> Bool) -> some View {
        #if os(macOS)
        return AnyView(self.onDrop(of: supportedTypes, isTargeted: targeted, perform: action))
        #else
        return AnyView(self)
        #endif
    }
}


extension HistoryView {
    var uti: String { "public.utf8-plain-text" }
    
    func dropHandler(_ items: [NSItemProvider]) -> Bool {
        guard let item = items.first else { return false }
        print(item.registeredTypeIdentifiers)
        item.loadItem(forTypeIdentifier: uti, options: nil) { (data, error) in
            DispatchQueue.main.async {
                if self.store.value.broadcastEnabled, let data = data as? Data {
                    let msg = Message(kind: .reset, action: "", state: data)
                    Transceiver.shared.broadcast(msg)
                }
            }
        }
        return true
    }
}
