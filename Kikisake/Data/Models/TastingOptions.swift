//  TastingOptions.swift
//  Kikisake

import SwiftUI

/// 外観カラーオプションの構造体
public struct ColorOption: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let color: Color
    public let hex: String
    
    public init(name: String, color: Color, hex: String) {
        self.name = name
        self.color = color
        self.hex = hex
    }
}

/// 香りの分類データ構造
public struct AromaCategory: Identifiable {
    public let id = UUID()
    public let title: String
    public let tags: [String]
    
    public init(title: String, tags: [String]) {
        self.title = title
        self.tags = tags
    }
}

/// 共通のテイスティング選択肢プロバイダ
public enum TastingOptions {
    
    // MARK: - Pro限定アイテムの個別指定セット（ここを自由に編集可能）
    
    /// Pro版限定とする「香りのタグ名」一覧
    /// ※ ここに含まれるタグは自動的にPro限定（鍵付き）になり、含まれないタグは無料版で選択可能になります。
    public static let proAromaTags: Set<String> = [
        // --- ワイン（赤・白・ロゼ・オレンジ） ---
        "スーボア", "ペトロール", "トリュフ", "ランシオ", "ヨード", "なめし皮", "動物的なニュアンス",
        "フェノール", "麝香", "硫黄", "ワックス", "蜜蝋", "ジンジャーブレッド", "パン・ド・ミ", "グリエ", "乾いた肉",
        
        // --- 日本酒 ---
        "つきたての餅", "サワークリーム", "発酵バター", "クリームチーズ", "ヨード香", "腐葉土",
        "朝鮮人参", "粘土", "熟成チーズ", "スモーク香", "杏仁豆腐",
        
        // --- ビール ---
        "松やに", "スモーキー", "ビスケット"
    ]
    
    /// Pro版限定とする「外観カラー名」一覧
    /// ※ ここに含まれる色名は自動的にPro限定（鍵付き）になります。
    public static let proColorNames: Set<String> = [
        // ワイン
        "アンバー", "マホガニー", "ダーク・ガーネット", "ダーク・ルビー", "ブロンズ", "コッパー",
        // 日本酒
        "琥珀色（古酒）", "ダーク・アンバー", "淡金色", "黄金色",
        // ビール
        "ブラウン", "ダーク・ブラウン", "ブラック", "ペール・アンバー"
    ]

    // MARK: - 判定ヘルパーメソッド
    
    /// 指定された香りタグが無料版で利用可能か判定（proAromaTags に含まれていなければ無料）
    public static func isFreeAromaTag(_ tag: String, in category: AromaCategory) -> Bool {
        return !proAromaTags.contains(tag)
    }
    
