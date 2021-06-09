//
//  UserProfile.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import Foundation

struct UserProfile: Codable {
    let id: Int
    let username: String
    let avatar: String

    enum CodingKeys : String, CodingKey {
        case id
        case username = "username"
        case avatar = "avatar"
    }
}
