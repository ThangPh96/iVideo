//
//  VideoApp.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit
import FontAwesome_swift
import RealmSwift
import QorumLogs
import Alamofire
import SSSnackbar
import XCDYouTubeKit
import SystemConfiguration

class VideoApp: NSObject {

    static var tabbarController = UITabBarController()
    static let realm = try! Realm()
    // Categories Trending Video
    static var categoriesTrendingVideo: VideoCategories = VideoCategories()
    static var categoryId: String!
    static var categoryTitle: String!
    // Playing now
    class NowPlaying {
        private var playlist = Videos()
        private var index: Int = 0 {
            didSet {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.playVideo), object: nil)
            }
        }
        public func playVideo(playlist: Videos, index: Int) {
            self.playlist = playlist
            if playlist.videos.count != 0 {
                self.index = index
            }
        }
        public func changeVideoPlaying(index: Int) {
            if playlist.videos.count != 0 {
                self.index = index
            }
        }
        public func getPlaylist() -> Videos{
            return self.playlist
        }
        public func getIndex() -> Int {
            return self.index
        }
        
    }
    
    static var nowPlaying = NowPlaying()
    //
    class Constants {
        static let downloadListName = "Downloads"
        static let favoritesVideoListName = "FavoriteVideos"
        static let searchHistoriesListName = "SearchHistories"
    }
    
    enum Order: String {
        case relevance = "relevance"
        case date = "date"
        case viewCount = "viewCount"
    }

    class Notifications {
        static let searchButtonDidTapped = "searchButtonDidTappedNotification"
        static let didChangeCategory = "didChangeCategoryNotification"
        static let playVideo = "playVideoNotification"
        static let deleteAllFavoriteVideosDone = "deleteAllFavoriteVideosDoneNotification"
        static let selectSortVideosDone = "selectSortVideoDoneNotification"
        static let addVideoToFavoriteDone = "addVideoToFavoriteDoneNotification"
        static let addVideoToPlaylistDone = "addVideoToPlaylistDoneNotification"
        static let downloadVideoDone = "downloadVideoDoneNotification"
        static let changeQualityDone = "changeQualityDoneNotification"
    }
    // Check internet connecting
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }

