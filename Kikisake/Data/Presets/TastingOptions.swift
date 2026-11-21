//
//  TastingOptions.swift
//  Kikisake
//

import SwiftUI

/// 外観カラーオプションの構造体（Pro限定フラグを内包）
public struct ColorOption: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let color: Color
    public let hex: String
    public let isPro: Bool

    public init(id: UUID = UUID(), name: String, color: Color, hex: String, isPro: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.hex = hex
        self.isPro = isPro
    }
}

/// 香りタグの構造体（Pro限定フラグを内包）
public struct AromaTag: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let isPro: Bool

    public init(id: UUID = UUID(), _ name: String, isPro: Bool) {
        self.id = id
        self.name = name
        self.isPro = isPro
    }
}

/// 香りの分類データ構造
public struct AromaCategory: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let tags: [AromaTag]

    public init(id: UUID = UUID(), title: String, tags: [AromaTag]) {
        self.id = id
        self.title = title
        self.tags = tags
    }
}

/// 共通のテイスティング選択肢プロバイダ
public enum TastingOptions {
    private struct RGBAColorSpec {
        let name: String
        let r: Double
        let g: Double
        let b: Double
        let hex: String
        let isPro: Bool

        func toColorOption() -> ColorOption {
            ColorOption(
                name: String(localized: String.LocalizationValue(name)),
                color: Color(red: r, green: g, blue: b),
                hex: hex,
                isPro: isPro
            )
        }
    }

    // MARK: - 判定ヘルパーメソッド

    /// 指定された香りタグが無料版で利用可能か判定
    public static func isFreeAromaTag(_ tag: String, in category: AromaCategory) -> Bool {
        guard let aromaTag = category.tags.first(where: { $0.name == tag }) else { return true }
        return !aromaTag.isPro
    }

    /// 指定されたカラーオプションが無料版で利用可能か判定
    public static func isFreeColorOption(_ option: ColorOption, in options: [ColorOption]) -> Bool {
        guard let found = options.first(where: { $0.name == option.name }) else { return true }
        return !found.isPro
    }

    // MARK: - マスター選択肢一覧

    /// 味わいのバランス表現のマスター選択肢一覧（カスタム要素を統合）
    public static var balanceOptions: [String] {
        let defaults = [
            String(localized: "スムーズな"),
            String(localized: "コンパクトな"),
            String(localized: "スリムな"),
            String(localized: "ドライな"),
            String(localized: "引き締まった"),
            String(localized: "ジューシーな"),
            String(localized: "豊潤な"),
            String(localized: "厚みのある"),
            String(localized: "まろやかな"),
            String(localized: "ふくよかな"),
            String(localized: "ねっとりした")
        ]
        return defaults + TastingCustomizationManager.shared.customBalances
    }

    /// 酒種・タイプに応じた外観カラーオプションを取得（薄い色〜濃い色の順にソート、カスタム要素を統合）
    public static func colorOptions(for category: BeverageCategory?, wineType: String = "赤") -> [ColorOption] {
        guard let category else {
            var allOptions: [ColorOption] = []
            var seenNames = Set<String>()

            let combinations: [(BeverageCategory, String)] = [
                (.wine, "赤"), (.wine, "白"), (.wine, "ロゼ"), (.wine, "オレンジ"),
                (.sake, "赤"), (.beer, "赤")
            ]

            for (cat, wType) in combinations {
                for option in colorOptions(for: cat, wineType: wType) where seenNames.insert(option.name).inserted {
                    allOptions.append(option)
                }
            }
            return allOptions
        }

        let specs: [RGBAColorSpec]
        switch category {
        case .wine:
            specs = wineColorSpecs(for: wineType)
        case .sake:
            specs = sakeColorSpecs
        case .beer:
            specs = beerColorSpecs
        }

        let baseOptions = specs.map { $0.toColorOption() }
        let customColorsMapped = TastingCustomizationManager.shared.customColors.map { custom in
            ColorOption(
                name: custom.name,
                color: Color(hex: custom.hex) ?? .gray,
                hex: custom.hex,
                isPro: custom.isPro
            )
        }

        return baseOptions + customColorsMapped
    }

