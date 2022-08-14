import UIKit
import Models
import Defaults
import XXModels
import Integration
import DependencyInjection

public final class PushHandler: PushHandling {
    private enum Constants {
        static let appGroup = "group.elixxir.messenger"
        static let usernamesSetting = "isShowingUsernames"
    }

    @KeyObject(.pushNotifications, defaultValue: false) var isPushEnabled: Bool

    let requestAuth: RequestAuth
    public static let defaultRequestAuth = UNUserNotificationCenter.current().requestAuthorization
    public typealias RequestAuth = (UNAuthorizationOptions, @escaping (Bool, Error?) -> Void) -> Void

    public var pushExtractor: PushExtractor
    public var contentsBuilder: ContentsBuilder
    public var applicationState: () -> UIApplication.State

    public init(
        requestAuth: @escaping RequestAuth = defaultRequestAuth,
        pushExtractor: PushExtractor = .live,
        contentsBuilder: ContentsBuilder = .live,
        applicationState: @escaping () -> UIApplication.State = { UIApplication.shared.applicationState }
    ) {
        self.requestAuth = requestAuth
        self.pushExtractor = pushExtractor
        self.contentsBuilder = contentsBuilder
        self.applicationState = applicationState
    }

    public func registerToken(_ token: Data) {
        do {
            let session = try DependencyInjection.Container.shared.resolve() as SessionType
            try session.registerNotifications(token)
        } catch {
            isPushEnabled = false
        }
    }

    public func requestAuthorization(
        _ completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        requestAuth(options) { granted, error in
            guard let error = error else {
                completion(.success(granted))
                return
            }

            completion(.failure(error))
        }
    }

    public func handlePush(
        _ userInfo: [AnyHashable: Any],
        _ completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        do {
            guard
                let pushes = try pushExtractor.extractFrom(userInfo).get(),
                applicationState() == .background,
                pushes.isEmpty == false
            else {
                completion(.noData)
                return
            }

            let content = contentsBuilder.build("New Messages Available", pushes.first!)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: Bundle.main.bundleIdentifier!, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if error == nil {
                    completion(.newData)
                } else {
                    completion(.failed)
                }
            }
        } catch {
            completion(.failed)
        }
    }

    public func handlePush(
        _ request: UNNotificationRequest,
        _ completion: @escaping (UNNotificationContent) -> Void
    ) {
        guard let pushes = try? pushExtractor.extractFrom(request.content.userInfo).get(), !pushes.isEmpty,
              let defaults = UserDefaults(suiteName: Constants.appGroup) else {
            return
        }

        let dbPath = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
            .appendingPathComponent("xxm_database")
            .appendingPathExtension("sqlite").path

        let tuples: [(String, Push)] = pushes.compactMap {
            guard let userId = $0.source,
                  let dbManager = try? Database.onDisk(path: dbPath),
                  let contact = try? dbManager.fetchContacts(.init(id: [userId])).first else {
                return ($0.type.unknownSenderContent!, $0)
            }

            if contact.isBlocked || contact.isBanned {
                return nil
            }

            if let showSender = defaults.value(forKey: Constants.usernamesSetting) as? Bool, showSender == true {
                let name = (contact.nickname ?? contact.username) ?? ""
                return ($0.type.knownSenderContent(name)!, $0)
            } else {
                return ($0.type.unknownSenderContent!, $0)
            }
        }

        tuples
            .map(contentsBuilder.build)
            .forEach { completion($0) }
    }

    public func handleAction(
        _ router: PushRouter,
        _ userInfo: [AnyHashable : Any],
        _ completion: @escaping () -> Void
    ) {
        guard let typeString = userInfo["type"] as? String,
              let type = PushType(rawValue: typeString) else {
            completion()
            return
        }

        let route: PushRouter.Route

        switch type {
        case .e2e:
            guard let source = userInfo["source"] as? Data else {
                completion()
                return
            }

            route = .contactChat(id: source)

        case .group:
            guard let source = userInfo["source"] as? Data else {
                completion()
                return
            }

            route = .groupChat(id: source)

        case .request, .groupRq:
            route = .requests

        case .silent, .`default`:
            fatalError("Silent/Default push types should be filtered at this point")

        case .reset, .endFT, .confirm:
            route = .requests
        }

        router.navigateTo(route, completion)
    }
}
