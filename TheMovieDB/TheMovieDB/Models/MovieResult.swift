//
//  MovieResult.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 31/07/22.
//

import UIKit

struct MovieResult: Codable {
    let totalResults: Int?
    let totalPages: Int?
    let page: Int?
    let results: [Movie]?

    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}
