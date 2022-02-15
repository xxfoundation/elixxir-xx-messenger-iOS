import Voxophone
import Foundation

public struct ChatInputEnvironment {
    public var voxophone: Voxophone
    public var sendAudio: (URL) -> Void
    public var didTapCamera: () -> Void
    public var didTapLibrary: () -> Void
    public var sendText: (String) -> Void
    public var didTapAbortReply: () -> Void
    public var didTapMicrophone: () -> Bool

    public init(
        voxophone: Voxophone,
        sendAudio: @escaping (URL) -> Void,
        didTapCamera: @escaping () -> Void,
        didTapLibrary: @escaping () -> Void,
        sendText: @escaping (String) -> Void,
        didTapAbortReply: @escaping () -> Void,
        didTapMicrophone: @escaping () -> Bool
    ) {
        self.voxophone = voxophone
        self.sendAudio = sendAudio
        self.sendText = sendText
        self.didTapCamera = didTapCamera
        self.didTapLibrary = didTapLibrary
        self.didTapAbortReply = didTapAbortReply
        self.didTapMicrophone = didTapMicrophone
    }
}
