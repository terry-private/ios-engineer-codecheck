//
//  RepositoriesTableViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoriesTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var repositorySearchBar: UISearchBar!
    
    var repositories: [[String: Any]]=[]
    
    var task: URLSessionTask?
    var word: String!
    var url: String!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        repositorySearchBar.text = "GitHubのリポジトリを検索できるよー"
        repositorySearchBar.delegate = self
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // ↓こうすれば初期のテキストを消せる
        searchBar.text = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        task?.cancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        word = searchBar.text!
        
        if word.count == 0 { return }
        
        // URLの強制アンラップを廃止し事前にエラーとしてreturn
        guard let url = URL(string: "https://api.github.com/search/repositories?q=\(word!)") else {
            print("urlエラー")
            return
        }
        task = URLSession.shared.dataTask(with: url) { (data, res, err) in
            // クライアント側のエラー
            if let err = err {
                print("検索失敗。\(err)")
                return
            }
            guard let data = data, let obj = try! JSONSerialization.jsonObject(with: data) as? [String: Any] else {return}
            if let items = obj["items"] as? [[String: Any]] {
                self.repositories = items
                // これ呼ばなきゃリストが更新されません
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        task?.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Detail"{
            let dtl = segue.destination as! RepositoryViewController
            dtl.repository = RepositoryModel(dic: repositories[index])
            dtl.repository?.delegate = dtl
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let rp = repositories[indexPath.row]
        cell.textLabel?.text = rp["full_name"] as? String ?? ""
        cell.detailTextLabel?.text = rp["language"] as? String ?? ""
        cell.tag = indexPath.row
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 画面遷移時に呼ばれる
        index = indexPath.row
        performSegue(withIdentifier: "Detail", sender: self)
        
    }
    
}
