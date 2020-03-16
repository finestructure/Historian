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


struct HistoryView: View {
    @ObservedObject var store: Store<State, Action>
    @SwiftUI.State var targeted = false

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

    var body: some View {
        let stack = VStack(alignment: .leading) {
            #if os(macOS)
            Text("History").font(.system(.headline)).padding([.leading, .top])
            #else
            Text("History").font(.system(.headline)).padding()
            #endif

            #if os(iOS)
            List(selection: store.binding(value: \.selection, action: /Action.selection)) {
                ForEach(store.value.history.reversed()) {
                    self.rowView(for: $0)
                }
            }
            #else
            List(selection: store.binding(value: \.selection, action: /Action.selection)) {
                ForEach(store.value.history.reversed(), id: \.self) {
                    self.rowView(for: $0)
                }
            }
            .onDrop(of: [uti], isTargeted: $targeted, perform: dropHandler)
            #endif

            HStack {
                Button(action: { self.store.send(.deleteTapped) }, label: {
                    #if os(iOS)
                    Image(systemName: "trash").padding()
                    #else
                    Text("Delete")
                    #endif
                })
                Spacer()
                Button(action: { self.store.send(.backTapped) }, label: {
                    #if os(iOS)
                    Image(systemName: "backward").padding()
                    #else
                    Text("←")
                    #endif
                })
                Button(action: { self.store.send(.forwardTapped) }, label: {
                    #if os(iOS)
                    Image(systemName: "forward").padding()
                    #else
                    Text("→")
                    #endif
                })
            }
            .padding()
        }

        #if os(macOS)
        return stack.frame(minWidth: 500, minHeight: 300)
        #else
        return stack
        #endif
    }
}


extension HistoryView {
    struct State {
        var history: [Step] = []
        var selection: Step? = nil
        var broadcastEnabled = false

        func stepAfter(_ step: Step) -> Step? {
            guard
                let idx = history.firstIndex(of: step),
                case let nextIdx = history.index(after: idx),
                history.indices.contains(nextIdx)
                else { return nil }
            return history[nextIdx]
        }

        func stepBefore(_ step: Step) -> Step? {
            guard
                let idx = history.firstIndex(of: step),
                case let prevIdx = history.index(before: idx),
                history.indices.contains(prevIdx)
                else { return nil }
            return history[prevIdx]
        }
    }

    enum Action {
        case appendStep(String, Data?)
        case selection(Step?)
        case deleteTapped
        case backTapped
        case forwardTapped
        case newState(Data?)
        case row(IdentifiedRow)
    }

    static var reducer: Reducer<State, Action> {
        return { state, action in
            switch action {
                case let .appendStep(stepAction, .some(postActionState)):
                    let newStep = Step(index: state.history.count,
                                       action: stepAction,
                                       resultingState: postActionState)
                    state.history.append(newStep)
                    state.selection = newStep
                    return []
                case .appendStep(_, .none):
                    // ignore empty data when appending
                    return []
                case .selection(let step):
                    state.selection = step
                    guard let step = step else { return [] }
                    return [ .sync { .newState(step.resultingState) } ]
                case .deleteTapped:
                    guard let current = state.selection else { return [] }
                    defer { state.history.removeFirst(value: current) }
                    guard let previous = state.stepBefore(current)
                        // we're at the start / on the first entry
                        else { return [ .sync { .newState(nil) } ] }
                    state.selection = previous
                    return [ .sync { .newState(previous.resultingState) } ]
                case .backTapped:
                    guard
                        let current = state.selection,
                        let previous = state.stepBefore(current)
                        else { return [ .sync { .newState(nil) } ] }
                    state.selection = previous
                    return [ .sync { .newState(previous.resultingState) } ]
                case .forwardTapped:
                    guard let current = state.selection else { return [] }
                    guard
                        let idx = state.history.firstIndex(of: current),
                        idx != state.history.count - 1
                        // can't advance further than tip
                        else { return [] }
                    guard let next = state.stepAfter(current)
                        else { return [ .sync { .newState(nil) } ] }
                    state.selection = next
                    return [ .sync { .newState(next.resultingState) } ]
                case .newState(let newState):
                    if state.broadcastEnabled {
                        let msg = Message(kind: .reset, action: "", state: newState)
                        Transceiver.broadcast(msg)
                    }
                    return []
                case .row((let id, .rowTapped)):
                    guard let step = state.history.first(where: { $0.id == id })
                        else { return [] }
                    state.selection = step
                    return [ .sync { .newState(step.resultingState) } ]
            }
        }
    }
}


extension HistoryView {
    static func store(history: [Step], broadcastEnabled: Bool) -> Store<State, Action> {
        return Store(initialValue: State(history: history, broadcastEnabled: broadcastEnabled),
                     reducer: reducer)
    }

    init(history: [Step], broadcastEnabled: Bool) {
        self.store = Self.store(history: history, broadcastEnabled: broadcastEnabled)
    }
}


extension HistoryView {
    #if os(macOS)
    var uti: String { "public.utf8-plain-text" }

    func dropHandler(_ items: [NSItemProvider]) -> Bool {
        guard let item = items.first else { return false }
        print(item.registeredTypeIdentifiers)
        item.loadItem(forTypeIdentifier: uti, options: nil) { (data, error) in
            DispatchQueue.main.async {
                if self.store.value.broadcastEnabled, let data = data as? Data {
                    let msg = Message(kind: .reset, action: "", state: data)
                    Transceiver.broadcast(msg)
                }
            }
        }
        return true
    }
    #endif
}


extension HistoryView {
    struct Sample {
        static var history: [Step] {
            [0, 1, 2, 3].map({
                Step(index: $0,
                     action: "action \($0)",
                    resultingState: Data("foo".utf8))
            })
        }
    }
}


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(history: HistoryView.Sample.history, broadcastEnabled: false)
    }
}
