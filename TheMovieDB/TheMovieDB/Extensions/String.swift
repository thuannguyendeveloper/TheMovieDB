//
//  String.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 01/08/2022.
//

import UIKit

extension String {
    func makeTheFullImagePath() -> String {
        return "http://image.tmdb.org/t/p/w500/".appending(self)
    }
}
