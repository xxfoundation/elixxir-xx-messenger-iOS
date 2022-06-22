import Models
import XXModels
import Foundation

final class GroupManagerMock: GroupManagerInterface {
    func join(_: Data) throws {}

    func leave(_: Data) throws {}

    func send(_: Data, to: Data) -> Result<(Int64, Data?, String), Error> {
        .success((1, nil, "https://www.google.com.br"))
    }

    func create(
        me: Data,
        name: String,
        welcome: String?,
        with: [Data],
        _: @escaping (Result<Group, Error>) -> Void
    ) {}
}
