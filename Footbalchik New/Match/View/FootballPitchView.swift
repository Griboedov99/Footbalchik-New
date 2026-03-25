//
//  MatchSearchBarView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class FootballPitchView: UIView {

    // MARK: - Public API

    var homePlayers: [PlayerOnField] = [] {
        didSet { updatePlayers() }
    }

    var awayPlayers: [PlayerOnField] = [] {
        didSet { updatePlayers() }
    }

    // MARK: - Views

    private let fieldView = FieldCanvasView()

    private let homeLayer = UIView()
    private let awayLayer = UIView()

    // MARK: - Storage

    private var homeAvatars: [String: PlayerAvatarView] = [:]
    private var awayAvatars: [String: PlayerAvatarView] = [:]

    // MARK: - Layout constants

    private let labelHeight: CGFloat = 16

    private var avatarBaseSize: CGFloat {
        let base = contentRect.width / 14
        return min(max(base, 28), 36)
    }

    // MARK: - Pitch geometry

    internal var pitchRect: CGRect {

        let padding: CGFloat = 2
        let available = bounds.insetBy(dx: padding, dy: padding)

        let aspect: CGFloat = 0.5

        let width = available.width
        let height = width / aspect

        if height <= available.height {
            return CGRect(
                x: available.minX,
                y: available.midY - height / 2,
                width: width,
                height: height
            )
        }

        let newHeight = available.height
        let newWidth = newHeight * aspect

        return CGRect(
            x: available.midX - newWidth / 2,
            y: available.minY,
            width: newWidth,
            height: newHeight
        )
    }

    internal var contentRect: CGRect {
        pitchRect.insetBy(dx: 8, dy: 10)
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        addSubview(fieldView)
        addSubview(homeLayer)
        addSubview(awayLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        fieldView.frame = pitchRect
        homeLayer.frame = bounds
        awayLayer.frame = bounds

        layoutPlayers(animated: false)
    }

    // MARK: - Player management

    private func updatePlayers() {

        for player in homePlayers {

            if homeAvatars[player.id] == nil {

                let avatar = PlayerAvatarView(
                    name: player.lastName ?? player.name,
                    isHome: true,
                    avatarDiameter: avatarBaseSize,
                    labelHeight: labelHeight
                )

                homeLayer.addSubview(avatar)
                homeAvatars[player.id] = avatar
            }
        }

        for player in awayPlayers {

            if awayAvatars[player.id] == nil {

                let avatar = PlayerAvatarView(
                    name: player.lastName ?? player.name,
                    isHome: false,
                    avatarDiameter: avatarBaseSize,
                    labelHeight: labelHeight
                )

                awayLayer.addSubview(avatar)
                awayAvatars[player.id] = avatar
            }
        }

        layoutPlayers(animated: true)
    }

    private func layoutPlayers(animated: Bool) {

        for player in homePlayers {

            guard let avatar = homeAvatars[player.id] else { continue }

            avatar.frame.size = avatar.intrinsicContentSize

            let newCenter = position(player, mirror: false)

            if animated {
                UIView.animate(withDuration: 0.35) {
                    avatar.center = newCenter
                }
            } else {
                avatar.center = newCenter
            }
        }

        for player in awayPlayers {

            guard let avatar = awayAvatars[player.id] else { continue }

            avatar.frame.size = avatar.intrinsicContentSize

            let newCenter = position(player, mirror: true)

            if animated {
                UIView.animate(withDuration: 0.35) {
                    avatar.center = newCenter
                }
            } else {
                avatar.center = newCenter
            }
        }
    }

    // MARK: - Position calculation

    private func position(
        _ player: PlayerOnField,
        mirror: Bool
    ) -> CGPoint {

        var p = player.fieldPosition

        if mirror {
            p.y = 1 - p.y
            p.y = p.y * 0.5
        } else {
            p.y = 0.5 + p.y * 0.5
        }

        let safeTop: CGFloat = 0.05
        let safeBottom: CGFloat = 0.05
        let safeLeft: CGFloat = 0.05
        let safeRight: CGFloat = 0.05

        let field = pitchRect

        let insetX = field.width * (safeLeft + safeRight)
        let insetY = field.height * (safeTop + safeBottom)

        let x = field.minX + field.width * safeLeft + (field.width - insetX) * p.x
        let y = field.minY + field.height * safeTop + (field.height - insetY) * p.y

        return CGPoint(x: x, y: y)
    }
}
