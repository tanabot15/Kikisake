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
        "スムーズな", "コンパクトな", "スリムな", "ドライな",
        "引き締まった", "ジューシーな", "豊潤な", "厚みのある",
        "まろやかな", "ふくよかな", "ねっとりした"
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
                    ColorOption(name: "ペール・イエロー", color: Color(red: 0.98, green: 0.96, blue: 0.75), hex: "#FAF5BF", isPro: false),
                    ColorOption(name: "レモン・イエロー", color: Color(red: 0.95, green: 0.93, blue: 0.6), hex: "#F3ED99", isPro: true),
                    ColorOption(name: "グリーン・イエロー", color: Color(red: 0.85, green: 0.92, blue: 0.6), hex: "#D9EB99", isPro: true),
                    ColorOption(name: "ストロー・イエロー", color: Color(red: 0.95, green: 0.90, blue: 0.5), hex: "#F3E680", isPro: false),
                    ColorOption(name: "ペール・ゴールド", color: Color(red: 0.92, green: 0.88, blue: 0.6), hex: "#EBE099", isPro: true),
                    ColorOption(name: "ストロー", color: Color(red: 0.90, green: 0.85, blue: 0.55), hex: "#E6D98C", isPro: true),
                    ColorOption(name: "ゴールデン・イエロー", color: Color(red: 0.92, green: 0.82, blue: 0.3), hex: "#EBD14D", isPro: true),
                    ColorOption(name: "ゴールド", color: Color(red: 0.88, green: 0.75, blue: 0.2), hex: "#E0BF33", isPro: false),
                    ColorOption(name: "ハニー", color: Color(red: 0.85, green: 0.70, blue: 0.3), hex: "#D9B34D", isPro: true),
                    ColorOption(name: "アンバー", color: Color(red: 0.80, green: 0.62, blue: 0.2), hex: "#CC9E33", isPro: false)
                ]
            } else if wineType == "ロゼ" {
                return [
                    ColorOption(name: "チェリー・ブロッサム", color: Color(red: 0.98, green: 0.80, blue: 0.82), hex: "#FACDD1", isPro: false),
                    ColorOption(name: "ピーチ・スキン", color: Color(red: 0.96, green: 0.80, blue: 0.70), hex: "#F5CCB3", isPro: true),
                    ColorOption(name: "サーモン・ピンク", color: Color(red: 0.96, green: 0.72, blue: 0.65), hex: "#F5B8A6", isPro: false),
                    ColorOption(name: "ラズベリー・ピンク", color: Color(red: 0.95, green: 0.70, blue: 0.75), hex: "#F2B3BF", isPro: true)
                ]
            } else if wineType == "オレンジ" {
                return [
                    ColorOption(name: "アプリコット", color: Color(red: 0.95, green: 0.65, blue: 0.35), hex: "#F3A659", isPro: true),
                    ColorOption(name: "アンバー・オレンジ", color: Color(red: 0.92, green: 0.55, blue: 0.2), hex: "#EB8C33", isPro: false),
                    ColorOption(name: "コッパー", color: Color(red: 0.85, green: 0.48, blue: 0.25), hex: "#D97A40", isPro: true),
                    ColorOption(name: "ブロンズ", color: Color(red: 0.80, green: 0.50, blue: 0.3), hex: "#CC804D", isPro: false)
                ]
            } else {
                return [
                    ColorOption(name: "ラズベリーレッド", color: Color(red: 0.8, green: 0.2, blue: 0.3), hex: "#CC334D", isPro: false),
                    ColorOption(name: "チェリーレッド", color: Color(red: 0.7, green: 0.15, blue: 0.25), hex: "#B32640", isPro: true),
                    ColorOption(name: "クリムゾン", color: Color(red: 0.65, green: 0.08, blue: 0.2), hex: "#A61433", isPro: true),
                    ColorOption(name: "ルビーレッド", color: Color(red: 0.6, green: 0.1, blue: 0.2), hex: "#991A33", isPro: false),
                    ColorOption(name: "レンガ/ブリック", color: Color(red: 0.6, green: 0.25, blue: 0.2), hex: "#994033", isPro: true),
                    ColorOption(name: "ガーネット", color: Color(red: 0.5, green: 0.15, blue: 0.2), hex: "#802633", isPro: false),
                    ColorOption(name: "パープル", color: Color(red: 0.45, green: 0.1, blue: 0.3), hex: "#731A4D", isPro: false),
                    ColorOption(name: "ダーク・ルビー", color: Color(red: 0.45, green: 0.05, blue: 0.15), hex: "#730D26", isPro: true),
                    ColorOption(name: "ダーク・ガーネット", color: Color(red: 0.45, green: 0.2, blue: 0.2), hex: "#733333", isPro: true),
                    ColorOption(name: "マホガニー", color: Color(red: 0.4, green: 0.15, blue: 0.1), hex: "#66261A", isPro: true)
                ]
            }

        case .sake:
            return [
                ColorOption(name: "無色透明", color: Color(.systemGray6), hex: "#F2F2F7", isPro: false),
                ColorOption(name: "クリスタル・クリア", color: Color(red: 0.97, green: 0.98, blue: 0.98), hex: "#F7FAFA", isPro: true),
                ColorOption(name: "にごり（濃い乳白色）", color: Color.white, hex: "#FFFFFF", isPro: true),
                ColorOption(name: "にごり（白濁・薄い）", color: Color(red: 0.95, green: 0.95, blue: 0.95), hex: "#F2F2F2", isPro: true),
                ColorOption(name: "うすにごり（ささにごり）", color: Color(red: 0.92, green: 0.93, blue: 0.90), hex: "#EBEBE6", isPro: false),
                ColorOption(name: "微黄色", color: Color(red: 0.98, green: 0.96, blue: 0.85), hex: "#FAF5D9", isPro: false),
                ColorOption(name: "淡金色", color: Color(red: 0.95, green: 0.90, blue: 0.7), hex: "#F3E6B3", isPro: true),
                ColorOption(name: "黄金色", color: Color(red: 0.90, green: 0.78, blue: 0.4), hex: "#E6C766", isPro: true),
                ColorOption(name: "琥珀色（古酒）", color: Color(red: 0.78, green: 0.55, blue: 0.2), hex: "#C78C33", isPro: false),
                ColorOption(name: "ダーク・アンバー", color: Color(red: 0.6, green: 0.38, blue: 0.1), hex: "#99611A", isPro: true)
            ]

        case .beer:
            return [
                ColorOption(name: "ペール・ストロー", color: Color(red: 0.98, green: 0.94, blue: 0.5), hex: "#FAF080", isPro: false),
                ColorOption(name: "ストロー/麦わら色", color: Color(red: 0.96, green: 0.90, blue: 0.35), hex: "#F5E659", isPro: true),
                ColorOption(name: "ゴールデン", color: Color(red: 0.92, green: 0.78, blue: 0.2), hex: "#EBC733", isPro: false),
                ColorOption(name: "ディープ・ゴールデン", color: Color(red: 0.88, green: 0.68, blue: 0.15), hex: "#E0AD26", isPro: true),
                ColorOption(name: "ペール・アンバー", color: Color(red: 0.80, green: 0.52, blue: 0.18), hex: "#CC852E", isPro: true),
                ColorOption(name: "アンバー", color: Color(red: 0.70, green: 0.38, blue: 0.12), hex: "#B3611F", isPro: false),
                ColorOption(name: "コッパー", color: Color(red: 0.60, green: 0.30, blue: 0.1), hex: "#994D1A", isPro: true),
                ColorOption(name: "ブラウン", color: Color(red: 0.42, green: 0.20, blue: 0.08), hex: "#6B3314", isPro: false),
                ColorOption(name: "ダーク・ブラウン", color: Color(red: 0.25, green: 0.12, blue: 0.05), hex: "#401F0D", isPro: true),
                ColorOption(name: "ブラック", color: Color(red: 0.12, green: 0.08, blue: 0.06), hex: "#1F140F", isPro: false)
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
            return [AromaCategory(title: "すべての香り要素", tags: combinedTags)]
        }

        switch category {
        case .wine:
            if wineType == "白" || wineType == "スパークリング" {
                return [
                    AromaCategory(
                        title: "果実",
                        tags: [
                            AromaTag("柑橘類", isPro: false),
                            AromaTag("青リンゴ", isPro: true),
                            AromaTag("リンゴ", isPro: false),
                            AromaTag("洋梨", isPro: false),
                            AromaTag("マスカット", isPro: true),
                            AromaTag("花梨", isPro: true),
                            AromaTag("パッションフルーツ", isPro: false),
                            AromaTag("白桃", isPro: true),
                            AromaTag("アプリコット", isPro: true),
                            AromaTag("パイナップル", isPro: true),
                            AromaTag("ライチ", isPro: false),
                            AromaTag("バナナ", isPro: true),
                            AromaTag("マンゴー", isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: "花・植物",
                        tags: [
                            AromaTag("スイカズラ", isPro: false),
                            AromaTag("アカシア", isPro: false),
                            AromaTag("白バラ", isPro: true),
                            AromaTag("キンモクセイ", isPro: true),
                            AromaTag("菩提樹", isPro: false),
                            AromaTag("ミント", isPro: true),
                            AromaTag("アニス", isPro: true),
                            AromaTag("ヴェルヴェーヌ", isPro: false),
                            AromaTag("草", isPro: true),
                            AromaTag("タイム", isPro: true),
                            AromaTag("フレッシュアーモンド", isPro: true),
                            AromaTag("ヘーゼルナッツ", isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: "その他",
                        tags: [
                            AromaTag("石灰", isPro: false),
                            AromaTag("火打石", isPro: false),
                            AromaTag("貝殻", isPro: true),
                            AromaTag("鉱物", isPro: true),
                            AromaTag("海の香り", isPro: true),
                            AromaTag("トースト", isPro: false),
                            AromaTag("ヴァニラ", isPro: false),
                            AromaTag("煙・薫製", isPro: true),
                            AromaTag("シナモン", isPro: true),
                            AromaTag("白胡椒", isPro: false),
                            AromaTag("コリアンダー", isPro: false),
                            AromaTag("丁字", isPro: true),
                            AromaTag("香木", isPro: true),
                            AromaTag("ジンジャーブレッド", isPro: true),
                            AromaTag("ペトロール", isPro: false),
                            AromaTag("パン・ド・ミ", isPro: false),
                            AromaTag("乳製品", isPro: true),
                            AromaTag("フェノール", isPro: true),
                            AromaTag("麝香", isPro: true),
                            AromaTag("花の蜜", isPro: true),
                            AromaTag("硫黄", isPro: true),
                            AromaTag("ワックス", isPro: true),
                            AromaTag("蜜蝋", isPro: true),
                            AromaTag("蜂蜜", isPro: true)
                        ]
                    )
                ]
            } else if wineType == "ロゼ" {
                return [
                    AromaCategory(
                        title: "果実",
                        tags: [
                            AromaTag("ストロベリー", isPro: false),
                            AromaTag("ラズベリー", isPro: false),
                            AromaTag("チェリー", isPro: true),
                            AromaTag("赤スグリ", isPro: true),
                            AromaTag("桃", isPro: true),
                            AromaTag("柑橘類", isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: "花・植物",
                        tags: [
                            AromaTag("ローズ", isPro: false),
                            AromaTag("ゼラニウム", isPro: true),
                            AromaTag("グリーンリーフ", isPro: true),
                            AromaTag("アカシア", isPro: false)
                        ]
                    ),
                    AromaCategory(
                        title: "その他",
                        tags: [
                            AromaTag("キャンディ", isPro: true),
                            AromaTag("白コショウ", isPro: true),
                            AromaTag("ミネラル", isPro: true),
                            AromaTag("ハチミツ", isPro: true)
                        ]
                    )
                ]
            } else if wineType == "オレンジ" {
                return [
                    AromaCategory(
                        title: "果実",
                        tags: [
                            AromaTag("オレンジピール", isPro: false),
                            AromaTag("アプリコット", isPro: false),
                            AromaTag("ドライフルーツ", isPro: true),
                            AromaTag("マーマレード", isPro: true),
                            AromaTag("洋梨", isPro: false)
                        ]
                    ),
                    AromaCategory(
                        title: "花・植物",
                        tags: [
                            AromaTag("カモミール", isPro: false),
                            AromaTag("ドライフラワー", isPro: true),
                            AromaTag("紅茶の葉", isPro: false),
                            AromaTag("ハーブ", isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: "その他",
                        tags: [
                            AromaTag("ナッツ", isPro: true),
                            AromaTag("スパイス", isPro: true),
                            AromaTag("ハチミツ", isPro: true),
                            AromaTag("酵母", isPro: true),
                            AromaTag("鉱物", isPro: true),
                            AromaTag("トースト", isPro: true)
                        ]
                    )
                ]
            } else {
                return [
                    AromaCategory(
                        title: "果実",
                        tags: [
                            AromaTag("イチゴ", isPro: false),
                            AromaTag("ラズベリー", isPro: false),
                            AromaTag("ブルーベリー", isPro: false),
                            AromaTag("カシス", isPro: false),
                            AromaTag("ブラックベリー", isPro: false),
                            AromaTag("ブラックチェリー", isPro: true),
                            AromaTag("干しプラム", isPro: true),
                            AromaTag("乾燥イチジク", isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: "花・植物",
                        tags: [
                            AromaTag("バラ", isPro: true),
                            AromaTag("スミレ", isPro: false),
                            AromaTag("牡丹", isPro: false),
                            AromaTag("ゼラニウム", isPro: true),
                            AromaTag("ピーマン", isPro: true),
                            AromaTag("トマト", isPro: true),
                            AromaTag("黒オリーブ", isPro: true),
                            AromaTag("メントール", isPro: true),
                            AromaTag("シダ", isPro: false),
                            AromaTag("ローリエ", isPro: true),
                            AromaTag("杉", isPro: false),
                            AromaTag("針葉樹", isPro: true),
                            AromaTag("ユーカリ", isPro: true),
                            AromaTag("ドライハーブ", isPro: true)
                        ]
                    ),
                    AromaCategory(
                        title: "その他",
                        tags: [
                            AromaTag("タバコ", isPro: true),
                            AromaTag("紅茶", isPro: false),
                            AromaTag("スーボア", isPro: true),
                            AromaTag("キノコ", isPro: true),
                            AromaTag("トリュフ", isPro: true),
                            AromaTag("黒胡椒", isPro: false),
                            AromaTag("丁子", isPro: false),
                            AromaTag("シナモン", isPro: true),
                            AromaTag("ナツメグ", isPro: true),
                            AromaTag("甘草", isPro: true),
                            AromaTag("ヴァニラ", isPro: false),
                            AromaTag("ロースト", isPro: false),
                            AromaTag("コーヒー", isPro: true),
                            AromaTag("チョコレート", isPro: true),
                            AromaTag("煙・薫製", isPro: true),
                            AromaTag("動物的なニュアンス", isPro: true),
                            AromaTag("鉄分", isPro: true),
                            AromaTag("生肉", isPro: true),
                            AromaTag("グリエ", isPro: true),
                            AromaTag("乾いた肉", isPro: true),
                            AromaTag("なめし皮", isPro: true),
                            AromaTag("樹脂", isPro: true),
                            AromaTag("ヨード", isPro: true),
                            AromaTag("ランシオ", isPro: true)
                        ]
                    )
                ]
            }

        case .sake:
            return [
                AromaCategory(
                    title: "果実",
                    tags: [
                        AromaTag("グレープフルーツ", isPro: true),
                        AromaTag("黄色いリンゴ", isPro: false),
                        AromaTag("洋ナシ", isPro: false),
                        AromaTag("白桃", isPro: false),
                        AromaTag("バナナ", isPro: false),
                        AromaTag("メロン", isPro: false),
                        AromaTag("マスカット", isPro: true),
                        AromaTag("ライチ", isPro: true),
                        AromaTag("パイナップル", isPro: true)
                    ]
                ),
                AromaCategory(
                    title: "花・植物",
                    tags: [
                        AromaTag("スイカズラ", isPro: false),
                        AromaTag("スミレ", isPro: true),
                        AromaTag("アカシア", isPro: true),
                        AromaTag("菩提樹", isPro: false),
                        AromaTag("セルフィーユ", isPro: true),
                        AromaTag("青竹", isPro: false),
                        AromaTag("新緑", isPro: false),
                        AromaTag("紅茶", isPro: true),
                        AromaTag("月桂樹の葉", isPro: true),
                        AromaTag("ヒノキ", isPro: true),
                        AromaTag("香木", isPro: true)
                    ]
                ),
                AromaCategory(
                    title: "その他",
                    tags: [
                        AromaTag("ゴボウ", isPro: false),
                        AromaTag("朝鮮人参", isPro: true),
                        AromaTag("マッシュルーム", isPro: false),
                        AromaTag("椎茸", isPro: true),
                        AromaTag("丁字", isPro: false),
                        AromaTag("シナモン", isPro: true),
                        AromaTag("ビターチョコレート", isPro: true),
                        AromaTag("栗", isPro: true),
                        AromaTag("クルミ", isPro: true),
                        AromaTag("アーモンド", isPro: false),
                        AromaTag("炊いた米", isPro: false),
                        AromaTag("つきたての餅", isPro: true),
                        AromaTag("上新粉", isPro: false),
                        AromaTag("白玉団子", isPro: false),
                        AromaTag("杏仁豆腐", isPro: true),
                        AromaTag("生クリーム", isPro: true),
                        AromaTag("サワークリーム", isPro: false),
                        AromaTag("ヨーグルト", isPro: false),
                        AromaTag("発酵バター", isPro: true),
                        AromaTag("クリームチーズ", isPro: true),
                        AromaTag("粘土", isPro: true),
                        AromaTag("腐葉土", isPro: true),
                        AromaTag("石灰", isPro: false),
                        AromaTag("カラメル", isPro: false),
                        AromaTag("コーヒー", isPro: false),
                        AromaTag("醤油", isPro: false),
                        AromaTag("ヨード香", isPro: true),
                        AromaTag("蜂蜜", isPro: false),
                        AromaTag("スモーク香", isPro: true),
                        AromaTag("カビ", isPro: false),
                        AromaTag("タマネギ", isPro: false),
                        AromaTag("熟成チーズ", isPro: true)
                    ]
                )
            ]

        case .beer:
            return [
                AromaCategory(
                    title: "果実",
                    tags: [
                        AromaTag("シトラス", isPro: false),
                        AromaTag("グレープフルーツ", isPro: false),
                        AromaTag("トロピカルフルーツ", isPro: false),
                        AromaTag("青りんご", isPro: false),
                        AromaTag("オレンジピール", isPro: true)
                    ]
                ),
                AromaCategory(
                    title: "花・植物",
                    tags: [
                        AromaTag("ホップ", isPro: false),
                        AromaTag("ハーバル", isPro: false),
                        AromaTag("松やに", isPro: true),
                        AromaTag("フローラル", isPro: false),
                        AromaTag("スパイス", isPro: false)
                    ]
                ),
                AromaCategory(
                    title: "その他",
                    tags: [
                        AromaTag("麦芽", isPro: false),
                        AromaTag("ロースト香", isPro: false),
                        AromaTag("キャラメル", isPro: false),
                        AromaTag("チョコレート", isPro: false),
                        AromaTag("ビスケット", isPro: true),
                        AromaTag("スモーキー", isPro: true),
                        AromaTag("酵母", isPro: false)
                    ]
                )
            ]
        }
    }
}