    /// 香りカテゴリ一覧を取得（カスタム香りタグを統合）
    public static func aromaCategories(for category: BeverageCategory?, wineType: String = "赤") -> [AromaCategory] {
        guard let category else {
            var tagSet = Set<String>()
            var combinedTags: [AromaTag] = []

            for cat in [BeverageCategory.wine, .sake, .beer] {
                for aromaCategory in aromaCategories(for: cat, wineType: wineType) {
                    for tag in aromaCategory.tags where tagSet.insert(tag.name).inserted {
                        combinedTags.append(tag)
                    }
                }
            }
            return [AromaCategory(title: String(localized: "すべての香り要素"), tags: combinedTags)]
        }

        var categories: [AromaCategory]
        switch category {
        case .wine:
            categories = wineAromaCategories(for: wineType)
        case .sake:
            categories = sakeAromaCategories
        case .beer:
            categories = beerAromaCategories
        }

        let customAromas = TastingCustomizationManager.shared.customAromas
        if !customAromas.isEmpty {
            categories = categories.map { cat in
                let matchingCustoms = customAromas.filter { $0.categoryTitle == cat.title }
                guard !matchingCustoms.isEmpty else { return cat }
                let mergedTags = cat.tags + matchingCustoms.map { AromaTag($0.name, isPro: true) }
                return AromaCategory(title: cat.title, tags: mergedTags)
            }
        }

        return categories
    }

    // MARK: - カラー仕様定義

