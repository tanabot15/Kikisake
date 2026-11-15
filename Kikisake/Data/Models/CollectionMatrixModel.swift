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
            // 無料版（isProOnly: false）= 30種 / Pro版 = 全100種
            return [
                // ==========================================
                // 1. 新潟・東北の銘酒蔵 (無料: 12種 / Pro追加: 18種)
                // ==========================================
                .init(region: "新潟県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "新潟県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "新潟県", targetElement: "越淡麗", category: .sake, isProOnly: false),
                .init(region: "山形県", targetElement: "出羽燦々", category: .sake, isProOnly: false),
                .init(region: "山形県", targetElement: "美山錦", category: .sake, isProOnly: false),
                .init(region: "山形県", targetElement: "雄町", category: .sake, isProOnly: false),
                .init(region: "秋田県", targetElement: "秋田酒こまち", category: .sake, isProOnly: false),
                .init(region: "秋田県", targetElement: "美山錦", category: .sake, isProOnly: false),
                .init(region: "宮城県", targetElement: "蔵の華", category: .sake, isProOnly: false),
                .init(region: "福島県", targetElement: "夢の香", category: .sake, isProOnly: false),
                .init(region: "福島県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "北海道", targetElement: "彗星", category: .sake, isProOnly: false),
                
                .init(region: "新潟県", targetElement: "こいみどり", category: .sake, isProOnly: true),
                .init(region: "新潟県", targetElement: "一般米（食用米）", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "雪女神", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "羽州誉", category: .sake, isProOnly: true),
                .init(region: "秋田県", targetElement: "一輪", category: .sake, isProOnly: true),
                .init(region: "宮城県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "福島県", targetElement: "五百万石", category: .sake, isProOnly: true),
                .init(region: "岩手県", targetElement: "ぎんおとめ", category: .sake, isProOnly: true),
                .init(region: "岩手県", targetElement: "結の香", category: .sake, isProOnly: true),
                .init(region: "青森県", targetElement: "華吹雪", category: .sake, isProOnly: true),
                .init(region: "青森県", targetElement: "華想い", category: .sake, isProOnly: true),
                .init(region: "北海道", targetElement: "きたしずく", category: .sake, isProOnly: true),
                .init(region: "北海道", targetElement: "吟風", category: .sake, isProOnly: true),
                .init(region: "岩手県", targetElement: "美山錦", category: .sake, isProOnly: true),
                .init(region: "青森県", targetElement: "まっしぐら", category: .sake, isProOnly: true),
                .init(region: "山形県", targetElement: "愛山", category: .sake, isProOnly: true),
                .init(region: "秋田県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "宮城県", targetElement: "ササニシキ", category: .sake, isProOnly: true),

                // ==========================================
                // 2. 関東・甲信越・北陸の酒処 (無料: 6種 / Pro追加: 19種)
                // ==========================================
                .init(region: "長野県", targetElement: "美山錦", category: .sake, isProOnly: false),
                .init(region: "長野県", targetElement: "ひとごこち", category: .sake, isProOnly: false),
                .init(region: "静岡県", targetElement: "誉富士", category: .sake, isProOnly: false),
                .init(region: "石川県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "福井県", targetElement: "五百万石", category: .sake, isProOnly: false),
                .init(region: "富山県", targetElement: "五百万石", category: .sake, isProOnly: false),
                
                .init(region: "長野県", targetElement: "金紋錦", category: .sake, isProOnly: true),
                .init(region: "長野県", targetElement: "山恵錦", category: .sake, isProOnly: true),
                .init(region: "長野県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "山梨県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "山梨県", targetElement: "一般米（食用米）", category: .sake, isProOnly: true),
                .init(region: "静岡県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "富山県", targetElement: "雄山錦", category: .sake, isProOnly: true),
                .init(region: "石川県", targetElement: "石川門", category: .sake, isProOnly: true),
                .init(region: "福井県", targetElement: "さけににしき", category: .sake, isProOnly: true),
                .init(region: "群馬県", targetElement: "舞風", category: .sake, isProOnly: true),
                .init(region: "栃木県", targetElement: "とちぎ酒14", category: .sake, isProOnly: true),
                .init(region: "茨城県", targetElement: "常盤錦", category: .sake, isProOnly: true),
                .init(region: "埼玉県", targetElement: "さけ武蔵", category: .sake, isProOnly: true),
                .init(region: "東京都", targetElement: "一般米（食用米）", category: .sake, isProOnly: true),
                .init(region: "神奈川県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "千葉県", targetElement: "総の舞", category: .sake, isProOnly: true),
                .init(region: "岐阜県", targetElement: "ひだほまれ", category: .sake, isProOnly: true),
                .init(region: "愛知県", targetElement: "夢山水", category: .sake, isProOnly: true),
                .init(region: "三重県", targetElement: "神の穂", category: .sake, isProOnly: true),

                // ==========================================
                // 3. 近畿・中国・四国の酒米文化 (無料: 10種 / Pro追加: 20種)
                // ==========================================
                .init(region: "兵庫県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "兵庫県", targetElement: "雄町", category: .sake, isProOnly: false),
                .init(region: "京都府", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "京都府", targetElement: "祝", category: .sake, isProOnly: false),
                .init(region: "岡山県", targetElement: "雄町", category: .sake, isProOnly: false),
                .init(region: "広島県", targetElement: "八反錦", category: .sake, isProOnly: false),
                .init(region: "山口県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "高知県", targetElement: "吟の夢", category: .sake, isProOnly: false),
                .init(region: "三重県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "滋賀県", targetElement: "玉栄", category: .sake, isProOnly: false),
                
                .init(region: "兵庫県", targetElement: "兵庫北錦", category: .sake, isProOnly: true),
                .init(region: "兵庫県", targetElement: "愛山", category: .sake, isProOnly: true),
                .init(region: "京都府", targetElement: "五百万石", category: .sake, isProOnly: true),
                .init(region: "滋賀県", targetElement: "秋の詩", category: .sake, isProOnly: true),
                .init(region: "奈良県", targetElement: "露葉風", category: .sake, isProOnly: true),
                .init(region: "奈良県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "和歌山県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "大阪府", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "岡山県", targetElement: "赤磐雄町", category: .sake, isProOnly: true),
                .init(region: "広島県", targetElement: "千本錦", category: .sake, isProOnly: true),
                .init(region: "山口県", targetElement: "西都の雫", category: .sake, isProOnly: true),
                .init(region: "島根県", targetElement: "神の舞", category: .sake, isProOnly: true),
                .init(region: "島根県", targetElement: "佐香錦", category: .sake, isProOnly: true),
                .init(region: "鳥取県", targetElement: "強力", category: .sake, isProOnly: true),
                .init(region: "鳥取県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "高知県", targetElement: "松山三井", category: .sake, isProOnly: true),
                .init(region: "愛媛県", targetElement: "しずく媛", category: .sake, isProOnly: true),
                .init(region: "徳島県", targetElement: "阿波山田錦", category: .sake, isProOnly: true),
                .init(region: "香川県", targetElement: "オオセト", category: .sake, isProOnly: true),
                .init(region: "岡山県", targetElement: "朝日", category: .sake, isProOnly: true),

                // ==========================================
                // 4. 九州・沖縄のレア地域 (無料: 2種 / Pro追加: 13種)
                // ==========================================
                .init(region: "福岡県", targetElement: "山田錦", category: .sake, isProOnly: false),
                .init(region: "佐賀県", targetElement: "山田錦", category: .sake, isProOnly: false),
                
                .init(region: "福岡県", targetElement: "夢一献", category: .sake, isProOnly: true),
                .init(region: "佐賀県", targetElement: "佐賀の華", category: .sake, isProOnly: true),
                .init(region: "長崎県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "熊本県", targetElement: "華錦", category: .sake, isProOnly: true),
                .init(region: "熊本県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "大分県", targetElement: "ひのひかり", category: .sake, isProOnly: true),
                .init(region: "大分県", targetElement: "山田錦", category: .sake, isProOnly: true),
                .init(region: "宮崎県", targetElement: "一般米（食用米）", category: .sake, isProOnly: true),
                .init(region: "鹿児島県", targetElement: "一般米（食用米）", category: .sake, isProOnly: true),
                .init(region: "沖縄県", targetElement: "一般米（食用米）", category: .sake, isProOnly: true),
                .init(region: "佐賀県", targetElement: "雄町", category: .sake, isProOnly: true),
                .init(region: "福岡県", targetElement: "雄町", category: .sake, isProOnly: true),
                .init(region: "熊本県", targetElement: "神力", category: .sake, isProOnly: true)
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
