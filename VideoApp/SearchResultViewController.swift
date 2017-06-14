//
//  SearchResultViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit
import CarbonKit
import QorumLogs

class SearchResultViewController: VideoAppViewController, CarbonTabSwipeNavigationDelegate {

    private let tabItems = [
        NSLocalizedString("Relevance", comment: ""),
        NSLocalizedString("Playlist", comment: ""),
        NSLocalizedString("ViewCount", comment: ""),
        NSLocalizedString("Published", comment: "")
    ]
    
    @IBOutlet weak var contentView: UIView!
    var query: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Custom TabSwipeNavigation
        let tabSwipeNavigation = CarbonTabSwipeNavigation(items: tabItems, delegate: self)
        tabSwipeNavigation.setIndicatorColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        tabSwipeNavigation.setSelectedColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        tabSwipeNavigation.setNormalColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        tabSwipeNavigation.setTabBarHeight(36)
        
        tabSwipeNavigation.carbonSegmentedControl?.backgroundColor = VideoApp.Settings.themeColor
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(UIScreen.main.bounds.width/3, forSegmentAt: 0)
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(UIScreen.main.bounds.width/3, forSegmentAt: 1)
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(UIScreen.main.bounds.width/2.95, forSegmentAt: 2)
        
        tabSwipeNavigation.setIndicatorHeight(2)
        tabSwipeNavigation.insert(intoRootViewController: self, andTargetView: self.contentView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CarbonTabSwipeNavigationDelegate
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        switch index {
        case 0:
            return searchVideoListVC(order: VideoApp.Order.relevance)
        case 1:
            return searchPlaylistVC()
        case 2:
            return searchVideoListVC(order: VideoApp.Order.viewCount)
        case 3:
            return searchVideoListVC(order: VideoApp.Order.date)
        default:
            break
        }
        return UIViewController()
    }
    
    private func searchVideoListVC(order: VideoApp.Order) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vC = storyboard.instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
        
        vC.viewDidLoadHandler = {
            vC.swipeRefreshControl.startRefreshing()
            self.loadVideoList(query: self.query, order: order, vC: vC)
        }
        
        vC.registerObserver(name: VideoApp.Notifications.searchButtonDidTapped, object: nil, queue: nil) { (noti) -> Void in
            vC.swipeRefreshControl.startRefreshing()
            self.loadVideoList(query: self.query, order: order, vC: vC)
        }
        
        vC.refreshListHander = {
            self.loadVideoList(query: self.query, order: order, vC: vC)
        }
        
        vC.extraButtonAtCellTappedHandler = { cell in
            VideoApp.showExtraOptionOnlineVideo(video: cell.video)
        }
        
        vC.scrollViewDidEndDraggingHandler = {
            if let _ = vC.videos.nextPage {
                sharedAPI.searchVideos(query: self.query, videos: vC.videos, order: order, completionHandler: { (videos) -> Void in
                    vC.videos = videos
                    vC.tableView.reloadData()
                })
            }
        }

        return vC
    }
    
    func loadVideoList(query: String, order: VideoApp.Order, vC: VideoListViewController) {
        sharedAPI.searchVideos(query: query, videos: Videos(), order: order, completionHandler: {(videos) in
            vC.videos = videos
            vC.tableView.reloadData()
            vC.swipeRefreshControl.endRefreshing()
        })
    }

    
    private func searchPlaylistVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vC = storyboard.instantiateViewController(withIdentifier: "PlaylistListViewController") as! PlaylistListViewController
        
        vC.viewDidLoadHandler = {
            vC.swipeRefreshControl.startRefreshing()
            self.loadPlaylistList(query: self.query, vC: vC)
        }
        
        vC.refreshListHander = {
            self.loadPlaylistList(query: self.query, vC: vC)
        }
        
        vC.registerObserver(name: VideoApp.Notifications.searchButtonDidTapped, object: nil, queue: nil) { (noti) -> Void in
            vC.swipeRefreshControl.startRefreshing()
            self.loadPlaylistList(query: self.query, vC: vC)
        }
        
        vC.scrollViewDidEndDraggingHandler = {
            if let _ = vC.videos.nextPage {
                sharedAPI.searchPlaylist(query: self.query, playlists: vC.videos) { (videos) -> Void in
                    vC.videos = videos
                    vC.tableView.reloadData()
                }
            }
        }

        return vC
    }
    
    private func loadPlaylistList(query: String, vC: PlaylistListViewController) {
        sharedAPI.searchPlaylist(query: query, playlists: Videos(), completionHandler: {(videos) in
            vC.videos = videos
            vC.tableView.reloadData()
            vC.swipeRefreshControl.endRefreshing()
        })
    }
    
}
