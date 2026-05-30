//
//  MainTabBarController.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


//
//  MainTabBarController.swift
//  Footbalchik
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    private let matchService: MatchService
    private let teamService: TeamServicing
    private let leagueService: LeagueServicing
    private let standingsService: StandingsServicing
    private let favoriteStorage: FavoriteTeamStorage
    
    init(
        matchService: MatchService,
        teamService: TeamServicing,
        leagueService: LeagueServicing,
        standingsService: StandingsServicing,
        favoriteStorage: FavoriteTeamStorage
    ) {
        self.matchService = matchService
        self.teamService = teamService
        self.leagueService = leagueService
        self.standingsService = standingsService
        self.favoriteStorage = favoriteStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setupTabs()
    }
    
    private func setupTabs() {
        // Home tab
        let homeViewModel = HomeViewModel(
            matchService: matchService,
            leagueService: leagueService,
            standingsService: standingsService,
            favoriteStorage: favoriteStorage
        )
        let homeVC = HomeViewController(viewModel: homeViewModel)
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.setNavigationBarHidden(true, animated: false)
        
        homeVC.onMatchSelected = { [weak homeNav] match in
            let vm = MatchViewModel(match: match, matchService: self.matchService)
            let vc = MatchViewController(viewModel: vm)
            homeNav?.pushViewController(vc, animated: true)
        }
        
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // Search tab
        let searchViewModel = SearchTeamsViewModel(
            teamService: teamService,
            favoriteStorage: favoriteStorage
        )
        let searchVC = SearchTeamsViewController(viewModel: searchViewModel)
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )
        
        // Favorites tab
        let favoritesViewModel = FavoritesViewModel(favoriteStorage: favoriteStorage)
        let favoritesVC = FavoritesViewController(viewModel: favoritesViewModel)
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        // Profile tab
        let profileVC = UIViewController()
        profileVC.view.backgroundColor = .black
        let profileLabel = UILabel()
        profileLabel.text = "Profile Screen\nComing Soon"
        profileLabel.textColor = .white
        profileLabel.textAlignment = .center
        profileLabel.numberOfLines = 0
        profileVC.view.addSubview(profileLabel)
        profileLabel.pinCenter(to: profileVC.view)
        
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        viewControllers = [homeNav, searchNav, favoritesNav, profileNav]
        selectedIndex = 0
    }
    
    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemGreen
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
        
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        
        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor.systemGreen
        tabBar.unselectedItemTintColor = UIColor.lightGray
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = UIColor.systemGreen
    }
}
