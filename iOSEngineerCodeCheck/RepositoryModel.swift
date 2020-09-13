//
//  RepositoryModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 若江照仁 on 2020/09/13.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

protocol RepositoryModelDelegate: class {
    func fetchImage(image: UIImage)
    func fetchContents()
}
class RepositoryModel {
    var fullName: String = ""
    var language: String = ""
    var stars: Int = 0
    var forks: Int = 0
    var issues: Int = 0
    var subscribersCount: Int = 0
    var owner: [String: Any] = [String: Any]()
    
    // githubにおいてwatcherの概念が変更となるようです。
    // subscribers_countを利用する必要がある
    // だたし検索結果のjsonにはsubscribers_urlしかないので、fetchSubscribersCountを作りました。
    // 参考：https://github.com/milo/github-api/issues/19
    var repositoryUrl: String = ""
    
    weak var delegate: RepositoryModelDelegate?

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
    
    func fetchSubscribersCount() {
        if repositoryUrl == "" { return }
        guard let url = URL(string: repositoryUrl) else {
            print("urlエラー")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
            // クライアント側のエラー
            if let err = err {
                print("検索失敗。\(err)")
                return
            }
            guard let data = data, let obj = try! JSONSerialization.jsonObject(with: data) as? [String: Any] else { print("error") ;return}
            self.subscribersCount = obj["subscribers_count"] as? Int ?? 0
            self.delegate?.fetchContents()
        }
        task.resume()
    }
    
    func fetchImage() {
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
            guard let data = data, let img = UIImage(data: data) else {
                return
            }
            self.delegate?.fetchImage(image: img)
        }.resume()
    }

}

