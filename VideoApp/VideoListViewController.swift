//
//  VideoListViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit
import Haneke
import CarbonKit
import DZNEmptyDataSet
import FontAwesome_swift

class VideoListViewController: VideoAppViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "VideoListCell"
    var extraButtonAtCellTappedHandler: ((VideoListTableViewCell) -> Void)?

    var viewDidLoadHandler: ((Void) -> Void)?
    var reloadDataHandler: ((Void) -> Void)?
    var swipeRefreshControl: CarbonSwipeRefresh!
    var scrollViewDidEndDraggingHandler: ((Void) -> Void)?
    var refreshListHander: ((Void) -> Void)?
    var isHistoryVC: Bool = false
    var videos = Videos()
    var isPlayingList = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
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
        let cell: VideoListTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VideoListTableViewCell
        
        cell.thumbImgView.hnk_setImageFromURL(NSURL(string: videos.videos[indexPath.row].thumbnail.medium.url)! as URL)
        cell.playingBtn.isHidden = true
        if isHistoryVC {
            cell.downloadBtnWidthLayoutConstraint.constant = 0
        }
        if isPlayingList {
            cell.backgroundColor = UIColor.black
            cell.titleLbl.textColor = UIColor.white
            cell.likeCountLbl.textColor = UIColor.white
            cell.viewCountLbl.textColor = UIColor.white
            cell.menuButton.backgroundColor = UIColor.white
            cell.numberBtnWidthLayoutConstraint.constant = 36
            cell.numberBtn.setTitleColor(UIColor.white, for: .normal)
            cell.numberBtn.setTitle("\(indexPath.row + 1)", for: .normal)
            if VideoApp.nowPlaying.getPlaylist().videos.count != 0 && VideoApp.nowPlaying.getIndex() == indexPath.row {
                cell.numberBtn.setTitle("", for: .normal)
                cell.playingBtn.isHidden = false
                let image = #imageLiteral(resourceName: "PlayFilled")
                let setImage = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.playingBtn.setImage(setImage, for: .normal)
                cell.playingBtn.tintColor = UIColor.red
                
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
            }
        } else {
            cell.numberBtnWidthLayoutConstraint.constant = 0
        }
        cell.titleLbl.text = videos.videos[indexPath.row].title
        cell.authorLbl.text = videos.videos[indexPath.row].channelTitle
        cell.durationLbl.text = videos.videos[indexPath.row].duration
        cell.likeCountLbl.text = String(videos.videos[indexPath.row].likesCount)
        cell.viewCountLbl.text = String(videos.videos[indexPath.row].viewsCount)
        cell.extraButtonTappedHandler = extraButtonAtCellTappedHandler
        cell.video = videos.videos[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        VideoApp.nowPlaying.playVideo(playlist: videos, index: indexPath.row)
        VideoApp.tabbarController.selectedIndex = 2
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
        reloadDataHandler?()
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        reloadDataHandler?()
    }
}
