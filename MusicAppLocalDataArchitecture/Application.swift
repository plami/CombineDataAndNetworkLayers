//
//  Application.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 15.05.24.
//

import UIKit
import Combine

class Application {
    static let shared = Application()

    private let dataManager = DataManager.shared
    private let networkManager = NetworkManager.shared
    
    func updateArtists() {
        networkManager.getArtists { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                DispatchQueue.main.async {
                    self.dataManager.processSavingArtists(artists: result)
                }
                for artist in result {
                    DispatchQueue.global().async {
                        self.getArtistsImages(url: artist.photoUrl, artist: artist)
                    }
                }
            }
        }
    }
    
    func getArtists() {
        self.dataManager.getAllArtists()
    }
    
    
    func getArtistsImages(url: String, artist: ArtistModel) {
        guard let urlRequest = URL(string: url) else { return }
        networkManager.getImageDataForArtist(url: urlRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                DispatchQueue.main.async {
                    self.dataManager.processSavingArtistsPhoto(photo: result, artist: artist)
                }
            }
        }
    }
    
    func addArtistToFavourite(artist: ArtistModelProtocol) {
        self.dataManager.processAddingArtistsToFavourite(isFavourite: true, artist: artist)
    }
    
    func getArtistByURL(url: String) throws -> ArtistWrapper {
        return try dataManager.getArtistByUrl(byUrl: url)
    }

    var artistsPublisher: AnyPublisher<[ArtistWrapper], Never> {
        dataManager.$artists.eraseToAnyPublisher()
    }
    
    var artists: [ArtistWrapper] { dataManager.artists }
}

extension ArtistModel : ArtistModelProtocol { }
