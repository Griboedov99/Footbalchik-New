//
//  HomeCollectionManager.swift
//  Footbalchik
//
//  Created by Nick on 21.03.2026.
//


import UIKit

final class HomeCollectionManager: NSObject {

    private let viewModel: HomeViewModel
    var onMatchSelected: ((Match) -> Void)?

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Helpers

    private func match(at indexPath: IndexPath) -> Match {
        switch HomeSection(rawValue: indexPath.section) {
        case .favorites:
            return viewModel.favoriteMatches[indexPath.item]
        case .matches:
            return viewModel.leagueMatches[indexPath.item]
        default:
            return viewModel.leagueMatches[indexPath.item]   // для .standings сюда не заходим
        }
    }
}

// MARK: - DataSource

extension HomeCollectionManager: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSection.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        guard let section = HomeSection(rawValue: section) else { return 0 }

        switch section {
        case .favorites:
            return viewModel.favoriteMatches.count
        case .standings:
            return viewModel.standings.isEmpty ? 0 : 1   // одна карточка-таблица, или 0 если данных нет
        case .matches:
            return viewModel.leagueMatches.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        // Секция таблицы — отдельная ячейка, перехватываем до MatchCardCell
        if HomeSection(rawValue: indexPath.section) == .standings {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StandingsCell.reuseId,
                for: indexPath
            ) as? StandingsCell else {
                return UICollectionViewCell()
            }

            cell.configure(rows: viewModel.standings)
            cell.onLayoutChange = { [weak collectionView] in
                collectionView?.collectionViewLayout.invalidateLayout()
            }
            return cell
        }

        // Матчи (favorites + matches)
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchCardCell.reuseId,
            for: indexPath
        ) as? MatchCardCell else {
            return UICollectionViewCell()
        }

        let match = match(at: indexPath)

        var day: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: match.utcDate)
        }

        var time: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: match.utcDate)
        }

        let vm = MatchCardViewModel(
            homeTeamName: match.homeTeam.displayName,
            awayTeamName: match.awayTeam.displayName,
            homeLogoURL: match.homeTeam.crest,
            awayLogoURL: match.awayTeam.crest,
            dateText: day,
            timeText: time,
            isLive: match.status.isLive
        )

        cell.configure(with: vm)
        cell.onTap = { [weak self] in
            guard let self else { return }
            let selectedMatch = self.match(at: indexPath)
            self.onMatchSelected?(selectedMatch)
        }

        return cell
    }
}

// MARK: - Delegate

extension HomeCollectionManager: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard HomeSection(rawValue: indexPath.section) != .standings else { return }
        let match = match(at: indexPath)
        onMatchSelected?(match)
    }
}
