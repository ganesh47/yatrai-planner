import AuthenticationServices
import Combine
import Foundation
import UIKit

protocol TokenProviding {
    func fetchToken() async throws -> String
}

enum TokenError: Error {
    case missingToken
}

@MainActor
final class AppleAuthManager: NSObject, ObservableObject, TokenProviding {
    @Published private(set) var currentToken: String?

    func fetchToken() async throws -> String {
        if let token = currentToken {
            return token
        }
        try await signIn()
        if let token = currentToken {
            return token
        }
        throw TokenError.missingToken
    }

    func signIn() async throws {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        let result = try await withCheckedThrowingContinuation { continuation in
            self.signInContinuation = continuation
            controller.performRequests()
        }

        currentToken = result
    }

    private var signInContinuation: CheckedContinuation<String, Error>?
}

extension AppleAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let tokenData = credential.identityToken,
           let tokenString = String(data: tokenData, encoding: .utf8) {
            signInContinuation?.resume(returning: tokenString)
        } else {
            signInContinuation?.resume(throwing: TokenError.missingToken)
        }
        signInContinuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        signInContinuation?.resume(throwing: error)
        signInContinuation = nil
    }
}

extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap { $0.windows }.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}
