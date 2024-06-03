//
//  DataManager.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 15.05.24.
//

import Foundation
import Combine
import CoreData

protocol ArtistModelProtocol {
    var name: String { get }
    var biggestHit: String { get }
    var lastAlbum: String { get }
    var photoUrl: String { get }
}

class DataManager {
    static let shared = DataManager()
    private var coreDataManager = CoreDataManager(modelName: "CoreDataModel")
    
    @Published var artists = [ArtistWrapper]()
    
     //save artists in localData
    func processSavingArtists(artists: [ArtistModelProtocol]) {
        do {
            try artists.forEach {
                try self.saveArtist(artistInfo: $0)
            }
        } catch {
            print("Failed to save artist", error)
        }
    }
    
    //save artists photo in localData
   func processSavingArtistsPhoto(photo: Data, artist: ArtistModelProtocol) {
       do {
           print("Artist image \(photo)")
           try self.updateArtist(artistInfo: photo, networkArtist: artist)
       } catch {
           print("Failed saving photo to artist", error)
       }
   }
    
    //save artists photo in localData
   func processAddingArtistsToFavourite(isFavourite: Bool, artist: ArtistModelProtocol) {
       do {
           try self.addArtistToFavourites(artistInfo: isFavourite, networkArtist: artist)
       } catch {
           print("Failed adding artists to favourites", error)
       }
   }
    
    
    func getArtistByUrl(byUrl url: String) throws -> ArtistWrapper {
        let artist = (try? coreDataManager.fetchArtist(byUrl: url))!
        return ArtistWrapper(artist: artist)
    }
    
    private func updateArtist(artistInfo photo: Data, networkArtist: ArtistModelProtocol) throws {
        let artist = try coreDataManager.fetchArtist(byUrl: networkArtist.photoUrl)
        artist?.photo = photo
        coreDataManager.saveContext()
    }
    
    private func addArtistToFavourites(artistInfo isFavourite: Bool, networkArtist: ArtistModelProtocol) throws {
        let artist = try coreDataManager.fetchArtist(byUrl: networkArtist.photoUrl)
        artist?.isFavourite = isFavourite
        coreDataManager.saveContext()
    }
    
    private func saveArtist(artistInfo o: ArtistModelProtocol) throws {
        let artist = try coreDataManager.fetchArtist(byUrl: o.photoUrl) ?? coreDataManager.createArtist()
        artist.artist = o.name
        artist.biggest_hit = o.biggestHit
        artist.last_album = o.lastAlbum
        artist.photo_url = o.photoUrl
        artist.isPhotoAvailable = false
        if o.photoUrl != "" {
            artist.isPhotoAvailable = true
        }
        coreDataManager.saveContext()
        artists = [ArtistWrapper(artist: artist)]
    }
    
    func getAllArtists() {
        
        do {
            let artistsLocalDB = try coreDataManager.fetchAllArtists()
            var wrappedArtists = [ArtistWrapper]()
            for artist in artistsLocalDB {
                wrappedArtists.append(ArtistWrapper(artist: artist))
            }
            artists = wrappedArtists
        } catch {
            print(error)
        }
    }
}

fileprivate extension CoreDataManager {

    func createArtist() -> Artist {
        let localArtist = Artist(entity: Artist.entity(), insertInto: managedObjectContext)

        localArtist.artist = ""
        localArtist.artistId = 0
        localArtist.biggest_hit = ""
        localArtist.isPhotoAvailable = false
        localArtist.last_album = ""
        localArtist.photo = Data()
        localArtist.photo_url = ""
        localArtist.photoThumbnail = Data()
        
        return localArtist
    }
    
    func fetchAllArtists() throws -> [Artist] {
        let fetchRequest = Artist.fetchRequest()
        return try managedObjectContext.fetch(fetchRequest)
    }
    
    func fetchArtist(byUrl url: String) throws -> Artist? {
        let fetchRequest = Artist.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "photo_url == %@", url)
        let res = try managedObjectContext.fetch(fetchRequest)
        return res.first
    }
}
