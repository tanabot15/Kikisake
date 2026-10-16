//
//  ModelContainerManager.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import SwiftData
import os

/// SwiftDataのModelContainerを管理するシングルトンおよびファクトリ
public final class ModelContainerManager {
    public static let shared = ModelContainerManager()

    /// 共有のModelContainerインスタンス
    public let container: ModelContainer

    private init() {
        let schema = Schema([
            BeverageItem.self,
            TastingLog.self
        ])
        
        // プレビュー（Canvas）実行中かどうかを安全に判定する
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        
        // プレビュー時はインメモリ、通常時は永続ストレージを使用する
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isPreview,
            allowsSave: true
        )
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLogger.persistence.info("Successfully initialized SwiftData ModelContainer (isPreview: \(isPreview)).")
        } catch {
            AppLogger.persistence.critical("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription, privacy: .public)")
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }
}
