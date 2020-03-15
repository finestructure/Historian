//
//  HistoryView.swift
//  Playgrounder
//
//  Created by Sven A. Schmidt on 11/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


struct Step: Identifiable, Hashable {
    var id: Int { index }
    var index: Int
    var action: String
    var resultingState: Data
}


struct RowView: View {
    var row: Step
    var body: some View {
        HStack {
            Text("\(row.index)")
                .frame(width: 30, alignment: .trailing)
            Text(row.action)
            Spacer()
            Button(action: { historyStore.send(.selection(self.row)) },
                   label: {
                    Image(systemName: "square.and.arrow.up")
            })
        }
    }
}


struct HistoryView: View {
    @ObservedObject var store: Store<State, Action>
    @SwiftUI.State var targeted = false

    var body: some View {
        VStack {
//            HStack {
//                Spacer()
//
//                Button(action: { self.store.send(.deleteTapped) }, label: {
//                    Text("Delete")
//                })
//                Button(action: { self.store.send(.backTapped) }, label: {
//                    Text("←")
//                })
//                Button(action: { self.store.send(.forwardTapped) }, label: {
//                    Text("→")
//                })
//            }
//            .padding([.top, .trailing], 6)

            List(selection: store.binding(value: \.selection, action: /Action.selection)) {
                ForEach(store.value.history, id: \.self) {
                    RowView(row: $0)
                }
            }
        }
//        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
    }

}


extension HistoryView {
    struct State {
        var history: [Step] = []
        var selection: Step? = nil

        func stepBefore(_ step: Step) -> Step? {
            guard
                let idx = history.firstIndex(of: step),
                case let nextIdx = history.index(after: idx),
                history.indices.contains(nextIdx)
                else { return nil }
            return history[nextIdx]
        }

        func stepAfter(_ step: Step) -> Step? {
            guard
                let idx = history.firstIndex(of: step),
                case let prevIdx = history.index(before: idx),
                history.indices.contains(prevIdx)
                else { return nil }
            return history[prevIdx]
        }
    }

    enum Action {
        case appendStep(String, Data)
        case selection(Step?)
//        case deleteTapped
//        case backTapped
//        case forwardTapped
        case newState(Data)
    }

    static var reducer: Reducer<State, Action> {
        return { state, action in
            switch action {
                case let .appendStep(stepAction, postActionState):
                    let newStep = Step(index: state.history.count,
                                       action: stepAction,
                                       resultingState: postActionState)
                    state.history.insert(newStep, at: 0)
                    state.selection = newStep
                    return []
                case .selection(let step):
                    state.selection = step
                    guard let step = step else { return [] }
                    return [ .sync { .newState(step.resultingState) } ]
//                case .deleteTapped:
//                    guard let current = state.selection else { return [] }
//                    defer { state.history.removeFirst(value: current) }
//                    guard
//                        let previous = state.stepBefore(current),
//                        let newState = previous.contentViewState()
//                        // we're at the start / on the first entry
//                        else { return [ .sync { .newState(ContentView.State()) } ] }
//                    state.selection = previous
//                    return [ .sync { .newState(newState) } ]
//                case .backTapped:
//                    guard
//                        let current = state.selection,
//                        let previous = state.stepBefore(current),
//                        let newState = previous.contentViewState()
//                        else { return [ .sync { .newState(ContentView.State()) } ] }
//                    state.selection = previous
//                    return [ .sync { .newState(newState) } ]
//                case .forwardTapped:
//                    guard let current = state.selection else { return [] }
//                    guard
//                        let idx = state.history.firstIndex(of: current),
//                        idx != 0
//                        // can't advance further than tip
//                        else { return [] }
//                    guard
//                        let next = state.stepAfter(current),
//                        let newState = next.contentViewState()
//                        else { return [ .sync { .newState(ContentView.State()) } ] }
//                    state.selection = next
//                    return [ .sync { .newState(newState) } ]
                case .newState(let state):
                    let msg = Message(kind: .reset, action: "", state: state)
                    Transceiver.broadcast(msg)
                    return []
            }
        }
    }
}


struct Sample {
    static var history: [Step] {
        [0, 1, 2, 3].map({
            Step(index: $0,
                action: "action \($0)",
                resultingState: Data("foo".utf8))
        })
    }
}


extension HistoryView {
    static func store(history: [Step]) -> Store<State, Action> {
        return Store(initialValue: State(history: history), reducer: reducer)
    }

    init(history: [Step]) {
        self.store = Self.store(history: history)
    }
}


public func record<Value: Encodable, Action>(_ reducer: @escaping Reducer<Value, Action>) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [.fireAndForget {
            if let data = try? JSONEncoder().encode(newValue) {
                historyStore.send(HistoryView.Action.appendStep("\(action)", data))
            }
            }] + effects
    }
}


extension UUID {
    var short: String {
        uuidString.split(separator: "-").first!.lowercased()
    }
}


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(history: Sample.history)
    }
}

var historyStore = HistoryView.store(history: [])
//var historyStore = HistoryView.store(history: Sample.history)