    private static func wineColorSpecs(for wineType: String) -> [RGBAColorSpec] {
        if wineType == "白" || wineType == "スパークリング" {
            return [
                .init(name: "プラチナ", r: 0.95, g: 0.95, b: 0.90, hex: "#F2F2E6", isPro: true),
                .init(name: "ペール・イエロー", r: 0.98, g: 0.96, b: 0.75, hex: "#FAF5BF", isPro: false),
                .init(name: "シャンパン", r: 0.96, g: 0.92, b: 0.78, hex: "#F4EBC7", isPro: false),
                .init(name: "レモン・イエロー", r: 0.95, g: 0.93, b: 0.60, hex: "#F3ED99", isPro: false),
                .init(name: "ストロー・イエロー", r: 0.95, g: 0.90, b: 0.50, hex: "#F3E680", isPro: false),
                .init(name: "カナリー", r: 0.98, g: 0.92, b: 0.40, hex: "#FAEB66", isPro: true),
                .init(name: "グリーン・イエロー", r: 0.85, g: 0.92, b: 0.60, hex: "#D9EB99", isPro: true),
                .init(name: "ライム", r: 0.90, g: 0.95, b: 0.70, hex: "#E6F2B3", isPro: true),
                .init(name: "ペール・ゴールド", r: 0.92, g: 0.88, b: 0.60, hex: "#EBE099", isPro: true),
                .init(name: "ストロー", r: 0.90, g: 0.85, b: 0.55, hex: "#E6D98C", isPro: false),
                .init(name: "麦わら金色", r: 0.86, g: 0.78, b: 0.45, hex: "#DBC773", isPro: false),
                .init(name: "ゴールデン・イエロー", r: 0.92, g: 0.82, b: 0.30, hex: "#EBD14D", isPro: true),
                .init(name: "マドラス", r: 0.88, g: 0.72, b: 0.35, hex: "#E0B859", isPro: true),
                .init(name: "ゴールド", r: 0.88, g: 0.75, b: 0.20, hex: "#E0BF33", isPro: false),
                .init(name: "トパーズ", r: 0.82, g: 0.65, b: 0.25, hex: "#D1A640", isPro: true),
                .init(name: "ハニー", r: 0.85, g: 0.70, b: 0.30, hex: "#D9B34D", isPro: true),
                .init(name: "オールド・ゴールド", r: 0.75, g: 0.60, b: 0.20, hex: "#BF9933", isPro: true),
                .init(name: "ブロンズ・ホワイト", r: 0.70, g: 0.55, b: 0.25, hex: "#B38C40", isPro: true),
                .init(name: "アンバー", r: 0.80, g: 0.62, b: 0.20, hex: "#CC9E33", isPro: false),
                .init(name: "ダーク・ゴールド", r: 0.65, g: 0.48, b: 0.15, hex: "#A67A26", isPro: true)
            ]
        } else if wineType == "ロゼ" {
            return [
                .init(name: "チェリー・ブロッサム", r: 0.98, g: 0.80, b: 0.82, hex: "#FACDD1", isPro: false),
                .init(name: "ピーチ・スキン", r: 0.96, g: 0.80, b: 0.70, hex: "#F5CCB3", isPro: true),
                .init(name: "サーモン・ピンク", r: 0.96, g: 0.72, b: 0.65, hex: "#F5B8A6", isPro: false),
                .init(name: "ラズベリー・ピンク", r: 0.95, g: 0.70, b: 0.75, hex: "#F2B3BF", isPro: true),
                .init(name: "コーラル・ピンク", r: 0.95, g: 0.65, b: 0.60, hex: "#F3A699", isPro: false),
                .init(name: "ストロベリー・ピンク", r: 0.92, g: 0.58, b: 0.62, hex: "#EB949E", isPro: true),
                .init(name: "オニオン・スキン", r: 0.88, g: 0.68, b: 0.55, hex: "#E0AD8C", isPro: true),
                .init(name: "ラベンダー・ローズ", r: 0.85, g: 0.60, b: 0.65, hex: "#D999A6", isPro: true),
                .init(name: "アザミ色", r: 0.80, g: 0.50, b: 0.55, hex: "#CC808C", isPro: false),
                .init(name: "チェリー・ピンク", r: 0.85, g: 0.45, b: 0.50, hex: "#D97380", isPro: true)
            ]
        } else if wineType == "オレンジ" {
            return [
                .init(name: "アプリコット", r: 0.95, g: 0.65, b: 0.35, hex: "#F3A659", isPro: false),
                .init(name: "タンジェリン", r: 0.96, g: 0.60, b: 0.25, hex: "#F59940", isPro: false),
                .init(name: "ピーチ・アンバー", r: 0.88, g: 0.60, b: 0.35, hex: "#E09959", isPro: true),
                .init(name: "アンバー・オレンジ", r: 0.92, g: 0.55, b: 0.20, hex: "#EB8C33", isPro: false),
                .init(name: "サフラン", r: 0.90, g: 0.68, b: 0.20, hex: "#E6AD33", isPro: true),
                .init(name: "コッパー", r: 0.85, g: 0.48, b: 0.25, hex: "#D97A40", isPro: true),
                .init(name: "オーカー（黄土）", r: 0.82, g: 0.52, b: 0.25, hex: "#D18540", isPro: true),
                .init(name: "ブロンズ", r: 0.80, g: 0.50, b: 0.30, hex: "#CC804D", isPro: true),
                .init(name: "テラコッタ", r: 0.78, g: 0.42, b: 0.22, hex: "#C76B38", isPro: false),
                .init(name: "マホガニー・オレンジ", r: 0.70, g: 0.35, b: 0.18, hex: "#B3592E", isPro: true)
            ]
        } else {
            return [
                .init(name: "ストロベリー・レッド", r: 0.85, g: 0.25, b: 0.35, hex: "#D94059", isPro: true),
                .init(name: "スカーレット", r: 0.88, g: 0.15, b: 0.20, hex: "#E02633", isPro: true),
                .init(name: "ラズベリーレッド", r: 0.80, g: 0.20, b: 0.30, hex: "#CC334D", isPro: false),
                .init(name: "チェリーレッド", r: 0.70, g: 0.15, b: 0.25, hex: "#B32640", isPro: false),
                .init(name: "クリムゾン", r: 0.65, g: 0.08, b: 0.20, hex: "#A61433", isPro: true),
                .init(name: "ルビーレッド", r: 0.60, g: 0.10, b: 0.20, hex: "#991A33", isPro: false),
                .init(name: "レンガ/ブリック", r: 0.60, g: 0.25, b: 0.20, hex: "#994033", isPro: true),
                .init(name: "オールド・ルビー", r: 0.55, g: 0.22, b: 0.25, hex: "#8C3840", isPro: true),
                .init(name: "赤褐色", r: 0.52, g: 0.20, b: 0.15, hex: "#853326", isPro: false),
                .init(name: "ガーネット", r: 0.50, g: 0.15, b: 0.20, hex: "#802633", isPro: false),
                .init(name: "ボルドー", r: 0.50, g: 0.08, b: 0.18, hex: "#80142E", isPro: false),
                .init(name: "プラム", r: 0.48, g: 0.12, b: 0.28, hex: "#7A1F47", isPro: true),
                .init(name: "パープル", r: 0.45, g: 0.10, b: 0.30, hex: "#731A4D", isPro: true),
                .init(name: "ダーク・ルビー", r: 0.45, g: 0.05, b: 0.15, hex: "#730D26", isPro: true),
                .init(name: "ダーク・ガーネット", r: 0.45, g: 0.20, b: 0.20, hex: "#733333", isPro: true),
                .init(name: "バーガンディ", r: 0.42, g: 0.06, b: 0.15, hex: "#6B0F26", isPro: true),
                .init(name: "マホガニー", r: 0.40, g: 0.15, b: 0.10, hex: "#66261A", isPro: true),
                .init(name: "マルーン", r: 0.40, g: 0.10, b: 0.18, hex: "#661A2E", isPro: true),
                .init(name: "ダーク・チェリー", r: 0.38, g: 0.08, b: 0.15, hex: "#611426", isPro: true),
                .init(name: "黒赤色（ノワール）", r: 0.25, g: 0.05, b: 0.08, hex: "#400D14", isPro: true)
            ]
        }
    }

