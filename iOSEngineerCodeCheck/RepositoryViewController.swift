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
    var repository: RepositoryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        repository?.fetchImage()
    }
    func setContent() {
        titleLabel.text = repository?.fullName
        languageLabel.text = "Written in \(repository?.language ?? "")"
        starsLabel.text = "\(repository?.stars ?? 0) stars"
        watchersLabel.text = "\(repository?.watchers ?? 0) watchers"
        forksLabel.text = "\(repository?.forks ?? 0) forks"
        issuesLabel.text = "\(repository?.issues ?? 0) open issues"
    }
}

extension RepositoryViewController: RepositoryModelDelegate{
    func fetchImage(image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
