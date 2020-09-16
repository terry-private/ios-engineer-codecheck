//
//  RepositoryListModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 若江照仁 on 2020/09/13.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Foundation
protocol RepositoryListDelegate: class {
    func fetchRepositories(result: ApiResult)
}


class RepositoryListModel {
    var task: URLSessionTask?
    // メモリリークを避けるための弱参照
    weak var delegate: RepositoryListDelegate?
    
    func cancel() {
        task?.cancel()
    }
    
    /// getApiResultでApiResultをVCに送ります。
    /// - Parameter serchWord: 検索ワードをapiのurlとくっつけて渡します　欲しい結果のタイプはJsonです。
    func serchRepositories(_ serchWord: String) {
        if serchWord.count == 0 { return }
        guard let delegateFunc = delegate?.fetchRepositories else { return }
        URLSession.getApiResult(apiUrl: "https://api.github.com/search/repositories?q=\(serchWord)",
            type: .Json, delegateFunc: delegateFunc)
    }
}
