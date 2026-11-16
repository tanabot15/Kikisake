//  CollectionMatrixModel.swift
//  Kikisake

import Foundation

/// 図鑑のペアリング項目（縦軸の産地 × 横軸の品種・米・スタイル）
public struct CollectionItemDefinition: Identifiable, Hashable {
    public let id = UUID()
    public let region: String          // 産地 (例: "フランス", "新潟県")
    public let targetElement: String   // 品種・米・スタイル (例: "ピノ・ノワール", "山田錦")
    public let category: BeverageCategory
    public let isProOnly: Bool         // Pro版限定（マイナー・マニアック枠）かどうか
    
    public init(region: String, targetElement: String, category: BeverageCategory, isProOnly: Bool = false) {
        self.region = region
        self.targetElement = targetElement
        self.category = category
        self.isProOnly = isProOnly
    }
}

/// コンプリート図鑑のマスターマッピング管理
public enum CollectionMatrixDataSource {
    
    /// 指定した酒種の有効な掛け合わせリスト（無料版はスタンダードのみ、Pro版は全て）
    public static func definitions(for category: BeverageCategory) -> [CollectionItemDefinition] {
        switch category {
        case .wine:
            // 無料版（isProOnly: false）= 30種 / Pro版 = 全100種
            return [
                // ==========================================
                // 1. フランス (無料: 7種 / Pro追加: 18種)
                // ==========================================
                .init(region: "フランス", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: false),
                .init(region: "フランス", targetElement: "メルロ", category: .wine, isProOnly: false),
                .init(region: "フランス", targetElement: "ピノ・ノワール", category: .wine, isProOnly: false),
                .init(region: "フランス", targetElement: "シャルドネ", category: .wine, isProOnly: false),
                .init(region: "フランス", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: false),
                .init(region: "フランス", targetElement: "シラー / シラーズ", category: .wine, isProOnly: false),
                .init(region: "フランス", targetElement: "ガメイ", category: .wine, isProOnly: false),
                
                .init(region: "フランス", targetElement: "リースリング", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "カベルネ・フラン", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "プティ・ヴェルド", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "マルベック", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ガルナッチャ / グレナッシュ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ムールヴェードル", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "カリニャン", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "タナ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "シュナン・ブラン", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "セミヨン", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ヴィオニエ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ピノ・グリ / ピノ-グリージョ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ゲヴュルツトラミネール", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ミュスカデ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "マルサンヌ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ルーサンヌ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "シャスラ", category: .wine, isProOnly: true),
                .init(region: "フランス", targetElement: "ピノ・ブラン", category: .wine, isProOnly: true),

                // ==========================================
                // 2. イタリア (無料: 5種 / Pro追加: 15種)
                // ==========================================
                .init(region: "イタリア", targetElement: "サンジョヴェーゼ", category: .wine, isProOnly: false),
                .init(region: "イタリア", targetElement: "ネッビオーロ", category: .wine, isProOnly: false),
                .init(region: "イタリア", targetElement: "バルベラ", category: .wine, isProOnly: false),
                .init(region: "イタリア", targetElement: "ピノ・グリ / ピノ-グリージョ", category: .wine, isProOnly: false),
                .init(region: "イタリア", targetElement: "グレラ (プロセッコ)", category: .wine, isProOnly: false),
                
                .init(region: "イタリア", targetElement: "ドルチェット", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "アリアニコ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "ネグロアマーロ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "プリミティーヴォ / ジンファンデル", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "コルヴィーナ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "ネレッロマスカレーゼ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "フラッパート", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "サグランド", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "シャルドネ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "ヴェルメンティーノ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "ガヴィ / コルテーゼ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "ガルガネガ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "ペコリーノ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "パッセリーナ", category: .wine, isProOnly: true),
                .init(region: "イタリア", targetElement: "フィアーノ", category: .wine, isProOnly: true),

                // ==========================================
                // 3. スペイン & ポルトガル (無料: 3種 / Pro追加: 9種)
                // ==========================================
                .init(region: "スペイン", targetElement: "テンプラニーリョ", category: .wine, isProOnly: false),
                .init(region: "スペイン", targetElement: "ガルナッチャ / グレナッシュ", category: .wine, isProOnly: false),
                .init(region: "スペイン", targetElement: "アルバリーニョ", category: .wine, isProOnly: false),
                
                .init(region: "スペイン", targetElement: "メンシア", category: .wine, isProOnly: true),
                .init(region: "スペイン", targetElement: "ヴェルデホ", category: .wine, isProOnly: true),
                .init(region: "スペイン", targetElement: "シャルドネ", category: .wine, isProOnly: true),
                .init(region: "ポルトガル", targetElement: "トゥーリガイ nacional", category: .wine, isProOnly: true),
                .init(region: "ポルトガル", targetElement: "ティラ", category: .wine, isProOnly: true),
                .init(region: "ポルトガル", targetElement: "アルリーニョ", category: .wine, isProOnly: true),
                .init(region: "ポルトガル", targetElement: "トウリガ・フランカ", category: .wine, isProOnly: true),
                .init(region: "ポルトガル", targetElement: "ロウレイロ", category: .wine, isProOnly: true),
                .init(region: "ポルトガル", targetElement: "フェルナン・ピレス", category: .wine, isProOnly: true),

                // ==========================================
                // 4. ドイツ & オーストリア & スイス & ハンガリー (無料: 2種 / Pro追加: 10種)
                // ==========================================
                .init(region: "ドイツ", targetElement: "リースリング", category: .wine, isProOnly: false),
                .init(region: "ドイツ", targetElement: "シュペートブルクンダー (ピノ・ノワール)", category: .wine, isProOnly: false),
                
                .init(region: "ドイツ", targetElement: "ヴァイスブルクンダー (ピノ・ブラン)", category: .wine, isProOnly: true),
                .init(region: "ドイツ", targetElement: "グラウブルクンダー (ピノ・グリ)", category: .wine, isProOnly: true),
                .init(region: "ドイツ", targetElement: "シルヴァーナー", category: .wine, isProOnly: true),
                .init(region: "オーストリア", targetElement: "グリューナー・フェルトリーナー", category: .wine, isProOnly: true),
                .init(region: "オーストリア", targetElement: "ブラウフランキッシュ", category: .wine, isProOnly: true),
                .init(region: "オーストリア", targetElement: "ツヴァイゲルトレーベ", category: .wine, isProOnly: true),
                .init(region: "スイス", targetElement: "シャスラ", category: .wine, isProOnly: true),
                .init(region: "スイス", targetElement: "ピノ・ノワール", category: .wine, isProOnly: true),
                .init(region: "ハンガリー", targetElement: "フルミント", category: .wine, isProOnly: true),
                .init(region: "ハンガリー", targetElement: "ハルシュレヴェリュ", category: .wine, isProOnly: true),

                // ==========================================
                // 5. アメリカ & カナダ & 南米 (無料: 7種 / Pro追加: 5種)
                // ==========================================
                .init(region: "アメリカ", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: false),
                .init(region: "アメリカ", targetElement: "シャルドネ", category: .wine, isProOnly: false),
                .init(region: "アメリカ", targetElement: "ピノ・ノワール", category: .wine, isProOnly: false),
                .init(region: "アメリカ", targetElement: "プリミティーヴォ / ジンファンデル", category: .wine, isProOnly: false),
                .init(region: "アルゼンチン", targetElement: "マルベック", category: .wine, isProOnly: false),
                .init(region: "チリ", targetElement: "カルメネール", category: .wine, isProOnly: false),
                .init(region: "チリ", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: false),
                
                .init(region: "アメリカ", targetElement: "メルロ", category: .wine, isProOnly: true),
                .init(region: "アメリカ", targetElement: "シラー / シラーズ", category: .wine, isProOnly: true),
                .init(region: "アルゼンチン", targetElement: "トロンテス", category: .wine, isProOnly: true),
                .init(region: "カナダ", targetElement: "リースリング", category: .wine, isProOnly: true),
                .init(region: "カナダ", targetElement: "ヴィダル", category: .wine, isProOnly: true),

                // ==========================================
                // 6. オーストラリア & ニュージーランド & 南アフリカ (無料: 4種 / Pro追加: 5種)
                // ==========================================
                .init(region: "オーストラリア", targetElement: "シラー / シラーズ", category: .wine, isProOnly: false),
                .init(region: "オーストラリア", targetElement: "シャルドネ", category: .wine, isProOnly: false),
                .init(region: "ニュージーランド", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: false),
                .init(region: "ニュージーランド", targetElement: "ピノ・ノワール", category: .wine, isProOnly: false),
                
                .init(region: "オーストラリア", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: true),
                .init(region: "南アフリカ", targetElement: "シュナン・ブラン", category: .wine, isProOnly: true),
                .init(region: "南アフリカ", targetElement: "ピノタージュ", category: .wine, isProOnly: true),
                .init(region: "南アフリカ", targetElement: "シラー / シラーズ", category: .wine, isProOnly: true),
                .init(region: "南アフリカ", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: true),

                // ==========================================
                // 7. 日本 & マイナー・伝統生産国 (無料: 2種 / Pro追加: 8種)
                // ==========================================
                .init(region: "日本", targetElement: "甲州", category: .wine, isProOnly: false),
                .init(region: "日本", targetElement: "マスカット・ベーリーA", category: .wine, isProOnly: false),
                
                .init(region: "日本", targetElement: "山葡萄", category: .wine, isProOnly: true),
                .init(region: "日本", targetElement: "ナイアガラ", category: .wine, isProOnly: true),
                .init(region: "ギリシャ", targetElement: "アッシルト", category: .wine, isProOnly: true),
                .init(region: "ジョージア", targetElement: "カツィツェリ", category: .wine, isProOnly: true),
                .init(region: "ジョージア", targetElement: "サペラヴィ", category: .wine, isProOnly: true),
                .init(region: "レバノン", targetElement: "サンソー", category: .wine, isProOnly: true),
                .init(region: "イギリス", targetElement: "シャルドネ", category: .wine, isProOnly: true),
                .init(region: "イギリス", targetElement: "ピノ・ノワール", category: .wine, isProOnly: true)
            ]
            
        case .sake:
            // すべての酒造好適米を網羅
            return [
                // ==========================================
                // 1. 北海道
                // ==========================================
                .init(region: "北海道", targetElement: "彗星", category: .sake, isProOnly: false),
                .init(region: "北海道", targetElement: "吟風", category: .sake, isProOnly: false),
                .init(region: "北海道", targetElement: "きたしずく", category: .sake, isProOnly: true),

                // ==========================================
                // 2. 青森県
                // ==========================================
                .init(region: "青森県", targetElement: "華吹雪", category: .sake, isProOnly: false),
                .init(region: "青森県", targetElement: "華想い", category: .sake, isProOnly: false),
                .init(region: "青森県", targetElement: "豊盃", category: .sake, isProOnly: true),
                .init(region: "青森県", targetElement: "吟烏帽子", category: .sake, isProOnly: true),
                .init(region: "青森県", targetElement: "古城錦", category: .sake, isProOnly: true),

                // ==========================================
                // 3. 岩手県
                // ==========================================
                .init(region: "岩手県", targetElement: "吟ぎんが", category: .sake, isProOnly: false),
                .init(region: "岩手県", targetElement: "ぎんおとめ", category: .sake, isProOnly: false),
                .init(region: "岩手県", targetElement: "結の香", category: .sake, isProOnly: true),
                .init(region: "岩手県", targetElement: "美山錦", category: .sake, isProOnly: true),

                // ==========================================
                // 4. 宮城県
                // ==========================================
                .init(region: "宮城県", targetElement: "蔵の華", category: .sake, isProOnly: false),
                .init(region: "宮城県", targetElement: "吟のいろは", category: .sake, isProOnly: false),
                .init(region: "宮城県", targetElement: "美山錦", category: .sake, isProOnly: true),
                .init(region: "宮城県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "宮城県", targetElement: "ササニシキ", category: .sake, isProOnly: true),

                // ==========================================
                // 5. 秋田県
                // ==========================================
                .init(region: "秋田県", targetElement: "秋田酒こまち", category: .sake, isProOnly: false),
                .init(region: "秋田県", targetElement: "美山錦", category: .sake, isProOnly: false),
                .init(region: "秋田県", targetElement: "美郷錦", category: .sake, isProOnly: true),
                .init(region: "秋田県", targetElement: "百田", category: .sake, isProOnly: true),
                .init(region: "秋田県", targetElement: "改良信交", category: .sake, isProOnly: true),
                .init(region: "秋田県", targetElement: "一穂積", category: .sake, isProOnly: true),
                .init(region: "秋田県", targetElement: "星あかり", category: .sake, isProOnly: true),
                .init(region: "秋田県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 6. 山形県
                // ==========================================
                .init(region: "山形県", targetElement: "出羽燦々", category: .sake, isProOnly: false),
                .init(region: "山形県", targetElement: "出羽の里", category: .sake, isProOnly: false),
                .init(region: "山形県", targetElement: "美山錦", category: .sake, isProOnly: false),
                .init(region: "山形県", targetElement: "雪女神", category: .sake, isProOnly: false),
                .init(region: "山形県", targetElement: "酒未来", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "山酒4号", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "改良信交", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "羽州誉", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "龍の落とし子", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "亀粋", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "豊国", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "愛山", category: .sake, isProOnly: true),

                // ==========================================
                // 7. 福島県
                // ==========================================
                .init(region: "福島県", targetElement: "夢の香", category: .sake, isProOnly: false),
                .init(region: "福島県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "福島県", targetElement: "福乃香", category: .sake, isProOnly: false),
                .init(region: "福島県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "福島県", targetElement: "美山錦", category: .sake, isProOnly: true),

                // ==========================================
                // 8. 茨城県
                // ==========================================
                .init(region: "茨城県", targetElement: "ひたち錦", category: .sake, isProOnly: false),
                .init(region: "茨城県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "茨城県", targetElement: "美山錦", category: .sake, isProOnly: true),
                .init(region: "茨城県", targetElement: "渡船", category: .sake, isProOnly: true),
                .init(region: "茨城県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 9. 栃木県
                // ==========================================
                .init(region: "栃木県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "栃木県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "栃木県", targetElement: "夢ささら", category: .sake, isProOnly: false),
                .init(region: "栃木県", targetElement: "ひとごこち", category: .sake, isProOnly: true),
                .init(region: "栃木県", targetElement: "とちぎ酒14", category: .sake, isProOnly: true),

                // ==========================================
                // 10. 群馬県
                // ==========================================
                .init(region: "群馬県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "群馬県", targetElement: "若水", category: .sake, isProOnly: false),
                .init(region: "群馬県", targetElement: "改良信交", category: .sake, isProOnly: true),
                .init(region: "群馬県", targetElement: "舞風", category: .sake, isProOnly: true),
                .init(region: "群馬県", targetElement: "山酒4号", category: .sake, isProOnly: true),
                .init(region: "群馬県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 11. 埼玉県
                // ==========================================
                .init(region: "埼玉県", targetElement: "さけ武蔵", category: .sake, isProOnly: false),
                .init(region: "埼玉県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "埼玉県", targetElement: "五百万石", category: .sake, isProOnly: true),

                // ==========================================
                // 12. 千葉県
                // ==========================================
                .init(region: "千葉県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "千葉県", targetElement: "総の舞", category: .sake, isProOnly: false),
                .init(region: "千葉県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 13. 東京都
                // ==========================================
                .init(region: "東京都", targetElement: "一般米（食用米）", category: .sake, isProOnly: false),

                // ==========================================
                // 14. 神奈川県
                // ==========================================
                .init(region: "神奈川県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "神奈川県", targetElement: "楽風舞", category: .sake, isProOnly: false),
                .init(region: "神奈川県", targetElement: "若水", category: .sake, isProOnly: true),
                .init(region: "神奈川県", targetElement: "雄町", category: .sake, isProOnly: true),

                // ==========================================
                // 15. 新潟県
                // ==========================================
                .init(region: "新潟県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "新潟県", targetElement: "越淡麗", category: .sake, isProOnly: false),
                .init(region: "新潟県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "新潟県", targetElement: "たかね錦", category: .sake, isProOnly: true),
                .init(region: "新潟県", targetElement: "一本〆", category: .sake, isProOnly: true),
                .init(region: "新潟県", targetElement: "菊水", category: .sake, isProOnly: true),
                .init(region: "新潟県", targetElement: "越神楽", category: .sake, isProOnly: true),
                .init(region: "新潟県", targetElement: "楽風舞", category: .sake, isProOnly: true),

                // ==========================================
                // 16. 富山県
                // ==========================================
                .init(region: "富山県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "富山県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "富山県", targetElement: "雄山錦", category: .sake, isProOnly: true),
                .init(region: "富山県", targetElement: "富の香", category: .sake, isProOnly: true),
                .init(region: "富山県", targetElement: "美山錦", category: .sake, isProOnly: true),

                // ==========================================
                // 17. 石川県
                // ==========================================
                .init(region: "石川県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "石川県", targetElement: "石川門", category: .sake, isProOnly: false),
                .init(region: "石川県", targetElement: "石川酒68号", category: .sake, isProOnly: true),
                .init(region: "石川県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 18. 福井県
                // ==========================================
                .init(region: "福井県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "福井県", targetElement: "さかほまれ", category: .sake, isProOnly: false),
                .init(region: "福井県", targetElement: "越の雫", category: .sake, isProOnly: true),
                .init(region: "福井県", targetElement: "九頭竜", category: .sake, isProOnly: true),
                .init(region: "福井県", targetElement: "神力", category: .sake, isProOnly: true),
                .init(region: "福井県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 19. 山梨県
                // ==========================================
                .init(region: "山梨県", targetElement: "ひとごこち", category: .sake, isProOnly: false),
                .init(region: "山梨県", targetElement: "夢山水", category: .sake, isProOnly: false),
                .init(region: "山梨県", targetElement: "玉栄", category: .sake, isProOnly: true),
                .init(region: "山梨県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "山梨県", targetElement: "美山錦", category: .sake, isProOnly: true),

                // ==========================================
                // 20. 長野県
                // ==========================================
                .init(region: "長野県", targetElement: "美山錦", category: .sake, isProOnly: false),
                .init(region: "長野県", targetElement: "ひとごこち", category: .sake, isProOnly: false),
                .init(region: "長野県", targetElement: "山恵錦", category: .sake, isProOnly: false),
                .init(region: "長野県", targetElement: "金紋錦", category: .sake, isProOnly: true),
                .init(region: "長野県", targetElement: "しらかば錦", category: .sake, isProOnly: true),
                .init(region: "長野県", targetElement: "たかね錦", category: .sake, isProOnly: true),
                .init(region: "長野県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 21. 岐阜県
                // ==========================================
                .init(region: "岐阜県", targetElement: "ひだほまれ", category: .sake, isProOnly: false),
                .init(region: "岐阜県", targetElement: "五百万石", category: .sake, isProOnly: true),

                // ==========================================
                // 22. 静岡県
                // ==========================================
                .init(region: "静岡県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "静岡県", targetElement: "令和誉富士", category: .sake, isProOnly: false),
                .init(region: "静岡県", targetElement: "誉富士", category: .sake, isProOnly: true),

                // ==========================================
                // 23. 愛知県
                // ==========================================
                .init(region: "愛知県", targetElement: "夢山水", category: .sake, isProOnly: false),
                .init(region: "愛知県", targetElement: "若水", category: .sake, isProOnly: false),
                .init(region: "愛知県", targetElement: "夢吟香", category: .sake, isProOnly: true),
                .init(region: "愛知県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 24. 三重県
                // ==========================================
                .init(region: "三重県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "三重県", targetElement: "神の穂", category: .sake, isProOnly: false),
                .init(region: "三重県", targetElement: "五百万石", category: .sake, isProOnly: true),
                .init(region: "三重県", targetElement: "伊勢錦", category: .sake, isProOnly: true),

                // ==========================================
                // 25. 滋賀県
                // ==========================================
                .init(region: "滋賀県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "滋賀県", targetElement: "玉栄", category: .sake, isProOnly: false),
                .init(region: "滋賀県", targetElement: "吟吹雪", category: .sake, isProOnly: true),
                .init(region: "滋賀県", targetElement: "滋賀渡船6号", category: .sake, isProOnly: true),

                // ==========================================
                // 26. 京都府
                // ==========================================
                .init(region: "京都府", targetElement: "祝", category: .sake, isProOnly: false),
                .init(region: "京都府", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "京都府", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 27. 大阪府
                // ==========================================
                .init(region: "大阪府", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "大阪府", targetElement: "雄町", category: .sake, isProOnly: true),

                // ==========================================
                // 28. 兵庫県
                // ==========================================
                .init(region: "兵庫県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "兵庫県", targetElement: "愛山", category: .sake, isProOnly: false),
                .init(region: "兵庫県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "兵庫県", targetElement: "白鶴錦", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "兵庫北錦", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "山田穂", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "兵庫錦", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "渡船2号", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "兵庫恋錦", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "Hyogo Sake85", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "但馬強力", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "神力", category: .sake, isProOnly: true),

                // ==========================================
                // 29. 奈良県
                // ==========================================
                .init(region: "奈良県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "奈良県", targetElement: "露葉風", category: .sake, isProOnly: false),
                .init(region: "奈良県", targetElement: "なら酒1504", category: .sake, isProOnly: true),

                // ==========================================
                // 30. 和歌山県
                // ==========================================
                .init(region: "和歌山県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "和歌山県", targetElement: "五百万石", category: .sake, isProOnly: true),
                .init(region: "和歌山県", targetElement: "玉栄", category: .sake, isProOnly: true),

                // ==========================================
                // 31. 鳥取県
                // ==========================================
                .init(region: "鳥取県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "鳥取県", targetElement: "強力", category: .sake, isProOnly: false),
                .init(region: "鳥取県", targetElement: "五百万石", category: .sake, isProOnly: true),
                .init(region: "鳥取県", targetElement: "玉栄", category: .sake, isProOnly: true),

                // ==========================================
                // 32. 島根県
                // ==========================================
                .init(region: "島根県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "島根県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "島根県", targetElement: "佐香錦", category: .sake, isProOnly: true),
                .init(region: "島根県", targetElement: "改良雄町", category: .sake, isProOnly: true),
                .init(region: "島根県", targetElement: "縁の舞", category: .sake, isProOnly: true),
                .init(region: "島根県", targetElement: "改良八反流", category: .sake, isProOnly: true),
                .init(region: "島根県", targetElement: "神の舞", category: .sake, isProOnly: true),

                // ==========================================
                // 33. 岡山県
                // ==========================================
                .init(region: "岡山県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "岡山県", targetElement: "雄町", category: .sake, isProOnly: false),
                .init(region: "岡山県", targetElement: "赤磐雄町", category: .sake, isProOnly: true),
                .init(region: "岡山県", targetElement: "吟のさと", category: .sake, isProOnly: true),

                // ==========================================
                // 34. 広島県
                // ==========================================
                .init(region: "広島県", targetElement: "八反錦1号", category: .sake, isProOnly: false),
                .init(region: "広島県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "広島県", targetElement: "八反35号", category: .sake, isProOnly: true),
                .init(region: "広島県", targetElement: "千本錦", category: .sake, isProOnly: true),
                .init(region: "広島県", targetElement: "萌えいぶき", category: .sake, isProOnly: true),
                .init(region: "広島県", targetElement: "改良雄町", category: .sake, isProOnly: true),
                .init(region: "広島県", targetElement: "こいおまち", category: .sake, isProOnly: true),

                // ==========================================
                // 35. 山口県
                // ==========================================
                .init(region: "山口県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "山口県", targetElement: "西都の雫", category: .sake, isProOnly: false),
                .init(region: "山口県", targetElement: "白鶴錦", category: .sake, isProOnly: true),

                // ==========================================
                // 36. 徳島県
                // ==========================================
                .init(region: "徳島県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "徳島県", targetElement: "吟のさと", category: .sake, isProOnly: true),

                // ==========================================
                // 37. 香川県
                // ==========================================
                .init(region: "香川県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "香川県", targetElement: "雄町", category: .sake, isProOnly: true),

                // ==========================================
                // 38. 愛媛県
                // ==========================================
                .init(region: "愛媛県", targetElement: "しずく媛", category: .sake, isProOnly: false),
                .init(region: "愛媛県", targetElement: "山田錦", category: .sake, isProOnly: true),

                // ==========================================
                // 39. 高知県
                // ==========================================
                .init(region: "高知県", targetElement: "吟の夢", category: .sake, isProOnly: false),
                .init(region: "高知県", targetElement: "土佐麗", category: .sake, isProOnly: false),
                .init(region: "高知県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "高知県", targetElement: "風鳴子", category: .sake, isProOnly: true),

                // ==========================================
                // 40. 福岡県
                // ==========================================
                .init(region: "福岡県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "福岡県", targetElement: "吟のさと", category: .sake, isProOnly: false),
                .init(region: "福岡県", targetElement: "壽限無", category: .sake, isProOnly: true),
                .init(region: "福岡県", targetElement: "雄町", category: .sake, isProOnly: true),

                // ==========================================
                // 41. 佐賀県
                // ==========================================
                .init(region: "佐賀県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "佐賀県", targetElement: "さがの華", category: .sake, isProOnly: false),

                // ==========================================
                // 42. 長崎県
                // ==========================================
                .init(region: "長崎県", targetElement: "山田錦", category: .sake, isProOnly: false),

                // ==========================================
                // 43. 熊本県
                // ==========================================
                .init(region: "熊本県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "熊本県", targetElement: "華錦", category: .sake, isProOnly: false),
                .init(region: "熊本県", targetElement: "神力", category: .sake, isProOnly: true),
                .init(region: "熊本県", targetElement: "吟のさと", category: .sake, isProOnly: true),

                // ==========================================
                // 44. 大分県
                // ==========================================
                .init(region: "大分県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "大分県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "大分県", targetElement: "若水", category: .sake, isProOnly: true),
                .init(region: "大分県", targetElement: "雄町", category: .sake, isProOnly: true),

                // ==========================================
                // 45. 宮崎県
                // ==========================================
                .init(region: "宮崎県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "宮崎県", targetElement: "はなかぐら", category: .sake, isProOnly: true),
                .init(region: "宮崎県", targetElement: "ちほのまい", category: .sake, isProOnly: true),

                // ==========================================
                // 46. 鹿児島県
                // ==========================================
                .init(region: "鹿児島県", targetElement: "山田錦", category: .sake, isProOnly: false),

                // ==========================================
                // 47. 沖縄県
                // ==========================================
                .init(region: "沖縄県", targetElement: "一般米（食用米）", category: .sake, isProOnly: true)
            ]
            
        case .beer:
            // 無料版（isProOnly: false）= 20種 / Pro版 = 全50種
            return [
                // ==========================================
                // 1. ドイツ & チェコ (無料: 5種 / Pro追加: 7種)
                // ==========================================
                .init(region: "ドイツ", targetElement: "ピルスナー", category: .beer, isProOnly: false),
                .init(region: "ドイツ", targetElement: "ヴァイツェン（ヘーフェヴァイツェン）", category: .beer, isProOnly: false),
                .init(region: "ドイツ", targetElement: "ボック", category: .beer, isProOnly: false),
                .init(region: "ドイツ", targetElement: "シュバルツ", category: .beer, isProOnly: false),
                .init(region: "チェコ", targetElement: "ピルスナー", category: .beer, isProOnly: false),
                
                .init(region: "ドイツ", targetElement: "ボヘミアン・ピルスナー", category: .beer, isProOnly: true),
                .init(region: "ドイツ", targetElement: "デュンケル", category: .beer, isProOnly: true),
                .init(region: "ドイツ", targetElement: "ドッペルボック", category: .beer, isProOnly: true),
                .init(region: "ドイツ", targetElement: "メルツェン / オクトーバーフェスト", category: .beer, isProOnly: true),
                .init(region: "ドイツ", targetElement: "ラオハス（燻製ビール）", category: .beer, isProOnly: true),
                .init(region: "ドイツ", targetElement: "ケルシュ", category: .beer, isProOnly: true),
                .init(region: "ドイツ", targetElement: "アルトビール", category: .beer, isProOnly: true),

                // ==========================================
                // 2. ベルギー (無料: 3種 / Pro追加: 7種)
                // ==========================================
                .init(region: "ベルギー", targetElement: "ベルジャンホワイト（ヴィットビール）", category: .beer, isProOnly: false),
                .init(region: "ベルギー", targetElement: "セゾン", category: .beer, isProOnly: false),
                .init(region: "ベルギー", targetElement: "サワーエール", category: .beer, isProOnly: false),
                
                .init(region: "ベルギー", targetElement: "ベルジャン・ブロンド", category: .beer, isProOnly: true),
                .init(region: "ベルギー", targetElement: "ベルジャン・デュペル", category: .beer, isProOnly: true),
                .init(region: "ベルギー", targetElement: "ベルジャン・トリプル", category: .beer, isProOnly: true),
                .init(region: "ベルギー", targetElement: "ベルジャン・クアドルペル", category: .beer, isProOnly: true),
                .init(region: "ベルギー", targetElement: "ランビック", category: .beer, isProOnly: true),
                .init(region: "ベルギー", targetElement: "フラダース・レッドエール", category: .beer, isProOnly: true),
                .init(region: "ベルギー", targetElement: "フルーツビール", category: .beer, isProOnly: true),

                // ==========================================
                // 3. イギリス & アイルランド (無料: 4種 / Pro追加: 4種)
                // ==========================================
                .init(region: "イギリス", targetElement: "イングリッシュ・ペールエール", category: .beer, isProOnly: false),
                .init(region: "イギリス", targetElement: "ポーター", category: .beer, isProOnly: false),
                .init(region: "イギリス", targetElement: "スタウト", category: .beer, isProOnly: false),
                .init(region: "アイルランド", targetElement: "アイリッシュ・スタウト", category: .beer, isProOnly: false),
                
                .init(region: "イギリス", targetElement: "ビター / ESB", category: .beer, isProOnly: true),
                .init(region: "イギリス", targetElement: "イングリッシュ・IPA", category: .beer, isProOnly: true),
                .init(region: "イギリス", targetElement: "インペリアルスタウト", category: .beer, isProOnly: true),
                .init(region: "イギリス", targetElement: "バーレイワイン", category: .beer, isProOnly: true),

                // ==========================================
                // 4. アメリカ (無料: 4種 / Pro追加: 8種)
                // ==========================================
                .init(region: "アメリカ", targetElement: "IPA", category: .beer, isProOnly: false),
                .init(region: "アメリカ", targetElement: "ヘイジーIPA（ニューイングランドIPA）", category: .beer, isProOnly: false),
                .init(region: "アメリカ", targetElement: "ダブルIPA（インペリアルIPA）", category: .beer, isProOnly: false),
                .init(region: "アメリカ", targetElement: "アメリカン・ペールエール", category: .beer, isProOnly: false),
                
                .init(region: "アメリカ", targetElement: "トリプルIPA", category: .beer, isProOnly: true),
                .init(region: "アメリカ", targetElement: "セッションIPA", category: .beer, isProOnly: true),
                .init(region: "アメリカ", targetElement: "ブラックIPA", category: .beer, isProOnly: true),
                .init(region: "アメリカ", targetElement: "アメリカン・ラガー", category: .beer, isProOnly: true),
                .init(region: "アメリカ", targetElement: "サワーエール", category: .beer, isProOnly: true),
                .init(region: "アメリカ", targetElement: "ゴーゼ", category: .beer, isProOnly: true),
                .init(region: "アメリカ", targetElement: "ミルクスタウト（オートミールスタウト）", category: .beer, isProOnly: true),
                .init(region: "アメリカ", targetElement: "フルーツビール", category: .beer, isProOnly: true),

                // ==========================================
                // 5. 日本 & 新興クラフトシーン (無料: 4種 / Pro追加: 4種)
                // ==========================================
                .init(region: "日本", targetElement: "ピルスナー", category: .beer, isProOnly: false),
                .init(region: "日本", targetElement: "IPA", category: .beer, isProOnly: false),
                .init(region: "日本", targetElement: "ヘイジーIPA（ニューイングランドIPA）", category: .beer, isProOnly: false),
                .init(region: "日本", targetElement: "ヴァイツェン（ヘーフェヴァイツェン）", category: .beer, isProOnly: false),
                
                .init(region: "日本", targetElement: "イングリッシュ・ペールエール", category: .beer, isProOnly: true),
                .init(region: "日本", targetElement: "フルーツビール", category: .beer, isProOnly: true),
                .init(region: "デンマーク", targetElement: "インペリアルスタウト", category: .beer, isProOnly: true),
                .init(region: "エストニア", targetElement: "ポーター", category: .beer, isProOnly: true)
            ]
        }
    }
}
