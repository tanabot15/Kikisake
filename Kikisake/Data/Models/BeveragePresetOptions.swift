//  BeveragePresetOptions.swift
//  Kikisake

import Foundation

/// ワイン品種・日本酒使用米・ビアスタイルの選択肢マスター
public enum BeveragePresetOptions {
    
    /// 主要およびマイナーブドウ品種（ワイン）
    public static let grapeVarieties: [String] = [
        // --- メジャー黒ブドウ ---
        String(localized: "カベルネ・ソーヴィニヨン"),
        String(localized: "メルロ"),
        String(localized: "ピノ・ノワール"),
        String(localized: "シラー / シラーズ"),
        String(localized: "カベルネ・フラン"),
        String(localized: "プティ・ヴェルド"),
        String(localized: "マルベック"),
        String(localized: "テンプラニーリョ"),
        String(localized: "ガルナッチャ / グレナッシュ"),
        String(localized: "サンジョヴェーゼ"),
        String(localized: "ネッビオーロ"),
        String(localized: "バルベラ"),
        String(localized: "ドルチェット"),
        String(localized: "アリアニコ"),
        String(localized: "ネグロアマーロ"),
        String(localized: "プリミティーヴォ / ジンファンデル"),
        String(localized: "コルヴィーナ"),
        String(localized: "ムールヴェードル"),
        String(localized: "カリニャン"),
        String(localized: "ガメイ"),
        String(localized: "カルメネール"),
        // --- マイナー・ローカル黒ブドウ ---
        String(localized: "タナ"),
        String(localized: "サグランド"),
        String(localized: "ネレッロ・マスカレーゼ"),
        String(localized: "フラッパート"),
        String(localized: "メンシア"),
        String(localized: "トゥーリガ・ナショナル"),
        String(localized: "ピノ・タナージュ"),
        String(localized: "ブラウフランキッシュ"),
        String(localized: "ツヴァイゲルトレーベ"),
        String(localized: "サンローラン"),
        
        // --- メジャー白ブドウ ---
        String(localized: "シャルドネ"),
        String(localized: "ソーヴィニヨン・ブラン"),
        String(localized: "リースリング"),
        String(localized: "シュナン・ブラン"),
        String(localized: "セミヨン"),
        String(localized: "ヴィオニエ"),
        String(localized: "ピノ・グリ / ピノ-グリージョ"),
        String(localized: "ゲヴュルツトラミネール"),
        String(localized: "アルバリーニョ"),
        String(localized: "ミュスカデ"),
        String(localized: "ヴェルメンティーノ"),
        String(localized: "ガヴィ / コルテーゼ"),
        String(localized: "ピノ・ブラン"),
        String(localized: "シルヴァーナー"),
        // --- マイナー・ローカル白ブドウ ---
        String(localized: "シャスラ"),
        String(localized: "マルサンヌ"),
        String(localized: "ルーサンヌ"),
        String(localized: "グルナッシュ・ブラン"),
        String(localized: "ヴェルデホ"),
        String(localized: "ゴデーリョ"),
        String(localized: "トッビーア / フルラノ"),
        String(localized: "グレーラ"),
        String(localized: "ガルガネガ"),
        String(localized: "レッチーナ"),
        String(localized: "ペコリーノ"),
        String(localized: "パッセリーナ"),
        
        // --- 日本の固有品種 ---
        String(localized: "甲州"),
        String(localized: "マスカット・ベーリーA"),
        String(localized: "山葡萄"),
        String(localized: "ナイアガラ"),
        String(localized: "デラウェア"),
        String(localized: "コンコード"),
        String(localized: "清見"),
        
        String(localized: "その他")
    ]
    
