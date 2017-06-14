//
//  PlaylistsViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/7/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit
import CarbonKit
import Haneke
import FontAwesome_swift
import DZNEmptyDataSet

class PlaylistListViewController: VideoAppViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

//    // Check type for listVideoVC
//    enum VCType {
//        case playlist // didSelectedRow to load listVideo from laylist
//        case channel // didSelectedRow to load listPlaylist from channel
//    }
    
    var viewDidLoadHandler: ((Void) -> Void)?
    var swipeRefreshControl: CarbonSwipeRefresh!
    var scrollViewDidEndDraggingHandler: ((Void) -> Void)?
    var refreshListHander: ((Void) -> Void)?
    var videos = Videos()
    
    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "PlaylistsCell"
//    var vCType: VCType = .playlist

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70
        //
        swipeRefreshControl = CarbonSwipeRefresh.init(scrollView: self.tableView)
        swipeRefreshControl.colors = [#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)]
        swipeRefreshControl.addTarget(self, action: #selector(self.refreshList(swipeRefreshControl:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(swipeRefreshControl)
        
        //
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        // Load data
        self.viewDidLoadHandler?()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlaylistsTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PlaylistsTableViewCell
        cell.thumbImgView.hnk_setImageFromURL(NSURL(string: videos.videos[indexPath.row].thumbnail.medium.url)! as URL)
        cell.titleLbl.text = videos.videos[indexPath.row].title
        cell.authorLabel.text = videos.videos[indexPath.row].channelTitle
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if vCType == .playlist {
            loadPlaylistList(playlistId: self.videos.videos[indexPath.row].videoId, channelTitle: self.videos.videos[indexPath.row].title)
//        } else {
//            loadChannelList(channelId: self.videos.videos[indexPath.row].videoId, channelTitle: self.videos.videos[indexPath.row].title)
//        }
    }
    
    // MARK: SwipeRefreshControl delegate
    func refreshList(swipeRefreshControl: CarbonSwipeRefresh) {
        if refreshListHander != nil {
            refreshListHander?()
        } else {
            swipeRefreshControl.endRefreshing()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 100) {
            scrollViewDidEndDraggingHandler?()
        }
    }

    // MARK: - DZNEmptyDataSetSource
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let string = NSLocalizedString("Tap here to reload data.", comment: "")
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
                          NSForegroundColorAttributeName: UIColor.lightGray]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIcon(name: FontAwesome.film, textColor: UIColor.lightGray, size: CGSize(width: 80, height: 80))
    }
    
    func emptyDataSetDidTap(_ scrollView: UIScrollView!) {
        viewDidLoadHandler?()
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        viewDidLoadHandler?()
    }
    
    // MARK: - Private function
    
    private func loadPlaylistList(playlistId: String, channelTitle: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let listVideoVC = storyboard.instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
        listVideoVC.title = channelTitle
        
        listVideoVC.viewDidLoadHandler = {
            sharedAPI.getPlaylistVideos(playlistId: playlistId, videos: Videos(), completionHandler: { (videos) in
                listVideoVC.videos = videos
                listVideoVC.tableView.reloadData()
            })
        }
        
                listVideoVC.extraButtonAtCellTappedHandler = { cell in
                    VideoApp.showExtraOptionOnlineVideo(video: cell.video)
                }
        
        //        listVideoVC.didSelectedCellItem = { indexPath, video in
        //            listVideoVC.playVideo(video: video, playlist: listVideoVC.videos)
        //        }
        
        self.navigationController?.pushViewController(listVideoVC, animated: false)
    }
    
//    private func loadChannelList(channelId: String, channelTitle: String) {
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let listVideoVC = storyboard.instantiateViewController(withIdentifier: "PlaylistListViewController") as! PlaylistListViewController
//        listVideoVC.title = channelTitle
//        listVideoVC.vCType = .playlist
//        
//        listVideoVC.viewDidLoadHandler = {
//            sharedAPI.getChannelVideos(channelId: channelId, videos: Videos(), completionHandler: { (videos) in
//                listVideoVC.videos = videos
//                listVideoVC.tableView.reloadData()
//            })
//        }
//        
//        //        listVideoVC.extraButtonAtCellTappedHandler = { cell in
//        //            VideoApp.showExtraOptionOnlineVideo(video: cell.video)
//        //        }
//        //
//        //        listVideoVC.didSelectedCellItem = { indexPath, video in
//        //            listVideoVC.playVideo(video: video, playlist: listVideoVC.videos)
//        //        }
//        
//        self.navigationController?.pushViewController(listVideoVC, animated: false)
//    }
}
