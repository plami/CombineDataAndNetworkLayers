//
//  ArtistWrapper.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 15.05.24.
//

import UIKit
import Combine
import CoreData

class ArtistWrapper: ObservableObject {
    
    private var wrappedArtist: Artist {
        didSet {
            objectWillChange.send()
        }
    }
    
    init(artist: Artist) {
        self.wrappedArtist = artist
    }
    
    var wrappedName: String { wrappedArtist.artist ?? "" }
    var wrappedBiggestHit: String { wrappedArtist.biggest_hit ?? ""  }
    var wrappedLastAlbum: String { wrappedArtist.last_album ?? ""  }
    var wrappedPhotoUrl: String { wrappedArtist.photo_url ?? ""  }
    var wrappedIsPhotoAvailable: Bool { wrappedArtist.isPhotoAvailable }
    var wrappedPhotoThumbnail: Data { wrappedArtist.photoThumbnail ?? Data() }
    var wrappedIsFavourite: Bool { wrappedArtist.isFavourite }
    var wrappedPhoto: Data { wrappedArtist.photo ?? Data()  }
//    var wrappedArtistId: Int { Int(wrappedArtist.artistId) }
}

extension ArtistWrapper : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedArtist.artist)
    }
    
    static func == (lhs: ArtistWrapper, rhs: ArtistWrapper) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

