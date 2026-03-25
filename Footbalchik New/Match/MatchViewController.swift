//
//  FootballFieldViewController.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class MatchViewController: BaseViewController {

    // MARK: - Properties

    private let match: Match
    private let matchService: MatchService

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let headerCard = MatchHeaderCardView()
    private let pitchView = FootballPitchView()
    private let infoCard = MatchInfoCardView()
    private let loadingLabel = UILabel()

    // MARK: - Init

    init(match: Match, matchService: MatchService) {
        self.match = match
        self.matchService = matchService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
        configureInitialState()
        loadMatchDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Убеждаемся что navigation bar виден
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupAppearance() {
        view.backgroundColor = .black
        title = "\(match.homeTeam.displayName) - \(match.awayTeam.displayName)"
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        scrollView.pinLeft(to: view)
        scrollView.pinRight(to: view)
        scrollView.pinBottom(to: view)

        contentView.pinTop(to: scrollView)
        contentView.pinLeft(to: scrollView)
        contentView.pinRight(to: scrollView)
        contentView.pinBottom(to: scrollView)
        contentView.pinWidth(to: view)

        stackView.axis = .vertical
        stackView.spacing = 20

        stackView.pinTop(to: contentView, 20)
        stackView.pinLeft(to: contentView, 16)
        stackView.pinRight(to: contentView, 16)
        stackView.pinBottom(to: contentView, 24)

        stackView.addArrangedSubview(headerCard)
        stackView.addArrangedSubview(pitchView)
        stackView.addArrangedSubview(loadingLabel)
        stackView.addArrangedSubview(infoCard)

        pitchView.setHeight(mode: .equal, 760)

        loadingLabel.textColor = .white.withAlphaComponent(0.82)
        loadingLabel.font = .systemFont(ofSize: 15, weight: .medium)
        loadingLabel.textAlignment = .center
        loadingLabel.numberOfLines = 0
    }

    // MARK: - Initial State

    private func configureInitialState() {
        configureHeader()
        configureEmptyPitch()
        showLoadingState()
        configureInitialInfo()
    }

    private func configureHeader() {
        headerCard.configure(
            homeTeamName: match.homeTeam.displayName,
            awayTeamName: match.awayTeam.displayName,
            homeLogoURL: match.homeTeam.crest,
            awayLogoURL: match.awayTeam.crest,
            dateText: Self.makeDateText(from: match.utcDate), 
            centerText: Self.makeCenterText(from: match),
            statusText: "",
        )
    }

    private func configureEmptyPitch() {
        pitchView.homePlayers = []
        pitchView.awayPlayers = []
    }

    private func configureInitialInfo() {
        infoCard.configure(
            title: "Информация о матче",
            text: """
            Статус: \(match.status.displayName)
            Стадион: \(formattedVenue)

            Составы пока не загружены.
            """
        )
    }

    // MARK: - Loading

    private func loadMatchDetails() {
        matchService.fetchMatchDetails(matchId: match.id) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let details):
                    self.handleLoadedDetails(details)

                case .failure(let error):
                    self.handleLoadingError(error)
                }
            }
        }
    }

    private func handleLoadedDetails(_ details: MatchDetailsResponse) {
        let homeLineup = details.homeTeam.lineup ?? []
        let awayLineup = details.awayTeam.lineup ?? []

        let homePlayers = makePlayers(
            from: homeLineup,
            teamId: details.homeTeam.id,
            formation: details.homeTeam.formation
        )

        let awayPlayers = makePlayers(
            from: awayLineup,
            teamId: details.awayTeam.id,
            formation: details.awayTeam.formation
        )

        pitchView.homePlayers = homePlayers
        pitchView.awayPlayers = awayPlayers

        if homePlayers.isEmpty && awayPlayers.isEmpty {
            switch match.status {
            case .scheduled, .timed:
                loadingLabel.text = "Стартовые составы пока еще не опубликованы"
            case .finished, .live, .inPlay, .paused:
                loadingLabel.text = "Составы отсутствуют в ответе API"
            default:
                loadingLabel.text = "Нет данных по составам"
            }
        } else {
            loadingLabel.text = nil
        }

        infoCard.configure(
            title: "Информация о матче",
            text: makeInfoText(
                homeFormation: details.homeTeam.formation,
                awayFormation: details.awayTeam.formation,
                homeCount: homePlayers.count,
                awayCount: awayPlayers.count
            )
        )
    }

    private func handleLoadingError(_ error: Error) {
        configureEmptyPitch()
        showErrorState()

        infoCard.configure(
            title: "Ошибка загрузки",
            text: """
            Статус: \(match.status.displayName)
            Стадион: \(formattedVenue)

            Ошибка:
            \(error.localizedDescription)
            """
        )
    }

    // MARK: - UI States

    private func showLoadingState() {
        loadingLabel.text = "Загрузка составов..."
    }

    private func showErrorState() {
        loadingLabel.text = "Не удалось загрузить составы"
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
