//
//  RepositoriesTableViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import Nuke

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
        
        cell.repositoryData = repositories[indexPath.row]
        
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
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageColorView: UIView!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    var repositoryData = [String: Any]() {
        didSet{
            guard let owner = repositoryData["owner"] as? [String: Any] else { return }
            guard let avatarUrl = owner["avatar_url"] as? String else { return }
            guard let url = URL(string:avatarUrl) else { return }
            Nuke.loadImage(with: url, into: avatarImageView)
            ownerNameLabel.text = owner["login"] as? String ?? ""
            languageLabel.text = repositoryData["language"] as? String ?? ""
            repositoryNameLabel.text = repositoryData["name"] as? String ?? ""
            starsLabel.text = String(repositoryData["stargazers_count"] as? Int ?? 0)
            if languageLabel.text == "" {
                languageColorView.isHidden = true
            } else {
                languageLabel.isHidden = false
                languageColorView.backgroundColor = .languageColor(language: languageLabel.text ?? "")
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width/2
        languageColorView.layer.cornerRadius = languageColorView.bounds.width/2
    }
}
