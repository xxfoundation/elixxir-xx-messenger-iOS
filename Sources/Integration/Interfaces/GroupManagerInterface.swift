import Models
import XXModels
import Foundation

public protocol GroupManagerInterface {

    func join(_: Data) throws

    func leave(_: Data) throws

    func send(_: Data, to: Data) -> Result<(Int64, Data?, String), Error>

    func create(me: Data, name: String, welcome: String?, with: [Data], _: @escaping (Result<Group, Error>) -> Void)
}
