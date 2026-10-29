//
//  BoardingView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/19.
//

import SwiftUI

/// アプリを初めて起動したユーザー向けのご案内（オンボーディング）画面
public struct BoardingView: View {
    @Binding public var isPresented: Bool

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // アプリロゴ・アイコン的表現
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "wineglass.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.accentColor)
            }

            VStack(spacing: 8) {
                Text(String(localized: "Kikisakeへようこそ"))
                    .font(.title)
                    .fontWeight(.bold)

                Text(String(localized: "お酒の感動を記録し、あなたの「好み」を深く知るためのテイスティング手帳"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // 機能紹介リスト
            VStack(alignment: .leading, spacing: 20) {
                boardingFeatureRow(
                    icon: "waveform.path.ecg.text.clipboard",
                    title: String(localized: "詳細なテイスティング記録"),
                    description: String(localized: "外観、香り、五味（甘味・酸味・苦味・旨味・塩味）を直感的に記録できます。")
                )

                boardingFeatureRow(
                    icon: "chart.pie",
                    title: String(localized: "リッチな分析と好みの一覧"),
                    description: String(localized: "酒種ごとの比率や、あなた自身の味覚プロファイル、お気に入り銘柄を可視化します。")
                )

                boardingFeatureRow(
                    icon: "refrigerator",
                    title: String(localized: "スマートな在庫・セラー管理"),
                    description: String(localized: "自宅のセラーや冷蔵庫ごとの在庫を把握し、スムーズにテイスティングへ移行できます。")
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            // はじめるボタン
            Button {
                isPresented = false
            } label: {
                Text(String(localized: "さっそくはじめる"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
    }

    private func boardingFeatureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    BoardingView(isPresented: .constant(true))
}
