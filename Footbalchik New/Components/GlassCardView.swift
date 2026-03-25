//
//  MatchSearchBarView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

class GlassCardView: UIView {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let contentContainer = UIView()
    private let borderLayer = CAGradientLayer()
    private let shapeMask = CAShapeLayer()

    var contentView: UIView { contentContainer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = 16
        layer.masksToBounds = true

        addSubview(blurView)
        blurView.pin(to: self)

        addSubview(contentContainer)
        contentContainer.pin(to: self)

        borderLayer.startPoint = CGPoint(x: 0, y: 0)
        borderLayer.endPoint = CGPoint(x: 1, y: 1)
        borderLayer.colors = [
            UIColor.white.withAlphaComponent(0.25).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        layer.addSublayer(borderLayer)
        borderLayer.mask = shapeMask

        layer.shadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16)
        shapeMask.path = path.cgPath
        shapeMask.lineWidth = 1
        shapeMask.fillColor = UIColor.clear.cgColor
        shapeMask.strokeColor = UIColor.white.cgColor
    }

    func updateAccent(colors: [UIColor]) {
        let cg = colors.map { $0.withAlphaComponent(0.35).cgColor }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.35)
        borderLayer.colors = cg.isEmpty ? [
            UIColor.white.withAlphaComponent(0.25).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ] : cg
        layer.shadowColor = (colors.first ?? UIColor.white).withAlphaComponent(0.25).cgColor
        CATransaction.commit()
    }
}
