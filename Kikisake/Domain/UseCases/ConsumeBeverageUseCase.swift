//  ConsumeBeverageUseCase.swift
//  Kikisake

import Foundation
import os

/// 在庫ボトルを開けて消費し、テイスティングログ作成へスムーズに連携するユースケース
public struct ConsumeBeverageUseCase {
    
    public init() {}

    /// 指定された在庫アイテムの消費処理を行いログを記録可能にする
    /// - Parameter item: 対象の BeverageItem
    /// - Throws: 消費処理時のエラー
    public func executeConsumption(for item: BeverageItem) throws {
        AppLogger.general.info("Opened bottle: \(item.name, privacy: .public)")
    }
}
