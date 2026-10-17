//
//  StorageLocation.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/17.
//

import Foundation
import SwiftData

/// ユーザーが自由に追加・管理できる保管場所モデル
@Model
public final class StorageLocation {
    @Attribute(.unique) public var id: UUID
    public var name: String             // 保管場所の名前（例: "自宅セラー", "サブ冷蔵庫"）
    public var typeRawValue: String     // 種類（"ワインセラー", "冷蔵庫", "常温" など）
    public var memo: String             // 補足メモ
    public var createdAt: Date

    public var type: StorageCategoryType {
        get { StorageCategoryType(rawValue: typeRawValue) ?? .cellar }
        set { typeRawValue = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        name: String,
        type: StorageCategoryType,
        memo: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.typeRawValue = type.rawValue
        self.memo = memo
        self.createdAt = createdAt
    }
}

/// 保管大分類の種類
public enum StorageCategoryType: String, CaseIterable, Codable, Identifiable {
    case cellar = "ワインセラー"
    case refrigerator = "冷蔵庫"
    case roomTemp = "常温"
    case other = "その他"

    public var id: String { rawValue }

    public var defaultIconName: String {
        switch self {
        case .cellar: return "cabinet.fill"
        case .refrigerator: return "refrigerator.fill"
        case .roomTemp: return "humidity.fill"
        case .other: return "shippingbox.fill"
        }
    }
}
