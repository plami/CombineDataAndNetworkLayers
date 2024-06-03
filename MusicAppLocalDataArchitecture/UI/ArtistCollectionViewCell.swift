//
//  ArtistCollectionViewCell.swift
//  MusicAppLocalStorage
//
//  Created by Plamena Nikolova on 10.05.24.
//

import UIKit
import Combine

protocol ArtistConfigurable {
    func configure(with artist: ArtistWrapper)
}

protocol FavouritesViewDelegate {
    func addToFavouritesByIndex(at index: IndexPath)
}

class ArtistCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var imageArtistPhoto: UIImageView!
    @IBOutlet private weak var labelArtistName: UILabel!
    @IBOutlet private weak var labelBiggestHit: UILabel!
    @IBOutlet private weak var labelLastAlbum: UILabel!
    @IBOutlet private weak var photoFavourites: UIImageView! {
        didSet {
            photoFavourites.isUserInteractionEnabled = true
            photoFavourites.image = UIImage(systemName: "star")
        }
    }
    
    @IBOutlet private weak var defaultPhoto: UIImageView!
    
    var delegate: FavouritesViewDelegate!
    var index: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addToFavourites(_:)))
        photoFavourites.addGestureRecognizer(tapGesture)
    }
    
    @objc func addToFavourites(_ sender: UITapGestureRecognizer) {
        if photoFavourites.image == UIImage(systemName: "star") {
            photoFavourites.image = UIImage(systemName: "star.fill")
        } else {
            photoFavourites.image = UIImage(systemName: "star")
        }
//        delegate.addToFavouritesByIndex(at: index)
    }
}

extension ArtistCollectionViewCell: ArtistConfigurable {
    
    func configure(with artist: ArtistWrapper) {
        
        self.labelArtistName.text = artist.wrappedName
        self.labelBiggestHit.text = artist.wrappedBiggestHit
        self.labelLastAlbum.text = artist.wrappedLastAlbum
        //the placeholder is displayed synchronously
        self.imageArtistPhoto.image = nil
        self.defaultPhoto.isHidden = false

        Task {
            if artist.wrappedIsPhotoAvailable {
                guard let imageArtist = UIImage(data: artist.wrappedPhoto) else { return }
                //prefetch mechanism -> get the image before the cell is visible (the mechanism is asynchronously)
                let staticSize = CGSize(width: 100, height: 100)
                imageArtist.prepareThumbnail(of: staticSize, completionHandler: { thumbnailImage in
                    DispatchQueue.main.async {
                        self.imageArtistPhoto.image = thumbnailImage
                        self.defaultPhoto.isHidden = true
                    }
                })
                
//                imageArtist.prepareForDisplay { preparedImage in
//                    DispatchQueue.main.async {
//                        self.imageArtistPhoto.image = preparedImage
//                        self.defaultPhoto.isHidden = true
//                    }
//                }
            }
        }
    }
}
