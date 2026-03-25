//
//  BaseViewController.swift
//  Footbalchik
//

import UIKit

class BaseViewController: UIViewController {
    private let backgroundView = UIView()
    private let glassEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let accentGradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureGlassEffect()
        configureAccent()
        
        // Настройка отступов для безопасной зоны
        additionalSafeAreaInsets = .zero
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func configureBackground() {
        view.addSubview(backgroundView)
        backgroundView.pin(to: view)
        backgroundView.backgroundColor = .black
    }

    private func configureGlassEffect() {
        view.addSubview(glassEffectView)
        glassEffectView.pin(to: view)
        glassEffectView.isUserInteractionEnabled = false
        glassEffectView.alpha = 0.85
    }

    private func configureAccent() {
        accentGradientLayer.colors = [
            UIColor.systemGreen.withAlphaComponent(0.15).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        ]
        accentGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        accentGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(accentGradientLayer, below: glassEffectView.layer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        accentGradientLayer.frame = view.bounds
    }

    func updateAccentColors(_ colors: [UIColor]) {
        let cgColors = colors.map { $0.withAlphaComponent(0.15).cgColor }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        accentGradientLayer.colors = cgColors.isEmpty ? [
            UIColor.systemGreen.withAlphaComponent(0.15).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        ] : cgColors
        CATransaction.commit()
    }
}
