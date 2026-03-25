//
//  HomeViewModel.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class HomeViewController: BaseViewController {
    
    private let viewModel: HomeViewModel
    var onMatchSelected: ((Match) -> Void)?
    
    private lazy var collectionManager = HomeCollectionManager(viewModel: viewModel)
    private var collectionView: UICollectionView!
    private let leagueSelector = LeagueSelectorView()
    private let refreshControl = UIRefreshControl()
    private var isSelectorVisible = false
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeagueSelector()
        setupCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Скрываем navigation bar когда показываем главный экран
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.refreshFavorites()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Показываем navigation bar когда уходим с главного экрана
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupLeagueSelector() {
        leagueSelector.delegate = self
        view.addSubview(leagueSelector)
        leagueSelector.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 8)
        leagueSelector.pinLeft(to: view)
        leagueSelector.pinRight(to: view)
        leagueSelector.setHeight(mode: .equal, 50)
        
        // Изначально скрываем, пока не загрузим лиги
        leagueSelector.alpha = 0
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: HomeLayoutFactory.create()
        )
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        
        view.addSubview(collectionView)
        collectionView.pinTop(to: leagueSelector.bottomAnchor, 8)
        collectionView.pinLeft(to: view)
        collectionView.pinRight(to: view)
        collectionView.pinBottom(to: view)
        
        collectionView.dataSource = collectionManager
        collectionView.delegate = collectionManager
        
        collectionView.register(
            MatchCardCell.self,
            forCellWithReuseIdentifier: MatchCardCell.reuseId
        )
        
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseId
        )
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .white
    }
    
    @objc private func refreshData() {
        if let league = viewModel.currentLeague {
            viewModel.loadData(for: league, forceRefresh: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func bind() {
        collectionManager.onMatchSelected = { [weak self] match in
            self?.onMatchSelected?(match)
        }
        
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.onError = { [weak self] error in
            print("HomeViewModel error:", error)
            self?.showErrorAlert(message: error)
        }
        
        viewModel.onLoadingChanged = { isLoading in
            // Можно показать индикатор загрузки
        }
        
        viewModel.onLeaguesLoaded = { [weak self] leagues in
            guard let self = self,
                  let selectedLeague = self.viewModel.currentLeague else { return }
            
            self.leagueSelector.configure(with: leagues, selectedLeague: selectedLeague)
            
            // Анимация появления селектора
            UIView.animate(withDuration: 0.3) {
                self.leagueSelector.alpha = 1
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - LeagueSelectorDelegate

extension HomeViewController: LeagueSelectorDelegate {
    func didSelectLeague(_ league: League) {
        viewModel.loadData(for: league)
    }
}