    private static let sakeColorSpecs: [RGBAColorSpec] = [
        .init(name: "無色透明", r: 0.95, g: 0.95, b: 0.97, hex: "#F2F2F7", isPro: false),
        .init(name: "クリスタル・クリア", r: 0.97, g: 0.98, b: 0.98, hex: "#F7FAFA", isPro: false),
        .init(name: "にごり（濃い乳白色）", r: 1.00, g: 1.00, b: 1.00, hex: "#FFFFFF", isPro: false),
        .init(name: "パール・ホワイト", r: 0.98, g: 0.98, b: 0.96, hex: "#FAFAF5", isPro: true),
        .init(name: "にごり（白濁・薄い）", r: 0.95, g: 0.95, b: 0.95, hex: "#F2F2F2", isPro: true),
        .init(name: "白銀（プラチナ）", r: 0.94, g: 0.95, b: 0.94, hex: "#F0F2F0", isPro: true),
        .init(name: "うすにごり（ささにごり）", r: 0.92, g: 0.93, b: 0.90, hex: "#EBEBE6", isPro: false),
        .init(name: "水明（青みクリア）", r: 0.90, g: 0.96, b: 0.96, hex: "#E6F5F5", isPro: true),
        .init(name: "若草・微緑", r: 0.90, g: 0.95, b: 0.85, hex: "#E6F2D9", isPro: true),
        .init(name: "微黄色", r: 0.98, g: 0.96, b: 0.85, hex: "#FAF5D9", isPro: false),
        .init(name: "シャンパン・ゴールド", r: 0.96, g: 0.92, b: 0.75, hex: "#F4EBBF", isPro: true),
        .init(name: "淡金色", r: 0.95, g: 0.90, b: 0.70, hex: "#F3E6B3", isPro: false),
        .init(name: "麦わら色", r: 0.92, g: 0.86, b: 0.60, hex: "#EBDC99", isPro: true),
        .init(name: "黄金色", r: 0.90, g: 0.78, b: 0.40, hex: "#E6C766", isPro: true),
        .init(name: "赤金色（オレンジゴールド）", r: 0.85, g: 0.62, b: 0.25, hex: "#D99E40", isPro: true),
        .init(name: "真鍮色（ブラス）", r: 0.82, g: 0.70, b: 0.35, hex: "#D1B359", isPro: true),
        .init(name: "琥珀色（古酒）", r: 0.78, g: 0.55, b: 0.20, hex: "#C78C33", isPro: false),
        .init(name: "ダーク・アンバー", r: 0.60, g: 0.38, b: 0.10, hex: "#99611A", isPro: true),
        .init(name: "熟成ブラウン", r: 0.50, g: 0.30, b: 0.12, hex: "#804D1F", isPro: true),
        .init(name: "マホガニー古酒", r: 0.38, g: 0.20, b: 0.08, hex: "#613314", isPro: true)
    ]

