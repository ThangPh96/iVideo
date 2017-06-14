//
//  PlaylistViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class PlaylistViewController: VideoAppViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "PlaylistCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Playlists"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 3:
//            return 6
//        default:
//            return 1
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
//        cell.imageView?.tintColor = UIColor.white
//        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.white
        switch indexPath.section {
        case 0:
            cell.imageView?.image = #imageLiteral(resourceName: "LikeFilled")
            cell.textLabel?.text = "Favorites"
        case 1:
            cell.imageView?.image = #imageLiteral(resourceName: "Playlist")
            cell.textLabel?.text = "My Playlists"
//        case 2:
//            cell.imageView?.image = #imageLiteral(resourceName: "Music")
//            cell.textLabel?.text = "iTunes Top 100"
//        case 3:
//            cell.textLabel?.textColor = UIColor.black
//            cell.backgroundColor = UIColor.white
//            cell.textLabel?.text = "Playlist"
        default:
            cell.textLabel?.text = "Playlist"
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        let label = UILabel()
//        
//        label.text = "Top 100"
//        label.textColor = UIColor.black
//        
//        view.backgroundColor = VideoApp.Settings.themeColor
//        view.addSubview(label)
//        
////        view.addConst raints(<#[NSLayoutConstraint]#>)
//        return view
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 3 {
//            return 36
//        } else {
//            return 0
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vC = storyboard.instantiateViewController(withIdentifier: "PersonalViewController") as! PersonalViewController
            vC.isFavoriteVC = true
            self.navigationController?.pushViewController(vC, animated: true)
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let createdPlaylistListVC = storyboard.instantiateViewController(withIdentifier: "CreatedPlaylistViewController") as! CreatedPlaylistViewController
            createdPlaylistListVC.title = NSLocalizedString("Playlists", comment: "")
            self.navigationController?.pushViewController(createdPlaylistListVC, animated: true)
//        case 2:
//            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//            let vC = storyboard.instantiateViewController(withIdentifier: "PlaylistListViewController") as! PlaylistListViewController
//            self.navigationController?.pushViewController(vC, animated: true)
        default:
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vC = storyboard.instantiateViewController(withIdentifier: "PlaylistListViewController") as! PlaylistListViewController
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }

}
