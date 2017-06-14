//
//  API.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import Alamofire
import SwiftyJSON
import QorumLogs

let sharedAPI = API()

class API: NSObject {
    // Private properties
    private var manager: Alamofire.SessionManager
    
    override init() {
        
        // Create a shared URL cache
        let memoryCapacity = 500 * 1024 * 1024; // 500 MB
        let diskCapacity = 500 * 1024 * 1024; // 500 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
        
        // Create a custom configuration
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .useProtocolCachePolicy // this is the default
        configuration.urlCache = cache
        
        // Create your own manager instance that uses your custom configuration
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    
    public func getTrendingVideos(categoryId: String, videos: Videos, completionHandler: ((Videos) -> Void)?) {
        self.request(router: Router.getTrendingVideos(categoryId: categoryId, pageToken: videos.nextPage)) { (json) in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.videoPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
    
            for item in json["items"].arrayValue {
                videos.videos.append(Video.init(fromJson: item))
            }
            completionHandler?(videos)
        }
    }
    
    public func getVideoCategories(completionHandler: ((VideoCategories) -> Void)?) {
        self.request(router: Router.getCategoriesId()) { (json) in
            completionHandler?(VideoCategories.init(fromJson: json))
        }
    }
    
    public func getSearchSuggests(query: String, completionHandler: ((SearchSuggests) -> Void)?) {
        self.request(router: RouterSearchSuggest.getSearchSuggests(query: query)) { (json) in
            completionHandler?(SearchSuggests.init(fromJson: json))
        }
    }
    
    public func getPlaylistVideos(playlistId: String, videos: Videos, completionHandler: ((Videos) -> Void)?) {
        self.request(router: Router.getPlaylistVideos(playlistId: playlistId, pageToken: videos.nextPage)) { (json) -> Void in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.videoPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.videos.append(Video.init(fromJson: item))
            }
            completionHandler?(videos)
        }
    }
    
