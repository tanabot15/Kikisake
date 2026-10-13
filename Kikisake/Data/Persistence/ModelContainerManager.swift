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
        
        // 通常のマイグレーションとインメモリ構成を考慮した設定
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLogger.persistence.info("Successfully initialized SwiftData ModelContainer.")
        } catch {
            AppLogger.persistence.critical("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription, privacy: .public)")
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }
}
