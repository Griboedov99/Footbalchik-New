//
//  MatchLineupsViewData.swift
//  Footbalchik New
//
//  Created by Nick on 01.05.2026.
//


import Foundation

struct MatchLineupsViewData {
    let homePlayers: [PlayerOnField]
    let awayPlayers: [PlayerOnField]
    let infoText: String
    let lineupMessage: String?   // текст для loadingLabel; nil — спрятать
}

final class MatchViewModel {

    private let match: Match
    private let matchService: MatchService

    // MARK: Outputs
    var onLoadingChanged: ((Bool) -> Void)?
    var onLineupsLoaded: ((MatchLineupsViewData) -> Void)?
    var onError: ((_ title: String, _ text: String) -> Void)?

    init(match: Match, matchService: MatchService) {
        self.match = match
        self.matchService = matchService
    }

    // MARK: Данные шапки (доступны сразу, без сети)
    var screenTitle: String { "\(match.homeTeam.displayName) - \(match.awayTeam.displayName)" }
    var homeTeamName: String { match.homeTeam.displayName }
    var awayTeamName: String { match.awayTeam.displayName }
    var homeLogoURL: String? { match.homeTeam.crest }
    var awayLogoURL: String? { match.awayTeam.crest }
    var dateText: String { Self.makeDateText(from: match.utcDate) }
    var centerText: String { Self.makeCenterText(from: match) }

    var initialInfoText: String {
        """
        Статус: \(match.status.displayName)
        Стадион: \(formattedVenue)

        Составы пока не загружены.
        """
    }

    // MARK: Загрузка
    func loadDetails() {
        onLoadingChanged?(true)
        matchService.fetchMatchDetails(matchId: match.id) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.onLoadingChanged?(false)
                switch result {
                case .success(let details):
                    self.onLineupsLoaded?(self.makeViewData(from: details))
                case .failure(let error):
                    self.onError?("Ошибка загрузки", """
                        Статус: \(self.match.status.displayName)
                        Стадион: \(self.formattedVenue)

                        Ошибка:
                        \(error.localizedDescription)
                        """)
                }
            }
        }
    }

    private func makeViewData(from details: MatchDetailsResponse) -> MatchLineupsViewData {
        let homePlayers = makePlayers(from: details.homeTeam.lineup ?? [],
                                      teamId: details.homeTeam.id,
                                      formation: details.homeTeam.formation)
        let awayPlayers = makePlayers(from: details.awayTeam.lineup ?? [],
                                      teamId: details.awayTeam.id,
                                      formation: details.awayTeam.formation)

        let message: String?
        if homePlayers.isEmpty && awayPlayers.isEmpty {
            switch match.status {
            case .scheduled, .timed:                 message = "Стартовые составы пока еще не опубликованы"
            case .finished, .live, .inPlay, .paused: message = "Составы отсутствуют в ответе API"
            default:                                 message = "Нет данных по составам"
            }
        } else {
            message = nil
        }

        return MatchLineupsViewData(
            homePlayers: homePlayers,
            awayPlayers: awayPlayers,
            infoText: makeInfoText(homeFormation: details.homeTeam.formation,
                                   awayFormation: details.awayTeam.formation,
                                   homeCount: homePlayers.count,
                                   awayCount: awayPlayers.count),
            lineupMessage: message
        )
    }

    // MARK: - Mapping

    private func makePlayers(
        from apiPlayers: [MatchDetailsPlayer],
        teamId: Int,
        formation: String?
    ) -> [PlayerOnField] {
        apiPlayers.enumerated().map { index, player in
            PlayerOnField(
                id: String(player.id),
                teamId: String(teamId),
                name: player.name,
                firstName: nil,
                lastName: resolvedLastName(fullName: player.name),
                shirtNumber: player.shirtNumber,
                position: resolvedPosition(raw: player.position, index: index),
                formationPlace: index + 1,
                formation: resolvedFormation(
                    formation,
                    playerCount: apiPlayers.count
                ),
                captain: false,
                rating: nil,
                goals: nil,
                assists: nil,
                yellowCard: false,
                redCard: false
            )
        }
    }

    private func resolvedLastName(fullName: String) -> String {
        let parts = fullName.split(separator: " ")
        if let last = parts.last {
            return String(last)
        }
        return fullName
    }

    private func resolvedFormation(
        _ formation: String?,
        playerCount: Int
    ) -> String {
        if let formation, !formation.isEmpty {
            return formation
        }

        return playerCount >= 11 ? "4-3-3" : "4-4-2"
    }

    private func resolvedPosition(raw: String?, index: Int) -> PlayerPosition {
        let value = (raw ?? "").lowercased()

        if value.contains("goalkeeper") || value.contains("keeper") {
            return .goalkeeper
        }

        if value.contains("back")
            || value.contains("defender")
            || value.contains("centre-back")
            || value.contains("center-back") {
            return .defender
        }

        if value.contains("midfield")
            || value.contains("midfielder")
            || value.contains("wing")
            || value.contains("winger") {
            return .midfielder
        }

        if value.contains("forward")
            || value.contains("striker")
            || value.contains("attacker") {
            return .forward
        }

        switch index {
        case 0:
            return .goalkeeper
        case 1...4:
            return .defender
        case 5...7:
            return .midfielder
        default:
            return .forward
        }
    }

    // MARK: - Text Builders

    private func makeInfoText(
        homeFormation: String?,
        awayFormation: String?,
        homeCount: Int,
        awayCount: Int
    ) -> String {
        """
        Статус: \(match.status.displayName)
        Стадион: \(formattedVenue)

        Домашняя команда:
        Схема: \(homeFormation ?? "Не указана")
        Игроков в составе: \(homeCount)

        Гостевая команда:
        Схема: \(awayFormation ?? "Не указана")
        Игроков в составе: \(awayCount)
        """
    }

    private var formattedVenue: String {
        guard let venue = match.venue, !venue.isEmpty else {
            return "Не указан"
        }
        return venue
    }

    // MARK: - Date Formatting

    private static func makeDateText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM"
        return formatter.string(from: date)
    }

    private static func makeTimeText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private static func makeCenterText(from match: Match) -> String {
        if match.status == .finished, let scoreText = match.score?.displayText {
            return scoreText
        }

        return makeTimeText(from: match.utcDate)
    }
}
