//
//  ListingPhoto.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import Foundation

struct ListingPhoto {
    
    let id: Int
    
    let thumbnail: URL?
    let list: URL?
    let medium: URL?
    let gallery: URL?
    let large: URL?
    let fullSize: URL?
    
    init?(json: JSON) {
        guard let json = json["Value"] as? JSON,
            let id = json["PhotoId"] as? Int
            else { return nil }
        
        func url(_ value: Any?) -> URL? {
            return (value as? String).flatMap(URL.init(string:))
        }
        
        self.id = id
        self.thumbnail = url(json["Thumbnail"])
        self.list = url(json["List"])
        self.medium = url(json["Medium"])
        self.gallery = url(json["Gallery"])
        self.large = url(json["Large"])
        self.fullSize = url(json["FullSize"])
    }
}

// MARK: - Equatable

extension ListingPhoto: Equatable {
    
    static func == (lhs: ListingPhoto, rhs: ListingPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}
