//
//  MatchSearchBarView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class MatchSearchBarView: UIView {

    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let textField = UITextField()
    private let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {

        layer.cornerRadius = 18
        layer.masksToBounds = true

        addSubview(blur)
        blur.pin(to: self)

        icon.tintColor = .white.withAlphaComponent(0.7)
        addSubview(icon)

        icon.pinLeft(to: self, 14)
        icon.pinCenterY(to: self)
        icon.setWidth(mode: .equal, 18)
        icon.setHeight(mode: .equal, 18)

        addSubview(textField)

        textField.pinLeft(to: icon.trailingAnchor, 10)
        textField.pinRight(to: self, 14)
        textField.pinTop(to: self)
        textField.pinBottom(to: self)

        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "UEFA League",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )

        setHeight(mode: .equal, 44)
    }
}