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
    public let suggestionHint: String  // 未達成時のサジェストヒント
    
    public init(
        region: String,
        targetElement: String,
        category: BeverageCategory,
        isProOnly: Bool = false,
        suggestionHint: String = ""
    ) {
        self.region = region
        self.targetElement = targetElement
        self.category = category
        self.isProOnly = isProOnly
        self.suggestionHint = suggestionHint.isEmpty
            ? "\(region)産の「\(targetElement)」系のお酒を記録してみましょう。"
            : suggestionHint
    }
}

/// コンプリート図鑑のマスターマッピング管理
public enum CollectionMatrixDataSource {
    
    /// 指定した酒種の有効な掛け合わせリスト
    public static func definitions(for category: BeverageCategory) -> [CollectionItemDefinition] {
        switch category {
        case .wine:
            return [
                // ==========================================
                // 1. フランス
                // ==========================================
                .init(region: "フランス", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: false, suggestionHint: "シャトー・ラトゥール、シャトー・ムートン・ロートシルト など"),
                .init(region: "フランス", targetElement: "メルロ", category: .wine, isProOnly: false, suggestionHint: "シャトー・ペトリュス、シャトー・シュヴァル・ブラン など"),
                .init(region: "フランス", targetElement: "ピノ・ノワール", category: .wine, isProOnly: false, suggestionHint: "ドメーヌ・ド・ラ・ロマネ・コンティ (DRC)、シャンボール・ミュジニー など"),
                .init(region: "フランス", targetElement: "シャルドネ", category: .wine, isProOnly: false, suggestionHint: "モンラッシェ、シャブリ (ルイ・ジャドなど)"),
                .init(region: "フランス", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: false, suggestionHint: "サンセール (アンリ・ブルジョワなど)、プイィ・フュメ"),
                .init(region: "フランス", targetElement: "シラー / シラーズ", category: .wine, isProOnly: false, suggestionHint: "コート・ロティ (E.ギガルなど)、エルミタージュ"),
                .init(region: "フランス", targetElement: "ガメイ", category: .wine, isProOnly: false, suggestionHint: "ボジョレー・ヌーヴォー、フルーリー"),
                
                .init(region: "フランス", targetElement: "リースリング", category: .wine, isProOnly: true, suggestionHint: "アルザス・リースリング (トリンバック、H.ヒューゲル)"),
                .init(region: "フランス", targetElement: "カベルネ・フラン", category: .wine, isProOnly: true, suggestionHint: "シノン (シャルル・ジャルグ)、ブルグイユ"),
                .init(region: "フランス", targetElement: "プティ・ヴェルド", category: .wine, isProOnly: true, suggestionHint: "ボルドー格付けシャトーのブレンド、または単一品種ワイン"),
                .init(region: "フランス", targetElement: "マルベック", category: .wine, isProOnly: true, suggestionHint: "カオール (シャトー・デュ・コトなど)"),
                .init(region: "フランス", targetElement: "ガルナッチャ / グレナッシュ", category: .wine, isProOnly: true, suggestionHint: "シャトーヌフ・デュ・パプ (シャトー・ド・ボーカステル)"),
                .init(region: "フランス", targetElement: "ムールヴェードル", category: .wine, isProOnly: true, suggestionHint: "バンドール (ドメーヌ・テンピエ)"),
                .init(region: "フランス", targetElement: "カリニャン", category: .wine, isProOnly: true, suggestionHint: "ラングドック・ルーションのV.I.P.V. や古木キュヴェ"),
                .init(region: "フランス", targetElement: "サンソー", category: .wine, isProOnly: true, suggestionHint: "南仏のロゼワインやローヌのブレンド用品種"),
                .init(region: "フランス", targetElement: "タナ", category: .wine, isProOnly: true, suggestionHint: "マディラン (シャトー・モンテュス)"),
                .init(region: "フランス", targetElement: "シュナン・ブラン", category: .wine, isProOnly: true, suggestionHint: "ヴォーヴレ (ドメーヌ・ド・ユエ)、サトゥルニエ"),
                .init(region: "フランス", targetElement: "セミヨン", category: .wine, isProOnly: true, suggestionHint: "ソーテルヌ (シャトー・ディケム)"),
                .init(region: "フランス", targetElement: "ヴィオニエ", category: .wine, isProOnly: true, suggestionHint: "コンドリュー (E.ギガル「ラ・ドリアーヌ」)"),
                .init(region: "フランス", targetElement: "ピノ・グリ / ピノ・グリージョ", category: .wine, isProOnly: true, suggestionHint: "アルザス・ピノ・グリ (マルセル・ダイスなど)"),
                .init(region: "フランス", targetElement: "ゲヴュルツトラミネール", category: .wine, isProOnly: true, suggestionHint: "アルザス・ゲヴュルツトラミネール (トリンバック)"),
                .init(region: "フランス", targetElement: "ミュスカデ", category: .wine, isProOnly: true, suggestionHint: "ミュスカデ・セーヴル・エ・メーヌ (シュール・リー)"),
                .init(region: "フランス", targetElement: "マルサンヌ", category: .wine, isProOnly: true, suggestionHint: "サン・ペーレ、エルミタージュ・ブラン"),
                .init(region: "フランス", targetElement: "ルーサンヌ", category: .wine, isProOnly: true, suggestionHint: "コート・デュ・ローヌ・ブランの高級キュヴェ"),
                .init(region: "フランス", targetElement: "グルナッシュ・ブラン", category: .wine, isProOnly: true, suggestionHint: "コート・デュ・ローヌやルーションの白ワイン"),
                .init(region: "フランス", targetElement: "シャスラ", category: .wine, isProOnly: true, suggestionHint: "サヴォワ地方の白ワイン (リポレなど)"),
                .init(region: "フランス", targetElement: "ピノ・ブラン", category: .wine, isProOnly: true, suggestionHint: "アルザス・ピノ・ブラン"),
                .init(region: "フランス", targetElement: "サヴァニャン", category: .wine, isProOnly: true, suggestionHint: "ジュラ地方のヴァン・ジョーヌ (黄ワイン)"),
                .init(region: "フランス", targetElement: "ユニ・ブラン", category: .wine, isProOnly: true, suggestionHint: "コニャックやアルマニャックの原料、コスティエ・ド・ニーム等"),

                // ==========================================
                // 2. イタリア
                // ==========================================
                .init(region: "イタリア", targetElement: "サンジョヴェーゼ", category: .wine, isProOnly: false, suggestionHint: "キャンティ・クラシコ (アンティノリなど)、ブルネッロ・ディ・モンタルチーノ"),
                .init(region: "イタリア", targetElement: "ネッビオーロ", category: .wine, isProOnly: false, suggestionHint: "バローロ (ガヤ、ジャコモ・コンテルノ)、バルバレスコ"),
                .init(region: "イタリア", targetElement: "バルベラ", category: .wine, isProOnly: false, suggestionHint: "バルベラ・ダスティ (ボッジョーロなど)"),
                .init(region: "イタリア", targetElement: "ピノ・グリ / ピノ・グリージョ", category: .wine, isProOnly: false, suggestionHint: "フリウリやヴェネトのピノ・グリージョ (サン・マルゲリータ)"),
                .init(region: "イタリア", targetElement: "グレーラ", category: .wine, isProOnly: false, suggestionHint: "プロセッコ (ビソル、カ・ディ・レオーネ)"),
                
                .init(region: "イタリア", targetElement: "ドルチェット", category: .wine, isProOnly: true, suggestionHint: "ドルチェット・ディ・ディアーノ・ダルバ"),
                .init(region: "イタリア", targetElement: "モンテプルチアーノ", category: .wine, isProOnly: true, suggestionHint: "モンテプルチアーノ・ダブルッツォ (カタルディ・マドンナ)"),
                .init(region: "イタリア", targetElement: "アリアニコ", category: .wine, isProOnly: true, suggestionHint: "タウラス (マストロヤーニ)"),
                .init(region: "イタリア", targetElement: "ネグロアマーロ", category: .wine, isProOnly: true, suggestionHint: "サリーチェ・サレンティーノ"),
                .init(region: "イタリア", targetElement: "プリミティーヴォ / ジンファンデル", category: .wine, isProOnly: true, suggestionHint: "プリミティーヴォ・ディ・マンデュリア"),
                .init(region: "イタリア", targetElement: "コルヴィーナ", category: .wine, isProOnly: true, suggestionHint: "アマローネ・ディ・ヴァルポリチェッラ (マァジ、アッレ格)"),
                .init(region: "イタリア", targetElement: "ネロ・ダーヴォラ", category: .wine, isProOnly: true, suggestionHint: "シチリアの赤ワイン (プラネタなど)"),
                .init(region: "イタリア", targetElement: "ネレッロ・マスカレーゼ", category: .wine, isProOnly: true, suggestionHint: "エトナ・ロッソ (テッレ・ネーレ)"),
                .init(region: "イタリア", targetElement: "フラッパート", category: .wine, isProOnly: true, suggestionHint: "チェラスオーロ・ディ・ヴィットリア"),
                .init(region: "イタリア", targetElement: "サグランティーノ", category: .wine, isProOnly: true, suggestionHint: "サグランティーノ・ディ・モンテファルコ (アルナルド・カプリライ)"),
                .init(region: "イタリア", targetElement: "ランブルスコ", category: .wine, isProOnly: true, suggestionHint: "ランブルスコ・ディ・セドレート (キアラリ)"),
                .init(region: "イタリア", targetElement: "シャルドネ", category: .wine, isProOnly: true, suggestionHint: "ガヴィア (ガヤ「バティアール」)"),
                .init(region: "イタリア", targetElement: "トレッビアーノ", category: .wine, isProOnly: true, suggestionHint: "トレッビアーノ・ダブルッツォ (エメディオ・ペペ)"),
                .init(region: "イタリア", targetElement: "ヴェルメンティーノ", category: .wine, isProOnly: true, suggestionHint: "ヴェルメンティーノ・ディ・サルデーニャ (カピキーラ)"),
                .init(region: "イタリア", targetElement: "コルテーゼ", category: .wine, isProOnly: true, suggestionHint: "ガヴィ (ラ・スコラーカ)"),
                .init(region: "イタリア", targetElement: "ガルガーネガ", category: .wine, isProOnly: true, suggestionHint: "ソアヴェ・クラッシコ (ピエロパン、インカマッティ)"),
                .init(region: "イタリア", targetElement: "ヴェルディッキオ", category: .wine, isProOnly: true, suggestionHint: "ヴェルディッキオ・デイ・カステッリ・ディ・イエージ (ブッチ)"),
                .init(region: "イタリア", targetElement: "ペコリーノ", category: .wine, isProOnly: true, suggestionHint: "アブルッツォやマルケのペコリーノ種白ワイン"),
                .init(region: "イタリア", targetElement: "パッセリーナ", category: .wine, isProOnly: true, suggestionHint: "中部イタリアの土着品種白ワイン"),
                .init(region: "イタリア", targetElement: "フィアーノ", category: .wine, isProOnly: true, suggestionHint: "フィアーノ・ディ・アヴェッリーノ (マストロベラルディーノ)"),
                .init(region: "イタリア", targetElement: "グレーコ", category: .wine, isProOnly: true, suggestionHint: "グレーコ・ディ・トッフォ"),
                .init(region: "イタリア", targetElement: "フリウラーノ", category: .wine, isProOnly: true, suggestionHint: "フリウリのコッリオ白ワイン (ヴィエ・ディ・ロマンス)"),

                // ==========================================
                // 3. スペイン & ポルトガル
                // ==========================================
                .init(region: "スペイン", targetElement: "テンプラニーリョ", category: .wine, isProOnly: false, suggestionHint: "リオハ・グラン・レセルバ (マルケス・デ・リスカル、ベガ・シシリア)"),
                .init(region: "スペイン", targetElement: "ガルナッチャ / グレナッシュ", category: .wine, isProOnly: false, suggestionHint: "プリラート (アルバロ・パラシオ「レルミタ」)"),
                .init(region: "スペイン", targetElement: "アルバリーニョ", category: .wine, isProOnly: false, suggestionHint: "リアス・バイシャス (マルデ・アモ、マルトックス)"),
                
                .init(region: "スペイン", targetElement: "モナストレル", category: .wine, isProOnly: true, suggestionHint: "フミージャの赤ワイン (カストロ・デス・ヒネス)"),
                .init(region: "スペイン", targetElement: "カリニャン", category: .wine, isProOnly: true, suggestionHint: "カタルーニャのカリニェナ (サムソ)"),
                .init(region: "スペイン", targetElement: "メンシア", category: .wine, isProOnly: true, suggestionHint: "ビエルソの赤ワイン (パラシオ・デ・フェラドス)"),
                .init(region: "スペイン", targetElement: "ヴェルデホ", category: .wine, isProOnly: true, suggestionHint: "ルエダの白ワイン (マルケス・デ・リスカル)"),
                .init(region: "スペイン", targetElement: "ゴデーリョ", category: .wine, isProOnly: true, suggestionHint: "バルデオーラスの高級白ワイン (ラファエル・パラシオ)"),
                .init(region: "スペイン", targetElement: "マカベо", category: .wine, isProOnly: true, suggestionHint: "カバ (スパークリングワイン) の主要ブレンド品種"),
                .init(region: "スペイン", targetElement: "チャレッロ", category: .wine, isProOnly: true, suggestionHint: "レコレタのカバ、またはペネデスのスティル白ワイン"),
                .init(region: "スペイン", targetElement: "パレリャーダ", category: .wine, isProOnly: true, suggestionHint: "フランソワやカバの気品あるブレンド白"),
                .init(region: "スペイン", targetElement: "パロミノ", category: .wine, isProOnly: true, suggestionHint: "シェリー酒 (フィノやマンサニージャの原料)"),
                .init(region: "ポルトガル", targetElement: "トウリガ・ナショナル", category: .wine, isProOnly: true, suggestionHint: "ポルトワイン、ドウロの赤ワイン (クインタ・ド・ヴァルード)"),
                .init(region: "ポルトガル", targetElement: "トウリガ・フランカ", category: .wine, isProOnly: true, suggestionHint: "ドウロの赤ワインおよびポート酒ブレンド"),
                .init(region: "ポルトガル", targetElement: "ティンタ・ロリス", category: .wine, isProOnly: true, suggestionHint: "アラゴン風テンプラニーリョのフルボディ赤"),
                .init(region: "ポルトガル", targetElement: "バガ", category: .wine, isProOnly: true, suggestionHint: "バラダの長期熟成赤ワイン (ルイス・ペレイラ)"),
                .init(region: "ポルトガル", targetElement: "アルバリーニョ", category: .wine, isProOnly: true, suggestionHint: "ヴィーニョ・ヴェルデの高品質アルバリーニョ (ソアレイロ)"),
                .init(region: "ポルトガル", targetElement: "ロウレイロ", category: .wine, isProOnly: true, suggestionHint: "アロマティックなヴィーニョ・ヴェルデ白"),
                .init(region: "ポルトガル", targetElement: "アリント", category: .wine, isProOnly: true, suggestionHint: "ブブレスやテージョのミネラル豊かな白ワイン"),
                .init(region: "ポルトガル", targetElement: "フェルナン・ピレス", category: .wine, isProOnly: true, suggestionHint: "フェト・ダ・グラサなどの華やかな白ワイン"),

                // ==========================================
                // 4. ドイツ & オーストリア & スイス & ハンガリー
                // ==========================================
                .init(region: "ドイツ", targetElement: "リースリング", category: .wine, isProOnly: false, suggestionHint: "ラインガウ / モーゼル・リースリング (エゴン・ミュラー、J.J.プリュム)"),
                .init(region: "ドイツ", targetElement: "シュペートブルグンダー (ピノ・ノワール)", category: .wine, isProOnly: false, suggestionHint: "バーデンやファルツのシュペートブルグンダー (ベルンハルト・フーバー)"),
                
                .init(region: "ドイツ", targetElement: "ヴァイスブルグンダー (ピノ・ブラン)", category: .wine, isProOnly: true, suggestionHint: "ピーロートや各地の高品質ピノ・ブラン"),
                .init(region: "ドイツ", targetElement: "グラウブルグンダー (ピノ・グリ)", category: .wine, isProOnly: true, suggestionHint: "バーデンのリッチなグラウブルグンダー"),
                .init(region: "ドイツ", targetElement: "シルヴァーナー", category: .wine, isProOnly: true, suggestionHint: "フランケン地方のワイン (フランケン・ボトル)"),
                .init(region: "ドイツ", targetElement: "ミュラー・トゥルガウ", category: .wine, isProOnly: true, suggestionHint: "フランケンやバーデンの日常向きフルーティー白"),
                .init(region: "ドイツ", targetElement: "ドルンフェルダー", category: .wine, isProOnly: true, suggestionHint: "濃い色合いを持つドイツのフルーティーな赤"),
                .init(region: "オーストリア", targetElement: "グリューナー・フェルトリーナー", category: .wine, isProOnly: true, suggestionHint: "ヴァッハウのグリューナー・フェルトリーナー (ニコライホーフ)"),
                .init(region: "オーストリア", targetElement: "ブラウフランキッシュ", category: .wine, isProOnly: true, suggestionHint: "ブルゲンランドの赤ワイン (モーザーなど)"),
                .init(region: "オーストリア", targetElement: "ツヴァイゲルト", category: .wine, isProOnly: true, suggestionHint: "オーストリアで最も栽培される赤ワイン品種"),
                .init(region: "オーストリア", targetElement: "サン・ローラン", category: .wine, isProOnly: true, suggestionHint: "ピノ・ノワールに似たスパイシーな赤ワイン"),
                .init(region: "スイス", targetElement: "シャスラ", category: .wine, isProOnly: true, suggestionHint: "ヴォー州、ローザンヌやAIGLEのシャスラ"),
                .init(region: "スイス", targetElement: "ピノ・ノワール", category: .wine, isProOnly: true, suggestionHint: "グラウビュンデン州の高級ピノ・ノワール (ガッタリ)"),
                .init(region: "ハンガリー", targetElement: "フルミント", category: .wine, isProOnly: true, suggestionHint: "トカイ・アスー (貴腐ワイン、オレムスなど)"),
                .init(region: "ハンガリー", targetElement: "ハールシュレヴェリュー", category: .wine, isProOnly: true, suggestionHint: "トカイの伝統的な貴腐ブレンド用白品種"),

                // ==========================================
                // 5. アメリカ & カナダ & 南米
                // ==========================================
                .init(region: "アメリカ", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: false, suggestionHint: "ナパ・ヴァレー (スタッグス・リープ、ケイマス、スクリーミング・イーグル)"),
                .init(region: "アメリカ", targetElement: "シャルドネ", category: .wine, isProOnly: false, suggestionHint: "カリフォルニア (キスラー、オーベール、ロシアン・リヴァー・ヴァレー)"),
                .init(region: "アメリカ", targetElement: "ピノ・ノワール", category: .wine, isProOnly: false, suggestionHint: "オレゴン / ソノマ (ウィラメット・ヴァレー、コスタ・ブラウン)"),
                .init(region: "アメリカ", targetElement: "プリミティーヴォ / ジンファンデル", category: .wine, isProOnly: false, suggestionHint: "ソノマやナパの古木ジンファンデル (リッジ・ヴィンヤーズ)"),
                .init(region: "アルゼンチン", targetElement: "マルベック", category: .wine, isProOnly: false, suggestionHint: "メンドーサのマルベック (カテナ・サパータ)"),
                .init(region: "チリ", targetElement: "カルメネール", category: .wine, isProOnly: false, suggestionHint: "コルチャグア・ヴァレー (モンテス・パープル・エンジェル)"),
                .init(region: "チリ", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: false, suggestionHint: "レイダやカサブランカ・ヴァレーの爽快な白 (エラスリス)"),
                
                .init(region: "アメリカ", targetElement: "メルロ", category: .wine, isProOnly: true, suggestionHint: "ナパのメルロ (ダックホーン)"),
                .init(region: "アメリカ", targetElement: "シラー / シラーズ", category: .wine, isProOnly: true, suggestionHint: "シーカーやシラーによるカリフォルニアのパワフルな赤"),
                .init(region: "アメリカ", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: true, suggestionHint: "ナパの樽熟成ソーヴィニヨン・ブラン (モンダヴィ)"),
                .init(region: "チリ", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: true, suggestionHint: "アルマヴィヴァ、ドン・メルチョー"),
                .init(region: "チリ", targetElement: "パイス", category: .wine, isProOnly: true, suggestionHint: "チリ最古のブドウ樹から造られるビオワイン (トーレスなど)"),
                .init(region: "アルゼンチン", targetElement: "トロンテス", category: .wine, isProOnly: true, suggestionHint: "サルタ州カフェジャテの華やかな白ワイン (コレス・デ・カファジャテ)"),
                .init(region: "アルゼンチン", targetElement: "ボナルダ", category: .wine, isProOnly: true, suggestionHint: "メンドーサのジューシーな赤ワイン"),
                .init(region: "カナダ", targetElement: "リースリング", category: .wine, isProOnly: true, suggestionHint: "ナイアガラ半島のドライ〜アイスワイン (ストロ・アイランド)"),
                .init(region: "カナダ", targetElement: "ヴィダル", category: .wine, isProOnly: true, suggestionHint: "オンタリオ州のアイスワイン (ピーター・リーマン等)"),
                .init(region: "ウルグアイ", targetElement: "タナ", category: .wine, isProOnly: true, suggestionHint: "ウルグアイの国酒的タナ (ボデガ・ガルソン)"),

                // ==========================================
                // 6. オーストラリア & ニュージーランド & 南アフリカ
                // ==========================================
                .init(region: "オーストラリア", targetElement: "シラー / シラーズ", category: .wine, isProOnly: false, suggestionHint: "バロッサ・ヴァレー (ペンフォールズ「グランジ」、トルブレック)"),
                .init(region: "オーストラリア", targetElement: "シャルドネ", category: .wine, isProOnly: false, suggestionHint: "ヤラ・ヴァレー / アデレード・ヒルズ (ギガ・バワーズ、ペンフォールズ)"),
                .init(region: "ニュージーランド", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: false, suggestionHint: "マールボロ (クラウディ・ベイ、オイスター・ベイ)"),
                .init(region: "ニュージーランド", targetElement: "ピノ・ノワール", category: .wine, isProOnly: false, suggestionHint: "セントラル・オタゴ (フェルトン・ロード、アプロ・ロード)"),
                
                .init(region: "オーストラリア", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: true, suggestionHint: "クーンワラ (ルーウィン・エステート、ペンフォールズ「707」)"),
                .init(region: "オーストラリア", targetElement: "セミヨン", category: .wine, isProOnly: true, suggestionHint: "ハンター・ヴァレーの長期熟成セミヨン (ティレルズ)"),
                .init(region: "オーストラリア", targetElement: "リースリング", category: .wine, isProOnly: true, suggestionHint: "クレア・ヴァレーやイーデン・ヴァレーの辛口リースリング (ピーター・レーマン)"),
                .init(region: "ニュージーランド", targetElement: "シャルドネ", category: .wine, isProOnly: true, suggestionHint: "ホークス・ベイやマールボロの上質シャルドネ (テ・マタ)"),
                .init(region: "南アフリカ", targetElement: "シュナン・ブラン", category: .wine, isProOnly: true, suggestionHint: "スワートランド / ステレンボッシュ (バッド・ボーイ、サディ・ファミリー)"),
                .init(region: "南アフリカ", targetElement: "ピノタージュ", category: .wine, isProOnly: true, suggestionHint: "カノンコップなどの固有品種赤ワイン"),
                .init(region: "南アフリカ", targetElement: "シラー / シラーズ", category: .wine, isProOnly: true, suggestionHint: "シラーによるスパイシーで美しい赤 (ブーケンハーツーフロート)"),
                .init(region: "南アフリカ", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: true, suggestionHint: "ステレンボッシュのボルドーブレンド (ルイ・ルートル)"),

                // ==========================================
                // 7. 日本 & 伝統・新興生産国
                // ==========================================
                .init(region: "日本", targetElement: "甲州", category: .wine, isProOnly: false, suggestionHint: "勝沼醸造「アルガブランカ」、中央葡萄酒「グレイス甲州」"),
                .init(region: "日本", targetElement: "マスカット・ベーリーA", category: .wine, isProOnly: false, suggestionHint: "マルエス、シャトー勝沼、シャトー・メルシャン「穂坂」"),
                
                .init(region: "日本", targetElement: "メルロ", category: .wine, isProOnly: true, suggestionHint: "シャトー・メルシャン「桔梗ヶ原メルロ」、ドメーヌ・ミエ・イケノ"),
                .init(region: "日本", targetElement: "シャルドネ", category: .wine, isProOnly: true, suggestionHint: "ココ・ファーム・ワイナリー、タケダワイナリー"),
                .init(region: "日本", targetElement: "ケルナー", category: .wine, isProOnly: true, suggestionHint: "北海道余市・千歳ワイナリー、北海道ワイン (おたる特選)"),
                .init(region: "日本", targetElement: "ツヴァイゲルト", category: .wine, isProOnly: true, suggestionHint: "北海道の冷涼な気候で育つ力強い赤 (宝水ワイナリー)"),
                .init(region: "日本", targetElement: "ピノ・ノワール", category: .wine, isProOnly: true, suggestionHint: "ドメーヌ・タカヒコ (ヨイチ・ノボリ「ナナサイ」)"),
                .init(region: "日本", targetElement: "ソーヴィニヨン・ブラン", category: .wine, isProOnly: true, suggestionHint: "各地の新進ワイナリーによるハーブ香豊かな白"),
                .init(region: "日本", targetElement: "カベルネ・ソーヴィニヨン", category: .wine, isProOnly: true, suggestionHint: "長野や山梨の本格的ボルドー系赤ワイン"),
                .init(region: "日本", targetElement: "山葡萄", category: .wine, isProOnly: true, suggestionHint: "岩手・山形のヤマ・ブドウ交配種の野性味あるワイン"),
                .init(region: "日本", targetElement: "ナイアガラ", category: .wine, isProOnly: true, suggestionHint: "甘く芳醇な香りの日本固有(アメリカ系)白ワイン"),
                .init(region: "ギリシャ", targetElement: "アシルティコ", category: .wine, isProOnly: true, suggestionHint: "サントリーニ島のミネラル爆弾的白ワイン (ガイア)"),
                .init(region: "ギリシャ", targetElement: "クシノマヴロ", category: .wine, isProOnly: true, suggestionHint: "ナウサの長熟な赤ワイン (タイナロス)"),
                .init(region: "ギリシャ", targetElement: "アギオルギティコ", category: .wine, isProOnly: true, suggestionHint: "ネメアのフルーティーな赤ワイン (スクーラス)"),
                .init(region: "ジョージア", targetElement: "ルカツィテリ", category: .wine, isProOnly: true, suggestionHint: "クヴェヴリ (土壺) で醸す伝統的オレンジワイン"),
                .init(region: "ジョージア", targetElement: "サペラヴィ", category: .wine, isProOnly: true, suggestionHint: "果肉まで赤い、ジョージアの代表的黒ブドウ品種"),
                .init(region: "レバノン", targetElement: "サンソー", category: .wine, isProOnly: true, suggestionHint: "ベカ・バレーの歴史的ワイナリー (シャトー・ミュージアム)"),
                .init(region: "イギリス", targetElement: "シャルドネ", category: .wine, isProOnly: true, suggestionHint: "ナイティンバーなどのスパークリング用シャルドネ"),
                .init(region: "イギリス", targetElement: "ピノ・ノワール", category: .wine, isProOnly: true, suggestionHint: "ハンプシャーやサセックスのスパークリング・赤ワイン")
            ]
            
        case .sake:
            return [
                // 1. 北海道
                .init(region: "北海道", targetElement: "彗星", category: .sake, isProOnly: false, suggestionHint: "国稀、北の誉、男山 の彗星仕込み"),
                .init(region: "北海道", targetElement: "吟風", category: .sake, isProOnly: true, suggestionHint: "千歳鶴、国士無双 の吟風純米"),
                .init(region: "北海道", targetElement: "きたしずく", category: .sake, isProOnly: true, suggestionHint: "上川大雪、二世古 のきたしずく"),
                // 2. 青森県
                .init(region: "青森県", targetElement: "華吹雪", category: .sake, isProOnly: false, suggestionHint: "陸奥八仙、田酒 の華吹雪仕込み"),
                .init(region: "青森県", targetElement: "華想い", category: .sake, isProOnly: true, suggestionHint: "田酒 純米大吟醸 華想い"),
                .init(region: "青森県", targetElement: "豊盃", category: .sake, isProOnly: true, suggestionHint: "豊盃 (三浦酒造の看板銘柄)"),
                .init(region: "青森県", targetElement: "吟烏帽子", category: .sake, isProOnly: true, suggestionHint: "青森県の新しい酒米を用いた地酒"),
                .init(region: "青森県", targetElement: "古城錦", category: .sake, isProOnly: true, suggestionHint: "幻の酒米「古城錦」を使った青森の限定酒"),
                // 3. 岩手県
                .init(region: "岩手県", targetElement: "吟ぎんが", category: .sake, isProOnly: false, suggestionHint: "赤武 (AKABU)、南部美人 の吟ぎんが"),
                .init(region: "岩手県", targetElement: "ぎんおとめ", category: .sake, isProOnly: true, suggestionHint: "浜千鳥、あさ開 のぎんおとめ"),
                .init(region: "岩手県", targetElement: "結の香", category: .sake, isProOnly: true, suggestionHint: "銘酒 鷲の尾、南部美人 の最高峰純米大吟醸"),
                .init(region: "岩手県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "廣喜、月の輪 の美山錦"),
                // 4. 宮城県
                .init(region: "宮城県", targetElement: "蔵の華", category: .sake, isProOnly: false, suggestionHint: "伯楽星 (新澤醸造店)、宮寒梅 の蔵の華"),
                .init(region: "宮城県", targetElement: "吟のいろは", category: .sake, isProOnly: true, suggestionHint: "宮城県が開発した新しい酒米「吟のいろは」の純米大吟醸"),
                .init(region: "宮城県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "墨廼江、黄金澤 の美山錦"),
                .init(region: "宮城県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "浦霞、日高見 の山田錦"),
                .init(region: "宮城県", targetElement: "ササニシキ", category: .sake, isProOnly: true, suggestionHint: "黄金澤 山廃純米 (食用米ササニシキ使用)"),
                // 5. 秋田県
                .init(region: "秋田県", targetElement: "秋田酒こまち", category: .sake, isProOnly: false, suggestionHint: "新政 (No.6等)、一白水成 の秋田酒こまち"),
                .init(region: "秋田県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "飛良泉、春霞 の美山錦"),
                .init(region: "秋田県", targetElement: "美郷錦", category: .sake, isProOnly: true, suggestionHint: "春霞、山本 の美郷錦"),
                .init(region: "秋田県", targetElement: "百田", category: .sake, isProOnly: true, suggestionHint: "新政の「Colors」シリーズ (木邨酒造などでも使用)"),
                .init(region: "秋田県", targetElement: "改良信交", category: .sake, isProOnly: true, suggestionHint: "阿櫻、ゆきの美人 の改良信交"),
                .init(region: "秋田県", targetElement: "一穂積", category: .sake, isProOnly: true, suggestionHint: "秋田県の次世代酒米「一穂積」を使った純米酒"),
                .init(region: "秋田県", targetElement: "星あかり", category: .sake, isProOnly: true, suggestionHint: "秋田県の可憐な酒米「星あかり」のお酒"),
                .init(region: "秋田県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "天の戸、太平山 の山田錦仕込み"),
                // 6. 山形県
                .init(region: "山形県", targetElement: "出羽燦々", category: .sake, isProOnly: false, suggestionHint: "出羽桜、東光 の出羽燦々"),
                .init(region: "山形県", targetElement: "出羽の里", category: .sake, isProOnly: true, suggestionHint: "栄光冨士、錦之江 の出羽の里"),
                .init(region: "山形県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "くどき上手、上喜元 の美山錦"),
                .init(region: "山形県", targetElement: "雪女神", category: .sake, isProOnly: true, suggestionHint: "山形県が誇る大吟醸向けの最高峰酒米「雪女神」"),
                .init(region: "山形県", targetElement: "酒未来", category: .sake, isProOnly: true, suggestionHint: "十四代 (高木酒造) 開発の希少な酒米「酒未来」"),
                .init(region: "山形県", targetElement: "山酒4号", category: .sake, isProOnly: true, suggestionHint: "別名「羽州誉」。十四代や東光などで使用"),
                .init(region: "山形県", targetElement: "改良信交", category: .sake, isProOnly: true, suggestionHint: "山形の伝統的酒米を用いた味わい深い純米酒"),
                .init(region: "山形県", targetElement: "羽州誉", category: .sake, isProOnly: true, suggestionHint: "芳醇でキレのある山形のプレミアム酒"),
                .init(region: "山形県", targetElement: "龍の落とし子", category: .sake, isProOnly: true, suggestionHint: "十四代蔵元の独自開発米「龍の落とし子」"),
                .init(region: "山形県", targetElement: "亀粋", category: .sake, isProOnly: true, suggestionHint: "楯野川 などの亀粋仕込み"),
                .init(region: "山形県", targetElement: "豊国", category: .sake, isProOnly: true, suggestionHint: "山形の地酒蔵が醸す豊国仕込みの酒"),
                .init(region: "山形県", targetElement: "愛山", category: .sake, isProOnly: true, suggestionHint: "栄光冨士、東光などの愛山純米大吟醸"),
                // 7. 福島県
                .init(region: "福島県", targetElement: "夢の香", category: .sake, isProOnly: false, suggestionHint: "飛露喜、写楽 の夢の香仕込み"),
                .init(region: "福島県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "廣戸川、奥の松 の五百万石"),
                .init(region: "福島県", targetElement: "福乃香", category: .sake, isProOnly: true, suggestionHint: "福島県の新しいエース酒米「福乃香」"),
                .init(region: "福島県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "飛露喜、自然郷 の山田錦"),
                .init(region: "福島県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "会津中将、国権 の美山錦"),
                // 8. 茨城県
                .init(region: "茨城県", targetElement: "ひたち錦", category: .sake, isProOnly: false, suggestionHint: "来福、浦里 のひたち錦"),
                .init(region: "茨城県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "一品、武勇 の五百万石"),
                .init(region: "茨城県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "郷乃誉 (花薫光) の美山錦"),
                .init(region: "茨城県", targetElement: "渡船", category: .sake, isProOnly: true, suggestionHint: "来福 (副シグネチャーの幻の酒米・渡船)"),
                .init(region: "茨城県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "来福 超辛口山田錦"),
                // 9. 栃木県
                .init(region: "栃木県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "鳳凰美田 (小林酒造)、仙禽 の山田錦"),
                .init(region: "栃木県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "燦爛、東力士 の五百万石"),
                .init(region: "栃木県", targetElement: "夢ささら", category: .sake, isProOnly: true, suggestionHint: "鳳凰美田、若駒 の夢ささら"),
                .init(region: "栃木県", targetElement: "ひとごこち", category: .sake, isProOnly: true, suggestionHint: "惣誉、四季桜 のひとごこち"),
                .init(region: "栃木県", targetElement: "とちぎ酒14", category: .sake, isProOnly: true, suggestionHint: "栃木県オリジナル酵母と酒米による県産酒"),
                // 10. 群馬県
                .init(region: "群馬県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "聖 (土田酒造)、流輝 の五百万石"),
                .init(region: "群馬県", targetElement: "若水", category: .sake, isProOnly: true, suggestionHint: "尾瀬の雪どけ、群馬泉 の若水"),
                .init(region: "群馬県", targetElement: "改良信交", category: .sake, isProOnly: true, suggestionHint: "土田、町田酒造 の改良信交"),
                .init(region: "群馬県", targetElement: "舞風", category: .sake, isProOnly: true, suggestionHint: "群馬県オリジナル酒米「舞風」の純米吟醸"),
                .init(region: "群馬県", targetElement: "山酒4号", category: .sake, isProOnly: true, suggestionHint: "浅間山 の山酒4号仕込み"),
                .init(region: "群馬県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "聖、貴娘 の山田錦"),
                // 11. 埼玉県
                .init(region: "埼玉県", targetElement: "さけ武蔵", category: .sake, isProOnly: false, suggestionHint: "神亀、秩父錦、晴雲 のさけ武蔵"),
                .init(region: "埼玉県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "花陽浴 (南陽醸造)、彩來 の山田錦"),
                .init(region: "埼玉県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "秩父源流水、鏡山 の五百万石"),
                // 12. 千葉県
                .init(region: "千葉県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "寿萬亀、聖泉 の五百万石"),
                .init(region: "千葉県", targetElement: "総の舞", category: .sake, isProOnly: true, suggestionHint: "甲子 (飯沼本家)、鳴海 の総の舞"),
                .init(region: "千葉県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "木戸泉、不動 の山田錦"),
                // 13. 東京都
                .init(region: "東京都", targetElement: "一般米（食用米）", category: .sake, isProOnly: false, suggestionHint: "澤乃井 (小澤酒造：多摩の清酒)"),
                // 14. 神奈川県
                .init(region: "神奈川県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "いずみ橋 (泉橋酒造)、残草蓬莱 の山田錦"),
                .init(region: "神奈川県", targetElement: "楽風舞", category: .sake, isProOnly: true, suggestionHint: "いずみ橋酒造の恵シリーズ (楽風舞)"),
                .init(region: "神奈川県", targetElement: "若水", category: .sake, isProOnly: true, suggestionHint: "神奈川の隠れた名酒の若水仕込み"),
                .init(region: "神奈川県", targetElement: "雄町", category: .sake, isProOnly: true, suggestionHint: "いずみ橋 雄町純米吟醸"),
                // 15. 新潟県
                .init(region: "新潟県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "越乃寒梅、久保田 (千寿・百寿)、八海山"),
                .init(region: "新潟県", targetElement: "越淡麗", category: .sake, isProOnly: true, suggestionHint: "久保田 (萬寿)、北雪、真野鶴 の越淡麗"),
                .init(region: "新潟県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "麒麟山、朝日山 の山田錦大吟醸"),
                .init(region: "新潟県", targetElement: "たかね錦", category: .sake, isProOnly: true, suggestionHint: "荷札酒 (加茂錦) 等のたかね錦"),
                .init(region: "新潟県", targetElement: "一本〆", category: .sake, isProOnly: true, suggestionHint: "根知男山 (渡辺酒造店) の一本〆"),
                .init(region: "新潟県", targetElement: "菊水", category: .sake, isProOnly: true, suggestionHint: "菊水酒造の代表的辛口酒"),
                .init(region: "新潟県", targetElement: "越神楽", category: .sake, isProOnly: true, suggestionHint: "新潟県オリジナルの高品質酒米"),
                .init(region: "新潟県", targetElement: "楽風舞", category: .sake, isProOnly: true, suggestionHint: "新潟の若手蔵が挑戦する楽風舞のお酒"),
                // 16. 富山県
                .init(region: "富山県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "勝駒 (清都酒造場)、若鶴 の五百万石"),
                .init(region: "富山県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "羽根屋 (富美菊酒造) の山田錦"),
                .init(region: "富山県", targetElement: "雄山錦", category: .sake, isProOnly: true, suggestionHint: "立山、幼竹 の雄山錦"),
                .init(region: "富山県", targetElement: "富の香", category: .sake, isProOnly: true, suggestionHint: "富山県オリジナルの酒米「富の香」"),
                .init(region: "富山県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "満寿泉 の美山錦"),
                // 17. 石川県
                .init(region: "石川県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "手取川 (吉田酒造店)、菊姫 の五百万石"),
                .init(region: "石川県", targetElement: "石川門", category: .sake, isProOnly: true, suggestionHint: "加賀鳶、獅子の里 の石川門"),
                .init(region: "石川県", targetElement: "石川酒68号", category: .sake, isProOnly: true, suggestionHint: "石川県の希少な新酒米を使った地酒"),
                .init(region: "石川県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "百万石乃白、車多酒造 (天狗舞)"),
                // 18. 福井県
                .init(region: "福井県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "黒龍 (黒龍酒造)、白龍 の五百万石"),
                .init(region: "福井県", targetElement: "さかほまれ", category: .sake, isProOnly: true, suggestionHint: "黒龍酒造と福井県が開発した最高峰酒米「さかほまれ」"),
                .init(region: "福井県", targetElement: "越の雫", category: .sake, isProOnly: true, suggestionHint: "常山、一本義 の越の雫"),
                .init(region: "福井県", targetElement: "九頭竜", category: .sake, isProOnly: true, suggestionHint: "黒龍酒造の「九頭竜」シリーズ"),
                .init(region: "福井県", targetElement: "神力", category: .sake, isProOnly: true, suggestionHint: "早瀬浦 の神力仕込み"),
                .init(region: "福井県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "黒龍 大吟醸 龍 (山田錦)"),
                // 19. 山梨県
                .init(region: "山梨県", targetElement: "ひとごこち", category: .sake, isProOnly: false, suggestionHint: "七賢 (山梨銘醸) のひとごこち"),
                .init(region: "山梨県", targetElement: "夢山水", category: .sake, isProOnly: true, suggestionHint: "旦 (笹一酒造) の夢山水"),
                .init(region: "山梨県", targetElement: "玉栄", category: .sake, isProOnly: true, suggestionHint: "山梨の地酒蔵が醸す玉栄純米"),
                .init(region: "山梨県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "七賢 純米大吟醸 絹の味"),
                .init(region: "山梨県", targetElement: "美山錦", category: .sake, isProOnly: true, suggestionHint: "春うらら等の山梨の美山錦酒"),
                // 20. 長野県
                .init(region: "長野県", targetElement: "美山錦", category: .sake, isProOnly: false, suggestionHint: "真澄 (宮坂醸造)、大信州 の美山錦"),
                .init(region: "長野県", targetElement: "ひとごこち", category: .sake, isProOnly: false, suggestionHint: "夜明け前 (小野酒造店)、川中島幻舞"),
                .init(region: "長野県", targetElement: "山恵錦", category: .sake, isProOnly: true, suggestionHint: "信州の新しいオリジナル酒米「山恵錦」"),
                .init(region: "長野県", targetElement: "金紋錦", category: .sake, isProOnly: true, suggestionHint: "依田川、大信州、産土などの金紋錦仕込み"),
                .init(region: "長野県", targetElement: "しらかば錦", category: .sake, isProOnly: true, suggestionHint: "長野県の稀少な酒米を用いた限定酒"),
                .init(region: "長野県", targetElement: "たかね錦", category: .sake, isProOnly: true, suggestionHint: "豊香、スキー正宗 のたかね錦"),
                .init(region: "長野県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "澤の花、黒澤 の山田錦"),
                // 21. 岐阜県
                .init(region: "岐阜県", targetElement: "ひだほまれ", category: .sake, isProOnly: false, suggestionHint: "小左衛門、三千盛、百春 のひだほまれ"),
                .init(region: "岐阜県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "達磨正宗、房島屋 の五百万石"),
                // 22. 静岡県
                .init(region: "静岡県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "磯自慢 (磯自慢酒造) の山田錦特等米"),
                .init(region: "静岡県", targetElement: "令和誉富士", category: .sake, isProOnly: true, suggestionHint: "富士高砂、英君 の令和誉富士"),
                .init(region: "静岡県", targetElement: "誉富士", category: .sake, isProOnly: true, suggestionHint: "白隠正宗、初亀 の誉富士"),
                // 23. 愛知県
                .init(region: "愛知県", targetElement: "夢山水", category: .sake, isProOnly: false, suggestionHint: "蓬莱泉 (関谷醸造「空」)、九重美碧"),
                .init(region: "愛知県", targetElement: "若水", category: .sake, isProOnly: true, suggestionHint: "長珍、醸し人九平次 (一部スペック) の若水"),
                .init(region: "愛知県", targetElement: "夢吟香", category: .sake, isProOnly: true, suggestionHint: "義侠、想天坊 の夢吟香"),
                .init(region: "愛知県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "醸し人九平次 (萬乗醸造) の山田錦"),
                // 24. 三重県
                .init(region: "三重県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "作 (清水清三郎商店「ZASSO」)、而今 (木屋正酒造)"),
                .init(region: "三重県", targetElement: "神の穂", category: .sake, isProOnly: true, suggestionHint: "半蔵、瀧自慢 の神の穂"),
                .init(region: "三重県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "而今 五百万石無濾過生"),
                .init(region: "三重県", targetElement: "伊勢錦", category: .sake, isProOnly: true, suggestionHint: "鈴鹿川、るみ子の酒の幻の伊勢錦仕込み"),
                // 25. 滋賀県
                .init(region: "滋賀県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "松の司 (宇都宮酒造)、笑四季 の山田錦"),
                .init(region: "滋賀県", targetElement: "玉栄", category: .sake, isProOnly: true, suggestionHint: "浪乃音、七本槍 の玉栄"),
                .init(region: "滋賀県", targetElement: "吟吹雪", category: .sake, isProOnly: true, suggestionHint: "滋賀県が誇る大吟醸用酒米「吟吹雪」"),
                .init(region: "滋賀県", targetElement: "滋賀渡船6号", category: .sake, isProOnly: true, suggestionHint: "冨田酒造「七本槍 渡船6号」"),
                // 26. 京都府
                .init(region: "京都府", targetElement: "祝", category: .sake, isProOnly: false, suggestionHint: "英勲、玉川、澤屋まつもと の京都産酒米「祝」"),
                .init(region: "京都府", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "蒼空、月桂冠 の五百万石仕込み"),
                .init(region: "京都府", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "招徳、城陽 の山田錦"),
                // 27. 大阪府
                .init(region: "大阪府", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "秋鹿 (秋鹿酒造：能勢の自社田山田錦)"),
                .init(region: "大阪府", targetElement: "雄町", category: .sake, isProOnly: true, suggestionHint: "秋鹿 雄町純米吟醸"),
                // 28. 兵庫県
                .init(region: "兵庫県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "播州山田錦を使用した全国の最高峰銘柄 (獺祭、黒龍など)"),
                .init(region: "兵庫県", targetElement: "愛山", category: .sake, isProOnly: false, suggestionHint: "十四代、飛露喜、花陽浴 などの超プレミアム愛山"),
                .init(region: "兵庫県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "兵庫県産五百万石を用いたすっきり辛口酒"),
                .init(region: "兵庫県", targetElement: "白鶴錦", category: .sake, isProOnly: true, suggestionHint: "白鶴酒造開発の姉妹米 (高木酒造「十四代 白鶴錦」など)"),
                .init(region: "兵庫県", targetElement: "兵庫北錦", category: .sake, isProOnly: true, suggestionHint: "播州一献、香住鶴 の兵庫北錦"),
                .init(region: "兵庫県", targetElement: "山田穂", category: .sake, isProOnly: true, suggestionHint: "山田錦の母にあたる希少米「山田穂」の純米大吟醸"),
                .init(region: "兵庫県", targetElement: "兵庫錦", category: .sake, isProOnly: true, suggestionHint: "兵庫県が育成した新品種酒米「兵庫錦」"),
                .init(region: "兵庫県", targetElement: "渡船2号", category: .sake, isProOnly: true, suggestionHint: "幻の酒米「渡船2号」を復活させた限定純米酒"),
                .init(region: "兵庫県", targetElement: "兵庫恋錦", category: .sake, isProOnly: true, suggestionHint: "兵庫の自然で育まれた恋錦仕込み"),
                .init(region: "兵庫県", targetElement: "Hyogo Sake85", category: .sake, isProOnly: true, suggestionHint: "兵庫県オリジナルの次世代酒米「Hyogo Sake 85」"),
                .init(region: "兵庫県", targetElement: "但馬強力", category: .sake, isProOnly: true, suggestionHint: "香住鶴などの但馬地方の力強い酒米"),
                .init(region: "兵庫県", targetElement: "神力", category: .sake, isProOnly: true, suggestionHint: "伝統の古品種「神力」を用いた味わい深い酒"),
                // 29. 奈良県
                .init(region: "奈良県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "風の森 (油長酒造)、みむろ杉 (今西酒造)"),
                .init(region: "奈良県", targetElement: "露葉風", category: .sake, isProOnly: true, suggestionHint: "奈良県オリジナルの酒米「露葉風」 (風の森など)"),
                .init(region: "奈良県", targetElement: "なら酒1504", category: .sake, isProOnly: true, suggestionHint: "奈良の新しい県産米を用いた日本酒"),
                // 30. 和歌山県
                .init(region: "和歌山県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "紀土 (平和酒造)、南方 の山田錦"),
                .init(region: "和歌山県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "紀土 五百万石純米吟醸"),
                .init(region: "和歌山県", targetElement: "玉栄", category: .sake, isProOnly: true, suggestionHint: "和歌山の地酒蔵が手掛ける玉栄仕込み"),
                // 31. 鳥取県
                .init(region: "鳥取県", targetElement: "強力", category: .sake, isProOnly: false, suggestionHint: "鷹勇 (大谷酒造)、日おろし、諏訪泉 の強力"),
                .init(region: "鳥取県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "稲田姫、弁慶の泣き所 等の山田錦"),
                .init(region: "鳥取県", targetElement: "五百万石", category: .sake, isProOnly: true, suggestionHint: "千代むすび の五百万石"),
                .init(region: "鳥取県", targetElement: "玉栄", category: .sake, isProOnly: true, suggestionHint: "日置桜 の玉栄"),
                // 32. 島根県
                .init(region: "島根県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "月山、李白 の五百万石"),
                .init(region: "島根県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "王祿、隠岐誉 の山田錦"),
                .init(region: "島根県", targetElement: "佐香錦", category: .sake, isProOnly: true, suggestionHint: "日本酒発祥の地・佐香にちなんだ酒米「佐香錦」"),
                .init(region: "島根県", targetElement: "改良雄町", category: .sake, isProOnly: true, suggestionHint: "島根独自の改良雄町を用いた濃厚な純米酒"),
                .init(region: "島根県", targetElement: "縁の舞", category: .sake, isProOnly: true, suggestionHint: "島根の縁結びを彩る酒米「縁の舞」"),
                .init(region: "島根県", targetElement: "改良八反流", category: .sake, isProOnly: true, suggestionHint: "旨味のある島根の地酒の定番酒米"),
                .init(region: "島根県", targetElement: "神の舞", category: .sake, isProOnly: true, suggestionHint: "神話の国・島根のオリジナル酒米"),
                // 33. 岡山県
                .init(region: "岡山県", targetElement: "雄町", category: .sake, isProOnly: false, suggestionHint: "赤磐雄町、御前酒、竹林、十八盛 などの雄町仕込み"),
                .init(region: "岡山県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "備前雄町と並ぶ岡山の山田錦"),
                .init(region: "岡山県", targetElement: "赤磐雄町", category: .sake, isProOnly: true, suggestionHint: "雄町の最高峰産地「赤磐」の特撰銘柄"),
                .init(region: "岡山県", targetElement: "吟のさと", category: .sake, isProOnly: true, suggestionHint: "岡山県生まれの短稈酒米「吟のさと」"),
                // 34. 広島県
                .init(region: "広島県", targetElement: "八反錦1号", category: .sake, isProOnly: false, suggestionHint: "宝剣、雨後の月、賀茂鶴 の八反錦"),
                .init(region: "広島県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "酔心、富久長 の山田錦"),
                .init(region: "広島県", targetElement: "八反35号", category: .sake, isProOnly: true, suggestionHint: "天寶一、竹鶴 の八反35号"),
                .init(region: "広島県", targetElement: "千本錦", category: .sake, isProOnly: true, suggestionHint: "雨後の月、富久長 の千本錦"),
                .init(region: "広島県", targetElement: "萌えいぶき", category: .sake, isProOnly: true, suggestionHint: "広島のユニークな新酒米のお酒"),
                .init(region: "広島県", targetElement: "改良雄町", category: .sake, isProOnly: true, suggestionHint: "広島の蔵元が好む改良雄町のふくよかな酒"),
                .init(region: "広島県", targetElement: "こいおまち", category: .sake, isProOnly: true, suggestionHint: "広島カープ名にちなんだ酒米「こいおまち」"),
                // 35. 山口県
                .init(region: "山口県", targetElement: "西都の雫", category: .sake, isProOnly: false, suggestionHint: "東洋美人 (澄川酒造場)、五橋 の西都の雫"),
                .init(region: "山口県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "獺祭 (旭酒造：磨き二割三分など) の山田錦"),
                .init(region: "山口県", targetElement: "白鶴錦", category: .sake, isProOnly: true, suggestionHint: "獺祭 白鶴錦"),
                // 36. 徳島県
                .init(region: "徳島県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "芳水、阿波の山田錦"),
                .init(region: "徳島県", targetElement: "吟のさと", category: .sake, isProOnly: true, suggestionHint: "阿芳水の吟のさと仕込み"),
                // 37. 香川県
                .init(region: "香川県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "凱陣 (丸尾本店) の山田錦"),
                .init(region: "香川県", targetElement: "雄町", category: .sake, isProOnly: true, suggestionHint: "讃岐の金陵 雄町純米"),
                // 38. 愛媛県
                .init(region: "愛媛県", targetElement: "しずく媛", category: .sake, isProOnly: false, suggestionHint: "石鎚、京ひな のしずく媛"),
                .init(region: "愛媛県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "小富士、梅美人 の山田錦"),
                // 39. 高知県
                .init(region: "高知県", targetElement: "吟の夢", category: .sake, isProOnly: false, suggestionHint: "酔鯨、美丈夫 の高知産酒米「吟の夢」"),
                .init(region: "高知県", targetElement: "土佐麗", category: .sake, isProOnly: true, suggestionHint: "南、安芸虎 の土佐麗 (とさうらら)"),
                .init(region: "高知県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "司牡丹、亀泉 の山田錦"),
                .init(region: "高知県", targetElement: "風鳴子", category: .sake, isProOnly: true, suggestionHint: "高知の爽やかな風土を映す風鳴子"),
                // 40. 福岡県
                .init(region: "福岡県", targetElement: "吟のさと", category: .sake, isProOnly: false, suggestionHint: "庭のうぐいす、田中六五 (白糸酒造)"),
                .init(region: "福岡県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "喜多屋、若波 の山田錦"),
                .init(region: "福岡県", targetElement: "壽限無", category: .sake, isProOnly: true, suggestionHint: "山田錦と夢の香から生まれた福岡の「壽限無」"),
                .init(region: "福岡県", targetElement: "雄町", category: .sake, isProOnly: true, suggestionHint: "田中六五 などの福岡産雄町酒"),
                // 41. 佐賀県
                .init(region: "佐賀県", targetElement: "さがの華", category: .sake, isProOnly: false, suggestionHint: "鍋島 (富久千代酒造)、東一 のさがの華"),
                .init(region: "佐賀県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "鍋島 特別純米 (山田錦)"),
                // 42. 長崎県
                .init(region: "長崎県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "六十餘洲 (今里酒造) の山田錦"),
                // 43. 熊本県
                .init(region: "熊本県", targetElement: "華錦", category: .sake, isProOnly: false, suggestionHint: "香露、美少年 の華錦"),
                .init(region: "熊本県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "産土 (山田錦：花の香酒造)"),
                .init(region: "熊本県", targetElement: "神力", category: .sake, isProOnly: true, suggestionHint: "産土 神力 (古代米の復活銘柄)"),
                .init(region: "熊本県", targetElement: "吟のさと", category: .sake, isProOnly: true, suggestionHint: "瑞鷹、通潤 の吟のさと"),
                // 44. 大分県
                .init(region: "大分県", targetElement: "五百万石", category: .sake, isProOnly: false, suggestionHint: "西の関 (萱島酒造) の五百万石"),
                .init(region: "大分県", targetElement: "山田錦", category: .sake, isProOnly: true, suggestionHint: "鷹来屋、ちえびじん の山田錦"),
                .init(region: "大分県", targetElement: "若水", category: .sake, isProOnly: true, suggestionHint: "大分の蔵元が醸す若水仕込み"),
                .init(region: "大分県", targetElement: "雄町", category: .sake, isProOnly: true, suggestionHint: "ちえびじん 雄町純米"),
                // 45. 宮崎県
                .init(region: "宮崎県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "千徳酒造の宮崎産山田錦仕込み"),
                .init(region: "宮崎県", targetElement: "はなかぐら", category: .sake, isProOnly: true, suggestionHint: "宮崎県オリジナルの酒米「はなかぐら」"),
                .init(region: "宮崎県", targetElement: "ちほのまい", category: .sake, isProOnly: true, suggestionHint: "高千穂の豊かな水と米で造る純米酒"),
                // 46. 鹿児島県
                .init(region: "鹿児島県", targetElement: "山田錦", category: .sake, isProOnly: false, suggestionHint: "焼酎蔵が本気で造る鹿児島の日本酒 (山元酒造など)"),
                // 47. 沖縄県
                .init(region: "沖縄県", targetElement: "一般米（食用米）", category: .sake, isProOnly: true, suggestionHint: "泡盛の技術を応用した沖縄のレアな日本酒や米発酵酒")
            ]
            
        case .beer:
            return [
                // 1. ドイツ & チェコ
                .init(region: "ドイツ", targetElement: "ピルスナー", category: .beer, isProOnly: false, suggestionHint: "ラーデベルガー、ヴェルティンス (ジャーマンピルスナー)"),
                .init(region: "ドイツ", targetElement: "ヴァイツェン（ヘーフェヴァイツェン）", category: .beer, isProOnly: false, suggestionHint: "パウラーナー、エルディンガー、フランツィスカーナー"),
                .init(region: "ドイツ", targetElement: "ボック", category: .beer, isProOnly: false, suggestionHint: "アインベッカー・ウルボック"),
                .init(region: "ドイツ", targetElement: "シュバルツ", category: .beer, isProOnly: false, suggestionHint: "クヴェッスチェル・シュバルツビア"),
                .init(region: "チェコ", targetElement: "ピルスナー", category: .beer, isProOnly: false, suggestionHint: "ピルスナーウルケル (元祖ピルスナー)"),
                
                .init(region: "ドイツ", targetElement: "ボヘミアン・ピルスナー", category: .beer, isProOnly: true, suggestionHint: "チェコ伝統スタイルの麦芽風味豊かなラガー"),
                .init(region: "ドイツ", targetElement: "デュンケル", category: .beer, isProOnly: true, suggestionHint: "アインベッカー・デュンケル"),
                .init(region: "ドイツ", targetElement: "ドッペルボック", category: .beer, isProOnly: true, suggestionHint: "アヴェンティヌス (エイブラinger)"),
                .init(region: "ドイツ", targetElement: "メルツェン / オクトーバーフェスト", category: .beer, isProOnly: true, suggestionHint: "ホフブロイ、パウラーナーのオクトーバーフェストビール"),
                .init(region: "ドイツ", targetElement: "ラオハス（燻製ビール）", category: .beer, isProOnly: true, suggestionHint: "シュレンケルラ・ラオホビア (バンベルク)"),
                .init(region: "ドイツ", targetElement: "ケルシュ", category: .beer, isProOnly: true, suggestionHint: "フリュー・ケルシュ (ケルン伝統の上面発酵ラガー)"),
                .init(region: "ドイツ", targetElement: "アルトビール", category: .beer, isProOnly: true, suggestionHint: "デュッセルドルフの伝統的銅色エール (シューマッハ)"),
                // 2. ベルギー
                .init(region: "ベルギー", targetElement: "ベルジャンホワイト（ヴィットビール）", category: .beer, isProOnly: false, suggestionHint: "ヒューガルデン・ホワイト、ブルッグス・ボック"),
                .init(region: "ベルギー", targetElement: "セゾン", category: .beer, isProOnly: false, suggestionHint: "セゾン・デュ・ポン (農家風ドライエール)"),
                .init(region: "ベルギー", targetElement: "サワーエール", category: .beer, isProOnly: false, suggestionHint: "ロシュフォールやランビック系の酸味ビール"),
                
                .init(region: "ベルギー", targetElement: "ベルジャン・ブロンド", category: .beer, isProOnly: true, suggestionHint: "デュヴェル (魔王と呼ばれる強アルコールビール)"),
                .init(region: "ベルギー", targetElement: "ベルジャン・デュペル", category: .beer, isProOnly: true, suggestionHint: "ウェストマール・デュペル (修道院ビール)"),
                .init(region: "ベルギー", targetElement: "ベルジャン・トリプル", category: .beer, isProOnly: true, suggestionHint: "シメイ・ホワイト、ウェストマール・トリプル"),
                .init(region: "ベルギー", targetElement: "ベルジャン・クアドルペル", category: .beer, isProOnly: true, suggestionHint: "ロシュフォール10、シメイ・ブルー"),
                .init(region: "ベルギー", targetElement: "ランビック", category: .beer, isProOnly: true, suggestionHint: "カンテール (自然発酵のグーズビール)"),
                .init(region: "ベルギー", targetElement: "フラダース・レッドエール", category: .beer, isProOnly: true, suggestionHint: "デュシャス・デ・ブルゴーニュ (木樽熟成の赤ビール)"),
                .init(region: "ベルギー", targetElement: "フルーツビール", category: .beer, isProOnly: true, suggestionHint: "リーフマンス (チェリーやフランボワーズ)"),
                // 3. イギリス & アイルランド
                .init(region: "イギリス", targetElement: "イングリッシュ・ペールエール", category: .beer, isProOnly: false, suggestionHint: "バス・ペールエール (伝統的エール)"),
                .init(region: "イギリス", targetElement: "ポーター", category: .beer, isProOnly: false, suggestionHint: "サミュエル・スミス・ポーター"),
                .init(region: "イギリス", targetElement: "スタウト", category: .beer, isProOnly: false, suggestionHint: "オートミールスタウト (サミュエル・スミス)"),
                .init(region: "アイルランド", targetElement: "アイリッシュ・スタウト", category: .beer, isProOnly: false, suggestionHint: "ギネス (Guinness：世界一有名なスタウト)"),
                
                .init(region: "イギリス", targetElement: "ビター / ESB", category: .beer, isProOnly: true, suggestionHint: "フラーズ ESB (Extra Special Bitter)"),
                .init(region: "イギリス", targetElement: "イングリッシュ・IPA", category: .beer, isProOnly: true, suggestionHint: "ホップが香る伝統的なイギリス式IPA"),
                .init(region: "イギリス", targetElement: "インペリアルスタウト", category: .beer, isProOnly: true, suggestionHint: "サミュエル・スミス・インペリアルスタウト"),
                .init(region: "イギリス", targetElement: "バーレイワイン", category: .beer, isProOnly: true, suggestionHint: "ワインのように熟成させる高アルコールエール"),
                // 4. アメリカ
                .init(region: "アメリカ", targetElement: "IPA", category: .beer, isProOnly: false, suggestionHint: "シエラネバダ・トーパー、ストーン・IPA"),
                .init(region: "アメリカ", targetElement: "ヘイジーIPA（ニューイングランドIPA）", category: .beer, isProOnly: false, suggestionHint: "トリージェント、シカゴ発祥の濁り系ジューシーIPA"),
                .init(region: "アメリカ", targetElement: "ダブルIPA（インペリアルIPA）", category: .beer, isProOnly: false, suggestionHint: "ロシアン・リヴァー「プラニー・ザ・エルダー」"),
                .init(region: "アメリカ", targetElement: "アメリカン・ペールエール", category: .beer, isProOnly: false, suggestionHint: "シエラネバダ・ペールエール (伝説的クラフトビール)"),
                
                .init(region: "アメリカ", targetElement: "トリプルIPA", category: .beer, isProOnly: true, suggestionHint: "アルコールとホップが極限まで高められた爆弾級IPA"),
                .init(region: "アメリカ", targetElement: "セッションIPA", category: .beer, isProOnly: true, suggestionHint: "低アルコールで飲みやすいホップ香豊かなIPA"),
                .init(region: "アメリカ", targetElement: "ブラックIPA", category: .beer, isProOnly: true, suggestionHint: "黒い見た目と強烈なホップ香を併せ持つ変種IPA"),
                .init(region: "アメリカ", targetElement: "アメリカン・ラガー", category: .beer, isProOnly: true, suggestionHint: "バドワイザー、クアーズ、ミラー等"),
                .init(region: "アメリカ", targetElement: "サワーエール", category: .beer, isProOnly: true, suggestionHint: "フルーツピューレを加えた近代的な酸っぱいエール"),
                .init(region: "アメリカ", targetElement: "ゴーゼ", category: .beer, isProOnly: true, suggestionHint: "塩とコリアンダーを使用したドイツ発祥の酸味ビール"),
                .init(region: "アメリカ", targetElement: "ミルクスタウト（オートミールスタウト）", category: .beer, isProOnly: true, suggestionHint: "ラウト・ミルクスタウト (乳糖由来のまろやかさ)"),
                .init(region: "アメリカ", targetElement: "フルーツビール", category: .beer, isProOnly: true, suggestionHint: "各種クラフトブルワリーによる果汁たっぷりエール"),
                // 5. 日本 & 新興クラフトシーン
                .init(region: "日本", targetElement: "ピルスナー", category: .beer, isProOnly: false, suggestionHint: "サッポロ黒ラベル、キリン一番搾り、よなよな等に対抗するクラフトピルス"),
                .init(region: "日本", targetElement: "IPA", category: .beer, isProOnly: false, suggestionHint: "よなよなエール「インドの青鬼」、ベアードビール"),
                .init(region: "日本", targetElement: "ヘイジーIPA（ニューイングランドIPA）", category: .beer, isProOnly: false, suggestionHint: "伊勢角屋麦酒、うちゅうブルーイング のヘイジー"),
                .init(region: "日本", targetElement: "ヴァイツェン（ヘーフェヴァイツェン）", category: .beer, isProOnly: false, suggestionHint: "銀河高原ビール、箕面ビール ヴァイツェン"),
                
                .init(region: "日本", targetElement: "イングリッシュ・ペールエール", category: .beer, isProOnly: true, suggestionHint: "常陸野ネストビール (木内酒造)"),
                .init(region: "日本", targetElement: "フルーツビール", category: .beer, isProOnly: true, suggestionHint: "箕面ビール「おさるのIPA / 桃のヴァイツェン」"),
                .init(region: "デンマーク", targetElement: "インペリアルスタウト", category: .beer, isProOnly: true, suggestionHint: "ミッケラー (Mikkeller) の変態的ハイアルコールビール"),
                .init(region: "エストニア", targetElement: "ポーター", category: .beer, isProOnly: true, suggestionHint: "ポホヤ (Pohjala) の世界的高評価バルティックポーター")
            ]
        }
    }
}
