//  CollectionMatrixModel.swift
//  Kikisake

import Foundation

/// 図鑑のペアリング項目（縦軸の産地 × 横軸の品種・米・スタイル）
public struct CollectionItemDefinition: Identifiable, Hashable {
    public let id = UUID()
    public let region: String          // 産地 (例: "フランス", "新潟県")
    public let targetElement: String   // 品種・米・スタイル (例: "ピノ・ノワール", "山田錦")
    public let category: BeverageCategory
    
    public init(region: String, targetElement: String, category: BeverageCategory) {
        self.region = region
        self.targetElement = targetElement
        self.category = category
    }
}

/// コンプリート図鑑のマスターマッピング管理
public enum CollectionMatrixDataSource {
    
    /// 指定した酒種の有効な掛け合わせリスト（図鑑の全コンプリート目標）
    public static func definitions(for category: BeverageCategory) -> [CollectionItemDefinition] {
        switch category {
        case .wine:
            return [
                // フランス
                .init(region: "フランス", targetElement: "カベルネ・ソーヴィニヨン", category: .wine),
                .init(region: "フランス", targetElement: "メルロ", category: .wine),
                .init(region: "フランス", targetElement: "ピノ・ノワール", category: .wine),
                .init(region: "フランス", targetElement: "シャルドネ", category: .wine),
                .init(region: "フランス", targetElement: "ソーヴィニヨン・ブラン", category: .wine),
                .init(region: "フランス", targetElement: "シラー / シラーズ", category: .wine),
                .init(region: "フランス", targetElement: "リースリング", category: .wine),
                // イタリア
                .init(region: "イタリア", targetElement: "サンジョヴェーゼ", category: .wine),
                .init(region: "イタリア", targetElement: "ネッビオーロ", category: .wine),
                .init(region: "イタリア", targetElement: "バルベラ", category: .wine),
                .init(region: "イタリア", targetElement: "ピノ・グリ / ピノ-グリージョ", category: .wine),
                // アメリカ
                .init(region: "アメリカ", targetElement: "カベルネ・ソーヴィニヨン", category: .wine),
                .init(region: "アメリカ", targetElement: "シャルドネ", category: .wine),
                .init(region: "アメリカ", targetElement: "ピノ・ノワール", category: .wine),
                // 日本
                .init(region: "日本", targetElement: "甲州", category: .wine),
                .init(region: "日本", targetElement: "マスカット・ベーリーA", category: .wine),
                // スイス（マイナー国の例：限定的な品種のみ）
                .init(region: "スイス", targetElement: "ピノ・ノワール", category: .wine),
                .init(region: "スイス", targetElement: "シャスラ", category: .wine)
            ]
            
        case .sake:
            return [
                // 新潟県
                .init(region: "新潟県", targetElement: "山田錦", category: .sake),
                .init(region: "新潟県", targetElement: "五百万石", category: .sake),
                .init(region: "新潟県", targetElement: "越淡麗", category: .sake),
                // 兵庫県
                .init(region: "兵庫県", targetElement: "山田錦", category: .sake),
                .init(region: "兵庫県", targetElement: "雄町", category: .sake),
                // 京都府
                .init(region: "京都府", targetElement: "山田錦", category: .sake),
                .init(region: "京都府", targetElement: "五百万石", category: .sake),
                // 山形県
                .init(region: "山形県", targetElement: "出羽燦々", category: .sake),
                .init(region: "山形県", targetElement: "美山錦", category: .sake),
                .init(region: "山形県", targetElement: "雄町", category: .sake),
                // 秋田県
                .init(region: "秋田県", targetElement: "秋田酒こまち", category: .sake),
                .init(region: "秋田県", targetElement: "美山錦", category: .sake)
            ]
            
        case .beer:
            return [
                // ベルギー
                .init(region: "ベルギー", targetElement: "ベルジャンホワイト", category: .beer),
                .init(region: "ベルギー", targetElement: "セゾン", category: .beer),
                .init(region: "ベルギー", targetElement: "サワーエール", category: .beer),
                // ドイツ
                .init(region: "ドイツ", targetElement: "ピルスナー", category: .beer),
                .init(region: "ドイツ", targetElement: "ヴァイツェン", category: .beer),
                .init(region: "ドイツ", targetElement: "ボック", category: .beer),
                // イギリス
                .init(region: "イギリス", targetElement: "ペールエール", category: .beer),
                .init(region: "イギリス", targetElement: "スタウト", category: .beer),
                .init(region: "イギリス", targetElement: "ポーター", category: .beer),
                // アメリカ
                .init(region: "アメリカ", targetElement: "IPA", category: .beer),
                .init(region: "アメリカ", targetElement: "ヘイジーIPA", category: .beer),
                .init(region: "アメリカ", targetElement: "ダブルIPA", category: .beer),
                .init(region: "アメリカ", targetElement: "ペールエール", category: .beer)
            ]
        }
    }
}
