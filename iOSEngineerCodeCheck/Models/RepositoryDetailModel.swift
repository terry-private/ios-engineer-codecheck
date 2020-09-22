//
//  RepositoryModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 若江照仁 on 2020/09/13.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

protocol RepositoryDetailModelDelegate: class {
    func fetchContentsResult(result: ApiResult)
}

class RepositoryDetailModel {
    var fullName: String = ""
    var language: String = ""
    var stars: Int = 0
    var forks: Int = 0
    var issues: Int = 0
    var subscribersCount: Int = 0
    var owner: [String: Any] = [String: Any]()
    var avatarImage: UIImage?
    /*
    githubにおいてwatcherの概念が変更となるようです。
    参考：https://github.com/milo/github-api/issues/19
    subscribers_countを利用する必要がある
    だたし検索結果のjsonにはないので、fetchSubscribersCountを作り
    repositoryUrlを使ってもう一度APIを叩きに行きます！
    そして今後リポジトリ画面にもっと詳細の情報を載せる拡張をするかもしれない。。。
    */
    var repositoryUrl: String = ""
    
    // メモリリークを避けるための弱参照
    weak var delegate: RepositoryDetailModelDelegate?
    var task : URLSessionTask?
    func cancel() {
        if task?.state != URLSessionTask.State.running { return }
        task?.cancel()
        task = nil
    }
    /// イニシャライザーでgithub api から取ったjsonをパースした辞書をそのまま展開します。
    /// - Parameter dic:github api から取ったjsonをパースした辞書
    init(dic: [String: Any]){
        language = dic["language"] as? String ?? ""
        stars = dic["stargazers_count"] as? Int ?? 0
        forks = dic["forks_count"] as? Int ?? 0
        issues = dic["open_issues_count"] as? Int ?? 0
        owner = dic["owner"] as? [String: Any] ?? [String: Any]()
        fullName = dic["full_name"] as? String ?? ""
        repositoryUrl = dic["url"] as? String ?? ""
    }

    func fetchSubscribersCount(){
        if repositoryUrl == "" { return }
        guard let delegateFunc = delegate?.fetchContentsResult else { return }
        cancel()
        task = URLSession.getApiResult(apiUrl: repositoryUrl, type: .Json, delegateFunc: delegateFunc)
    }
}
