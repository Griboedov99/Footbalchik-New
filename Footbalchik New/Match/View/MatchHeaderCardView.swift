//
//  MatchHeaderCardView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class MatchHeaderCardView: GlassCardView {

    private let homeLogo = UIImageView()
    private let awayLogo = UIImageView()

    private let homeName = UILabel()
    private let awayName = UILabel()

    private let dateLabel = UILabel()
    private let timeOrScoreLabel = UILabel()
    private let statusLabel = UILabel()

    private let leftPlayers = UILabel()
    private let rightPlayers = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        setHeight(mode: .equal, 200)

        homeLogo.setWidth(mode: .equal, 72)
        homeLogo.setHeight(mode: .equal, 72)

        awayLogo.setWidth(mode: .equal, 72)
        awayLogo.setHeight(mode: .equal, 72)

        homeName.textColor = .white
        awayName.textColor = .white

        homeName.font = .systemFont(ofSize: 16, weight: .medium)
        awayName.font = .systemFont(ofSize: 16, weight: .medium)

        dateLabel.textColor = .white.withAlphaComponent(0.6)
        dateLabel.font = .systemFont(ofSize: 14)

        timeOrScoreLabel.font = .systemFont(ofSize: 28, weight: .bold)
        timeOrScoreLabel.textColor = .white
        timeOrScoreLabel.textAlignment = .center

        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = .white.withAlphaComponent(0.75)
        statusLabel.textAlignment = .center

        leftPlayers.numberOfLines = 3
        rightPlayers.numberOfLines = 3

        leftPlayers.font = .systemFont(ofSize: 12)
        rightPlayers.font = .systemFont(ofSize: 12)

        leftPlayers.textColor = .white.withAlphaComponent(0.7)
        rightPlayers.textColor = .white.withAlphaComponent(0.7)

        contentView.addSubview(homeLogo)
        contentView.addSubview(awayLogo)
        contentView.addSubview(homeName)
        contentView.addSubview(awayName)
        contentView.addSubview(dateLabel)
        contentView.addSubview(timeOrScoreLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(leftPlayers)
        contentView.addSubview(rightPlayers)

        homeLogo.pinLeft(to: contentView, 16)
        homeLogo.pinTop(to: contentView, 16)

        awayLogo.pinRight(to: contentView, 16)
        awayLogo.pinTop(to: contentView, 16)

        homeName.pinTop(to: homeLogo.bottomAnchor, 6)
        homeName.pinCenterX(to: homeLogo)

        awayName.pinTop(to: awayLogo.bottomAnchor, 6)
        awayName.pinCenterX(to: awayLogo)

        timeOrScoreLabel.pinCenter(to: contentView)

        dateLabel.pinBottom(to: timeOrScoreLabel.topAnchor, 6)
        dateLabel.pinCenterX(to: contentView)

        statusLabel.pinTop(to: timeOrScoreLabel.bottomAnchor, 6)
        statusLabel.pinCenterX(to: contentView)

        leftPlayers.pinLeft(to: contentView, 20)
        leftPlayers.pinBottom(to: contentView, 12)

        rightPlayers.pinRight(to: contentView, 20)
        rightPlayers.pinBottom(to: contentView, 12)
    }

    func configure(
        homeTeamName: String,
        awayTeamName: String,
        homeLogoURL: String?,
        awayLogoURL: String?,
        dateText: String,
        centerText: String,
        statusText: String?
    ) {
        homeName.text = homeTeamName
        awayName.text = awayTeamName

        homeLogo.setImage(from: homeLogoURL)
        awayLogo.setImage(from: awayLogoURL)

        dateLabel.text = dateText
        timeOrScoreLabel.text = centerText
        statusLabel.text = statusText
        statusLabel.isHidden = (statusText == nil || statusText?.isEmpty == true)

        leftPlayers.text = ""
        rightPlayers.text = ""
    }
}
