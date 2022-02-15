import Foundation

public struct ChatInputState: Equatable {
    public enum Audio: Equatable {
        case idle(URL, duration: TimeInterval)
        case recording(URL, time: TimeInterval)
        case playing(URL, duration: TimeInterval, time: TimeInterval)

        public var url: URL {
            switch self {
            case .idle(let url, _), .recording(let url, _), .playing(let url, _, _):
                return url
            }
        }
    }

    public struct Reply: Equatable {
        public var name: String
        public var text: String
    }

    public var text: String
    public var audio: Audio?
    public var reply: Reply?
    public var canAddAttachments: Bool
    public var isPresentingActions: Bool
    public var audioRecordingMaxDuration: TimeInterval = 60.0

    public init(
        text: String = "",
        audio: Audio? = nil,
        reply: Reply? = nil,
        canAddAttachments: Bool = true,
        isPresentingActions: Bool = false
    ) {
        self.text = text
        self.audio = audio
        self.reply = reply
        self.canAddAttachments = canAddAttachments
        self.isPresentingActions = isPresentingActions
    }
}
