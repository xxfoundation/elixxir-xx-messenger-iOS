import UIKit
import Foundation

public extension FileManager {
    static var root: URL {
        self.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("xxm/")
    }

    static var xxContents: [String]? {
        try? self.default.contentsOfDirectory(atPath: root.path)
    }

    static var xxPath: String {
        if xxContents == nil {
            do {
                try self.default.createDirectory(
                    at: root,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch {
                fatalError(error.localizedDescription)
            }
        }

        return root.path
    }

    static func xxCleanup() {
        guard let files = xxContents else { return }
        files.forEach { try? FileManager.default.removeItem(at: root.appendingPathComponent($0)) }
    }

    static func url(for fileName: String) -> URL? {
        root.appendingPathComponent("\(fileName)")
    }

    static func store(data: Data, name: String, type: String) throws -> URL {
        guard let url = Self.url(for: "\(name).\(type)") else {
            throw NSError.create("The file path could not be retrieved")
        }

        try data.write(to: url)
        return url
    }

    static func delete(name: String, type: String) {
        if let url = Self.url(for: "\(name).\(type)") {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    static func dummyAudio() -> Data {
        let url = Bundle.module.url(forResource: "dummy_audio", withExtension: "m4a")
        return try! Data(contentsOf: url!)
    }

    static func retrieve(name: String, type: String) -> Data? {
        guard let url = Self.url(for: "\(name).\(type)") else { return nil }
        return try? Data(contentsOf: url)
    }

    static func retrieve(imageNamed name: String) -> UIImage? {
        guard let url = Self.url(for: name) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}
