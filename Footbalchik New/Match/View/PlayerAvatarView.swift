//
//  FootballFieldViewController.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class PlayerAvatarView: UIView {

    private let avatarView = UIView()
    private let nameLabel = UILabel()

    private let avatarSize: CGFloat
    private let labelHeight: CGFloat

    init(
        name: String,
        isHome: Bool,
        avatarDiameter: CGFloat,
        labelHeight: CGFloat
    ) {
        self.avatarSize = avatarDiameter
        self.labelHeight = labelHeight
        super.init(frame: .zero)

        setup()
        configure(name: name, isHome: isHome)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {

        backgroundColor = .clear
        isOpaque = false

        addSubview(avatarView)
        addSubview(nameLabel)

        avatarView.layer.borderWidth = 2
        avatarView.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.6
        nameLabel.numberOfLines = 1
    }

    private func configure(name: String, isHome: Bool) {

        avatarView.layer.borderColor =
        (isHome ? UIColor.systemYellow : UIColor.systemBlue).cgColor

        nameLabel.text = name
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: max(avatarSize + 12, 56),
            height: avatarSize + 4 + labelHeight
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let containerWidth = bounds.width

        let avatarX = (containerWidth - avatarSize) / 2

        avatarView.frame = CGRect(
            x: avatarX,
            y: 0,
            width: avatarSize,
            height: avatarSize
        )

        avatarView.layer.cornerRadius = avatarSize / 2

        nameLabel.frame = CGRect(
            x: 0,
            y: avatarView.frame.maxY + 4,
            width: containerWidth,
            height: labelHeight
        )
    }
}
