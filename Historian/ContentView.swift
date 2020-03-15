//
//  ContentView.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import SwiftUI
import MultipeerKit
import Combine

final class ViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var selectedPeers: [Peer] = []

    func toggle(_ peer: Peer) {
        if selectedPeers.contains(peer) {
            selectedPeers.remove(at: selectedPeers.firstIndex(of: peer)!)
        } else {
            selectedPeers.append(peer)
        }
    }
}

struct ContentView: View {
    @ObservedObject private(set) var viewModel = ViewModel()
    @EnvironmentObject var dataSource: MultipeerDataSource

    var body: some View {
        VStack(alignment: .leading) {
            Text("History").font(.system(.headline)).padding()
            HistoryView(store: historyStore)

            Text("Peers").font(.system(.headline)).padding()
            List {
                ForEach(dataSource.availablePeers) { peer in
                    HStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(peer.isConnected ? .green : .gray)

                        Text(peer.name)

                        Spacer()

                        if self.viewModel.selectedPeers.contains(peer) {
                            Image(systemName: "checkmark")
                        }
                    }.onTapGesture {
                        self.viewModel.toggle(peer)
                    }
                }
            }
            .frame(height: 150)
        }
    }

}

