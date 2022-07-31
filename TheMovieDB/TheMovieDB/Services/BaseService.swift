//
//  BaseService.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 31/07/22.
//

import RxSwift
import RxCocoa
import SVProgressHUD

enum Result<T, Error> {
    case Success(T)
    case Failure(Error)
}

// MARK: -Flickr URL Components
struct Configs {
    static var baseURLString = "https://api.themoviedb.org/3/"
    static let apiKey = "8eac22f4c24d01c480e4d99fef2edfc3"
}

enum API: String {
    case getMovies = "trending/movie/week"
    
    func getPath() -> String {
        return Configs.baseURLString + self.rawValue
    }
}

enum RequestError: Error {
    case unknown
}

class BaseService: BaseServiceProtocol {
    static func getMovies(page: Int) -> Observable<Result<MovieResult?, Error>> {
        let urlString = API.getMovies.getPath()
        let parameters = [
            "api_key" : Configs.apiKey,
            "page" : "\(page)"
        ]
        return request(urlString, parameters: parameters)
            .map({ result in
                switch result {
                case .Success(let data):
                    var searchResult: MovieResult?
                    do {
                        searchResult = try JSONDecoder().decode(MovieResult.self, from: data)
                    } catch let parseError {
                        return Result<MovieResult?, Error>.Failure(parseError)
                    }

                    return Result<MovieResult?, Error>.Success(searchResult)
                case .Failure(let error):
                    return Result<MovieResult?, Error>.Failure(error)
                }
            })
    }
    
    //MARK: - URL request
    static private func request(_ baseURL: String = "", parameters: [String: String] = [:]) -> Observable<Result<Data, Error>> {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        return Observable.create { observer in
            var components = URLComponents(string: baseURL)!
            components.queryItems = parameters.map(URLQueryItem.init)
            let url = components.url!
            var result: Result<Data, Error>?
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    result = Result<Data, Error>.Success(data)
                } else {
                    if let error = error {
                        result = Result<Data, Error>.Failure(error)
                    }
                }
                observer.onNext(result!)
                observer.onCompleted()
            }
            dataTask?.resume()
            return Disposables.create {
                dataTask?.cancel()
            }
        }
    }
}
