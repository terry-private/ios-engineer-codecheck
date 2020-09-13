//
//  RepositoryListModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 若江照仁 on 2020/09/13.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Foundation
protocol RepositoryListDelegate: class {
    func fetchRepositoryList(searchResults: [[String: Any]])
}

class RepositoryListModel {
    var task: URLSessionTask?
    // メモリリークを避けるための弱参照
    weak var delegate: RepositoryListDelegate?
    
    func cancel() {
        task?.cancel()
    }
    
    func serchRepositories(_ serchWord: String) {
        if serchWord.count == 0 { return }
        
        // URLの強制アンラップを廃止し事前にエラーとしてreturn
        guard let url = URL(string: "https://api.github.com/search/repositories?q=\(serchWord)") else {
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
                self.delegate?.fetchRepositoryList(searchResults: items)
            }
        }
        task?.resume()
    }
}
