//
//  SettingsModels.swift
//  MusicExpress
//
//  Created by Лексус on 25.04.2021.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}


