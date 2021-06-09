//
//  SearchReslutResponse.swift
//  MusicExpress
//
//  Created by Антон Шарин on 26.04.2021.
//

import Foundation
// приходит с поиска
struct SearchReslutResponse: Codable {

  let albums : [Song]?
  let artists : [Song]?
  let tracks: [Song]?

   
    
}

struct SearchAlbumsResponse:Codable {
    
}

