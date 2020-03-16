//
//  ContentView.swift
//  Historian
//
//  Created by Sven A. Schmidt on 15/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import HistoryView
import MultipeerKit
import SwiftUI


struct ContentView: View {
    @EnvironmentObject var dataSource: MultipeerDataSource

    var body: some View {
        VStack(alignment: .leading) {
            Text("Peers").font(.system(.headline)).padding()
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
            .frame(height: 150)

            HistoryView(store: historyStore)
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Transceiver.dataSource)
    }
}
