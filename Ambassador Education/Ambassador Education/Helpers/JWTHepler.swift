//
//  JWTHepler.swift
//  Ambassador Education
//
//  Created by IE Mac on 02/08/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit
import SwiftJWT

struct MyClaims: Claims {
    let iat: Int
    let exp: Int
    let id: String
}


class JWTHelper: NSObject {

    static let shared = JWTHelper()

    private let jwtSecret = "f076c09142677d1e34adb3a59355c977f35c13ed8fc905bb953bec0fe61c6a4f"
    // Function to create a JWT token
    private func createJWT(userID: String) -> String? {
        let currentTime = Int(Date().timeIntervalSince1970)
        let oneDayInSeconds = 24 * 60 * 60
        let expirationTime = currentTime + oneDayInSeconds

        // Define the payload (claims)
        let claims = MyClaims(
            iat: currentTime,
            exp: expirationTime,
            id: userID
        )

        // Define the header
        var jwtHeader = Header()
        jwtHeader.typ = "JWT"
        //jwtHeader.alg = "HS256"

        var jwt = JWT(header: jwtHeader, claims: claims)

        let jwtSigner = JWTSigner.hs256(key: Data(jwtSecret.utf8))
        do {
            let jwtToken = try jwt.sign(using: jwtSigner)
            UserDefaultsManager.manager.saveJwtToken(token: jwtToken)
            return jwtToken
        } catch {
            print("Failed to sign JWT: \(error)")
            return nil
        }
    }


    // Function to refresh JWT if needed
    private func refreshJWTIfNeeded(currentToken: String, userID: String) -> String? {
        let verifier = JWTVerifier.hs256(key: Data(jwtSecret.utf8))

        do {
            let jwtDecoder = JWTDecoder(jwtVerifier: verifier)
            let jwt = try jwtDecoder.decode(JWT<MyClaims>.self, fromString: currentToken)
            let payload = jwt.claims
            let expirationDate = Date(timeIntervalSince1970: TimeInterval(payload.exp))
            if expirationDate <= Date() {
                return createJWT(userID: userID)
            }
            return currentToken
        } catch {
            print("Failed to decode or verify JWT: \(error)")
            return nil
        }
    }

    func getStogoUrl() -> String? {
        let url = "https://dev.stogoworld.com?token="
        let userId = UserDefaultsManager.manager.getUserId()
        if let token = UserDefaultsManager.manager.getJwtToken() {
            if let refreshToken = refreshJWTIfNeeded(currentToken: token, userID: userId) {
                return url + refreshToken
            }
        } else {
            if let token = createJWT(userID: userId) {
                return url + token
            }
        }
        return nil
    }

}