    /// 指定されたカラーオプションが無料版で利用可能か判定（proColorNames に含まれていなければ無料）
    public static func isFreeColorOption(_ option: ColorOption, in options: [ColorOption]) -> Bool {
        return !proColorNames.contains(option.name)
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
                    ColorOption(name: "ペール・イエロー", color: Color(red: 0.98, green: 0.96, blue: 0.75), hex: "#FAF5BF"),
                    ColorOption(name: "レモン・イエロー", color: Color(red: 0.95, green: 0.93, blue: 0.6), hex: "#F3ED99"),
                    ColorOption(name: "グリーン・イエロー", color: Color(red: 0.85, green: 0.92, blue: 0.6), hex: "#D9EB99"),
                    ColorOption(name: "ストロー・イエロー", color: Color(red: 0.95, green: 0.90, blue: 0.5), hex: "#F3E680"),
                    ColorOption(name: "ペール・ゴールド", color: Color(red: 0.92, green: 0.88, blue: 0.6), hex: "#EBE099"),
                    ColorOption(name: "ストロー", color: Color(red: 0.90, green: 0.85, blue: 0.55), hex: "#E6D98C"),
                    ColorOption(name: "ゴールデン・イエロー", color: Color(red: 0.92, green: 0.82, blue: 0.3), hex: "#EBD14D"),
                    ColorOption(name: "ゴールド", color: Color(red: 0.88, green: 0.75, blue: 0.2), hex: "#E0BF33"),
                    ColorOption(name: "ハニー", color: Color(red: 0.85, green: 0.70, blue: 0.3), hex: "#D9B34D"),
                    ColorOption(name: "アンバー", color: Color(red: 0.80, green: 0.62, blue: 0.2), hex: "#CC9E33")
                ]
            } else if wineType == "ロゼ" {
                return [
                    ColorOption(name: "チェリー・ブロッサム", color: Color(red: 0.98, green: 0.80, blue: 0.82), hex: "#FACDD1"),
                    ColorOption(name: "ピーチ・スキン", color: Color(red: 0.96, green: 0.80, blue: 0.70), hex: "#F5CCB3"),
                    ColorOption(name: "サーモン・ピンク", color: Color(red: 0.96, green: 0.72, blue: 0.65), hex: "#F5B8A6"),
                    ColorOption(name: "ラズベリー・ピンク", color: Color(red: 0.95, green: 0.70, blue: 0.75), hex: "#F2B3BF")
                ]
            } else if wineType == "オレンジ" {
                return [
                    ColorOption(name: "アプリコット", color: Color(red: 0.95, green: 0.65, blue: 0.35), hex: "#F3A659"),
                    ColorOption(name: "アンバー・オレンジ", color: Color(red: 0.92, green: 0.55, blue: 0.2), hex: "#EB8C33"),
                    ColorOption(name: "コッパー", color: Color(red: 0.85, green: 0.48, blue: 0.25), hex: "#D97A40"),
                    ColorOption(name: "ブロンズ", color: Color(red: 0.80, green: 0.50, blue: 0.3), hex: "#CC804D")
                ]
            } else {
                return [
                    ColorOption(name: "ラズベリーレッド", color: Color(red: 0.8, green: 0.2, blue: 0.3), hex: "#CC334D"),
                    ColorOption(name: "チェリーレッド", color: Color(red: 0.7, green: 0.15, blue: 0.25), hex: "#B32640"),
                    ColorOption(name: "クリムゾン", color: Color(red: 0.65, green: 0.08, blue: 0.2), hex: "#A61433"),
                    ColorOption(name: "ルビーレッド", color: Color(red: 0.6, green: 0.1, blue: 0.2), hex: "#991A33"),
                    ColorOption(name: "レンガ/ブリック", color: Color(red: 0.6, green: 0.25, blue: 0.2), hex: "#994033"),
                    ColorOption(name: "ガーネット", color: Color(red: 0.5, green: 0.15, blue: 0.2), hex: "#802633"),
                    ColorOption(name: "パープル", color: Color(red: 0.45, green: 0.1, blue: 0.3), hex: "#731A4D"),
                    ColorOption(name: "ダーク・ルビー", color: Color(red: 0.45, green: 0.05, blue: 0.15), hex: "#730D26"),
                    ColorOption(name: "ダーク・ガーネット", color: Color(red: 0.45, green: 0.2, blue: 0.2), hex: "#733333"),
                    ColorOption(name: "マホガニー", color: Color(red: 0.4, green: 0.15, blue: 0.1), hex: "#66261A")
                ]
            }

        case .sake:
            return [
                ColorOption(name: "無色透明", color: Color(.systemGray6), hex: "#F2F2F7"),
                ColorOption(name: "クリスタル・クリア", color: Color(red: 0.97, green: 0.98, blue: 0.98), hex: "#F7FAFA"),
                ColorOption(name: "にごり（濃い乳白色）", color: Color.white, hex: "#FFFFFF"),
                ColorOption(name: "にごり（白濁・薄い）", color: Color(red: 0.95, green: 0.95, blue: 0.95), hex: "#F2F2F2"),
                ColorOption(name: "うすにごり（ささにごり）", color: Color(red: 0.92, green: 0.93, blue: 0.90), hex: "#EBEBE6"),
                ColorOption(name: "微黄色", color: Color(red: 0.98, green: 0.96, blue: 0.85), hex: "#FAF5D9"),
                ColorOption(name: "淡金色", color: Color(red: 0.95, green: 0.90, blue: 0.7), hex: "#F3E6B3"),
                ColorOption(name: "黄金色", color: Color(red: 0.90, green: 0.78, blue: 0.4), hex: "#E6C766"),
                ColorOption(name: "琥珀色（古酒）", color: Color(red: 0.78, green: 0.55, blue: 0.2), hex: "#C78C33"),
                ColorOption(name: "ダーク・アンバー", color: Color(red: 0.6, green: 0.38, blue: 0.1), hex: "#99611A")
            ]

        case .beer:
            return [
                ColorOption(name: "ペール・ストロー", color: Color(red: 0.98, green: 0.94, blue: 0.5), hex: "#FAF080"),
                ColorOption(name: "ストロー/麦わら色", color: Color(red: 0.96, green: 0.90, blue: 0.35), hex: "#F5E659"),
                ColorOption(name: "ゴールデン", color: Color(red: 0.92, green: 0.78, blue: 0.2), hex: "#EBC733"),
                ColorOption(name: "ディープ・ゴールデン", color: Color(red: 0.88, green: 0.68, blue: 0.15), hex: "#E0AD26"),
                ColorOption(name: "ペール・アンバー", color: Color(red: 0.80, green: 0.52, blue: 0.18), hex: "#CC852E"),
                ColorOption(name: "アンバー", color: Color(red: 0.70, green: 0.38, blue: 0.12), hex: "#B3611F"),
                ColorOption(name: "コッパー", color: Color(red: 0.60, green: 0.30, blue: 0.1), hex: "#994D1A"),
                ColorOption(name: "ブラウン", color: Color(red: 0.42, green: 0.20, blue: 0.08), hex: "#6B3314"),
                ColorOption(name: "ダーク・ブラウン", color: Color(red: 0.25, green: 0.12, blue: 0.05), hex: "#401F0D"),
                ColorOption(name: "ブラック", color: Color(red: 0.12, green: 0.08, blue: 0.06), hex: "#1F140F")
            ]
        }
    }

    /// 香りカテゴリ一覧を取得
    public static func aromaCategories(for category: BeverageCategory?, wineType: String = "赤") -> [AromaCategory] {
        guard let category = category else {
            var tagSet = Set<String>()
            var combinedTags: [String] = []
            
            let cats: [BeverageCategory] = [.wine, .sake, .beer]
            for cat in cats {
                let catsList = aromaCategories(for: cat, wineType: wineType)
                for c in catsList {
                    for t in c.tags {
                        if !tagSet.contains(t) {
                            tagSet.insert(t)
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
                    AromaCategory(title: "果実", tags: [
                        "柑橘類", "青リンゴ", "リンゴ", "洋梨", "マスカット", "花梨",
                        "パッションフルーツ", "白桃", "アプリコット", "パイナップル", "ライチ", "バナナ", "マンゴー"
                    ]),
                    AromaCategory(title: "花・植物", tags: [
                        "スイカズラ", "アカシア", "白バラ", "キンモクセイ", "菩提樹",
                        "ミント", "アニス", "ヴェルヴェーヌ", "草", "タイム", "フレッシュアーモンド", "ヘーゼルナッツ"
                    ]),
                    AromaCategory(title: "その他", tags: [
                        "石灰", "火打石", "貝殻", "鉱物", "海の香り", "トースト", "ヴァニラ",
                        "煙・薫製", "シナモン", "白胡椒", "コリアンダー", "丁字", "香木",
                        "ジンジャーブレッド", "ペトロール", "パン・ド・ミ", "乳製品",
                        "フェノール", "麝香", "花の蜜", "硫黄", "ワックス", "蜜蝋", "蜂蜜"
                    ])
                ]
            } else if wineType == "ロゼ" {
                return [
                    AromaCategory(title: "果実", tags: ["ストロベリー", "ラズベリー", "チェリー", "赤スグリ", "桃", "柑橘類"]),
                    AromaCategory(title: "花・植物", tags: ["ローズ", "ゼラニウム", "グリーンリーフ", "アカシア"]),
                    AromaCategory(title: "その他", tags: ["キャンディ", "白コショウ", "ミネラル", "ハチミツ"])
                ]
            } else if wineType == "オレンジ" {
                return [
                    AromaCategory(title: "果実", tags: ["オレンジピール", "アプリコット", "ドライフルーツ", "マーマレード", "洋梨"]),
                    AromaCategory(title: "花・植物", tags: ["カモミール", "ドライフラワー", "紅茶の葉", "ハーブ"]),
                    AromaCategory(title: "その他", tags: ["ナッツ", "スパイス", "ハチミツ", "酵母", "鉱物", "トースト"])
                ]
            } else {
                return [
                    AromaCategory(title: "果実", tags: [
                        "イチゴ", "ラズベリー", "ブルーベリー", "カシス", "ブラックベリー",
                        "ブラックチェリー", "干しプラム", "乾燥イチジク"
                    ]),
                    AromaCategory(title: "花・植物", tags: [
                        "バラ", "スミレ", "牡丹", "ゼラニウム", "ピーマン", "トマト",
                        "黒オリーブ", "メントール", "シダ", "ローリエ", "杉", "針葉樹", "ユーカリ", "ドライハーブ"
                    ]),
                    AromaCategory(title: "その他", tags: [
                        "タバコ", "紅茶", "スーボア", "キノコ", "トリュフ", "黒胡椒", "丁子",
                        "シナモン", "ナツメグ", "甘草", "ヴァニラ", "ロースト", "コーヒー",
                        "チョコレート", "煙・薫製", "動物的なニュアンス", "鉄分", "生肉",
                        "グリエ", "乾いた肉", "なめし皮", "樹脂", "ヨード", "ランシオ"
                    ])
                ]
            }

        case .sake:
            return [
                AromaCategory(title: "果実", tags: [
                    "グレープフルーツ", "黄色いリンゴ", "洋ナシ", "白桃", "バナナ",
                    "メロン", "マスカット", "ライチ", "パイナップル"
                ]),
                AromaCategory(title: "花・植物", tags: [
                    "スイカズラ", "スミレ", "アカシア", "菩提樹",
                    "セルフィーユ", "青竹", "新緑", "紅茶", "月桂樹の葉", "ヒノキ", "香木"
                ]),
                AromaCategory(title: "その他", tags: [
                    "ゴボウ", "朝鮮人参", "マッシュルーム", "椎茸", "丁字", "シナモン",
                    "ビターチョコレート", "栗", "クルミ", "アーモンド", "炊いた米",
                    "つきたての餅", "上新粉", "白玉団子", "杏仁豆腐", "生クリーム",
                    "サワークリーム", "ヨーグルト", "発酵バター", "クリームチーズ",
                    "粘土", "腐葉土", "石灰", "カラメル", "コーヒー", "醤油",
                    "ヨード香", "蜂蜜", "スモーク香", "カビ", "タマネギ", "熟成チーズ"
                ])
            ]

        case .beer:
            return [
                AromaCategory(title: "果実", tags: ["シトラス", "グレープフルーツ", "トロピカルフルーツ", "青りんご", "オレンジピール"]),
                AromaCategory(title: "花・植物", tags: ["ホップ", "ハーバル", "松やに", "フローラル", "スパイス"]),
                AromaCategory(title: "その他", tags: ["麦芽", "ロースト香", "キャラメル", "チョコレート", "ビスケット", "スモーキー", "酵母"])
            ]
        }
    }
}
