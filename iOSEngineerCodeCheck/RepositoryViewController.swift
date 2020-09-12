//
//  RepositoryViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoryViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!
    
    var repositoriesTableViewController: RepositoriesTableViewController!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repo = repositoriesTableViewController.repositories[repositoriesTableViewController.index]
        
        languageLabel.text = "Written in \(repo["language"] as? String ?? "")"
        starsLabel.text = "\(repo["stargazers_count"] as? Int ?? 0) stars"
        watchersLabel.text = "\(repo["wachers_count"] as? Int ?? 0) watchers"
        forksLabel.text = "\(repo["forks_count"] as? Int ?? 0) forks"
        issuesLabel.text = "\(repo["open_issues_count"] as? Int ?? 0) open issues"
        getImage()
    }
    
    func getImage() {
        let repo = repositoriesTableViewController.repositories[repositoriesTableViewController.index]
        titleLabel.text = repo["full_name"] as? String
        
        guard let owner = repo["owner"] as? [String: Any] else { return }
        guard let urlString = owner["avatar_url"] as? String else { return }
        // URLの強制アンラップを廃止し事前にエラーとしてreturn
        guard let imgURL = URL(string: urlString) else {
            print("urlエラー")
            return
        }
        URLSession.shared.dataTask(with: imgURL) { (data, res, err) in
            if let err = err {
                print("err: \(err)")
                return
            }
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = img
            }
        }.resume()
    }
}
