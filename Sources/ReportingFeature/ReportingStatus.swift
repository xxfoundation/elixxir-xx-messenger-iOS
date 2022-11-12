import Combine

public struct ReportingStatus {
  public var isOptional: () -> Bool
  public var isEnabled: () -> Bool
  public var isEnabledPublisher: () -> AnyPublisher<Bool, Never>
  public var enable: (Bool) -> Void
}

extension ReportingStatus {
  public static func live(
    isOptional: ReportingStatusIsOptional = .live(),
    isEnabled: ReportingStatusIsEnabled = .live()
  ) -> ReportingStatus {
    ReportingStatus(
      isOptional: {
        isOptional.get()
      },
      isEnabled: {
        if isOptional.get() == false {
          return true
        }

        return isEnabled.get()
      },
      isEnabledPublisher: {
        if isOptional.get() == false {
          return Just(true).eraseToAnyPublisher()
        }

        return isEnabled.publisher()
      },
      enable: { enabled in
        isEnabled.set(enabled)
      }
    )
  }

  public static func mock(
    isEnabled: Bool = false,
    isOptional: Bool = true
  ) -> ReportingStatus {
    let isEnabledSubject = CurrentValueSubject<Bool, Never>(isEnabled)
    return ReportingStatus(
      isOptional: { isOptional },
      isEnabled: { isEnabledSubject.value },
      isEnabledPublisher: { isEnabledSubject.eraseToAnyPublisher() },
      enable: { isEnabledSubject.send($0) }
    )
  }
}
