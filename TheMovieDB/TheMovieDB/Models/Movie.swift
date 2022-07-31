//
//  Movie.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 31/07/22.
//

import UIKit

struct Movie: Codable {
    var originalTitle: String? = ""
    var backdropPath: String? = ""
    
    private enum CodingKeys: String, CodingKey {
        case originalTitle = "original_title"
        case backdropPath = "backdrop_path"
    }
}
