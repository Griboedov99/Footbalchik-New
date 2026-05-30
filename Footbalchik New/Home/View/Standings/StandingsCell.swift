//
//  StandingsCell.swift
//  Footbalchik
//

import UIKit

final class StandingsCell: UICollectionViewCell {

    static let reuseId = "StandingsCell"

    private let card = StandingsCardView()

    var onLayoutChange: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(card)
        // прижимаем ко всем краям — это даёт ячейке самоопределяемую высоту для .estimated
        card.pin(to: contentView)

        // пробрасываем запрос на пересчёт высоты наверх (для invalidateLayout)
        card.onLayoutChange = { [weak self] in
            self?.onLayoutChange?()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(rows: [TableRow]) {
        card.configure(rows: rows)
    }
}