//
//  TopSongsResponse.swift
//  MusicExpress
//
//  Created by Антон Шарин on 23.04.2021.
//

import Foundation

// приходит с бэка и декодится в это

struct PlayList: Codable {
    let tracks: [Track]?
}

struct ArtistAlbums: Codable {
    let albums : [Song]?
    let artist : Song?
    let playlist : PlayList?
}



struct Track: Codable {
    let album_id: Int?
    let album_poster: String?
    let artist: String?
    let  artist_id: Int?
    let  audio: String?
    let  duration: Int?
    let  id: Int?
    let  index: Int?
    let  is_favorite: Bool?
    let  is_liked: Bool?
    let  title: String?
    
    
    enum CodingKeys : String,CodingKey {
        case album_id
        case album_poster = "album_poster"
        case artist = "artist"
        case  artist_id
        case  audio = "audio"
        case  duration
        case  id
        case  index
        case  is_favorite
        case  is_liked
        case  title = "title"
        
    }
}
struct Song: Codable {
    
    let duration: Int?
    let title: String? // альбомы трэк
    let artists : String?
    let id: Int?
    let audio : String? // трэк
    let album_poster : String? // трэк
    let artist_name : String? // альбомы
    let poster : String? //альбом
    let avatar: String? // артист
    let name: String? // артист
    let artist : String? // трэк
    let artist_id: Int?
    let tracks: [Track]?
    let playlist : PlayList?
    let description: String?
    let is_liked: Bool?
    let is_favorite: Bool?
    
  
    
  /*  enum CodingKeys : String, CodingKey {
        case title = "title"
        case id
        case artist_id
        case duration
        case audio = "audio"
        case album_poster = "album_poster"
        case artists = "artists"
        case artist_name = "artist_name"
        case poster = "poster"
        case avatar = "avatar"
        case name = "name"
        case artist = "artist"
        case tracks
    } */
}

struct PlaylistAPI: Codable {
     let playlist: PlayList
}
