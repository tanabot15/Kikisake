//  BottleMattingHelper.swift
//  Kikisake

import SwiftUI
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

public enum BottleMattingHelper {
    /// 与えられたUIImageからVisionを用いて背景を抽出し、ボトル等の前景のみを切り抜いたUIImageを返す（非同期）
    @MainActor
    public static func removeBackground(from sourceImage: UIImage) async -> UIImage {
        guard let cgImage = sourceImage.cgImage else { return sourceImage }
        
        #if os(iOS)
        if #available(iOS 17.0, *) {
            let request = VNGenerateForegroundInstanceMaskRequest()
            // 向き情報を渡すために CGImagePropertyOrientation に変換
            let orientation = CGImagePropertyOrientation(sourceImage.imageOrientation)
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            
            do {
                try handler.perform([request])
                guard let result = request.results?.first else { return sourceImage }
                
                // すべての前景インスタンス（IndexSet）を指定してマスクを生成
                let allInstances = result.allInstances
                let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: allInstances, from: handler)
                
                // CIImageを使ったマスキング処理
                let inputImage = CIImage(cgImage: cgImage)
                let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
                
                let filter = CIFilter.blendWithMask()
                filter.inputImage = inputImage
                filter.maskImage = maskImage
                filter.backgroundImage = CIImage(color: CIColor.clear).cropped(to: inputImage.extent)
                
                guard let outputCIImage = filter.outputImage else { return sourceImage }
                
                let context = CIContext(options: nil)
                guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return sourceImage }
                
                return UIImage(cgImage: outputCGImage, scale: sourceImage.scale, orientation: sourceImage.imageOrientation)
            } catch {
                // 失敗時はフォールバックとして元の画像を返す
                return sourceImage
            }
        }
        #endif
        
        return sourceImage
    }
}

// MARK: - UIImage.Orientation と CGImagePropertyOrientation の変換ヘルパー
@available(iOS 14.0, *)
fileprivate extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
