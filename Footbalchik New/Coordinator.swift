//
//  MatchSearchBarView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let container: AppDIContainer
    
    init(
        navigationController: UINavigationController,
        container: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let tabBarController = MainTabBarController(
            matchService: container.matchService,
            teamService: container.teamService,
            leagueService: container.leagueService,
            standingsService: container.standingsService,
            favoriteStorage: container.favoriteStorage
        )
        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
