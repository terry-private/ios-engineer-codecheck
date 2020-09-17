//
//  RepositoriesTableViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class SearchRepositoryViewController: UIViewController {
    let cellId = "cellId"
    var repositories: [[String: Any]]=[]
    let repositoryListModel = RepositoryListModel()
    var index = 0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var repositoryListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
        repositoryListTableView.delegate = self
        repositoryListTableView.dataSource = self
        repositoryListModel.delegate = self
    
    }
}

//class SearchRepositoryViewController: UITableViewController {
//    
//    @IBOutlet weak var repositorySearchBar: UISearchBar!
//    let cellId = "Repository"
//    var repositories: [[String: Any]]=[]
//    let repositoryListModel = RepositoryListModel()
//
//    var index: Int!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        repositorySearchBar.text = "GitHubのリポジトリを検索できるよー"
//        repositorySearchBar.delegate = self
//        repositoryListModel.delegate = self
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // 画面遷移直前に呼ばれる
//        if segue.identifier == "Detail"{
//            let dtl = segue.destination as! RepositoryDetailViewController
//            dtl.repository = RepositoryDetailModel(dic: repositories[index])
//            dtl.repository?.delegate = dtl
//            dtl.repository?.fetchSubscribersCount()
//            dtl.repository?.fetchImage()
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return repositories.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RepositoryListTabelViewCell
//
//        let rp = repositories[indexPath.row]
//        cell.titleLabel.text = rp["full_name"] as? String ?? ""
//        cell.detailLabel.text = rp["language"] as? String ?? ""
//        cell.tag = indexPath.row
//        return cell
//        
//    }
//    
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        index = indexPath.row
//        performSegue(withIdentifier: "Detail", sender: self)
//    }
//    
//}

extension SearchRepositoryViewController: UITableViewDelegate, UITableViewDataSource {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // 画面遷移直前に呼ばれる
        if segue.identifier == "Detail"{
            let dtl = segue.destination as! RepositoryDetailViewController
            dtl.repository = RepositoryDetailModel(dic: repositories[self.index])
            dtl.repository?.delegate = dtl
            dtl.repository?.fetchSubscribersCount()
            dtl.repository?.fetchImage()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = repositoryListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RepositoryListTabelViewCell

        let rp = repositories[indexPath.row]
        cell.titleLabel.text = rp["full_name"] as? String ?? ""
        cell.detailLabel.text = rp["language"] as? String ?? ""
        cell.tag = indexPath.row
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "Detail", sender: self)
    }
}

/// UISearchBarDelegateのロジック周りをextensionとして分けます。
extension SearchRepositoryViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // ↓こうすれば初期のテキストを消せる
        searchBar.text = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        repositoryListModel.cancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        repositoryListModel.serchRepositories(searchBar.text ?? "")
    }
}

// モデルからDelegateを使って変更を受信
extension SearchRepositoryViewController: RepositoryListModelDelegate {
    
    /// 非同期処理　itemsを手に入れて再描画←メインスレッドにて
    /// - Parameter result: ApiResult Json type 辞書型です。
    func fetchRepositories(result: ApiResult) {
        guard let repositoryData = result.value as? [String: Any] else { return }
        guard let items = repositoryData["items"] as? [[String: Any]] else { return }
        
        repositories = items
        DispatchQueue.main.async {
            self.repositoryListTableView.reloadData()
        }
    }
}

/// storyboardのカスタムセルでし。
class RepositoryListTabelViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
