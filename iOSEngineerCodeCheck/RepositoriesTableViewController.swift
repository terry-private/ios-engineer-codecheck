//
//  RepositoriesTableViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var repositorySearchBar: UISearchBar!
    let cellId = "Repository"
    var repositories: [[String: Any]]=[]
    let repositoryListModel = RepositoryListModel()

    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repositorySearchBar.text = "GitHubのリポジトリを検索できるよー"
        repositorySearchBar.delegate = self
        repositoryListModel.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 画面遷移直前に呼ばれる
        if segue.identifier == "Detail"{
            let dtl = segue.destination as! RepositoryViewController
            dtl.repository = RepositoryModel(dic: repositories[index])
            dtl.repository?.delegate = dtl
            dtl.repository?.fetchSubscribersCount()
            dtl.repository?.fetchImage()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RepositoryTabelViewCell

        let rp = repositories[indexPath.row]
        cell.titleLabel.text = rp["full_name"] as? String ?? ""
        cell.detailLabel.text = rp["language"] as? String ?? ""
        cell.tag = indexPath.row
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "Detail", sender: self)
    }
    
}

// UISearchBarDelegateのロジック周りをextensionとして分けます。
extension RepositoriesTableViewController: UISearchBarDelegate {
    
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

extension RepositoriesTableViewController: RepositoryListDelegate {
    func fetchRepositoryList(searchResults: [[String : Any]]) {
        repositories = searchResults
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

class RepositoryTabelViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
