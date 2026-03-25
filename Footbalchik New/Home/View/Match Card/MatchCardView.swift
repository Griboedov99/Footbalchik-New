//
//  MatchCardView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class MatchCardView: GlassCardView {

    // MARK: - UI

    private let homeLogo = UIImageView()
    private let awayLogo = UIImageView()

    private let homeNameLabel = UILabel()
    private let awayNameLabel = UILabel()

    private let dateLabel = UILabel()
    private let timeLabel = UILabel()

    private let centerStack = UIStackView()
    private let homeStack = UIStackView()
    private let awayStack = UIStackView()

    // MARK: - Actions

    var onTap: (() -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
        configureLayout()
        configureTap()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - configure

    private func configureUI() {

        setHeight(mode: .equal, 120)

        homeLogo.contentMode = .scaleAspectFit
        awayLogo.contentMode = .scaleAspectFit

        homeLogo.setWidth(mode: .equal, 56)
        homeLogo.setHeight(mode: .equal, 56)

        awayLogo.setWidth(mode: .equal, 56)
        awayLogo.setHeight(mode: .equal, 56)

        homeNameLabel.textColor = .white
        homeNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        homeNameLabel.textAlignment = .center

        awayNameLabel.textColor = .white
        awayNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        awayNameLabel.textAlignment = .center

        dateLabel.textColor = .white.withAlphaComponent(0.7)
        dateLabel.font = .systemFont(ofSize: 12)

        timeLabel.textColor = .white
        timeLabel.font = .systemFont(ofSize: 18, weight: .bold)

        centerStack.axis = .vertical
        centerStack.spacing = 4
        centerStack.alignment = .center

        homeStack.axis = .vertical
        homeStack.spacing = 6
        homeStack.alignment = .center

        awayStack.axis = .vertical
        awayStack.spacing = 6
        awayStack.alignment = .center
    }

    
    // MARK: - Layout
    
    private func configureLayout() {

        contentView.addSubview(homeStack)
        contentView.addSubview(awayStack)
        contentView.addSubview(centerStack)

        homeStack.addArrangedSubview(homeLogo)
        homeStack.addArrangedSubview(homeNameLabel)

        awayStack.addArrangedSubview(awayLogo)
        awayStack.addArrangedSubview(awayNameLabel)

        centerStack.addArrangedSubview(dateLabel)
        centerStack.addArrangedSubview(timeLabel)

        homeStack.pinLeft(to: contentView, 16)
        homeStack.pinCenterY(to: contentView)

        awayStack.pinRight(to: contentView, 16)
        awayStack.pinCenterY(to: contentView)

        centerStack.pinCenter(to: contentView)
    }

    private func configureTap() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    // MARK: - Configure

    func configure(with viewModel: MatchCardViewModel) {

        homeNameLabel.text = viewModel.homeTeamName
        awayNameLabel.text = viewModel.awayTeamName

        homeLogo.setImage(from: viewModel.homeLogoURL)
        awayLogo.setImage(from: viewModel.awayLogoURL)

        dateLabel.text = viewModel.dateText
        timeLabel.text = viewModel.timeText
    }

    // MARK: - Tap

    @objc
    private func didTap() {
        onTap?()
    }
}
