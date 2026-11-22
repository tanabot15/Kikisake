//
//  RadarChartShapes.swift
//  Kikisake
//

import SwiftUI

public struct RadarPolygon: Shape {
    public let sides: Int
    public let scale: CGFloat
    public let radiusOffset: CGFloat

    public init(sides: Int, scale: CGFloat, radiusOffset: CGFloat) {
        self.sides = sides
        self.scale = scale
        self.radiusOffset = radiusOffset
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard sides > 0 else { return path }

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = (min(rect.width, rect.height) / 2 - radiusOffset) * scale

        for i in 0..<sides {
            let angle = (CGFloat(i) * 2.0 * .pi / CGFloat(sides)) - (.pi / 2)
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

public struct RadarAxesLines: Shape {
    public let sides: Int
    public let radiusOffset: CGFloat

    public init(sides: Int, radiusOffset: CGFloat) {
        self.sides = sides
        self.radiusOffset = radiusOffset
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard sides > 0 else { return path }

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - radiusOffset

        for i in 0..<sides {
            let angle = (CGFloat(i) * 2.0 * .pi / CGFloat(sides)) - (.pi / 2)
            let endpoint = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )

            path.move(to: center)
            path.addLine(to: endpoint)
        }

        return path
    }
}

public struct RadarPolygonShape: Shape {
    public let values: [Double]
    public let radiusOffset: CGFloat

    public init(values: [Double], radiusOffset: CGFloat) {
        self.values = values
        self.radiusOffset = radiusOffset
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let sides = values.count
        guard sides > 0 else { return path }

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - radiusOffset

        for (i, value) in values.enumerated() {
            let clampedVal = max(0.0, min(1.0, value))
            let angle = (CGFloat(i) * 2.0 * .pi / CGFloat(sides)) - (.pi / 2)
            let point = CGPoint(
                x: center.x + radius * CGFloat(clampedVal) * cos(angle),
                y: center.y + radius * CGFloat(clampedVal) * sin(angle)
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}
