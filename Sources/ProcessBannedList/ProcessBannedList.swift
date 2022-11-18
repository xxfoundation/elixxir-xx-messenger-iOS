import Foundation
import SwiftCSV
import XCTestDynamicOverlay

public struct ProcessBannedList {
  public enum ElementError: Swift.Error {
    case missingUserId
    case invalidUserId(String)
  }

  public enum Error: Swift.Error {
    case invalidData
    case csv(Swift.Error)
  }

  public typealias ForEach = (Result<Data, ElementError>) -> Void
  public typealias Completion = (Result<Void, Error>) -> Void

  public var run: (Data, ForEach, Completion) -> Void

  public func callAsFunction(
    data: Data,
    forEach: ForEach,
    completion: Completion
  ) {
    run(data, forEach, completion)
  }
}

extension ProcessBannedList {
  public static let live = ProcessBannedList { data, forEach, completion in
    guard let csvString = String(data: data, encoding: .utf8) else {
      completion(.failure(.invalidData))
      return
    }
    let csv: EnumeratedCSV
    do {
      csv = try EnumeratedCSV(string: csvString)
    }
    catch {
      completion(.failure(.csv(error)))
      return
    }
    csv.rows.forEach { row in
      guard let userIdString = row.first else {
        forEach(.failure(.missingUserId))
        return
      }
      guard let userId = Data(base64Encoded: userIdString) else {
        forEach(.failure(.invalidUserId(userIdString)))
        return
      }
      forEach(.success(userId))
    }
    completion(.success(()))
  }
}

extension ProcessBannedList {
  public static let unimplemented = ProcessBannedList { _, _, _ in
    let run: () -> Void = XCTUnimplemented("\(Self.self)")
    run()
  }
}
