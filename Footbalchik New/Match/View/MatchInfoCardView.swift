//
//  MatchInfoCardView.swift
//  Footbalchik New
//
//  Created by Nick on 25.03.2026.
//


import UIKit

final class MatchInfoCardView: UIView {

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, text: String) {
        titleLabel.text = title
        textLabel.text = text
    }

    private func setup() {
        backgroundColor = .clear

        addSubview(cardView)
        cardView.pin(to: self)

        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        cardView.layer.cornerRadius = 24
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        cardView.addSubview(titleLabel)
        cardView.addSubview(textLabel)

        titleLabel.pinTop(to: cardView, 16)
        titleLabel.pinLeft(to: cardView, 16)
        titleLabel.pinRight(to: cardView, 16)

        textLabel.pinTop(to: titleLabel.bottomAnchor, 12)
        textLabel.pinLeft(to: cardView, 16)
        textLabel.pinRight(to: cardView, 16)
        textLabel.pinBottom(to: cardView, 16)

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        textLabel.textColor = .white.withAlphaComponent(0.82)
        textLabel.font = .systemFont(ofSize: 15, weight: .regular)
        textLabel.numberOfLines = 0
    }
}