    /// 酒造好適米・希少使用米（日本酒）
    public static let riceVarieties: [String] = [
        // --- 三大酒造好適米・主要米 ---
        String(localized: "山田錦"),
        String(localized: "五百万石"),
        String(localized: "美山錦"),
        String(localized: "雄町"),
        String(localized: "愛山"),
        String(localized: "出羽燦々"),
        String(localized: "八反錦"),
        String(localized: "越淡麗"),
        String(localized: "秋田酒こまち"),
        String(localized: "吟の夢"),
        String(localized: "亀の尾"),
        String(localized: "渡船"),
        // --- マイナー・復活米・ローカル酒米 ---
        String(localized: "神力"),
        String(localized: "強力"),
        String(localized: "赤磐雄町"),
        String(localized: "羽州誉"),
        String(localized: "吟のいろは"),
        String(localized: "雪女神"),
        String(localized: "たかね錦"),
        String(localized: "ひとごこち"),
        String(localized: "金紋錦"),
        String(localized: "惣無面"),
        String(localized: "旭の夢"),
        String(localized: "夢の香"),
        String(localized: "千本錦"),
        String(localized: "吟吹雪"),
        String(localized: "玉栄"),
        String(localized: "ひだほまれ"),
        String(localized: "九頭竜"),
        String(localized: "きたしずく"),
        String(localized: "彗星"),
        String(localized: "和飲"),
        String(localized: "華吹雪"),
        String(localized: "華厳"),
        String(localized: "コウノトリ育むお米"),
        // --- 食用米（飯米由来の銘酒） ---
        String(localized: "コシヒカリ"),
        String(localized: "ササニシキ"),
        String(localized: "ひとめぼれ"),
        String(localized: "あきたこまち"),
        String(localized: "まっしぐら"),
        String(localized: "ヒノヒカリ"),
        
        String(localized: "その他")
    ]
    
    /// 主要およびディープなビアスタイル（ビール）
    public static let beerStyles: [String] = [
        // --- ラガー系 ---
        String(localized: "ピルスナー"),
        String(localized: "ボヘミアン・ピルスナー"),
        String(localized: "アメリカン・ラガー"),
        String(localized: "デュンケル"),
        String(localized: "シュバルツ"),
        String(localized: "ボック"),
        String(localized: "ドッペルボック"),
        String(localized: "アイスボック"),
        String(localized: "ウィーン・ラガー"),
        String(localized: "メルツェン / オクトーバーフェスト"),
        String(localized: "ラオハス（燻製ビール）"),
        String(localized: "ケルシュ"),
        String(localized: "アルトビール"),
        // --- エール系：ペール / IPA ---
        String(localized: "イングリッシュ・ペールエール"),
        String(localized: "アメリカン・ペールエール"),
        String(localized: "ビター / ESB"),
        String(localized: "IPA"),
        String(localized: "イングリッシュ・IPA"),
        String(localized: "ダブルIPA（インペリアルIPA）"),
        String(localized: "トリプルIPA"),
        String(localized: "ヘイジーIPA"),
        String(localized: "セッションIPA"),
        String(localized: "ブラックIPA"),
        String(localized: "レッドIPA / ブラウンIPA"),
        String(localized: "ライIPA"),
        // --- エール系：ダーク / ストロング ---
        String(localized: "ポーター"),
        String(localized: "スタウト"),
        String(localized: "アイリッシュ・スタウト"),
        String(localized: "ミルクスタウト"),
        String(localized: "インペリアルスタウト"),
        String(localized: "パスク / ブラウンエール"),
        String(localized: "スコッチエール"),
        String(localized: "バーレイワイン"),
        String(localized: "オールドエール"),
        // --- ベルジャン / トラピスト系 ---
        String(localized: "ベルジャン・ブロンド"),
        String(localized: "ベルジャン・デュペル"),
        String(localized: "ベルジャン・トリプル"),
        String(localized: "ベルジャン・クアドルペル"),
        String(localized: "セゾン"),
        String(localized: "ビア・ド・ガルド"),
        String(localized: "ランビック"),
        String(localized: "グース / フルーツ・ランビック（グーズ）"),
        String(localized: "ベルジャンホワイト（ヴィットビール）"),
        // --- サワー / ワイルドエール系 ---
        String(localized: "サワーエール"),
        String(localized: "ゴーゼ"),
        String(localized: "ベルリーナー・ヴァイセ"),
        String(localized: "アメリカン・ワイルドエール"),
        String(localized: "フラダース・レッドエール"),
        // --- 小麦系その他 ---
        String(localized: "ヴァイツェン（ヘーフェヴァイツェン）"),
        String(localized: "デュンケルヴァイツェン"),
        String(localized: "ヴァイツェンボック"),
        String(localized: "アメリカン・ウィート"),
        // --- その他・モダン ---
        String(localized: "フルーツビール"),
        String(localized: "ハーブ・スパイスビール"),
        String(localized: "エンバーエール"),
        String(localized: "セッションエール"),
        
        String(localized: "その他")
    ]
}