//    class func checkForInternetConnection() -> Bool {
//        if VideoApp.isConnectedToNetwork() == false {
//            let alert = UIAlertView()
//            alert.title = NSLocalizedString("Connection Failed", comment: "")
//            alert.message = NSLocalizedString("Please Check Your Internet Connection", comment: "")
//            alert.addButton(withTitle: "OK")
//            alert.show()
//            return false
//        }
//        return true
//    }
    //
    class Settings {
        
        public enum VideoSort: String {
            case CreatedAt = "createdAt"
            case Title = "title"
        }
        // LimitCount
        static let favoritesLimitCount = 500
        static let searchHistoriesLimitCount = 50
        static let playlistLimitCount = 13
        static let videoPlaylistLimit = 500
        //
        static let themeColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        //
        static var videoSort: VideoSort {
            get {
                let defaults = UserDefaults.standard
                if let videoSort = defaults.string(forKey: "videoSortSetting")
                {
                    return VideoSort(rawValue: videoSort)!
                } else {
                    return VideoSort.CreatedAt
                }
            }
            
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue.rawValue, forKey: "videoSortSetting")
            }
        }

        //
        enum VideoQuality: String {
            case hd720p = "hd720"
            case medium = "medium"
            case small = "small"
        }
        
        static var videoQuality: VideoQuality {
            get {
                let defaults = UserDefaults.standard
                if let quality = defaults.string(forKey: "videoQualitySetting")
                {
                    return VideoQuality(rawValue: quality)!
                } else {
                    return VideoQuality.medium
                }
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue.rawValue, forKey: "videoQualitySetting")
            }
        }
        
        static var playVideoInBackground: Bool {
            get {
                let defaults = UserDefaults.standard
                return defaults.bool(forKey: "playVideoInBackgroundSetting")
            }
            
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "playVideoInBackgroundSetting")
            }
        }
    }
    
    class func saveSearchHistory(searchHistoryName: String) {
        // Save searchHistory
        let trimmedQuery = searchHistoryName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let searchHistory = SearchHistory()
        searchHistory.name = trimmedQuery
        var searchHistories = VideoApp.realm.objects(SearchHistories.self).filter("name = '\(VideoApp.Constants.searchHistoriesListName)'")[0].searchHistories
        
        let searchHistoriesSorted = VideoApp.realm.objects(SearchHistories.self).filter("name = '\(VideoApp.Constants.searchHistoriesListName)'")[0].searchHistories.sorted(byProperty: "modifiedAt", ascending: false)
        
        if searchHistories.filter("name = '\(searchHistory.name!)'").count == 0 {
            if searchHistories.count > VideoApp.Settings.searchHistoriesLimitCount {
                try! VideoApp.realm.write() {
                    if let name = searchHistoriesSorted.last?.name {
                        let item = searchHistories.filter("name = '\(name)'")[0]
                        searchHistories.remove(at: searchHistories.index(of: item)!)
                    }
                }
            }
            try! VideoApp.realm.write() {
                searchHistory.createdAt = NSDate()
                searchHistory.modifiedAt = NSDate()
                searchHistories.append(searchHistory)
                QL1("Video \(searchHistory.name!) was added to search histories.")
            }
        } else {
            try! VideoApp.realm.write() {
                searchHistories.filter("name = '\(searchHistory.name!)'")[0].modifiedAt = NSDate()
                QL1("Video \(searchHistory.name!) was updated to histories.")
            }
        }
    }
    
    class func showExtraOptionOnlineVideo(video: Video) {
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(title: video.title))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.shareAlt.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Share...", comment: ""), selectedAction: { (Void) -> Void in
                VideoApp.shareVideo(video: video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.heart.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                VideoApp.addVideoToFavorites(video: video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.list.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to playlist", comment: ""), selectedAction: { (Void) -> Void in
                VideoApp.addVideoToPlaylist(video: video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.angleDown.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                //
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }
    
    
    class func downloadBtnTapped(video: Video) {
        let vd = video
        var downloadOptions: [BottomMenuViewItem] = []
        XCDYouTubeClient.default().getVideoWithIdentifier(video.videoId) { (video, error) -> Void in
            if let video = video {
                downloadOptions = []
                if let streamURL = video.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue) as NSObject] {
                    downloadOptions.append(BottomMenuViewItem(title: "hd720", selectedAction: { (Void) -> Void in
                        QL1(streamURL)
                        self.downloadVideo(video: vd, streamURL: streamURL.absoluteString)
                    }))
                }
                if let streamURL = video.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue) as NSObject] {
                    downloadOptions.append(BottomMenuViewItem(title: "medium", selectedAction: { (Void) -> Void in
                        QL1(streamURL)
                        self.downloadVideo(video: vd, streamURL: streamURL.absoluteString)
                    }))
                }
                if let streamURL = video.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue) as NSObject] {
                    downloadOptions.append(BottomMenuViewItem(title: "small", selectedAction: { (Void) -> Void in
                        QL1(streamURL)
                        self.downloadVideo(video: vd, streamURL: streamURL.absoluteString)
                    }))
                }
                if downloadOptions.count > 0 {
                    downloadOptions.append(BottomMenuViewItem(title: NSLocalizedString("Cancel", comment: "")))
                }
                let bottomMenu = BottomMenuView(items: downloadOptions, didSelectedHandler: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
            } else {
                let snackBar = SSSnackbar.init(message: NSLocalizedString("This video can not download", comment: ""), actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                snackBar?.show()
            }
        }
    }
    
    class func downloadVideo(video: Video, streamURL: String!) {
//        var fractionCompleted: Double = 0
        let snackBar = SSSnackbar.init(message: NSLocalizedString("Start downloading ", comment: "") + video.title, actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
        snackBar?.show()
        VideoApp.downloadStreaming(url: streamURL, fileName: video.title,
                              onProgress: { fractionCompleted in
//                                self.fractionCompleted = fractionCompleted
        },
                              completionHandler: { (path) in
//                                self.fractionCompleted = 0
//                                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(VideoDetailView.updateDownloadPercent), object: nil)
//                                DispatchQueue.main.async {
//                                    self.downloadButton.setTitle(NSLocalizedString(" Downloaded", comment: ""), for: .normal)
//                                }
                                let videos = VideoApp.realm.objects(Videos.self).filter("name = 'Downloads'")[0].videos
                                try! VideoApp.realm.write() {
                                    video.offlinePath = path
                                    video.createdAt = NSDate()
                                    video.modifiedAt = NSDate()
                                    videos.append(video)
                                    let snackBar = SSSnackbar.init(message: NSLocalizedString("Downloaded ", comment: "") + video.title, actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                                    snackBar?.show()
                                }
        })
    }

    class func addVideoToFavorites(video: Video) {
        let videos = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.favoritesVideoListName)'")[0].videos
        if let videoId = video.videoId {
            if videos.filter("videoId = '\(videoId)'").count == 0 {
                if videos.count <= Settings.favoritesLimitCount {
                    try! VideoApp.realm.write() {
                        video.createdAt = NSDate()
                        video.modifiedAt = NSDate()
                        videos.append(video)
                        QL1("Video \(video.title) was added to favorites.")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.addVideoToFavoriteDone), object: nil)
                    }
                } else {
                    let snackBar = SSSnackbar.init(message: NSLocalizedString("You only can add \(Settings.favoritesLimitCount) videos", comment: ""), actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                    snackBar?.show()
                }
            }
        }
    }

    class func addVideoToPlaylist(video: Video) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(title: video.title))
        let playlists = VideoApp.realm.objects(Videos.self).filter("name != 'FavoriteVideos' && name != 'Histories' && name != 'Downloads'")
        for playlist in playlists {
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome.list, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("\(playlist.name!)", comment: ""), selectedAction: { (Void) -> Void in
                    if let videoId = video.videoId {
                        if playlist.videos.filter("videoId = '\(videoId)'").count == 0 {
                            if playlist.videos.count <= Settings.videoPlaylistLimit {
                                try! VideoApp.realm.write() {
                                    video.createdAt = NSDate()
                                    video.modifiedAt = NSDate()
                                    playlist.videos.append(video)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.addVideoToPlaylistDone), object: nil)
                                }
                            } else {
                                let snackBar = SSSnackbar.init(message: NSLocalizedString("You only can add \(Settings.videoPlaylistLimit) videos", comment: ""), actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                                snackBar?.show()
                            }
                        }
                    }
            }))
        }
        if playlists.count < (VideoApp.Settings.playlistLimitCount - 3) { // if playlist count equal limited playlist count, user can't create new playlist
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome.plus, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Create new playlist...", comment: ""), selectedAction: { (Void) -> Void in
                    let popup = PopUpViewController(size: CGSize(width: 280, height: 120))
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let createNewPlaylistVC = storyboard.instantiateViewController(withIdentifier: "CreateNewPlaylist") as! CreateNewPlaylistViewController
                    popup.addChildViewController(createNewPlaylistVC)
                    popup.viewContainer.addSubview(createNewPlaylistVC.view)
                    createNewPlaylistVC.view.translatesAutoresizingMaskIntoConstraints = false
                    popup.viewContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[createNewPlaylistView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["createNewPlaylistView": createNewPlaylistVC.view]))
                    popup.viewContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[createNewPlaylistView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["createNewPlaylistView": createNewPlaylistVC.view]))
                    createNewPlaylistVC.cancelButtonTappedHandler = {
                        popup.hide()
                    }
                    createNewPlaylistVC.createdPlaylistHandler = { playlist in
                        playlist.videos.append(video)
                        popup.hide()
                    }
                    popup.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
            }))
        }
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome.angleDown, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }

    class func editOfflineVideo(){
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.trash.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Remove all", comment: ""), selectedAction: { (Void) -> Void in
                deleteAllFavoriteVideos()
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.sort.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Sort", comment: ""), selectedAction: { (Void) -> Void in
                sortOfflineVideo()
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.angleDown.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                //
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }

    class func deleteAllFavoriteVideos() {
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.check.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Yes", comment: ""), selectedAction: { (Void) -> Void in
                let videoItems = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.favoritesVideoListName)'")[0].videos
                try! VideoApp.realm.write() {
                    videoItems.removeAll()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.deleteAllFavoriteVideosDone), object: nil)
                }
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.remove.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("No", comment: ""), selectedAction: { (Void) -> Void in
                //
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }
    
    class func sortOfflineVideo() {
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.sortNumericAsc.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Sort by date created", comment: ""), selectedAction: { (Void) -> Void in
                VideoApp.Settings.videoSort = .CreatedAt
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.selectSortVideosDone), object: nil)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.sortAlphaAsc.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Sort by name", comment: ""), selectedAction: { (Void) -> Void in
                VideoApp.Settings.videoSort = .Title
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.selectSortVideosDone),object: nil)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.angleDown.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                //
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }

    class func shareVideo(video: Video) {
                let shareString = NSLocalizedString("Great ", comment: "") + "https://www.youtube.com/watch?v=\(video.videoId!)"
                let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController!.present(activityViewController, animated: true, completion: {})
    }
    
    class func downloadStreaming(url: String, fileName: String?, onProgress: ((Double) -> Void)?, completionHandler: ((String) -> Void)?) {
        
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let typePath = "Downloads"
        let dataPath = directoryURL.appendingPathComponent(typePath)
        var fileName = fileName
        
        if !fileManager.fileExists(atPath: dataPath.path) {
            do {
                try fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { a, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            var fileURL = documentsURL.appendingPathComponent(typePath)
            if let name = response.suggestedFilename {
                if fileName == nil {
                    fileName = name
                    fileURL = fileURL.appendingPathComponent(fileName!)
                } else {
                    fileName = fileName! + "." + NSString(string: name).pathExtension
                    fileURL = fileURL.appendingPathComponent(fileName!)
                }
            } else {
                fileURL = fileURL.appendingPathComponent(fileName!)
            }
            
            return (fileURL, [.createIntermediateDirectories])
        }
        Alamofire.download(url, to: destination).response { response in
            debugPrint(response)
            }
            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
                onProgress!(progress.fractionCompleted)
            }
            .responseJSON { response in
                debugPrint("Downloaded file successfully")
                debugPrint(dataPath.appendingPathComponent(fileName!))
                completionHandler?(typePath + "/" + fileName!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.downloadVideoDone), object: nil)
        }
    }
}
