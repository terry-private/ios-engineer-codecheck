//
//  RepositoriesTableViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import Nuke

/// 検索画面
class SearchRepositoryViewController: UIViewController {
    let cellId = "cellId"
    var repositories: [[String: Any]]=[]
    let repositoryListModel = RepositoryListModel()
    var currentIndexPath: IndexPath?
    
    // クルクルインジゲーター
    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var repositoryListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
        repositoryListTableView.delegate = self
        repositoryListTableView.dataSource = self
        repositoryListModel.delegate = self
        
        // クルクルインジゲーター設定
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.large
        view.addSubview(indicator)
    
    }
}

extension SearchRepositoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 遷移前に遷移先Viewにモデルとそのデリゲートをセットします。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let indexPath = currentIndexPath else { return }
        if segue.identifier == "Detail"{
            let dtl = segue.destination as! RepositoryDetailViewController
            let cell = repositoryListTableView.cellForRow(at: indexPath) as? RepositoryListTabelViewCell
            dtl.repository = RepositoryDetailModel(dic: repositories[indexPath.row])
            dtl.repository?.delegate = dtl
            dtl.repository?.avatarImage = cell?.avatarImageView.image
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = repositoryListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RepositoryListTabelViewCell
        cell.repositoryData = repositories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // prepareの処理でindexを使いたいのでselfのindexに一旦保持します。
        currentIndexPath = indexPath
        performSegue(withIdentifier: "Detail", sender: self)
    }
}

/// UISearchBarDelegateのロジック周りをextensionとして分けます。
extension SearchRepositoryViewController: UISearchBarDelegate {
    
    // 編集するとApiのタスクとクルクルが止まる仕様
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        repositoryListModel.cancel()
        DispatchQueue.main.async {
            self.repositoryListTableView.reloadData()
            self.indicator.stopAnimating()
        }
    }
    
    // 検索ボタン押下時処理　クルクルスタート
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        indicator.startAnimating()
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
        
        // メインスレッド内で描画系の処理を走らせます。クルクルストップ
        DispatchQueue.main.async {
            self.repositoryListTableView.reloadData()
            self.indicator.stopAnimating()
        }
    }
}

/// storyboardのカスタムセル
class RepositoryListTabelViewCell: UITableViewCell {
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageColorView: UIView!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    var repositoryData = [String: Any]() {
        didSet{
            // モデルをセットしたタイミングで表示処理を走らせます。
            guard let owner = repositoryData["owner"] as? [String: Any] else { return }
            guard let avatarUrl = owner["avatar_url"] as? String else { return }
            guard let url = URL(string:avatarUrl) else { return }
            guard let language = repositoryData["language"] as? String else { return }
            Nuke.loadImage(with: url, into: avatarImageView)
            ownerNameLabel.text = owner["login"] as? String ?? ""
            languageLabel.text = language
            repositoryNameLabel.text = repositoryData["name"] as? String ?? ""
            starsLabel.text = String(repositoryData["stargazers_count"] as? Int ?? 0)
            
            if language == "" {
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