    private static let beerColorSpecs: [RGBAColorSpec] = [
        .init(name: "プラチナ・ブロンド", r: 0.98, g: 0.96, b: 0.70, hex: "#FAF5B3", isPro: true),
        .init(name: "ペール・ストロー", r: 0.98, g: 0.94, b: 0.50, hex: "#FAF080", isPro: false),
        .init(name: "レモン・ピール", r: 0.96, g: 0.92, b: 0.30, hex: "#F4EB4D", isPro: true),
        .init(name: "ストロー/麦わら色", r: 0.96, g: 0.90, b: 0.35, hex: "#F5E659", isPro: false),
        .init(name: "ウィート（小麦色）", r: 0.95, g: 0.85, b: 0.40, hex: "#F2D966", isPro: false),
        .init(name: "ゴールデン", r: 0.92, g: 0.78, b: 0.20, hex: "#EBC733", isPro: false),
        .init(name: "ハニー・ゴールド", r: 0.90, g: 0.72, b: 0.22, hex: "#E6B838", isPro: true),
        .init(name: "ディープ・ゴールデン", r: 0.88, g: 0.68, b: 0.15, hex: "#E0AD26", isPro: true),
        .init(name: "ペール・アンバー", r: 0.80, g: 0.52, b: 0.18, hex: "#CC852E", isPro: true),
        .init(name: "ライト・チェスナット", r: 0.75, g: 0.45, b: 0.20, hex: "#BF7333", isPro: true),
        .init(name: "アンバー", r: 0.70, g: 0.38, b: 0.12, hex: "#B3611F", isPro: false),
        .init(name: "コッパー", r: 0.60, g: 0.30, b: 0.10, hex: "#994D1A", isPro: true),
        .init(name: "ルビー・エール", r: 0.55, g: 0.18, b: 0.12, hex: "#8C2E1F", isPro: true),
        .init(name: "チェスナット（栗色）", r: 0.50, g: 0.25, b: 0.10, hex: "#80401A", isPro: true),
        .init(name: "ブラウン", r: 0.42, g: 0.20, b: 0.08, hex: "#6B3314", isPro: false),
        .init(name: "ダーク・チェスナット", r: 0.35, g: 0.16, b: 0.06, hex: "#59290F", isPro: true),
        .init(name: "ダーク・ブラウン", r: 0.25, g: 0.12, b: 0.05, hex: "#401F0D", isPro: true),
        .init(name: "スタウト・ブラック", r: 0.18, g: 0.10, b: 0.07, hex: "#2E1A12", isPro: true),
        .init(name: "ブラック", r: 0.12, g: 0.08, b: 0.06, hex: "#1F140F", isPro: false),
        .init(name: "漆黒（オックスフォード）", r: 0.08, g: 0.06, b: 0.05, hex: "#140F0D", isPro: true)
    ]

    // MARK: - 香りカテゴリ定義

    private static func makeCategory(_ titleKey: String, _ items: [(String, Bool)]) -> AromaCategory {
        AromaCategory(
            title: String(localized: String.LocalizationValue(titleKey)),
            tags: items.map { name, isPro in
                AromaTag(String(localized: String.LocalizationValue(name)), isPro: isPro)
            }
        )
    }

