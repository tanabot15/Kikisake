//
//  ConsumeBeverageUseCase.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import os

/// 在庫ボトルを開けて消費し、テイスティングログ作成へスムーズに連携するユースケース
public struct ConsumeBeverageUseCase {
    
    public init() {}

    /// 指定された在庫アイテムの在庫数を1減らし、消費処理を行う
    /// 在庫数が0以下になった場合の管理フラグ更新などもここに集約する
    /// - Parameter item: 対象の BeverageItem
    /// - Throws: 在庫不足エラー
    public func executeConsumption(for item: BeverageItem) throws {
        if item.stockQuantity > 0 {
            item.stockQuantity -= 1
            AppLogger.general.info("Consumed 1 bottle of: \(item.name, privacy: .public). Remaining: \(item.stockQuantity)")
        } else {
            throw NSError(
                domain: "ConsumeBeverageUseCase",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "このアイテムの在庫がありません。"]
            )
        }
    }
}
