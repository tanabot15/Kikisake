//  TastingOptions.swift
//  Kikisake

import SwiftUI

/// 外観カラーオプションの構造体（Pro限定フラグを内包）
public struct ColorOption: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let color: Color
    public let hex: String
    public let isPro: Bool
    
    public init(name: String, color: Color, hex: String, isPro: Bool) {
        self.name = name
        self.color = color
        self.hex = hex
        self.isPro = isPro
    }
}

/// 香りタグの構造体（Pro限定フラグを内包）
public struct AromaTag: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let isPro: Bool
    
    public init(_ name: String, isPro: Bool) {
        self.name = name
        self.isPro = isPro
    }
}

/// 香りの分類データ構造
public struct AromaCategory: Identifiable {
    public let id = UUID()
    public let title: String
    public let tags: [AromaTag]
    
    public init(title: String, tags: [AromaTag]) {
        self.title = title
        self.tags = tags
    }
}

/// 共通のテイスティング選択肢プロバイダ
public enum TastingOptions {
    
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
    
    /// 味わいのバランス表現のマスター選択肢一覧
    public static let balanceOptions: [String] = [
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
    
    /// 酒種・タイプに応じた外観カラーオプションを取得
    public static func colorOptions(for category: BeverageCategory?, wineType: String = "赤") -> [ColorOption] {
        guard let category = category else {
            var allOptions: [ColorOption] = []
            var seenNames = Set<String>()
            
            let categoriesToProcess: [(BeverageCategory, String)] = [
                (.wine, "赤"), (.wine, "白"), (.wine, "ロゼ"), (.wine, "オレンジ"),
                (.sake, "赤"), (.beer, "赤")
            ]
            
            for (cat, wType) in categoriesToProcess {
                let options = colorOptions(for: cat, wineType: wType)
                for opt in options {
                    if !seenNames.contains(opt.name) {
                        seenNames.insert(opt.name)
                        allOptions.append(opt)
                    }
                }
            }
            return allOptions
        }

        switch category {
        case .wine:
            if wineType == "白" || wineType == "スパークリング" {
                return [
                    ColorOption(name: String(localized: "ペール・イエロー"), color: Color(red: 0.98, green: 0.96, blue: 0.75), hex: "#FAF5BF", isPro: false),
                    ColorOption(name: String(localized: "レモン・イエロー"), color: Color(red: 0.95, green: 0.93, blue: 0.6), hex: "#F3ED99", isPro: true),
                    ColorOption(name: String(localized: "グリーン・イエロー"), color: Color(red: 0.85, green: 0.92, blue: 0.6), hex: "#D9EB99", isPro: true),
                    ColorOption(name: String(localized: "ストロー・イエロー"), color: Color(red: 0.95, green: 0.90, blue: 0.5), hex: "#F3E680", isPro: false),
                    ColorOption(name: String(localized: "ペール・ゴールド"), color: Color(red: 0.92, green: 0.88, blue: 0.6), hex: "#EBE099", isPro: true),
                    ColorOption(name: String(localized: "ストロー"), color: Color(red: 0.90, green: 0.85, blue: 0.55), hex: "#E6D98C", isPro: true),
                    ColorOption(name: String(localized: "ゴールデン・イエロー"), color: Color(red: 0.92, green: 0.82, blue: 0.3), hex: "#EBD14D", isPro: true),
                    ColorOption(name: String(localized: "ゴールド"), color: Color(red: 0.88, green: 0.75, blue: 0.2), hex: "#E0BF33", isPro: false),
                    ColorOption(name: String(localized: "ハニー"), color: Color(red: 0.85, green: 0.70, blue: 0.3), hex: "#D9B34D", isPro: true),
                    ColorOption(name: String(localized: "アンバー"), color: Color(red: 0.80, green: 0.62, blue: 0.2), hex: "#CC9E33", isPro: true)
                ]
            } else if wineType == "ロゼ" {
                return [
                    ColorOption(name: String(localized: "チェリー・ブロッサム"), color: Color(red: 0.98, green: 0.80, blue: 0.82), hex: "#FACDD1", isPro: false),
                    ColorOption(name: String(localized: "ピーチ・スキン"), color: Color(red: 0.96, green: 0.80, blue: 0.70), hex: "#F5CCB3", isPro: true),
                    ColorOption(name: String(localized: "サーモン・ピンク"), color: Color(red: 0.96, green: 0.72, blue: 0.65), hex: "#F5B8A6", isPro: false),
                    ColorOption(name: String(localized: "ラズベリー・ピンク"), color: Color(red: 0.95, green: 0.70, blue: 0.75), hex: "#F2B3BF", isPro: true)
                ]
            } else if wineType == "オレンジ" {
                return [
                    ColorOption(name: String(localized: "アプリコット"), color: Color(red: 0.95, green: 0.65, blue: 0.35), hex: "#F3A659", isPro: true),
                    ColorOption(name: String(localized: "アンバー・オレンジ"), color: Color(red: 0.92, green: 0.55, blue: 0.2), hex: "#EB8C33", isPro: false),
                    ColorOption(name: String(localized: "コッパー"), color: Color(red: 0.85, green: 0.48, blue: 0.25), hex: "#D97A40", isPro: true),
                    ColorOption(name: String(localized: "ブロンズ"), color: Color(red: 0.80, green: 0.50, blue: 0.3), hex: "#CC804D", isPro: true)
                ]
            } else {
                return [
                    ColorOption(name: String(localized: "ラズベリーレッド"), color: Color(red: 0.8, green: 0.2, blue: 0.3), hex: "#CC334D", isPro: false),
                    ColorOption(name: String(localized: "チェリーレッド"), color: Color(red: 0.7, green: 0.15, blue: 0.25), hex: "#B32640", isPro: true),
                    ColorOption(name: String(localized: "クリムゾン"), color: Color(red: 0.65, green: 0.08, blue: 0.2), hex: "#A61433", isPro: true),
                    ColorOption(name: String(localized: "ルビーレッド"), color: Color(red: 0.6, green: 0.1, blue: 0.2), hex: "#991A33", isPro: false),
                    ColorOption(name: String(localized: "レンガ/ブリック"), color: Color(red: 0.6, green: 0.25, blue: 0.2), hex: "#994033", isPro: true),
                    ColorOption(name: String(localized: "ガーネット"), color: Color(red: 0.5, green: 0.15, blue: 0.2), hex: "#802633", isPro: false),
                    ColorOption(name: String(localized: "パープル"), color: Color(red: 0.45, green: 0.1, blue: 0.3), hex: "#731A4D", isPro: true),
                    ColorOption(name: String(localized: "ダーク・ルビー"), color: Color(red: 0.45, green: 0.05, blue: 0.15), hex: "#730D26", isPro: true),
                    ColorOption(name: String(localized: "ダーク・ガーネット"), color: Color(red: 0.45, green: 0.2, blue: 0.2), hex: "#733333", isPro: true),
                    ColorOption(name: String(localized: "マホガニー"), color: Color(red: 0.4, green: 0.15, blue: 0.1), hex: "#66261A", isPro: true)
                ]
            }

        case .sake:
            return [
                ColorOption(name: String(localized: "無色透明"), color: Color(.systemGray6), hex: "#F2F2F7", isPro: false),
                ColorOption(name: String(localized: "クリスタル・クリア"), color: Color(red: 0.97, green: 0.98, blue: 0.98), hex: "#F7FAFA", isPro: true),
                ColorOption(name: String(localized: "にごり（濃い乳白色）"), color: Color.white, hex: "#FFFFFF", isPro: true),
                ColorOption(name: String(localized: "にごり（白濁・薄い）"), color: Color(red: 0.95, green: 0.95, blue: 0.95), hex: "#F2F2F2", isPro: true),
                ColorOption(name: String(localized: "うすにごり（ささにごり）"), color: Color(red: 0.92, green: 0.93, blue: 0.90), hex: "#EBEBE6", isPro: false),
                ColorOption(name: String(localized: "微黄色"), color: Color(red: 0.98, green: 0.96, blue: 0.85), hex: "#FAF5D9", isPro: false),
                ColorOption(name: String(localized: "淡金色"), color: Color(red: 0.95, green: 0.90, blue: 0.7), hex: "#F3E6B3", isPro: true),
                ColorOption(name: String(localized: "黄金色"), color: Color(red: 0.90, green: 0.78, blue: 0.4), hex: "#E6C766", isPro: true),
                ColorOption(name: String(localized: "琥珀色（古酒）"), color: Color(red: 0.78, green: 0.55, blue: 0.2), hex: "#C78C33", isPro: false),
                ColorOption(name: String(localized: "ダーク・アンバー"), color: Color(red: 0.6, green: 0.38, blue: 0.1), hex: "#99611A", isPro: true)
            ]

        case .beer:
            return [
                ColorOption(name: String(localized: "ペール・ストロー"), color: Color(red: 0.98, green: 0.94, blue: 0.5), hex: "#FAF080", isPro: false),
                ColorOption(name: String(localized: "ストロー/麦わら色"), color: Color(red: 0.96, green: 0.90, blue: 0.35), hex: "#F5E659", isPro: true),
                ColorOption(name: String(localized: "ゴールデン"), color: Color(red: 0.92, green: 0.78, blue: 0.2), hex: "#EBC733", isPro: false),
                ColorOption(name: String(localized: "ディープ・ゴールデン"), color: Color(red: 0.88, green: 0.68, blue: 0.15), hex: "#E0AD26", isPro: true),
                ColorOption(name: String(localized: "ペール・アンバー"), color: Color(red: 0.80, green: 0.52, blue: 0.18), hex: "#CC852E", isPro: true),
                ColorOption(name: String(localized: "アンバー"), color: Color(red: 0.70, green: 0.38, blue: 0.12), hex: "#B3611F", isPro: false),
                ColorOption(name: String(localized: "コッパー"), color: Color(red: 0.60, green: 0.30, blue: 0.1), hex: "#994D1A", isPro: true),
                ColorOption(name: String(localized: "ブラウン"), color: Color(red: 0.42, green: 0.20, blue: 0.08), hex: "#6B3314", isPro: false),
                ColorOption(name: String(localized: "ダーク・ブラウン"), color: Color(red: 0.25, green: 0.12, blue: 0.05), hex: "#401F0D", isPro: true),
                ColorOption(name: String(localized: "ブラック"), color: Color(red: 0.12, green: 0.08, blue: 0.06), hex: "#1F140F", isPro: false)
            ]
        }
    }

    /// 香りカテゴリ一覧を取得
    public static func aromaCategories(for category: BeverageCategory?, wineType: String = "赤") -> [AromaCategory] {
        guard let category = category else {
            var tagSet = Set<String>()
            var combinedTags: [AromaTag] = []
            
            let cats: [BeverageCategory] = [.wine, .sake, .beer]
            for cat in cats {
                let catsList = aromaCategories(for: cat, wineType: wineType)
                for c in catsList {
                    for t in c.tags {
                        if !tagSet.contains(t.name) {
                            tagSet.insert(t.name)
                            combinedTags.append(t)
                        }
                    }
                }
            }
            return [AromaCategory(title: String(localized: "すべての香り要素"), tags: combinedTags)]
        }

        switch category {
        case .wine:
            if wineType == "白" || wineType == "スパークリング" {
                return [
                    AromaCategory(
                        title: String(localized: "果実"),
                        tags: [
                            AromaTag(String(localized: "柑橘類"), isPro: false),
                            AromaTag(String(localized: "青リンゴ"), isPro: false),
                            AromaTag(String(localized: "リンゴ"), isPro: false),
                            AromaTag(String(localized: "洋梨"), isPro: false),
                            AromaTag(String(localized: "マスカット"), isPro: true),
                            AromaTag(String(localized: "花梨"), isPro: true),
                            AromaTag(String(localized: "パッションフルーツ"), isPro: true),
                            AromaTag(String(localized: "白桃"), isPro: false),
                            AromaTag(String(localized: "アプリコット"), isPro: true),
                            AromaTag(String(localized: "パイナップル"), isPro: true),
                            AromaTag(String(localized: "ライチ"), isPro: false),
                            AromaTag(String(localized: "バナナ"), isPro: true),
                            AromaTag(String(localized: "マンゴー"), isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "花・植物"),
                        tags: [
                            AromaTag(String(localized: "スイカズラ"), isPro: true),
                            AromaTag(String(localized: "アカシア"), isPro: false),
                            AromaTag(String(localized: "白バラ"), isPro: true),
                            AromaTag(String(localized: "キンモクセイ"), isPro: true),
                            AromaTag(String(localized: "菩提樹"), isPro: true),
                            AromaTag(String(localized: "ミント"), isPro: false),
                            AromaTag(String(localized: "アニス"), isPro: true),
                            AromaTag(String(localized: "ヴェルヴェーヌ"), isPro: true),
                            AromaTag(String(localized: "草"), isPro: false),
                            AromaTag(String(localized: "タイム"), isPro: true),
                            AromaTag(String(localized: "フレッシュアーモンド"), isPro: true),
                            AromaTag(String(localized: "ヘーゼルナッツ"), isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "その他"),
                        tags: [
                            AromaTag(String(localized: "石灰"), isPro: true),
                            AromaTag(String(localized: "火打石"), isPro: true),
                            AromaTag(String(localized: "貝殻"), isPro: true),
                            AromaTag(String(localized: "鉱物"), isPro: true),
                            AromaTag(String(localized: "海の香り"), isPro: true),
                            AromaTag(String(localized: "トースト"), isPro: false),
                            AromaTag(String(localized: "ヴァニラ"), isPro: false),
                            AromaTag(String(localized: "煙・薫製"), isPro: true),
                            AromaTag(String(localized: "シナモン"), isPro: true),
                            AromaTag(String(localized: "白胡椒"), isPro: false),
                            AromaTag(String(localized: "コリアンダー"), isPro: true),
                            AromaTag(String(localized: "丁字"), isPro: true),
                            AromaTag(String(localized: "香木"), isPro: true),
                            AromaTag(String(localized: "ジンジャーブレッド"), isPro: true),
                            AromaTag(String(localized: "ペトロール"), isPro: true),
                            AromaTag(String(localized: "パン・ド・ミ"), isPro: true),
                            AromaTag(String(localized: "乳製品"), isPro: true),
                            AromaTag(String(localized: "フェノール"), isPro: true),
                            AromaTag(String(localized: "麝香"), isPro: true),
                            AromaTag(String(localized: "花の蜜"), isPro: true),
                            AromaTag(String(localized: "硫黄"), isPro: true),
                            AromaTag(String(localized: "ワックス"), isPro: true),
                            AromaTag(String(localized: "蜜蝋"), isPro: true),
                            AromaTag(String(localized: "蜂蜜"), isPro: false)
                        ]
                    )
                ]
            } else if wineType == "ロゼ" {
                return [
                    AromaCategory(
                        title: String(localized: "果実"),
                        tags: [
                            AromaTag(String(localized: "ストロベリー"), isPro: false),
                            AromaTag(String(localized: "ラズベリー"), isPro: false),
                            AromaTag(String(localized: "チェリー"), isPro: false),
                            AromaTag(String(localized: "赤スグリ"), isPro: true),
                            AromaTag(String(localized: "桃"), isPro: false),
                            AromaTag(String(localized: "柑橘類"), isPro: false)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "花・植物"),
                        tags: [
                            AromaTag(String(localized: "ローズ"), isPro: false),
                            AromaTag(String(localized: "ゼラニウム"), isPro: true),
                            AromaTag(String(localized: "グリーンリーフ"), isPro: true),
                            AromaTag(String(localized: "アカシア"), isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "その他"),
                        tags: [
                            AromaTag(String(localized: "キャンディ"), isPro: false),
                            AromaTag(String(localized: "白コショウ"), isPro: true),
                            AromaTag(String(localized: "ミネラル"), isPro: true),
                            AromaTag(String(localized: "ハチミツ"), isPro: false)
                        ]
                    )
                ]
            } else if wineType == "オレンジ" {
                return [
                    AromaCategory(
                        title: String(localized: "果実"),
                        tags: [
                            AromaTag(String(localized: "オレンジピール"), isPro: false),
                            AromaTag(String(localized: "アプリコット"), isPro: false),
                            AromaTag(String(localized: "ドライフルーツ"), isPro: true),
                            AromaTag(String(localized: "マーマレード"), isPro: true),
                            AromaTag(String(localized: "洋梨"), isPro: false)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "花・植物"),
                        tags: [
                            AromaTag(String(localized: "カモミール"), isPro: false),
                            AromaTag(String(localized: "ドライフラワー"), isPro: true),
                            AromaTag(String(localized: "紅茶の葉"), isPro: false),
                            AromaTag(String(localized: "ハーブ"), isPro: false)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "その他"),
                        tags: [
                            AromaTag(String(localized: "ナッツ"), isPro: false),
                            AromaTag(String(localized: "スパイス"), isPro: false),
                            AromaTag(String(localized: "ハチミツ"), isPro: false),
                            AromaTag(String(localized: "酵母"), isPro: true),
                            AromaTag(String(localized: "鉱物"), isPro: true),
                            AromaTag(String(localized: "トースト"), isPro: false)
                        ]
                    )
                ]
            } else {
                return [
                    AromaCategory(
                        title: String(localized: "果実"),
                        tags: [
                            AromaTag(String(localized: "イチゴ"), isPro: false),
                            AromaTag(String(localized: "ラズベリー"), isPro: false),
                            AromaTag(String(localized: "ブルーベリー"), isPro: false),
                            AromaTag(String(localized: "カシス"), isPro: false),
                            AromaTag(String(localized: "ブラックベリー"), isPro: false),
                            AromaTag(String(localized: "ブラックチェリー"), isPro: true),
                            AromaTag(String(localized: "干しプラム"), isPro: true),
                            AromaTag(String(localized: "乾燥イチジク"), isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "花・植物"),
                        tags: [
                            AromaTag(String(localized: "バラ"), isPro: false),
                            AromaTag(String(localized: "スミレ"), isPro: false),
                            AromaTag(String(localized: "牡丹"), isPro: true),
                            AromaTag(String(localized: "ゼラニウム"), isPro: true),
                            AromaTag(String(localized: "ピーマン"), isPro: true),
                            AromaTag(String(localized: "トマト"), isPro: true),
                            AromaTag(String(localized: "黒オリーブ"), isPro: true),
                            AromaTag(String(localized: "メントール"), isPro: true),
                            AromaTag(String(localized: "シダ"), isPro: true),
                            AromaTag(String(localized: "ローリエ"), isPro: true),
                            AromaTag(String(localized: "杉"), isPro: true),
                            AromaTag(String(localized: "針葉樹"), isPro: true),
                            AromaTag(String(localized: "ユーカリ"), isPro: true),
                            AromaTag(String(localized: "ドライハーブ"), isPro: false)
                        ]
                    ),
                    AromaCategory(
                        title: String(localized: "その他"),
                        tags: [
                            AromaTag(String(localized: "タバコ"), isPro: true),
                            AromaTag(String(localized: "紅茶"), isPro: false),
                            AromaTag(String(localized: "スーボア"), isPro: true),
                            AromaTag(String(localized: "キノコ"), isPro: false),
                            AromaTag(String(localized: "トリュフ"), isPro: true),
                            AromaTag(String(localized: "黒胡椒"), isPro: false),
                            AromaTag(String(localized: "丁子"), isPro: true),
                            AromaTag(String(localized: "シナモン"), isPro: false),
                            AromaTag(String(localized: "ナツメグ"), isPro: true),
                            AromaTag(String(localized: "甘草"), isPro: true),
                            AromaTag(String(localized: "ヴァニラ"), isPro: false),
                            AromaTag(String(localized: "ロースト"), isPro: false),
                            AromaTag(String(localized: "コーヒー"), isPro: false),
                            AromaTag(String(localized: "チョコレート"), isPro: false),
                            AromaTag(String(localized: "煙・薫製"), isPro: true),
                            AromaTag(String(localized: "動物的なニュアンス"), isPro: true),
                            AromaTag(String(localized: "鉄分"), isPro: true),
                            AromaTag(String(localized: "生肉"), isPro: true),
                            AromaTag(String(localized: "グリエ"), isPro: true),
                            AromaTag(String(localized: "乾いた肉"), isPro: true),
                            AromaTag(String(localized: "なめし皮"), isPro: true),
                            AromaTag(String(localized: "樹脂"), isPro: true),
                            AromaTag(String(localized: "ヨード"), isPro: true),
                            AromaTag(String(localized: "ランシオ"), isPro: true)
                        ]
                    )
                ]
            }

        case .sake:
            return [
                AromaCategory(
                    title: String(localized: "果実"),
                    tags: [
                        AromaTag(String(localized: "グレープフルーツ"), isPro: true),
                        AromaTag(String(localized: "黄色いリンゴ"), isPro: false),
                        AromaTag(String(localized: "洋ナシ"), isPro: false),
                        AromaTag(String(localized: "白桃"), isPro: false),
                        AromaTag(String(localized: "バナナ"), isPro: false),
                        AromaTag(String(localized: "メロン"), isPro: false),
                        AromaTag(String(localized: "マスカット"), isPro: true),
                        AromaTag(String(localized: "ライチ"), isPro: true),
                        AromaTag(String(localized: "パイナップル"), isPro: true)
                    ]
                ),
                AromaCategory(
                    title: String(localized: "花・植物"),
                    tags: [
                        AromaTag(String(localized: "スイカズラ"), isPro: true),
                        AromaTag(String(localized: "スミレ"), isPro: true),
                        AromaTag(String(localized: "アカシア"), isPro: true),
                        AromaTag(String(localized: "菩提樹"), isPro: true),
                        AromaTag(String(localized: "セルフィーユ"), isPro: true),
                        AromaTag(String(localized: "青竹"), isPro: false),
                        AromaTag(String(localized: "新緑"), isPro: false),
                        AromaTag(String(localized: "紅茶"), isPro: true),
                        AromaTag(String(localized: "月桂樹の葉"), isPro: true),
                        AromaTag(String(localized: "ヒノキ"), isPro: true),
                        AromaTag(String(localized: "香木"), isPro: true)
                    ]
                ),
                AromaCategory(
                    title: String(localized: "その他"),
                    tags: [
                        AromaTag(String(localized: "ゴボウ"), isPro: false),
                        AromaTag(String(localized: "朝鮮人参"), isPro: true),
                        AromaTag(String(localized: "マッシュルーム"), isPro: false),
                        AromaTag(String(localized: "椎茸"), isPro: true),
                        AromaTag(String(localized: "丁字"), isPro: true),
                        AromaTag(String(localized: "シナモン"), isPro: true),
                        AromaTag(String(localized: "ビターチョコレート"), isPro: true),
                        AromaTag(String(localized: "栗"), isPro: true),
                        AromaTag(String(localized: "クルミ"), isPro: true),
                        AromaTag(String(localized: "アーモンド"), isPro: false),
                        AromaTag(String(localized: "炊いた米"), isPro: false),
                        AromaTag(String(localized: "つきたての餅"), isPro: true),
                        AromaTag(String(localized: "上新粉"), isPro: false),
                        AromaTag(String(localized: "白玉団子"), isPro: false),
                        AromaTag(String(localized: "杏仁豆腐"), isPro: true),
                        AromaTag(String(localized: "生クリーム"), isPro: false),
                        AromaTag(String(localized: "サワークリーム"), isPro: false),
                        AromaTag(String(localized: "ヨーグルト"), isPro: false),
                        AromaTag(String(localized: "発酵バター"), isPro: true),
                        AromaTag(String(localized: "クリームチーズ"), isPro: true),
                        AromaTag(String(localized: "粘土"), isPro: true),
                        AromaTag(String(localized: "腐葉土"), isPro: true),
                        AromaTag(String(localized: "石灰"), isPro: true),
                        AromaTag(String(localized: "カラメル"), isPro: false),
                        AromaTag(String(localized: "コーヒー"), isPro: false),
                        AromaTag(String(localized: "醤油"), isPro: false),
                        AromaTag(String(localized: "ヨード香"), isPro: true),
                        AromaTag(String(localized: "蜂蜜"), isPro: false),
                        AromaTag(String(localized: "スモーク香"), isPro: true),
                        AromaTag(String(localized: "カビ"), isPro: true),
                        AromaTag(String(localized: "タマネギ"), isPro: true),
                        AromaTag(String(localized: "熟成チーズ"), isPro: true)
                    ]
                )
            ]

        case .beer:
            return [
                AromaCategory(
                    title: String(localized: "果実"),
                    tags: [
                        AromaTag(String(localized: "シトラス"), isPro: false),
                        AromaTag(String(localized: "グレープフルーツ"), isPro: false),
                        AromaTag(String(localized: "トロピカルフルーツ"), isPro: false),
                        AromaTag(String(localized: "青りんご"), isPro: false),
                        AromaTag(String(localized: "オレンジピール"), isPro: true)
                    ]
                ),
                AromaCategory(
                    title: String(localized: "花・植物"),
                    tags: [
                        AromaTag(String(localized: "ホップ"), isPro: false),
                        AromaTag(String(localized: "ハーバル"), isPro: false),
                        AromaTag(String(localized: "松やに"), isPro: true),
                        AromaTag(String(localized: "フローラル"), isPro: false),
                        AromaTag(String(localized: "スパイス"), isPro: false)
                    ]
                ),
                AromaCategory(
                    title: String(localized: "その他"),
                    tags: [
                        AromaTag(String(localized: "麦芽"), isPro: false),
                        AromaTag(String(localized: "ロースト香"), isPro: false),
                        AromaTag(String(localized: "キャラメル"), isPro: false),
                        AromaTag(String(localized: "チョコレート"), isPro: false),
                        AromaTag(String(localized: "ビスケット"), isPro: true),
                        AromaTag(String(localized: "スモーキー"), isPro: true),
                        AromaTag(String(localized: "酵母"), isPro: false)
                    ]
                )
            ]
        }
    }
}
