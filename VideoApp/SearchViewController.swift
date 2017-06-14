//
//  SearchViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit
import QorumLogs

class SearchViewController: VideoAppViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    var extraButtonAtCellTappedHandler: ((SearchHistoriesTableViewCell) -> Void)?
    private let reuseIdentifier = "SearchHistoryCell"
    private var isSearchResult = false
    var rightBarButtonItem : UIBarButtonItem!
    private var searchHistoriesList: [SearchHistory] = []
    var searchSuggests: [String] = []
    
    var searchBar = UISearchBar()
    let vC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController

    let searchSuggestingVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchSuggestingViewController") as! SearchSuggestingViewController

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.tableView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        loadSearchHistories()
        //
        let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "History"), style: .plain, target: self, action: #selector(self.changeVCButtonTapped))
        leftBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let deleteButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Delete"), style: .plain, target: self, action: #selector(self.removeButtonTapped))
        deleteButtonItem.tintColor = UIColor.white
        rightBarButtonItem = deleteButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        self.tableView.tableFooterView = UIView()
        
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.isTranslucent = true
        
        let textField: UITextField? = searchBar.value(forKey: "_searchField") as? UITextField
        textField?.backgroundColor = UIColor.white
        textField?.textColor = UIColor.black
        textField?.tintColor = UIColor.black
        let textFieldInsideSearchBarLabel = textField?.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.lightGray

        self.navigationItem.titleView = searchBar
        
        self.extraButtonAtCellTappedHandler = { cell in
            self.searchBar.text = "\(String(describing: cell.searchHistoryLabel.text!)) "
        }
        searchSuggestingVC.extraButtonAtCellTappedHandler = { cell in
            self.searchBar.text = "\(String(describing: cell.searchHistoryLabel.text!)) "
            if cell.startSearch {
                self.vC.query = self.searchBar.text!
                self.removeSearchSuggestingVC()
                self.searchBar.resignFirstResponder()
                self.searchBar.showsCancelButton = false
                self.loadSearchHistories()
                if !self.isSearchResult {
                    self.addSearchResultVC()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //
    private func loadSearchHistories() {
        let searchHistoryItem = VideoApp.realm.objects(SearchHistories.self).filter("name = '\(VideoApp.Constants.searchHistoriesListName)'")[0].searchHistories.sorted(byProperty: "modifiedAt", ascending: false)
        searchHistoriesList = []
        searchHistoriesList.append(contentsOf: searchHistoryItem)
        tableView.reloadData()
    }

    // MARK: - UISearchController
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.addSearchSuggestingVC()
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sharedAPI.getSearchSuggests(query: searchBar.text!) { (result) in
            let searchSuggest: SearchSuggests = result
            self.searchSuggestingVC.searchSuggests = searchSuggest.searchSuggests
            self.searchSuggestingVC.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.removeSearchSuggestingVC()
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text != "" {
            VideoApp.saveSearchHistory(searchHistoryName: searchBar.text!)
            vC.query = searchBar.text!
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.searchButtonDidTapped), object: nil)
        }
        searchBar.showsCancelButton = false
        self.removeSearchSuggestingVC()
        if !isSearchResult {
            self.addSearchResultVC()
        }
        self.loadSearchHistories()
        self.tableView.reloadData()
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchHistoriesTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchHistoriesTableViewCell
        cell.searchHistoryLabel.text = searchHistoriesList[indexPath.row].name!
        cell.extraButtonTappedHandler = self.extraButtonAtCellTappedHandler
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vC.query = searchHistoriesList[indexPath.row].name
        searchBar.text = searchHistoriesList[indexPath.row].name
        // Update searchHistories
        let trimmedQuery = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let searchHistories = VideoApp.realm.objects(SearchHistories.self).filter("name = '\(VideoApp.Constants.searchHistoriesListName)'")[0].searchHistories
        try! VideoApp.realm.write() {
            searchHistories.filter("name = '\(trimmedQuery)'")[0].modifiedAt = NSDate()
        }
        self.loadSearchHistories()
        self.tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.searchButtonDidTapped), object: nil)
        self.removeSearchSuggestingVC()
        if !isSearchResult {
            self.addSearchResultVC()
        }
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }

    // MARK: - BarButtonItem Action

    func changeVCButtonTapped() {
        if !isSearchResult {
            self.addSearchResultVC()
            navigationItem.rightBarButtonItem = nil
        } else {
            removeSearchResultVC()
        }
        self.tableView.reloadData()
    }

    func removeButtonTapped() {
        self.view.endEditing(true)
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(title: NSLocalizedString("Yes", comment: ""), selectedAction: { (Void) -> Void in
            self.deleteHistories()
        }))
        items.append(BottomMenuViewItem(title: NSLocalizedString("No", comment: ""), selectedAction: { (Void) -> Void in
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }
    
    private func deleteHistories() {
        let searchHistories = VideoApp.realm.objects(SearchHistories.self).filter("name = '\(VideoApp.Constants.searchHistoriesListName)'")[0].searchHistories
        try! VideoApp.realm.write() {
            searchHistories.removeAll()
        }
        self.loadSearchHistories()
    }

    func removeSearchResultVC() {
        self.isSearchResult = false
        vC.willMove(toParentViewController: nil)
        vC.view.removeFromSuperview()
        vC.removeFromParentViewController()
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func addSearchResultVC() {
        self.isSearchResult = true
        self.addChildViewController(vC)
        vC.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(vC.view)
        vC.didMove(toParentViewController: self)
    }
    
    func addSearchSuggestingVC() {
        self.addChildViewController(searchSuggestingVC)
        searchSuggestingVC.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(searchSuggestingVC.view)
        searchSuggestingVC.didMove(toParentViewController: self)
        navigationItem.rightBarButtonItem = nil
    }

    func removeSearchSuggestingVC() {
        searchSuggestingVC.willMove(toParentViewController: nil)
        searchSuggestingVC.view.removeFromSuperview()
        searchSuggestingVC.removeFromParentViewController()
        navigationItem.rightBarButtonItem = nil
    }
}
