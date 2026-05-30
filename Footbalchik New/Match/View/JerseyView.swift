//
//  JerseyView.swift
//  Footbalchik New
//
//  Created by Nick on 28.04.2026.
//


import UIKit

final class JerseyView: UIView {

    enum Style {
        case home, away, goalkeeper

        var base: UIColor {
            switch self {
            case .home:       return UIColor(red: 0.86, green: 0.16, blue: 0.21, alpha: 1) // красный
            case .away:       return UIColor(red: 0.11, green: 0.30, blue: 0.78, alpha: 1) // синий
            case .goalkeeper: return UIColor(red: 0.10, green: 0.62, blue: 0.36, alpha: 1) // зелёный
            }
        }
    }

    private let numberLabel = UILabel()
    private let nameLabel = UILabel()
    private var style: Style = .home

    // доля высоты под саму футболку, остальное — подпись с фамилией
    private let jerseyHeightRatio: CGFloat = 0.74

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        setupLabels()
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: 48, height: 64) }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLabels() {
        numberLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        numberLabel.textAlignment = .center
        numberLabel.textColor = .white
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.minimumScaleFactor = 0.5
        addSubview(numberLabel)

        nameLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.6
        addSubview(nameLabel)
    }

    func configure(number: Int?, name: String?, style: Style) {
        self.style = style
        numberLabel.text = number.map(String.init) ?? ""
        nameLabel.text = name
        setNeedsDisplay()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        let jerseyH = bounds.height * jerseyHeightRatio
        numberLabel.frame = CGRect(x: bounds.width * 0.22, y: jerseyH * 0.38,
                                   width: bounds.width * 0.56, height: jerseyH * 0.44)
        nameLabel.frame = CGRect(x: 0, y: jerseyH + 2,
                                 width: bounds.width, height: bounds.height - jerseyH - 2)
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let w = rect.width
        let h = rect.height * jerseyHeightRatio
        let path = jerseyPath(width: w, height: h)

        // тень под футболкой
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 2), blur: 6,
                      color: UIColor.black.withAlphaComponent(0.35).cgColor)
        style.base.setFill()
        path.fill()
        ctx.restoreGState()

        // лёгкий вертикальный градиент для объёма, клипованный по форме
        ctx.saveGState()
        path.addClip()
        let colors = [style.base.lighter(0.12).cgColor,
                      style.base.cgColor,
                      style.base.darker(0.10).cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors, locations: [0, 0.55, 1]) {
            ctx.drawLinearGradient(gradient, start: .zero,
                                   end: CGPoint(x: 0, y: h), options: [])
        }
        ctx.restoreGState()

        // тонкий контур
        UIColor.black.withAlphaComponent(0.18).setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    private func jerseyPath(width w: CGFloat, height h: CGFloat) -> UIBezierPath {
        func p(_ fx: CGFloat, _ fy: CGFloat) -> CGPoint { CGPoint(x: w * fx, y: h * fy) }
        let path = UIBezierPath()
        path.move(to:    p(0.42, 0.14))                                  // левый край горловины
        path.addLine(to: p(0.30, 0.05))                                  // левое плечо
        path.addLine(to: p(0.02, 0.18))                                  // левый рукав, верх
        path.addLine(to: p(0.12, 0.44))                                  // левый рукав, низ
        path.addLine(to: p(0.28, 0.32))                                  // левая подмышка
        path.addLine(to: p(0.30, 0.96))                                  // низ слева
        path.addLine(to: p(0.70, 0.96))                                  // низ справа
        path.addLine(to: p(0.72, 0.32))                                  // правая подмышка
        path.addLine(to: p(0.88, 0.44))                                  // правый рукав, низ
        path.addLine(to: p(0.98, 0.18))                                  // правый рукав, верх
        path.addLine(to: p(0.70, 0.05))                                  // правое плечо
        path.addLine(to: p(0.58, 0.14))                                  // правый край горловины
        path.addQuadCurve(to: p(0.42, 0.14), controlPoint: p(0.50, 0.26))// вырез горловины
        path.close()
        path.lineJoinStyle = .round
        return path
    }
}

private extension UIColor {
    func lighter(_ a: CGFloat) -> UIColor { adjust(a) }
    func darker(_ a: CGFloat) -> UIColor { adjust(-a) }
    private func adjust(_ a: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, alpha: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &alpha) else { return self }
        return UIColor(red:   min(max(r + a, 0), 1),
                       green: min(max(g + a, 0), 1),
                       blue:  min(max(b + a, 0), 1), alpha: alpha)
    }
}
