//
//  URLsession-Extension.swift
//  iOSEngineerCodeCheck
//
//  Created by 若江照仁 on 2020/09/16.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

extension URLSession {
    
    /// apiを叩いて終了時に引数であるdelegateFunc()にApiResultを入れて実行します。
    /// 実行するとModelのdelegateを通してViewControllerのViewを更新する関数に繋がります。
    /// - Parameters:
    ///   - apiUrl: String型のAPIのURLを渡すとURLクラスをインスタンス化します。イニシャライズ時にサニタイズしてるっぽいのでnilでreturnするのみ
    ///   - type: ApiResultTypeを渡してApiResultを生成するときに型を指定します。
    ///   - delegateFunc: ここで生成したApiResultを元にViewControllerで描画処理をします。
    class func getApiResult(apiUrl: String, type: ApiResultType, delegateFunc: @escaping (ApiResult) -> Void) -> URLSessionTask? {
        guard let url = URL(string: apiUrl) else {
            print("getApiResult > url_error")
            delegateFunc(ApiResult(type: .Error, data: nil))
            return nil
        }
        
        //　ここから別スレッド
        let task = self.shared.dataTask(with: url) {(data, res, err) in
            if let err = err {
                print("session_error: \(err)")
                delegateFunc(ApiResult(type: .Error, data: nil))
                return
            }
            guard let data = data else {
                print("data = nil")
                delegateFunc(ApiResult(type: .Error, data: nil))
                return
            }
            delegateFunc(ApiResult(type: type, data: data))
        }
        task.resume()
        return task
    }
}

/// Apiの結果を複数のタイプに対応させるための構造体
struct ApiResult {
    private let type: ApiResultType
    private let data: Data?
    
    /// 読み取り専用
    /// type別にdataを加工して返します。
    /// .Json => パースして辞書型
    /// .Image => UIView
    var value: Any? {
        get{
            switch self.type {
            case .Json:
                guard let data = data  else { return nil}
                let obj = try! JSONSerialization.jsonObject(with: data)
                return obj
            default:
                return nil
            }
        }
    }
    
    init(type: ApiResultType, data: Data?) {
        self.type = type
        self.data = data
    }
}

/// ApiResultのタイプ。
/// タイプを追加する場合は
/// ApiResultのvalue.getterのcase処理も増やす必要があります。
enum ApiResultType {
    case Error
    case Json
}
