//
//  GithubService.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import Foundation
import RxSwift

// Host
class GithubService {
    let host = "https://api.github.com"
    let searchPath = "/search"
    let repositoryPath = "/repositories"
    let codePath = "/code"

    var searchRepositoriesUrlComponents: URLComponents {
        var url = URLComponents(string: ("\(host)\(searchPath)\(repositoryPath)"))!
        url.queryItems = [URLQueryItem]()
        return url
    }

    var searchCodeUrlComponents: URLComponents {
        var url = URLComponents(string: ("\(host)\(searchPath)\(codePath)"))!
        url.queryItems = [URLQueryItem]()
        return url
    }
}
// Header
extension GithubService {
    struct HeaderKey {
        static let authorization = "Authorization"
        static let accept = "Accept"
    }

    struct HeaderValue {
        static let authorization = AppDefaults.apiToken
        static let accept = "application/vnd.github.v3+json"
    }
    
    func authorizedRequest(with url: URLComponents) -> URLRequest {
        var request = URLRequest(url: url.url!)
        request.addValue(HeaderValue.accept, forHTTPHeaderField: HeaderKey.accept)
        request.addValue(HeaderValue.authorization, forHTTPHeaderField: HeaderKey.authorization)
        return request
    }
    
    func unauthorizedRequest(with url: URLComponents) -> URLRequest {
        var request = URLRequest(url: url.url!)
        request.addValue(HeaderValue.accept, forHTTPHeaderField: HeaderKey.accept)
        return request
    }
}
// Query
extension GithubService {
    struct QueryItems {
        static let query = "q"
        static let sort = "sort"
        static let order = "order"
        static let perPage = "per_page"
        static let page = "page"
    }
}
// Error
extension GithubService {
    enum Error: Swift.Error {
        case invalidResponse(URLResponse?)
        case invalidJSON(Swift.Error)
        case invalidRequest(URLRequest)
        case unauthorizedRequest(URLRequest)
        case invalidURL(URL?)
        case serviceUnvailable(URL?)
        case serviceForbidden(URL?)
        case useCache
        case allData
        case other
        case generic
    }
}

extension GithubService.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .other:
            return NSLocalizedString("Undefined error occured!", comment: "My error")
        case .invalidResponse(_):
            return NSLocalizedString("Invalid response!", comment: "My error")
        case .invalidJSON(let error):
            return error.localizedDescription
        case .invalidRequest(_):
            return NSLocalizedString("Correct your imputs.", comment: "My error")
        case .invalidURL(_):
            return NSLocalizedString("Undefined error occured!", comment: "My error")
        case .serviceUnvailable(_):
            return NSLocalizedString("Service not available.", comment: "My error")
        case .serviceForbidden(_):
            return NSLocalizedString("Service temporary forbidden.", comment: "My error")
        case .useCache:
            return NSLocalizedString("Cache data layer not implemented!", comment: "My error")
        case .unauthorizedRequest(_):
            return NSLocalizedString("Unauthorized request! You may have forgotten to update AppDefaults with your personal token.", comment: "My error")
        case .allData:
            return "All data have been loaded."
        case .generic:
            return "Something went wrong."
        }
    }
}

extension GithubService {
    func process<T: Decodable>(request: URLRequest) -> Observable<Result<T, GithubService.Error>> {
        URLSession.shared.rx
            .response(request: request)
            .map { result -> Result<T, GithubService.Error> in
                switch result.response.statusCode {
                case 200 ..< 300:
                    do {
                        let result = try JSONDecoder().decode(T.self, from: result.data)
                        return .success(result)
                    } catch let error {
                        throw Error.invalidJSON(error)
                    }
                    
                case 304:
                    return .failure(Error.useCache)
                case 401:
                    throw Error.unauthorizedRequest(request)
                case 403:
                    return .failure(Error.serviceForbidden(request.url))
                case 404:
                    throw Error.invalidURL(request.url)
                case 422:
                    return .failure(Error.invalidRequest(request))
                case 503:
                    throw Error.serviceUnvailable(request.url)
                default:
                    throw Error.other
                }
            }.retry { errors in
                return errors.enumerated().flatMap{ (index, error) -> Observable<Int> in
                    return index < 5
                    ? Observable<Int>.timer(RxTimeInterval.seconds(5),
                                            scheduler: MainScheduler.instance)
                    : Observable.error(error)
                }
            }
    }
}
