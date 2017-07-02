//
//  LoadingCell.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let centerLayoutGuide = UILayoutGuide()
    let loadingText = NSLocalizedString("loading_cell.loading",
                                        value: "Loading...",
                                        comment: "Indicator that the application is loading.")
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addLayoutGuide(centerLayoutGuide)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        titleLabel.textColor = .darkGray
        titleLabel.text = loadingText
        
        [titleLabel, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: centerLayoutGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: centerLayoutGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: centerLayoutGuide.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 5),
            activityIndicator.leadingAnchor.constraint(equalTo: centerLayoutGuide.leadingAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerLayoutGuide.centerYAnchor),
            centerLayoutGuide.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            centerLayoutGuide.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
}
