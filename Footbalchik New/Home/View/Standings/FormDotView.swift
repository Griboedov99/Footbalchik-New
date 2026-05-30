//
//  FormDotView.swift
//  Footbalchik New
//
//  Created by Nick on 20.05.2026.
//


import UIKit

final class FormDotView: UIView {

    private let icon = UIImageView()
    private let dotSize: Double

    init(result: FormResult, size: Double = 16) {
        self.dotSize = size
        super.init(frame: .zero)
        setup(result: result)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup(result: FormResult) {
        layer.cornerRadius = CGFloat(dotSize) / 2
        setWidth(mode: .equal, dotSize)
        setHeight(mode: .equal, dotSize)

        let config = UIImage.SymbolConfiguration(pointSize: CGFloat(dotSize) * 0.55, weight: .bold)
        switch result {
        case .win:
            backgroundColor = .systemGreen
            icon.image = UIImage(systemName: "checkmark", withConfiguration: config)
        case .loss:
            backgroundColor = .systemRed
            icon.image = UIImage(systemName: "xmark", withConfiguration: config)
        case .draw:
            backgroundColor = .systemGray
            icon.image = UIImage(systemName: "minus", withConfiguration: config)
        }

        icon.tintColor = .white
        icon.contentMode = .center

        addSubview(icon)
        icon.pinCenter(to: self)
    }
}
