//
//  BottleMattingHelper.swift
//  Kikisake
//

import SwiftUI
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import os

public enum BottleMattingHelper {
    /// 与えられたUIImageからVisionを用いて背景を抽出し、ボトル等の前景のみを切り抜いたUIImageを返す（非同期）
    @MainActor
    public static func removeBackground(from sourceImage: UIImage) async -> UIImage {
        let normalizedImage = sourceImage.normalized()
        guard let cgImage = normalizedImage.cgImage else { return sourceImage }

        #if os(iOS)
        if #available(iOS 17.0, *) {
            return extractForeground(
                from: cgImage,
                scale: normalizedImage.scale,
                fallback: sourceImage
            )
        }
        #endif

        return sourceImage
    }

    #if os(iOS)
    @available(iOS 17.0, *)
    private static func extractForeground(
        from cgImage: CGImage,
        scale: CGFloat,
        fallback: UIImage
    ) -> UIImage {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])

        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return fallback }

            let maskPixelBuffer = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )

            let inputImage = CIImage(cgImage: cgImage)
            let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

            let filter = CIFilter.blendWithMask()
            filter.inputImage = inputImage
            filter.maskImage = maskImage
            filter.backgroundImage = CIImage(color: CIColor.clear).cropped(to: inputImage.extent)

            let context = CIContext(options: nil)
            guard let outputCIImage = filter.outputImage,
                  let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return fallback
            }

            return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
        } catch {
            AppLogger.general.warning("Foreground mask extraction failed: \(error.localizedDescription, privacy: .public)")
            return fallback
        }
    }
    #endif
}

// MARK: - UIImage の向き正規化拡張
fileprivate extension UIImage {
    /// 画像の向きを .up に正規化し、ピクセルデータを正しい向きに描き直す
    func normalized() -> UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
