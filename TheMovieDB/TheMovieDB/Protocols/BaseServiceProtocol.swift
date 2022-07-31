//
//  BaseServiceProtocol.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 31/07/22.
//

import Foundation
import RxSwift

protocol BaseServiceProtocol {
    static func getMovies(page: Int) -> Observable<Result<MovieResult?, Error>>
}