    private static func wineAromaCategories(for wineType: String) -> [AromaCategory] {
        if wineType == "白" || wineType == "スパークリング" {
            return [
                makeCategory("果実", [
                    ("柑橘類", false), ("青リンゴ", false), ("リンゴ", false), ("洋梨", false),
                    ("マスカット", true), ("花梨", true), ("パッションフルーツ", false), ("白桃", false),
                    ("アプリコット", true), ("パイナップル", true), ("ライチ", false), ("バナナ", true),
                    ("マンゴー", true)
                ]),
                makeCategory("花・植物", [
                    ("スイカズラ", false), ("アカシア", false), ("白バラ", true), ("キンモクセイ", true),
                    ("菩提樹", true), ("ミント", false), ("アニス", true), ("ヴェルヴェーヌ", false),
                    ("草", false), ("タイム", true), ("フレッシュアーモンド", true), ("ヘーゼルナッツ", true)
                ]),
                makeCategory("その他", [
                    ("石灰", false), ("火打石", true), ("貝殻", true), ("鉱物", true),
                    ("海の香り", true), ("トースト", false), ("ヴァニラ", false), ("煙・薫製", true),
                    ("シナモン", true), ("白胡椒", false), ("コリアンダー", true), ("丁字", false),
                    ("香木", true), ("ジンジャーブレッド", true), ("ペトロール", true), ("パン・ド・ミ", true),
                    ("乳製品", true), ("フェノール", true), ("麝香", true), ("花の蜜", true),
                    ("硫黄", true), ("ワックス", true), ("蜜蝋", true), ("蜂蜜", false)
                ])
            ]
        } else if wineType == "ロゼ" {
            return [
                makeCategory("果実", [
                    ("ストロベリー", false), ("ラズベリー", false), ("チェリー", false),
                    ("赤スグリ", true), ("桃", false), ("柑橘類", false)
                ]),
                makeCategory("花・植物", [
                    ("ローズ", false), ("ゼラニウム", true), ("グリーンリーフ", true), ("アカシア", true)
                ]),
                makeCategory("その他", [
                    ("キャンディ", false), ("白コショウ", true), ("ミネラル", true), ("ハチミツ", false)
                ])
            ]
        } else if wineType == "オレンジ" {
            return [
                makeCategory("果実", [
                    ("オレンジピール", false), ("アプリコット", false), ("ドライフルーツ", true),
                    ("マーマレード", true), ("洋梨", false)
                ]),
                makeCategory("花・植物", [
                    ("カモミール", false), ("ドライフラワー", true), ("紅茶の葉", false), ("ハーブ", false)
                ]),
                makeCategory("その他", [
                    ("ナッツ", false), ("スパイス", false), ("ハチミツ", false), ("酵母", true),
                    ("鉱物", true), ("トースト", false)
                ])
            ]
        } else {
            return [
                makeCategory("果実", [
                    ("イチゴ", false), ("ラズベリー", false), ("ブルーベリー", false), ("カシス", false),
                    ("ブラックベリー", false), ("ブラックチェリー", true), ("干しプラム", true), ("乾燥イチジク", true)
                ]),
                makeCategory("花・植物", [
                    ("バラ", false), ("スミレ", false), ("牡丹", true), ("ゼラニウム", true),
                    ("ピーマン", true), ("トマト", true), ("黒オリーブ", true), ("メントール", true),
                    ("シダ", true), ("ローリエ", true), ("杉", true), ("針葉樹", true),
                    ("ユーカリ", true), ("ドライハーブ", false)
                ]),
                makeCategory("その他", [
                    ("タバコ", true), ("紅茶", false), ("スーボア", true), ("キノコ", false),
                    ("トリュフ", true), ("黒胡椒", false), ("丁子", true), ("シナモン", false),
                    ("ナツメグ", true), ("甘草", true), ("ヴァニラ", false), ("ロースト", false),
                    ("コーヒー", false), ("チョコレート", false), ("煙・薫製", true), ("動物的なニュアンス", true),
                    ("鉄分", true), ("生肉", true), ("グリエ", true), ("乾いた肉", true),
                    ("なめし皮", true), ("樹脂", true), ("ヨード", true), ("ランシオ", true)
                ])
            ]
        }
    }

    private static let sakeAromaCategories: [AromaCategory] = [
        makeCategory("果実", [
            ("グレープフルーツ", true), ("黄色いリンゴ", false), ("洋ナシ", false), ("白桃", false),
            ("バナナ", false), ("メロン", false), ("マスカット", true), ("ライチ", true),
            ("パイナップル", true)
        ]),
        makeCategory("花・植物", [
            ("スイカズラ", true), ("スミレ", true), ("アカシア", true), ("菩提樹", true),
            ("セルフィーユ", true), ("青竹", false), ("新緑", false), ("紅茶", true),
            ("月桂樹の葉", true), ("ヒノキ", true), ("香木", true)
        ]),
        makeCategory("その他", [
            ("ゴボウ", false), ("朝鮮人参", true), ("マッシュルーム", false), ("椎茸", true),
            ("丁字", true), ("シナモン", true), ("ビターチョコレート", true), ("栗", true),
            ("クルミ", true), ("アーモンド", false), ("炊いた米", false), ("つきたての餅", true),
            ("上新粉", false), ("白玉団子", false), ("杏仁豆腐", true), ("生クリーム", false),
            ("サワークリーム", false), ("ヨーグルト", false), ("発酵バター", true), ("クリームチーズ", true),
            ("粘土", true), ("腐葉土", true), ("石灰", true), ("カラメル", false),
            ("コーヒー", false), ("醤油", false), ("ヨード香", true), ("蜂蜜", false),
            ("スモーク香", true), ("カビ", true), ("タマネギ", true), ("熟成チーズ", true)
        ])
    ]

    private static let beerAromaCategories: [AromaCategory] = [
        makeCategory("果実", [
            ("シトラス", false), ("グレープフルーツ", false), ("トロピカルフルーツ", false),
            ("青りんご", false), ("オレンジピール", true)
        ]),
        makeCategory("花・植物", [
            ("ホップ", false), ("ハーバル", false), ("松やに", true), ("フローラル", false),
            ("スパイス", false)
        ]),
        makeCategory("その他", [
            ("麦芽", false), ("ロースト香", false), ("キャラメル", false), ("チョコレート", false),
            ("ビスケット", true), ("スモーキー", true), ("酵母", false)
        ])
    ]
}
