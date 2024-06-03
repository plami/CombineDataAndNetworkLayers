//
//  Artist+CoreDataProperties.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 19.05.24.
//
//

import Foundation
import CoreData


extension Artist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist")
    }

    @NSManaged public var artist: String?
    @NSManaged public var artistId: Int16
    @NSManaged public var biggest_hit: String?
    @NSManaged public var isPhotoAvailable: Bool
    @NSManaged public var last_album: String?
    @NSManaged public var photo: Data?
    @NSManaged public var photo_url: String?
    @NSManaged public var photoThumbnail: Data?
    @NSManaged public var isFavourite: Bool

}

extension Artist : Identifiable {

}
