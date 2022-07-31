//
//  MovieListViewModel.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 31/07/22.
//

import RxCocoa
import RxSwift

class MovieListViewModel {
    
    private let bag = DisposeBag()
    var apiType: BaseServiceProtocol.Type = BaseService.self
    
    // MARK: - Input
    
    // MARK: - Output
    var dataObservable: Observable<MovieResult?> = Observable.just(nil)
    
    // MARK: - Init
    func load(page: Int, apiType: BaseServiceProtocol.Type) {
        self.apiType = apiType
        dataObservable = apiType
            .getMovies(page: page)
            .flatMap ({resultNSURL -> Observable<Result<MovieResult?, Error>> in
                return self.apiType.getMovies(page: page)
            })
            .map() { result -> MovieResult? in
                switch result {
                case .Success(let result):
                    return result
                case .Failure:
                    return nil
                }
            }
    }
    
    func loadData(page: Int) {
        self.load(page: page,
                  apiType: apiType)
    }
}
