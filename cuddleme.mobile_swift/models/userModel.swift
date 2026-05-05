//
//  userModel.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 04/09/2024.
//

import Foundation

struct User: Identifiable, Codable {
  let id: String
  let fullname: String
  let email: String
}
