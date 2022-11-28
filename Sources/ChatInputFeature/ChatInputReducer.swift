import Foundation
import ComposableArchitecture

public let chatInputReducer = Reducer<ChatInputState, ChatInputAction, ChatInputEnvironment> { state, action, env in
    struct VoxophoneEffectId: Hashable {}

    switch action {
    case .setup:
        return env.voxophone.$state
            .map(ChatInputAction.voxophone)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
            .cancellable(id: VoxophoneEffectId(), cancelInFlight: true)

    case .destroy:
        return .cancel(id: VoxophoneEffectId())

    case .voxophone(.empty):
        return .none

    case let .voxophone(.idle(url, duration, isLoudspeaker)):
        if url == state.audio?.url {
            state.audio = .idle(url, duration: duration)
        }

        return .none

    case let .voxophone(.playing(url, duration, time, isLoudspeaker)):
        if url == state.audio?.url {
            state.audio = .playing(url, duration: duration, time: time)
        }

        return .none

    case let .voxophone(.recording(url, time, _)):
        state.audio = .recording(url, time: time)

        if time >= state.audioRecordingMaxDuration {
            return .fireAndForget { env.voxophone.stop() }
        }

        return .none

    case let .text(.didUpdate(text)):
        state.text = text
        return .none

    case .text(.didTriggerReply(let message, let sender)):
        state.reply = .init(name: sender, text: message)
        return .none
        
    case .text(.didTapAbortReply):
        state.reply = nil
        return .fireAndForget { env.didTapAbortReply() }

    case .text(.didTapShowActions):
        state.isPresentingActions = true
        return .none

    case .text(.didTapHideActions):
        state.isPresentingActions = false
        return .none

    case .text(.didTapSend):
        let text = state.text
        state.text = ""
        state.reply = nil
        return .fireAndForget { env.sendText(text) }

    case .text(.didTapAudio):
        state.isPresentingActions = false
        return .fireAndForget {
            if env.didTapMicrophone() {
                env.voxophone.record()
            }
        }

    case .audio(.didTapCancel):
        state.audio = nil
        return .fireAndForget { env.voxophone.reset() }

    case .audio(.didTapPlay):
        guard case let .idle(url, _) = state.audio else { return .none }
        return .fireAndForget {
            env.voxophone.load(url)
            env.voxophone.play()
        }

    case .audio(.didTapStopPlayback):
        guard case let .playing(url, _, _) = state.audio else { return .none }
        return .fireAndForget { env.voxophone.stop() }

    case .audio(.didTapStopRecording):
        guard case let .recording(url, _) = state.audio else { return .none }
        return .fireAndForget { env.voxophone.stop() }

    case .audio(.didTapSend):
        switch state.audio {
        case .idle(let url, _):
            state.audio = nil
            return .fireAndForget { env.sendAudio(url) }
        case .playing(let url, _, _):
            state.audio = nil
            return .fireAndForget {
                env.voxophone.reset()
                env.sendAudio(url)
            }
        case .recording(_, _), .none:
            return .none
        }

    case .actions(.didTapCamera):
        state.isPresentingActions = false
        return .fireAndForget { env.didTapCamera() }

    case .actions(.didTapLibrary):
        state.isPresentingActions = false
        return .fireAndForget { env.didTapLibrary() }
    }
}
