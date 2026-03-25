//
//  SearchTeamsCollectionManager.swift
//  Footbalchik New
//
//  Created by Nick on 19.05.2026.
//


import UIKit

final class SearchTeamsCollectionManager: NSObject {
    private let viewModel: SearchTeamsViewModel
    var onTeamSelected: ((Team) -> Void)?
    
    init(viewModel: SearchTeamsViewModel) {
        self.viewModel = viewModel
    }
}

extension SearchTeamsCollectionManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.teams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCardCell.reuseId, for: indexPath) as? TeamCardCell else {
            return UICollectionViewCell()
        }
        let team = viewModel.teams[indexPath.item]
        let isFavorite = viewModel.isFavorite(teamId: team.id ?? 0)
        cell.configure(with: team, isFavorite: isFavorite)
        cell.onFavoriteTapped = { [weak self] team, _ in
            self?.viewModel.toggleFavorite(teamId: team.id ?? 0, team: team)
        }
        return cell
    }
}

extension SearchTeamsCollectionManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let team = viewModel.teams[indexPath.item]
        onTeamSelected?(team)
    }
}
