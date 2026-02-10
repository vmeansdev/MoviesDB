import Foundation
@testable import AppHttpKit

final class MockClient: Client {
    var requestCallsCount = 0
    var requestCalledOnce: Bool { requestCallsCount == 1 }
    var requestCalled: Bool { requestCallsCount > 0 }
    var responseReturnValue: Response?
    var responseReturnClosure: ((Request) -> Response)?

    func request(_ httpRequest: Request) async throws -> Response {
        requestCallsCount += 1
        if let closure = responseReturnClosure {
            return closure(httpRequest)
        }
        guard let responseReturnValue else {
            fatalError("MockClient.responseReturnValue must be set before calling request.")
        }
        return responseReturnValue
    }
}