    public func getChannelVideos(channelId: String, videos: Videos, completionHandler: ((Videos) -> Void)?) {
        self.request(router: Router.getChannelVideos(channelId: channelId, pageToken: videos.nextPage)) { (json) in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.videoPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.videos.append(Video.init(fromJson: item))
            }
            completionHandler?(videos)
        }
    }
    
    public func getVideoDetails(videoId: String, completionHandler: ((Video) -> Void)?) {
        self.request(router: Router.getVideoDetails(videoId: videoId)) { (json) -> Void in
            completionHandler?(Video.init(fromJson: json["items"][0]))
        }
    }
    
    public func searchPlaylist(query: String, playlists: Videos, completionHandler: ((Videos) ->Void)?) {
        self.request(router: Router.searchPlaylists(query: query, pageToken: playlists.nextPage)) { (json) -> Void in
            playlists.total = json["pageInfo"]["totalResults"].intValue
            playlists.videoPerPage = json["pageInfo"]["resultsPerPage"].intValue
            playlists.nextPage = json["nextPageToken"].string
            playlists.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                playlists.videos.append(Video.init(fromJson: item))
            }
            
            completionHandler?(playlists)
        }
    }
    
    public func searchVideos(query: String, videos: Videos, order: VideoApp.Order, completionHandler: ((Videos) ->Void)?) {
        self.request(router: Router.searchVideos(query: query, order: order, pageToken: videos.nextPage)) { (json) -> Void in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.videoPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.videos.append(Video.init(fromJson: item))
            }
            
            completionHandler?(videos)
        }
    }
    
    public func searchChannels(query: String, channels: Videos, completionHandler: ((Videos) ->Void)?) {
        self.request(router: Router.searchChannels(query: query, pageToken: channels.nextPage)) { (json) -> Void in
            channels.total = json["pageInfo"]["totalResults"].intValue
            channels.videoPerPage = json["pageInfo"]["resultsPerPage"].intValue
            channels.nextPage = json["nextPageToken"].string
            channels.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                channels.videos.append(Video.init(fromJson: item))
            }
            
            completionHandler?(channels)
        }
    }
    
    public func getRelatedVideos(videoId: String!, videos: Videos, completionHandler: ((Videos) -> Void)?) {
        self.request(router: Router.getRelatedVideos(videoId: videoId, pageToken: videos.nextPage)) { (json) -> Void in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.videoPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.videos.append(Video.init(fromJson: item))
            }
            
            completionHandler?(videos)
        }
    }
    
    public func request(router: URLRequestConvertible, completionHandler: ((JSON) -> Void)?) {
        self.manager.request(router).responseJSON { (response) -> Void in
            QL1("Request: \(String(describing: response.request?.allHTTPHeaderFields))")
            QL1(response)
            if response.result.isSuccess {
                completionHandler?(JSON(response.result.value!))
            }
            if response.result.isFailure {
                completionHandler?(JSON(response.result.error!))
            }
        }
    }
    
    // MARK: Router

    public enum RouterSearchSuggest: URLRequestConvertible {
        
        static private let baseURL = "https://suggestqueries.google.com"
        static private let basePath = "/complete"
        
        case getSearchSuggests(query: String)
        
        // MARK: URLRequestConvertible
        
        public func asURLRequest() throws -> URLRequest {
            let path = "/search"
            let url = try RouterSearchSuggest.baseURL.appending(RouterSearchSuggest.basePath).asURL()
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            
            var parameters: [String: AnyObject] = Dictionary()
            parameters["client"] = "firefox" as AnyObject?
            parameters["ds"] = "yt" as AnyObject?
            
            switch self {
            case .getSearchSuggests(let query):
                parameters["q"] = query as AnyObject?
                break
            }
            return try URLEncoding.default.encode(urlRequest, with: parameters)
        }
    }
    
    public enum Router: URLRequestConvertible {
        
        static private let baseURL = "https://www.googleapis.com"
        static private let basePath = "/youtube/v3"
        
        case getPlaylistVideos(playlistId: String, pageToken: String?)
        case getChannelVideos(channelId: String, pageToken: String?)
        case getVideoDetails(videoId: String)
        case getRelatedVideos(videoId: String, pageToken: String?)
        case searchVideos(query: String, order: VideoApp.Order, pageToken: String?)
        case searchPlaylists(query: String, pageToken: String?)
        case searchChannels(query: String, pageToken: String?)
        case getCategoriesId()
        case getTrendingVideos(categoryId: String, pageToken: String?)
        
        var method: HTTPMethod {
            switch self {
            case .getPlaylistVideos, .getCategoriesId, .getTrendingVideos:
                return .get
            case .getChannelVideos:
                return .get
            case .getVideoDetails:
                return .get
            case .getRelatedVideos:
                return .get
            case .searchVideos:
                return .get
            case .searchPlaylists:
                return .get
            case .searchChannels:
                return .get
            }
        }
        
        var path: String {
            switch self {
            case .getChannelVideos, .getRelatedVideos, .searchVideos, .searchChannels, .searchPlaylists:
                return "/search"
            case .getVideoDetails, .getTrendingVideos:
                return "/videos"
            case .getPlaylistVideos:
                return "/playlistItems"
            case .getCategoriesId:
                return "/videoCategories"
            }
        }
        
        // MARK: URLRequestConvertible
        
        public func asURLRequest() throws -> URLRequest {
            
            let key = "AIzaSyBeoKLKQWEU1vrK8SLFYERGUf3Fy2Rhfy0"
            let locale = Locale.current
            let regionCode = locale.regionCode
            
            let url = try Router.baseURL.appending(Router.basePath).asURL()
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            
            var parameters: [String: AnyObject] = Dictionary()
            // Random key
            parameters["key"] = key as AnyObject?
            parameters["hl"] = "en" as AnyObject?
            if let rc = regionCode {
                parameters["regionCode"] = rc as AnyObject?
            }
            parameters["maxResults"] = 30 as AnyObject?
            
            switch self {
            case .getPlaylistVideos(let playlistId, let pageToken):
                parameters["part"] = "snippet,contentDetails" as AnyObject?
                parameters["playlistId"] = playlistId as AnyObject?
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken as AnyObject?
                }
                break
            case .getChannelVideos(let channelId, let pageToken):
                parameters["part"] = "snippet" as AnyObject?
                parameters["channelId"] = channelId as AnyObject?
                parameters["type"] = "video" as AnyObject?
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken as AnyObject?
                }
                break
            case .getVideoDetails(let videoId):
                parameters["part"] = "snippet,contentDetails,statistics" as AnyObject?
                parameters["id"] = videoId as AnyObject?
                break
            case .getRelatedVideos(let videoId, let pageToken):
                parameters["relatedToVideoId"] = videoId as AnyObject?
                parameters["part"] = "snippet" as AnyObject?
                parameters["type"] = "video" as AnyObject?
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken as AnyObject?
                }
                break
            case .searchPlaylists(let query, let pageToken):
                parameters["part"] = "snippet" as AnyObject?
                parameters["q"] = query as AnyObject?
                parameters["type"] = "playlist" as AnyObject?
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken as AnyObject?
                }
                break
            case .searchVideos(let query, let order, let pageToken):
                parameters["part"] = "snippet" as AnyObject?
                parameters["q"] = query as AnyObject?
                parameters["type"] = "video" as AnyObject?
                parameters["order"] = order as AnyObject?
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken as AnyObject?
                }
                break
            case .searchChannels(let query, let pageToken):
                parameters["part"] = "snippet" as AnyObject?
                parameters["q"] = query as AnyObject?
                parameters["type"] = "channel" as AnyObject?
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken as AnyObject?
                }
                break
            case .getCategoriesId():
                parameters["part"] = "snippet" as AnyObject?
                break
            case .getTrendingVideos(let categoryId, let pageToken):
                parameters["part"] = "snippet,contentDetails,statistics" as AnyObject?
                parameters["chart"] = "mostPopular" as AnyObject?
                parameters["videoCategoryId"] = categoryId as AnyObject?
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken as AnyObject?
                }
            }
            return try URLEncoding.default.encode(urlRequest, with: parameters)
        }
    }
    
}
