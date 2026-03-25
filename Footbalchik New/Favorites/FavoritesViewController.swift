//
//  FavoritesViewController.swift
//  Footbalchik New
//
//  Created by Nick on 25.05.2026.
//


//
//  FavoritesViewController.swift
//  Footbalchik
//

import UIKit

final class FavoritesViewController: BaseViewController {
    
    private let favoriteStorage: FavoriteTeamStorage
    private var collectionView: UICollectionView!
    private var favorites: [Team] = []
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(favoriteStorage: FavoriteTeamStorage) {
        self.favoriteStorage = favoriteStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        setupCollectionView()
        setupEmptyStateLabel()
        setupActivityIndicator()
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites() // Обновляем при каждом появлении экрана
    }
    
    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TeamCardCell.self, forCellWithReuseIdentifier: TeamCardCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.pin(to: view)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 12
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupEmptyStateLabel() {
        emptyStateLabel.text = "No favorite teams yet\nSearch and add teams to favorites"
        emptyStateLabel.textColor = .white.withAlphaComponent(0.7)
        emptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        emptyStateLabel.pinCenter(to: view)
        emptyStateLabel.pinLeft(to: view, 32)
        emptyStateLabel.pinRight(to: view, 32)
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.pinCenter(to: view)
    }
    
    private func loadFavorites() {
        activityIndicator.startAnimating()
        
        favoriteStorage.getAllFavorites { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let teams):
                    self?.favorites = teams
                    self?.collectionView.reloadData()
                    self?.emptyStateLabel.isHidden = !teams.isEmpty
                case .failure(let error):
                    print("Failed to load favorites: \(error)")
                    self?.emptyStateLabel.isHidden = false
                    self?.emptyStateLabel.text = "Error loading favorites\n\(error.localizedDescription)"
                }
            }
        }
    }
    
    private func removeFromFavorites(teamId: Int, at indexPath: IndexPath) {
        favoriteStorage.removeFavorite(teamId: teamId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.favorites.remove(at: indexPath.item)
                    self?.collectionView.deleteItems(at: [indexPath])
                    self?.emptyStateLabel.isHidden = !(self?.favorites.isEmpty ?? true)
                case .failure(let error):
                    print("Failed to remove favorite: \(error)")
                    // Показываем алерт об ошибке
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to remove from favorites: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func showTeamDetails(team: Team) {
        // TODO: Создать экран деталей команды
        let alert = UIAlertController(
            title: team.name,
            message: "Team details will be implemented later",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TeamCardCell.reuseId,
            for: indexPath
        ) as? TeamCardCell else {
            return UICollectionViewCell()
        }
        
        let team = favorites[indexPath.item]
        cell.configure(with: team, isFavorite: true)
        cell.onFavoriteTapped = { [weak self] team, _ in
            self?.removeFromFavorites(teamId: team.id ?? 0, at: indexPath)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let team = favorites[indexPath.item]
        showTeamDetails(team: team)
    }
}

// MARK: - UICollectionViewDelegate Flow Layout (для swipe-to-delete)

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            let team = self?.favorites[indexPath.item]
            if let teamId = team?.id {
                self?.removeFromFavorites(teamId: teamId, at: indexPath)
            }
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
