//
//  userModel.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 04/09/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    var stellarPublicKey: String?

    // ISS-012c: Extended profile fields
    var bio: String?
    var occupation: String?
    var age: Int?
    var interests: [String]?
    var photoURLs: [String]?
    var isPremiumUser: Bool?
    /// 0.0–1.0 — derived from how many optional fields are filled in.
    var profileSetupCompletion: Double?
}
