//
//  HistoryView+CA.swift
//  
//
//  Created by Sven A. Schmidt on 16/03/2020.
//

import CompArch
import Foundation


// MARK: - State, Action, Reducer - CA machinery

extension HistoryView {
    public struct State {
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

        public init(history: [Step] = [], selection: Step? = nil, broadcastEnabled: Bool = false) {
            self.history = history
            self.selection = selection
            self.broadcastEnabled = broadcastEnabled
        }
    }

    public enum Action {
        case appendStep(String, Data?)
        case selection(Step?)
        case deleteTapped
        case backTapped
        case forwardTapped
        case newState(Data?)
        case row(IdentifiedRow)
    }

    public static var reducer: Reducer<State, Action> {
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
                    let previous = state.stepBefore(current)
                    state.selection = previous
                    return [ .sync { .newState(previous?.resultingState) } ]
                case .backTapped:
                    guard let current = state.selection else { return [] }
                    let previous = state.stepBefore(current)
                    state.selection = previous
                    return [ .sync { .newState(previous?.resultingState) } ]
                case .forwardTapped:
                    guard let current = state.selection else { return [] }
                    guard
                        let idx = state.history.firstIndex(of: current),
                        idx != state.history.count - 1
                        // can't advance further than tip
                        else { return [] }
                    guard let next = state.stepAfter(current) else { return [] }
                    state.selection = next
                    return [ .sync { .newState(next.resultingState) } ]
                case .newState(let newState):
                    if state.broadcastEnabled {
                        let msg = Message(kind: .reset, action: "", state: newState)
                        Transceiver.shared.broadcast(msg)
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
