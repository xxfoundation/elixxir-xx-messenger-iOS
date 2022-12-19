import Shared
import Combine
import AVFoundation

public final class Voxophone: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
  public enum State: Equatable {
    case empty(isLoudspeaker: Bool)
    case idle(URL, duration: TimeInterval, isLoudspeaker: Bool)
    case recording(URL, time: TimeInterval, isLoudspeaker: Bool)
    case playing(URL, duration: TimeInterval, time: TimeInterval, isLoudspeaker: Bool)
  }

  public override init() {
    super.init()
  }

  deinit {
    destroyPlayer()
    destroyRecorder()
    stopTimer()
  }

  @Published public private(set) var state: State = .empty(isLoudspeaker: false)

  private let session: AVAudioSession = .sharedInstance()
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer?
  private var timer: Timer?

  public func reset() {
    destroyPlayer()
    destroyRecorder()
    state = .empty(isLoudspeaker: false)
  }

  public func toggleLoudspeaker() {
    state.isLoudspeaker.toggle()
    setupSessionCategory()
  }

  public func load(_ url: URL) {
    destroyPlayer()
    destroyRecorder()
    do {
      let player = try setupPlayer(url: url)
      state = .idle(url, duration: player.duration, isLoudspeaker: state.isLoudspeaker)
    } catch {
      state = .empty(isLoudspeaker: state.isLoudspeaker)
    }
  }

  public func play() {
    guard let player = player, let url = player.url else { return }
    destroyRecorder()
    state = .playing(url, duration: player.duration, time: player.currentTime, isLoudspeaker: state.isLoudspeaker)
    startPlayback()
  }

  public func record() {
    let url = URL(fileURLWithPath: FileManager.xxPath + "/recording_\(Date.asTimestamp).m4a")

    destroyPlayer()
    destroyRecorder()
    let recorder = setupRecorder(url: url)
    state = .recording(url, time: recorder.currentTime, isLoudspeaker: state.isLoudspeaker)
    startRecording()
  }

  public func stop() {
    switch state {
    case .empty, .idle:
      return

    case .recording:
      finishRecording()

    case .playing(let url, let duration, _, let isLoudspeaker):
      stopPlayback()
      state = .idle(url, duration: duration, isLoudspeaker: isLoudspeaker)
    }
  }

  private func setupPlayer(url: URL) throws -> AVAudioPlayer {
    let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
    self.player = player
    return player
  }

  private func setupSessionCategory() {
    switch state {
    case .playing(_, _, _, let isLoud):
      if isLoud, session.category != .playback {
        try! session.setCategory(.playback, options: .duckOthers)
      }

      if !isLoud, session.category != .playAndRecord {
        try! session.setCategory(.playAndRecord, options: .duckOthers)
      }
    case .recording(_, _, _):
      if session.category != .playAndRecord {
        try! session.setCategory(.playAndRecord, options: .duckOthers)
      }
    default:
      break
    }
  }

  private func startPlayback() {
    guard let player = player else { return }
    try! session.setActive(true)
    setupSessionCategory()
    player.delegate = self
    player.prepareToPlay()
    player.play()
    startTimer()
  }

  private func stopPlayback() {
    guard let player = player else { return }
    player.stop()
  }

  private func destroyPlayer() {
    player?.delegate = nil
    player?.stop()
    player = nil
  }

  // MARK: - Recorder

  private func setupRecorder(url: URL) -> AVAudioRecorder {
    let recorder = try! AVAudioRecorder(url: url, settings: [
      AVFormatIDKey: kAudioFormatMPEG4AAC,
      AVSampleRateKey: 12000,
      AVNumberOfChannelsKey: 1
    ])
    self.recorder = recorder
    return recorder
  }

  private func startRecording() {
    guard let recorder = recorder else { return }
    try! session.setActive(true)
    setupSessionCategory()
    recorder.delegate = self
    recorder.record()
    startTimer()
  }

  private func finishRecording() {
    guard let recorder = recorder else { return }
    recorder.stop()
  }

  private func destroyRecorder() {
    recorder?.delegate = nil
    recorder?.stop()
    recorder = nil
  }

  // MARK: - Timer

  private func startTimer() {
    stopTimer()
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      self.timerTick()
    }
  }

  private func timerTick() {
    switch state {
    case .empty, .idle:
      stopTimer()

    case .recording(_, _, let isLoud):
      guard let recorder = recorder else { return }
      state = .recording(recorder.url, time: recorder.currentTime, isLoudspeaker: isLoud)

    case .playing(_, _, _, let isLoud):
      guard let player = player, let url = player.url else { return }
      state = .playing(url, duration: player.duration, time: player.currentTime, isLoudspeaker: isLoud)
    }
  }

  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: - AVAudioRecorderDelegate

  public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    guard flag else {
      state = .empty(isLoudspeaker: state.isLoudspeaker)
      return
    }
    load(recorder.url)
  }

  // MARK: - AVAudioPlayerDelegate

  public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    guard flag, let url = player.url else {
      state = .empty(isLoudspeaker: state.isLoudspeaker)
      return
    }
    load(url)
  }
}

public extension Voxophone.State {
  var isLoudspeaker: Bool {
    get {
      switch self {
      case .playing(_, _, _, let isLoud), .idle(_, _, let isLoud), .empty(let isLoud), .recording(_, _, let isLoud):
        return isLoud
      }
    } set {
      switch self {
      case .empty(_):
        self = .empty(isLoudspeaker: newValue)
      case let .idle(url, duration, _):
        self = .idle(url, duration: duration, isLoudspeaker: newValue)
      case let .playing(url, duration, time, _):
        self = .playing(url, duration: duration, time: time, isLoudspeaker: newValue)
      case let .recording(url, time, _):
        self = .recording(url, time: time, isLoudspeaker: newValue)
      }
    }
  }
}
