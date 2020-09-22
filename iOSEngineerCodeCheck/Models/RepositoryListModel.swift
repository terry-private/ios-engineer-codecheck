//
//  RepositoryListModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 若江照仁 on 2020/09/13.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Foundation
protocol RepositoryListModelDelegate: class {
    func fetchRepositories(result: ApiResult)
}


/// レポジトリ検索画面のVCが保持するモデル
/// 実際のテーブルに表示するためのデータはVCのrepositoriesという変数で
/// searchRepositoriesでApiResultを作成して中身の["items"]の部分を渡す形をとっています。
class RepositoryListModel {
    var task: URLSessionTask?
    // メモリリークを避けるための弱参照
    weak var delegate: RepositoryListModelDelegate?
    
    func cancel() {
        if task?.state != URLSessionTask.State.running { return }
        task?.cancel()
        task = nil
    }
    
    /// getApiResultでApiResultをVCに送ります。
    /// - Parameter serchWord: 検索ワードをapiのurlとくっつけて渡します　欲しい結果のタイプはJsonです。
    func serchRepositories(_ serchWord: String) {
        if serchWord.count == 0 { return }
        guard let delegateFunc = delegate?.fetchRepositories else { return }
        cancel()
        task = URLSession.getApiResult(apiUrl: "https://api.github.com/search/repositories?q=\(serchWord)",
            type: .Json, delegateFunc: delegateFunc)
    }
}
