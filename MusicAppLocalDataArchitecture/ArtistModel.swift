//
//  ArtistModel.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 19.05.24.
//

import Foundation

struct ArtistModel {
    var name: String
    var biggestHit: String
    var lastAlbum: String
    var photoUrl: String
//    var artistId: Int
    
    private enum CodingKeys: String, CodingKey {
        case name = "artist"
        case biggestHit = "biggest_hit"
        case lastAlbum = "last_album"
        case photoUrl = "photo_url"
//        case artistId = "ArtistId"
    }
    
    init(
        artist: String,
        biggest_hit: String,
        last_album: String,
        photo_url: String
//        artistId: Int
    ) {
        self.name = artist
        self.biggestHit = biggest_hit
        self.lastAlbum = last_album
        self.photoUrl = photo_url
//        self.artistId = artistId
    }
}

extension ArtistModel: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.biggestHit = try container.decode(String.self, forKey: .biggestHit)
        self.lastAlbum = try container.decodeIfPresent(String.self, forKey: .lastAlbum) ?? ""
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl) ?? ""
//        self.artistId = try c.decodeIfPresent(Int.self, forKey: .artistId) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(biggestHit, forKey: .biggestHit)
        try container.encode(lastAlbum, forKey: .lastAlbum)
        try container.encode(photoUrl, forKey: .photoUrl)
//        try? c.encode(artistId, forKey: .artistId)
    }
}
