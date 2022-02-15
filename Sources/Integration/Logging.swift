import Bindings
import XXLogger
import CrashReporting
import DependencyInjection
import Foundation
import os

let oslogger = Logger(subsystem: "logs_xxmessenger", category: "Logging.swift")

final class BindingsError: NSObject, BindingsClientErrorProtocol {
    func report(_ source: String?, message: String?, trace: String?) {
        var content = ""

        content += String(describing: source) + "\n"
        content += String(describing: message) + "\n"
        content += String(describing: trace)

        log(string: content, type: .error)
    }
}

extension Error {
    func friendly() -> NSError {
        log(string: "Switching to friendly error from: \(localizedDescription)", type: .error)
        
        let error = BindingsErrorStringToUserFriendlyMessage(localizedDescription)
        if error.hasPrefix("UR") {
            let crashReporter = try! DependencyInjection.Container.shared.resolve() as CrashReporter
            crashReporter.sendError(self as NSError)
            return NSError.create("Unexpected error. Please try again")
        } else {
            return NSError.create(error)
        }
    }
}

enum LogType {
    case info
    case error
    case crumbs
    case bindings

    var icon: String {
        switch self {
        case .error:
            return "🟥"
        case .crumbs:
            return "🍞"
        case .bindings:
            return "⚙️"
        case .info:
            return "✅"
        }
    }
}

func log(
    string: String? = nil,
    type: LogType,
    function: String = #function,
    file: String = #file,
    line: Int = #line
) {
    var trimmedFile = ""
    if let index = file.lastIndex(of: "/") {
        let afterEqualsTo = String(file.suffix(from: index).dropFirst())
        trimmedFile = afterEqualsTo
    }

    let content = "\(type.icon) \(function) @\(trimmedFile):\(line) \(string ?? "")"
    let logger = try! DependencyInjection.Container.shared.resolve() as XXLogger

    switch type {
    case .info:
        logger.info(content)
        oslogger.info("\(content)")
    case .error:
        logger.error(content)
        oslogger.error("\(content)")
    case .crumbs:
        logger.debug(content)
    case .bindings:
        logger.warning(content)
    }
}
