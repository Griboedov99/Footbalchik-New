//
//  MatchCardCell.swift
//  Footbalchik
//
//  Created by Nick on 21.03.2026.
//


import UIKit

final class MatchCardCell: UICollectionViewCell {

    static let reuseId = "MatchCardCell"

    private let cardView = MatchCardView()
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        cardView.pin(to: contentView)

        contentView.isUserInteractionEnabled = true
        cardView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        cardView.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTap = nil
    }

    func configure(with viewModel: MatchCardViewModel) {
        cardView.configure(with: viewModel)
    }

    @objc
    private func handleTap() {
        onTap?()
    }
}
