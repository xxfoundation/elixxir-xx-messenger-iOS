import AVFoundation
import AudioToolbox

struct DeviceFeedback {
  enum Haptic: UInt32 {
    case impact = 1520
    case notification = 1521
    case selection = 1519
  }

  enum Alert: UInt32 {
    case smsSent = 1004
    case smsReceived = 1003
    case contactAdded = 1117
  }

  private init() {}

  static func sound(_ alert: Alert) {
    try? AVAudioSession
      .sharedInstance()
      .setCategory(.ambient, mode: .default, options: .mixWithOthers)

    AudioServicesPlaySystemSound(alert.rawValue)
  }

  static func shake(_ haptic: Haptic) {
    try? AVAudioSession
      .sharedInstance()
      .setCategory(.ambient, mode: .default, options: .mixWithOthers)

    AudioServicesPlaySystemSound(haptic.rawValue)
  }
}
