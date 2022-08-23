import Combine
import XXLogger
import Defaults
import Foundation
import CrashReporting
import ReportingFeature
import DependencyInjection

struct AdvancedViewState: Equatable {
    var isRecordingLogs = false
    var isCrashReporting = false
    var isShowingUsernames = false
    var isReportingEnabled = false
    var isReportingOptional = false
}

final class SettingsAdvancedViewModel {
    @KeyObject(.recordingLogs, defaultValue: true) var isRecordingLogs: Bool
    @KeyObject(.crashReporting, defaultValue: true) var isCrashReporting: Bool

    private let isShowingUsernamesKey = "isShowingUsernames"

    @Dependency private var logger: XXLogger
    @Dependency private var crashReporter: CrashReporter
    @Dependency private var reportingStatus: ReportingStatus

    var sharePublisher: AnyPublisher<URL, Never> { shareRelay.eraseToAnyPublisher() }
    private let shareRelay = PassthroughSubject<URL, Never>()

    var state: AnyPublisher<AdvancedViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<AdvancedViewState, Never>(.init())

    func loadCachedSettings() {
        stateRelay.value.isRecordingLogs = isRecordingLogs
        stateRelay.value.isCrashReporting = isCrashReporting
        stateRelay.value.isReportingEnabled = reportingStatus.isEnabled()
        stateRelay.value.isReportingOptional = reportingStatus.isOptional()

        guard let defaults = UserDefaults(suiteName: "group.elixxir.messenger") else {
            print("^^^ Couldn't access user defaults in the app group container \(#file):\(#line)")
            return
        }

        guard let isShowingUsernames = defaults.value(forKey: isShowingUsernamesKey) as? Bool else {
            defaults.set(false, forKey: isShowingUsernamesKey)
            return
        }

        stateRelay.value.isShowingUsernames = isShowingUsernames
    }

    func didToggleShowUsernames() {
        stateRelay.value.isShowingUsernames.toggle()

        guard let defaults = UserDefaults(suiteName: "group.elixxir.messenger") else {
            print("^^^ Couldn't access user defaults in the app group container \(#file):\(#line)")
            return
        }

        defaults.set(stateRelay.value.isShowingUsernames, forKey: isShowingUsernamesKey)
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

    func didToggleReporting() {
        reportingStatus.enable(reportingStatus.isEnabled())
        stateRelay.value.isReportingEnabled.toggle()
    }
}
