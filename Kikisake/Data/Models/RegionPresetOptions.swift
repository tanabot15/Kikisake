//  RegionPresetOptions.swift
//  Kikisake

import Foundation

/// 階層型産地データの構造体
public struct RegionHierarchy: Identifiable, Hashable {
    public let id = UUID()
    public let parent: String       // 親エリア (例: "フランス", "新潟県")
    public let children: [String]   // 子エリアリスト (例: ["ブルゴーニュ", "ボルドー", ...])

    public init(parent: String, children: [String] = []) {
        self.parent = parent
        self.children = children
    }
}

/// 共通の生産地プリセットプロバイダ
public enum RegionPresetOptions {

    /// 酒種に応じた階層型生産地リストを取得
    public static func regions(for category: BeverageCategory) -> [RegionHierarchy] {
        switch category {
        case .wine:
            return wineRegions
        case .sake:
            return sakeRegions
        case .beer:
            return beerRegions
        }
    }

    // MARK: - 1. ワイン主要産地 (国 > 地方)
    private static var wineRegions: [RegionHierarchy] {
        [
            RegionHierarchy(parent: String(localized: "フランス"), children: [
                String(localized: "ボルドー"),
                String(localized: "ブルゴーニュ"),
                String(localized: "シャンパーニュ"),
                String(localized: "ローヌ"),
                String(localized: "ロワール"),
                String(localized: "アルザス"),
                String(localized: "ラングドック・ルーション"),
                String(localized: "プロヴァンス")
            ]),
            RegionHierarchy(parent: String(localized: "イタリア"), children: [
                String(localized: "ピエモンテ"),
                String(localized: "トスカーナ"),
                String(localized: "ヴェネト"),
                String(localized: "シチリア"),
                String(localized: "フリウリ・ヴェネツィア・ジューリア"),
                String(localized: "ロンバルディア")
            ]),
            RegionHierarchy(parent: String(localized: "アメリカ"), children: [
                String(localized: "カリフォルニア (ナパ・ヴァレー)"),
                String(localized: "カリフォルニア (ソノマ)"),
                String(localized: "オレゴン"),
                String(localized: "ワシントン")
            ]),
            RegionHierarchy(parent: String(localized: "日本"), children: [
                String(localized: "山梨"),
                String(localized: "長野"),
                String(localized: "北海道"),
                String(localized: "山形")
            ]),
            RegionHierarchy(parent: String(localized: "スペイン"), children: [
                String(localized: "リオハ"),
                String(localized: "リベラ・デル・ドゥエロ"),
                String(localized: "カタルーニャ"),
                String(localized: "ヘレス (シェリー)")
            ]),
            RegionHierarchy(parent: String(localized: "ドイツ"), children: [
                String(localized: "モーゼル"),
                String(localized: "ラインガウ"),
                String(localized: "ファルツ")
            ]),
            RegionHierarchy(parent: String(localized: "オーストラリア"), children: [
                String(localized: "バロッサ・ヴァレー"),
                String(localized: "マーガレット・リヴァー"),
                String(localized: "ヤラ・ヴァレー")
            ]),
            RegionHierarchy(parent: String(localized: "ニュージーランド"), children: [
                String(localized: "マールボロ"),
                String(localized: "セントラル・オタゴ")
            ]),
            RegionHierarchy(parent: String(localized: "チリ"), children: [
                String(localized: "マイポ・ヴァレー"),
                String(localized: "カサブランカ・ヴァレー")
            ]),
            RegionHierarchy(parent: String(localized: "アルゼンチン"), children: [
                String(localized: "メンドーサ")
            ])
        ]
    }

    // MARK: - 2. 日本酒主要産地 (都道府県 > 主要酒処・地区)
    private static var sakeRegions: [RegionHierarchy] {
        [
            RegionHierarchy(parent: String(localized: "新潟県"), children: [
                String(localized: "中越 (長岡・魚沼)"),
                String(localized: "下越 (新潟・村上)"),
                String(localized: "上越 (上越)"),
                String(localized: "佐渡")
            ]),
            RegionHierarchy(parent: String(localized: "兵庫県"), children: [
                String(localized: "灘五郷"),
                String(localized: "播州 (西脇・加東)"),
                String(localized: "但馬")
            ]),
            RegionHierarchy(parent: String(localized: "京都府"), children: [
                String(localized: "伏見"),
                String(localized: "丹後・丹波")
            ]),
            RegionHierarchy(parent: String(localized: "山形県"), children: [
                String(localized: "村山 (山形)"),
                String(localized: "庄内 (酒田・鶴岡)"),
                String(localized: "置賜 (米沢)")
            ]),
            RegionHierarchy(parent: String(localized: "秋田県"), children: [
                String(localized: "中央 (秋田)"),
                String(localized: "県南 (横手・湯沢)"),
                String(localized: "県北 (能代)")
            ]),
            RegionHierarchy(parent: String(localized: "福島県"), children: [
                String(localized: "会津"),
                String(localized: "中通り"),
                String(localized: "浜通り")
            ]),
            RegionHierarchy(parent: String(localized: "長野県"), children: [
                String(localized: "北信"),
                String(localized: "中信"),
                String(localized: "南信"),
                String(localized: "東信")
            ]),
            RegionHierarchy(parent: String(localized: "石川県"), children: [
                String(localized: "加賀・白山"),
                String(localized: "能登")
            ]),
            RegionHierarchy(parent: String(localized: "広島県"), children: [
                String(localized: "西条 (東広島)"),
                String(localized: "呉・竹原")
            ]),
            RegionHierarchy(parent: String(localized: "高知県"), children: [
                String(localized: "土佐")
            ])
        ]
    }

    // MARK: - 3. ビール主要産地 (国 > 地方・都市)
    private static var beerRegions: [RegionHierarchy] {
        [
            RegionHierarchy(parent: String(localized: "ドイツ"), children: [
                String(localized: "バイエルン (ミュンヘン)"),
                String(localized: "ドルトムント"),
                String(localized: "ケルン"),
                String(localized: "バンベルク")
            ]),
            RegionHierarchy(parent: String(localized: "ベルギー"), children: [
                String(localized: "フランダース"),
                String(localized: "ワロン"),
                String(localized: "ブリュッセル")
            ]),
            RegionHierarchy(parent: String(localized: "イギリス"), children: [
                String(localized: "イングランド"),
                String(localized: "スコットランド")
            ]),
            RegionHierarchy(parent: String(localized: "アメリカ"), children: [
                String(localized: "西海岸 (ポートランド・サンディエゴ)"),
                String(localized: "東海岸 (バーモント・ニューヨーク)")
            ]),
            RegionHierarchy(parent: String(localized: "チェコ"), children: [
                String(localized: "プルゼニ (ピルゼン)"),
                String(localized: "プラハ")
            ]),
            RegionHierarchy(parent: String(localized: "日本"), children: [
                String(localized: "北海道"),
                String(localized: "長野"),
                String(localized: "静岡"),
                String(localized: "三重"),
                String(localized: "鳥取")
            ])
        ]
    }
}
