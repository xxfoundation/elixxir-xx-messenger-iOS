import Voxophone

public enum ChatInputAction: Equatable {
    public enum Text: Equatable {
        case didUpdate(String)
        case didTapShowActions
        case didTapHideActions
        case didTapSend
        case didTapAudio
        case didTapAbortReply
        case didTriggerReply(String, String)
    }

    public enum Audio: Equatable {
        case didTapCancel
        case didTapPlay
        case didTapStopPlayback
        case didTapStopRecording
        case didTapSend
    }

    public enum Actions: Equatable {
        case didTapCamera
        case didTapLibrary
    }

    case setup
    case destroy
    case voxophone(Voxophone.State)
    case text(Text)
    case audio(Audio)
    case actions(Actions)
}
