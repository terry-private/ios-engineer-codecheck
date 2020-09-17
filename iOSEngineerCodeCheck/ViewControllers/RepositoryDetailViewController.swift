//
//  RepositoryViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoryDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!

    var repository: RepositoryDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setContent() {
        titleLabel.text = repository?.fullName
        languageLabel.text = "Written in \(repository?.language ?? "")"
        starsLabel.text = "\(repository?.stars ?? 0) stars"
        forksLabel.text = "\(repository?.forks ?? 0) forks"
        issuesLabel.text = "\(repository?.issues ?? 0) open issues"
        watchersLabel.text = "\(repository?.subscribersCount ?? 0) watchers"
    }
}

// モデルからDelegateを使って変更を受信
extension RepositoryDetailViewController: RepositoryDetailModelDelegate{
    func fetchImageResult(result: ApiResult) {
        guard let image = result.value as? UIImage else { return }
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    // RepositoryModelからRepositoryModelDelegateを通して非同期で呼ばれる関数
    // ApiResultはjson type のため中身はパース後のdicのはず　違う場合はエラー処理
    func fetchContentsResult(result: ApiResult) {
        guard let repositoryData = result.value as? [String: Any] else { return }
        repository?.subscribersCount = repositoryData["subscribers_count"] as? Int ?? 0
        DispatchQueue.main.async {
            self.setContent()
        }
    }
}
