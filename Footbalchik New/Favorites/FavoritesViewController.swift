//
//  FavoritesViewController.swift
//  Footbalchik New
//
//  Created by Nick on 02.05.2026.
//


import UIKit

final class FavoritesViewController: BaseViewController {

    private let viewModel: FavoritesViewModel
    private var collectionView: UICollectionView!
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        setupTransparentNavBar()
        setupCollectionView()
        setupEmptyStateLabel()
        setupActivityIndicator()
        bind()
        viewModel.loadFavorites()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites() // обновляем при каждом появлении экрана
    }

    // MARK: - Setup

    private func setupTransparentNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
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

    // MARK: - Binding

    private func bind() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            self.emptyStateLabel.isHidden = !self.viewModel.isEmpty
        }

        viewModel.onLoadingChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }

        viewModel.onError = { [weak self] message in
            self?.emptyStateLabel.isHidden = false
            self?.emptyStateLabel.text = "Error loading favorites\n\(message)"
        }
    }

    // MARK: - Actions

    private func removeFromFavorites(at indexPath: IndexPath) {
        viewModel.removeFavorite(at: indexPath.item) { [weak self] success in
            guard let self, success else { return }
            self.collectionView.deleteItems(at: [indexPath])
            self.emptyStateLabel.isHidden = !self.viewModel.isEmpty
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
        viewModel.favorites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TeamCardCell.reuseId,
            for: indexPath
        ) as? TeamCardCell else {
            return UICollectionViewCell()
        }

        let team = viewModel.team(at: indexPath.item)
        cell.configure(with: team, isFavorite: true)
        cell.onFavoriteTapped = { [weak self] _, _ in
            self?.removeFromFavorites(at: indexPath)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let team = viewModel.team(at: indexPath.item)
        showTeamDetails(team: team)
    }
}

// MARK: - Swipe to delete

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.removeFromFavorites(at: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
