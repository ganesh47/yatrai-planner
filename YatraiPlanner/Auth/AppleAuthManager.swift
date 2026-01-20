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

struct AuthProfile {
    let userId: String
    let email: String?
    let displayName: String?
    let role: String?
}

@MainActor
final class AppleAuthManager: NSObject, ObservableObject, TokenProviding {
    @Published private(set) var currentToken: String?
    @Published private(set) var profile: AuthProfile?
    @Published private(set) var lastError: String?

    private let baseURL: URL

    init(baseURL: URL = AppConfig.workerBaseURL) {
        self.baseURL = baseURL
        super.init()
    }

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
        do {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self

            let result = try await withCheckedThrowingContinuation { continuation in
                self.signInContinuation = continuation
                controller.performRequests()
            }

            currentToken = result.token
            try await registerUser(token: result.token, fullName: result.fullName, email: result.email)
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    func handleAuthorization(_ authorization: ASAuthorization) async throws {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else {
            lastError = TokenError.missingToken.localizedDescription
            throw TokenError.missingToken
        }
        currentToken = tokenString
        try await registerUser(token: tokenString, fullName: credential.fullName, email: credential.email)
    }

    func handleAuthorizationError(_ error: Error) {
        lastError = error.localizedDescription
    }

    private func registerUser(token: String, fullName: PersonNameComponents?, email: String?) async throws {
        let url = baseURL.appendingPathComponent("auth/verify")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(AuthVerifyResponse.self, from: data)
        let formatter = PersonNameComponentsFormatter()
        let displayName = fullName.map { formatter.string(from: $0) }
        profile = AuthProfile(
            userId: decoded.sub,
            email: decoded.email ?? email,
            displayName: displayName,
            role: decoded.role
        )
        lastError = nil
    }

    private var signInContinuation: CheckedContinuation<AppleSignInResult, Error>?
}

extension AppleAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let tokenData = credential.identityToken,
           let tokenString = String(data: tokenData, encoding: .utf8) {
            let result = AppleSignInResult(
                token: tokenString,
                fullName: credential.fullName,
                email: credential.email
            )
            signInContinuation?.resume(returning: result)
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

private struct AppleSignInResult {
    let token: String
    let fullName: PersonNameComponents?
    let email: String?
}

private struct AuthVerifyResponse: Decodable {
    let sub: String
    let email: String?
    let role: String?
}
