//
//  FootballFieldViewController.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class FieldCanvasView: UIView {
    var cornerRadius: CGFloat = 26 { didSet { setNeedsDisplay() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let field = rect.insetBy(dx: 20, dy: 20)

        let lineColor = UIColor.white.withAlphaComponent(0.45)
        ctx.setStrokeColor(lineColor.cgColor)
        ctx.setLineWidth(2)

        // Outer field
        let outer = UIBezierPath(roundedRect: field, cornerRadius: cornerRadius)
        outer.stroke()

        // Center line
        ctx.move(to: CGPoint(x: field.minX, y: field.midY))
        ctx.addLine(to: CGPoint(x: field.maxX, y: field.midY))
        ctx.strokePath()

        // Center circle
        ctx.strokeEllipse(in: CGRect(x: field.midX - 40, y: field.midY - 40, width: 80, height: 80))

        // Penalty areas
        drawPenaltyArea(ctx: ctx, field: field, top: true)
        drawPenaltyArea(ctx: ctx, field: field, top: false)
    }

    private func drawPenaltyArea(ctx: CGContext, field: CGRect, top: Bool) {
        let penaltyWidth = field.width * 0.55
        let penaltyHeight: CGFloat = 90
        let x = field.midX - penaltyWidth/2
        let y = top ? field.minY : field.maxY - penaltyHeight
        let r: CGFloat = 12

        let path = UIBezierPath()
        if top {
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x, y: y + penaltyHeight - r))
            path.addQuadCurve(to: CGPoint(x: x + r, y: y + penaltyHeight), controlPoint: CGPoint(x: x, y: y + penaltyHeight))
            path.addLine(to: CGPoint(x: x + penaltyWidth - r, y: y + penaltyHeight))
            path.addQuadCurve(to: CGPoint(x: x + penaltyWidth, y: y + penaltyHeight - r), controlPoint: CGPoint(x: x + penaltyWidth, y: y + penaltyHeight))
            path.addLine(to: CGPoint(x: x + penaltyWidth, y: y))
        } else {
            path.move(to: CGPoint(x: x, y: y + penaltyHeight))
            path.addLine(to: CGPoint(x: x, y: y + r))
            path.addQuadCurve(to: CGPoint(x: x + r, y: y), controlPoint: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + penaltyWidth - r, y: y))
            path.addQuadCurve(to: CGPoint(x: x + penaltyWidth, y: y + r), controlPoint: CGPoint(x: x + penaltyWidth, y: y))
            path.addLine(to: CGPoint(x: x + penaltyWidth, y: y + penaltyHeight))
        }
        path.stroke()
    }
}
