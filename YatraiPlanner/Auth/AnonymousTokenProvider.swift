import Foundation

struct AnonymousTokenProvider: TokenProviding {
    func fetchToken() async throws -> String {
        throw TokenError.missingToken
    }
}
