//
//  MatchSearchBarView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

struct AppTheme {
    let backgroundColor: UIColor
    let defaultAccents: [UIColor]
    let statusBarStyle: UIStatusBarStyle

    static let liquidDark = AppTheme(
        backgroundColor: .black,
        defaultAccents: [UIColor.systemGreen, UIColor.systemBlue],
        statusBarStyle: .lightContent
    )
}

final class ThemeManager {
    static let shared = ThemeManager()
    private init() {}

    private(set) var current: AppTheme = .liquidDark

    func apply(to baseVC: BaseViewController) {
        baseVC.view.backgroundColor = current.backgroundColor
        baseVC.updateAccentColors(current.defaultAccents)
    }
}
