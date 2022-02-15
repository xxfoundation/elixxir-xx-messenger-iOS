import Foundation
import SwiftyBeaver

public typealias LogClosure = (Any, String, String, Int) -> Void

public struct XXLogger {
    var logInfo: LogClosure
    var logDebug: LogClosure
    var logError: LogClosure
    var logWarning: LogClosure
    var logVerbose: LogClosure

    public init(
        info: @escaping LogClosure,
        debug: @escaping LogClosure,
        error: @escaping LogClosure,
        warning: @escaping LogClosure,
        verbose: @escaping LogClosure
    ) {
        self.logInfo = info
        self.logDebug = debug
        self.logError = error
        self.logWarning = warning
        self.logVerbose = verbose
    }

    public func info(_ contents: Any, file: String = #file, function: String = #function, line: Int = #line) {
        logInfo(contents, file, function, line)
    }

    public func debug(_ contents: Any, file: String = #file, function: String = #function, line: Int = #line) {
        logDebug(contents, file, function, line)
    }

    public func error(_ contents: Any, file: String = #file, function: String = #function, line: Int = #line) {
        logError(contents, file, function, line)
    }

    public func warning(_ contents: Any, file: String = #file, function: String = #function, line: Int = #line) {
        logWarning(contents, file, function, line)
    }

    public func verbose(_ contents: Any, file: String = #file, function: String = #function, line: Int = #line) {
        logVerbose(contents, file, function, line)
    }
}

public extension XXLogger {
    static func stop() {
        let log = SwiftyBeaver.self
        log.removeAllDestinations()

        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("swiftybeaver.log")

        try? "".write(to: url, atomically: false, encoding: .utf8)
    }

    static func start() {
        let log = SwiftyBeaver.self

        let console = ConsoleDestination()
        console.levelString.error = "🟥"
        console.levelString.info = "✅"
        console.levelString.warning = "[BACKEND]"
        console.levelString.verbose = "[VERBOSE]"
        console.format = "$DHH:mm:ss$d $L $N.$F:$l $M"

        let file = FileDestination()
        file.levelString.error = "🟥"
        file.levelString.info = "✅"
        file.levelString.warning = "[BACKEND]"
        file.minLevel = .debug
        file.format = "$DHH:mm:ss$d $L $N.$F:$l $M"

        log.addDestination(console)
        log.addDestination(file)
    }

    static func live() -> Self {
        let log = SwiftyBeaver.self

        return .init {
            log.info($0, $1, $2, line: $3)
        } debug: {
            log.debug($0, $1, $2, line: $3)
        } error: {
            log.error($0, $1, $2, line: $3)
        } warning: {
            log.warning($0, $1, $2, line: $3)
        } verbose: {
            log.verbose($0, $1, $2, line: $3)
        }
    }

    static let noop: Self = .init(
        info: { _,_,_,_ in },
        debug: { _,_,_,_ in },
        error: { _,_,_,_ in },
        warning: { _,_,_,_ in },
        verbose: { _,_,_,_ in }
    )
}
