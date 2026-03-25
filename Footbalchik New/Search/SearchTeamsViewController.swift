//
//  SearchTeamsViewController.swift
//  Footbalchik New
//
//  Created by Nick on 16.04.2026.
//


import UIKit

final class SearchTeamsViewController: BaseViewController {

    private let viewModel: SearchTeamsViewModel
    private var collectionManager: SearchTeamsCollectionManager!
    private var collectionView: UICollectionView!
    private let searchBar = UISearchBar()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()

    init(viewModel: SearchTeamsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        setupActivityIndicator()
        setupEmptyLabel()
        bind()
        viewModel.loadSuggestions()
    }

    private func setupSearchBar() {
        searchBar.placeholder = "Search team by name"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.tintColor = .white
        searchBar.delegate = self
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.attributedPlaceholder = NSAttributedString(string: "Search team...", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        }
        view.addSubview(searchBar)
        searchBar.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 8)
        searchBar.pinLeft(to: view, 8)
        searchBar.pinRight(to: view, 8)
        searchBar.setHeight(mode: .equal, 50)
    }

    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TeamCardCell.self, forCellWithReuseIdentifier: TeamCardCell.reuseId)
        view.addSubview(collectionView)
        collectionView.pinTop(to: searchBar.bottomAnchor, 8)
        collectionView.pinLeft(to: view)
        collectionView.pinRight(to: view)
        collectionView.pinBottom(to: view)

        collectionManager = SearchTeamsCollectionManager(viewModel: viewModel)
        collectionView.dataSource = collectionManager
        collectionView.delegate = collectionManager
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        section.interGroupSpacing = 12
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupActivityIndicator() {
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.pinCenter(to: view)
    }

    private func setupEmptyLabel() {
        emptyLabel.text = "No teams found"
        emptyLabel.textColor = .white.withAlphaComponent(0.7)
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        emptyLabel.pinCenter(to: view)
    }

    private func bind() {
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
            let isEmpty = self?.viewModel.teams.isEmpty ?? true
            self?.emptyLabel.isHidden = !isEmpty
        }
        viewModel.onError = { [weak self] errorMsg in
            self?.showAlert(message: errorMsg)
        }
        viewModel.onLoadingChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshFavoriteStatuses()
    }
}

extension SearchTeamsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text else { return }
        viewModel.searchTeams(query: query)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.searchTeams(query: "")
        }
    }
}
