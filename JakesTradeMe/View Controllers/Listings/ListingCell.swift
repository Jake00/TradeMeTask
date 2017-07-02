//
//  ListingCell.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit

class ListingCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let previewImageView = UIImageView()
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        titleLabel.textColor = .darkGray
        titleLabel.numberOfLines = 0
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.backgroundColor = .offWhite
        
        [titleLabel, previewImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: 10),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: 100),
            previewImageView.heightAnchor.constraint(equalTo: previewImageView.widthAnchor)
            ])
    }
}
