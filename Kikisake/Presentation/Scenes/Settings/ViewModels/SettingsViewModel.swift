//
//  SettingsViewModel.swift
//  Kikisake
//

import Foundation
import UIKit
import SwiftData

/// Business logic and state coordinator for SettingsView.
@Observable
public final class SettingsViewModel {
    public var isProcessing: Bool = false
    public var alertTitle: String = ""
    public var alertMessage: String = ""
    public var showAlert: Bool = false

    public var isExporting: Bool = false
    public var exportDocument: BackupFileDocument? = nil
    public var exportFileName: String = ""

    public var selectedImportURL: URL? = nil
    public var showRestoreConfirmation: Bool = false

    public var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    public var currentLanguageDisplayName: String {
        let currentCode = Bundle.main.preferredLocalizations.first ?? "ja"
        let locale = Locale(identifier: currentCode)
        return locale.localizedString(forLanguageCode: currentCode) ?? currentCode
    }

    public init() {}

    public func openDeviceSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    public func deleteAllData(using modelContext: ModelContext) {
        do {
            try modelContext.delete(model: BeverageItem.self)
            try modelContext.delete(model: StorageLocation.self)
            try modelContext.save()
            presentAlert(
                title: String(localized: "完了"),
                message: String(localized: "すべてのデータが削除されました。")
            )
        } catch {
            presentAlert(
                title: String(localized: "エラー"),
                message: String(format: String(localized: "データの削除に失敗しました: %@"), error.localizedDescription)
            )
        }
    }

    @MainActor
    public func exportBackup(modelContext: ModelContext) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let data = try BackupManager.shared.exportData(modelContext: modelContext)
            exportDocument = BackupFileDocument(payloadData: data)
            exportFileName = BackupManager.shared.generateBackupFileName()
            isExporting = true
        } catch {
            presentAlert(title: String(localized: "エクスポート失敗"), message: error.localizedDescription)
        }
    }

    public func prepareImport(from urls: [URL]) {
        guard let url = urls.first else { return }
        selectedImportURL = url
        showRestoreConfirmation = true
    }

    @MainActor
    public func restoreBackup(strategy: RestoreStrategy, modelContext: ModelContext) async {
        guard let url = selectedImportURL else { return }
        isProcessing = true
        defer {
            isProcessing = false
            selectedImportURL = nil
        }

        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw BackupError.importFailed(String(localized: "ファイルアクセスの権限が取得できませんでした。"))
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let data = try Data(contentsOf: url)
            try BackupManager.shared.importData(from: data, strategy: strategy, modelContext: modelContext)
            presentAlert(
                title: String(localized: "復元完了"),
                message: String(localized: "バックアップからの復元が正常に完了しました。")
            )
        } catch {
            presentAlert(title: String(localized: "リストア失敗"), message: error.localizedDescription)
        }
    }

    public func presentAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
