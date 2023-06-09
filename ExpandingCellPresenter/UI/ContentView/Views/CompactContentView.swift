//
//  CompactContentView.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 28.03.2023.
//

import UIKit

class CompactContentView: UIView {
    let titleLabel = UILabel()
    let textLabel = UILabel()

    private let stackView = UIStackView()

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 5

        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0

        textLabel.font = .systemFont(ofSize: 15)
        textLabel.numberOfLines = 0
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .init(top: 20, left: 20, bottom: 20, right: 20))

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textLabel)
    }
}
