import Combine
import XXLogger
import Defaults
import Foundation
import CrashReporting
import DependencyInjection

struct AdvancedViewState: Equatable {
    var isRecordingLogs = false
    var isCrashReporting = false
}

final class AdvancedViewModel {
    @KeyObject(.recordingLogs, defaultValue: true) var isRecordingLogs: Bool
    @KeyObject(.crashReporting, defaultValue: true) var isCrashReporting: Bool

    @Dependency private var logger: XXLogger
    @Dependency private var crashReporter: CrashReporter

    var sharePublisher: AnyPublisher<URL, Never> { shareRelay.eraseToAnyPublisher() }
    private let shareRelay = PassthroughSubject<URL, Never>()

    var state: AnyPublisher<AdvancedViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<AdvancedViewState, Never>(.init())

    func loadCachedSettings() {
        stateRelay.value.isRecordingLogs = isRecordingLogs
        stateRelay.value.isCrashReporting = isCrashReporting
    }

    func didToggleRecordLogs() {
        if isRecordingLogs == true {
            XXLogger.stop()
        } else {
            XXLogger.start()
        }

        isRecordingLogs.toggle()
        stateRelay.value.isRecordingLogs.toggle()
    }

    func didTapDownloadLogs() {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        shareRelay.send(url.appendingPathComponent("swiftybeaver.log"))
    }

    func didToggleCrashReporting() {
        isCrashReporting.toggle()
        stateRelay.value.isCrashReporting.toggle()
        crashReporter.setEnabled(isCrashReporting)
    }
}
