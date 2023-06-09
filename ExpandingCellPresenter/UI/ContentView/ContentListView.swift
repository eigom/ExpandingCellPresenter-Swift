//
//  ContentListView.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 28.03.2023.
//

import UIKit

class ContentListView: UIView {
    let tableView = UITableView()

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .lightGray

        tableView.register(
            ContentCell.self,
            forCellReuseIdentifier: ContentCell.reuseIdentifier
        )
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }

    private func layout() {
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: .init(top: 20, left: 20, bottom: 20, right: 20))
    }
}
