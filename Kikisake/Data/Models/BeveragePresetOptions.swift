//  BeveragePresetOptions.swift
//  Kikisake

import Foundation

/// ワイン品種・日本酒使用米・ビアスタイルの選択肢マスター
public enum BeveragePresetOptions {
    
    /// 主要ブドウ品種（ワイン）
    public static let grapeVarieties: [String] = [
        String(localized: "カベルネ・ソーヴィニヨン"),
        String(localized: "メルロ"),
        String(localized: "ピノ・ノワール"),
        String(localized: "シラー / シラーズ"),
        String(localized: "シャルドネ"),
        String(localized: "ソーヴィニヨン・ブラン"),
        String(localized: "リースリング"),
        String(localized: "サンジョヴェーゼ"),
        String(localized: "ネッビオーロ"),
        String(localized: "テンプラニーリョ"),
        String(localized: "マルベック"),
        String(localized: "カベルネ・フラン"),
        String(localized: "プティ・ヴェルド"),
        String(localized: "カルメネール"),
        String(localized: "ガメイ"),
        String(localized: "グレナッシュ"),
        String(localized: "ムールヴェードル"),
        String(localized: "ネグロアマーロ"),
        String(localized: "アリアニコ"),
        String(localized: "バーベラ"),
        String(localized: "コルヴィーナ"),
        String(localized: "サンジョヴェーゼ・グロッソ"),
        String(localized: "ゼニト"),
        String(localized: "シュナン・ブラン"),
        String(localized: "セミヨン"),
        String(localized: "ヴィオニエ"),
        String(localized: "ピノ・グリ / ピノ-グリージョ"),
        String(localized: "ゲヴュルツトラミネール"),
        String(localized: "アルバリーニョ"),
        String(localized: "甲州"),
        String(localized: "マスカット・ベーリーA"),
        String(localized: "キャンベル・アーリー"),
        String(localized: "ナイアガラ"),
        String(localized: "デラウェア"),
        String(localized: "その他")
    ]
    
    /// 酒造好適米・使用米（日本酒）
    public static let riceVarieties: [String] = [
        String(localized: "山田錦"),
        String(localized: "五百万石"),
        String(localized: "雄町"),
        String(localized: "美山錦"),
        String(localized: "出羽燦々"),
        String(localized: "八反錦"),
        String(localized: "吟の夢"),
        String(localized: "愛山"),
        String(localized: "亀の尾"),
        String(localized: "越淡麗"),
        String(localized: "秋田酒コマチ"),
        String(localized: "吟吹雪"),
        String(localized: "千本錦"),
        String(localized: "玉栄"),
        String(localized: "ひだほまれ"),
        String(localized: "九頭竜"),
        String(localized: "神力"),
        String(localized: "強力"),
        String(localized: "きたしずく"),
        String(localized: "彗星"),
        String(localized: "吟のいろは"),
        String(localized: "夢の香"),
        String(localized: "華吹雪"),
        String(localized: "華厳"),
        String(localized: "まっしぐら"),
        String(localized: "ヒノヒカリ"),
        String(localized: "コシヒカリ"),
        String(localized: "その他")
    ]
    
    /// 主要ビアスタイル（ビール）
    public static let beerStyles: [String] = [
        String(localized: "Pilsner (ピルスナー)"),
        String(localized: "Pale Ale (ペールエール)"),
        String(localized: "IPA (インディア・ペールエール)"),
        String(localized: "Hazy IPA (ヘイジーIPA)"),
        String(localized: "Double IPA (ダブルIPA)"),
        String(localized: "Stout (スタウト)"),
        String(localized: "Imperial Stout (インペリアルスタウト)"),
        String(localized: "Porter (ポーター)"),
        String(localized: "Weizen (ヴァイツェン)"),
        String(localized: "Witbier (ベルジャンホワイト)"),
        String(localized: "Saison (セゾン)"),
        String(localized: "Sour Ale (サワーエール)"),
        String(localized: "Gose (ゴーゼ)"),
        String(localized: "Fruit Beer (フルーツビール)"),
        String(localized: "Barleywine (バーレイワイン)"),
        String(localized: "Amber Ale (アンバーエール)"),
        String(localized: "Brown Ale (ブラウンエール)"),
        String(localized: "Kölsch (ケルシュ)"),
        String(localized: "Bock (ボック)"),
        String(localized: "Doppelbock (ドッペルボック)"),
        String(localized: "Session IPA (セッションIPA)"),
        String(localized: "Lager (ラガー)"),
        String(localized: "Dunkel (ダンケル)"),
        String(localized: "Schwarzbier (シュヴァルツ)"),
        String(localized: "その他")
    ]
}
