import UIKit
import Shared
import Combine
import CasePaths
import Voxophone
import AppResources
import ComposableArchitecture

public final class ChatInputView: UIToolbar {
  public init(store: Store<ChatInputState, ChatInputAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
    super.init(frame: .zero)

    setup()
    observeStore()
    setupUIActions()
    viewStore.send(.setup)
  }

  required init?(coder: NSCoder) { nil }

  deinit {
    viewStore.send(.destroy)
  }

  public func setMaxHeight(_ function: @escaping () -> CGFloat) {
    text.maxHeight = function
  }

  public func setupReply(message: String, sender: String) {
    viewStore.send(.text(.didTriggerReply(message, sender)))
  }

  let store: Store<ChatInputState, ChatInputAction>
  let viewStore: ViewStore<ChatInputState, ChatInputAction>
  private var cancellables: Set<AnyCancellable> = []

  let stack = UIStackView()
  let text = TextInputView()
  let audio = AudioView()
  let actions = ActionsView()

  private func setup() {
    isTranslucent = false
    translatesAutoresizingMaskIntoConstraints = false
    barTintColor = Asset.neutralWhite.color

    stack.axis = .vertical
    stack.spacing = 8
    stack.addArrangedSubview(text)
    stack.addArrangedSubview(audio)
    stack.addArrangedSubview(actions)

    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
      stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
      stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
      stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
    ])
  }

  private func observeStore() {
    viewStore.publisher
      .map(\.isPresentingActions)
      .combineLatest(viewStore.publisher.map(\.canAddAttachments))
      .sink { [unowned self] isPresentingActions, canAddAttachments in
        if canAddAttachments {
          text.showActionsButton.isHidden = isPresentingActions
          text.hideActionsButton.isHidden = !isPresentingActions
          actions.isHidden = !isPresentingActions
        } else {
          text.showActionsButton.isHidden = true
          text.hideActionsButton.isHidden = true
          actions.isHidden = true
        }
      }
      .store(in: &cancellables)

    viewStore.publisher
      .map(\.reply)
      .sink { [unowned self] reply in
        guard let reply = reply else {
          text.replyView.isHidden = true
          return
        }

        text.replyView.isHidden = false
        text.replyView.messageLabel.text = reply.text
        text.replyView.nameLabel.text = reply.name
      }.store(in: &cancellables)

    viewStore.publisher
      .map(\.audio)
      .map { $0 != nil }
      .sink { [unowned self] in
        text.isHidden = $0
        audio.isHidden = !$0
      }
      .store(in: &cancellables)

    viewStore.publisher
      .map(\.text.isEmpty)
      .combineLatest(viewStore.publisher.map(\.canAddAttachments))
      .sink { [unowned self] textIsEmpty, canAddAttachments in
        if canAddAttachments {
          text.sendButton.isHidden = textIsEmpty
          text.audioButton.isHidden = !textIsEmpty
        } else {
          text.sendButton.isHidden = false
          text.audioButton.isHidden = true
        }

        text.sendButton.isEnabled = !textIsEmpty
        text.placeholderView.isHidden = !textIsEmpty
      }
      .store(in: &cancellables)

    viewStore.publisher
      .map(\.text)
      .sink { [unowned self] in
        if text.textView.markedTextRange == nil {
          let range = text.textView.selectedTextRange
          text.textView.text = $0

          if let range = range {
            text.textView.selectedTextRange = range
          }
        } else if $0 == "" {
          text.textView.text = $0
        }

        text.updateHeight()
      }.store(in: &cancellables)

    let timeFormatter = DateComponentsFormatter()
    timeFormatter.unitsStyle = .positional
    timeFormatter.allowedUnits = [.minute, .second]
    timeFormatter.zeroFormattingBehavior = .pad

    viewStore.publisher
      .map(\.audio)
      .sink { [unowned self] in
        switch $0 {
        case let .idle(_, duration):
          audio.playButton.isHidden = false
          audio.stopPlaybackButton.isHidden = true
          audio.stopRecordingButton.isHidden = true
          audio.sendButton.isHidden = false
          audio.timeLabel.text = timeFormatter.string(from: duration)

        case let .recording(_, time):
          audio.playButton.isHidden = true
          audio.stopPlaybackButton.isHidden = true
          audio.stopRecordingButton.isHidden = false
          audio.sendButton.isHidden = true
          audio.timeLabel.text = timeFormatter.string(from: time)

        case let .playing(_, _, time):
          audio.playButton.isHidden = true
          audio.stopPlaybackButton.isHidden = false
          audio.stopRecordingButton.isHidden = true
          audio.sendButton.isHidden = false
          audio.timeLabel.text = timeFormatter.string(from: time)

        case .none:
          audio.playButton.isHidden = true
          audio.stopPlaybackButton.isHidden = true
          audio.stopRecordingButton.isHidden = true
          audio.sendButton.isHidden = true
          audio.timeLabel.text = ""
        }
      }
      .store(in: &cancellables)
  }

  private func setupUIActions() {
    text.textDidChange = { [unowned self] text in viewStore.send(.text(.didUpdate(text))) }

    text.replyView.abortButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.text(.didTapAbortReply)) }
      .store(in: &cancellables)

    text.showActionsButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.text(.didTapShowActions)) }
      .store(in: &cancellables)

    text.hideActionsButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.text(.didTapHideActions)) }
      .store(in: &cancellables)

    text.sendButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.text(.didTapSend)) }
      .store(in: &cancellables)

    text.audioButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.text(.didTapAudio)) }
      .store(in: &cancellables)

    audio.cancelButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.audio(.didTapCancel)) }
      .store(in: &cancellables)

    audio.playButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.audio(.didTapPlay)) }
      .store(in: &cancellables)

    audio.stopPlaybackButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.audio(.didTapStopPlayback)) }
      .store(in: &cancellables)

    audio.stopRecordingButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.audio(.didTapStopRecording)) }
      .store(in: &cancellables)

    audio.sendButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.audio(.didTapSend)) }
      .store(in: &cancellables)

    actions.libraryButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.actions(.didTapLibrary)) }
      .store(in: &cancellables)

    actions.cameraButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewStore.send(.actions(.didTapCamera)) }
      .store(in: &cancellables)
  }
}
