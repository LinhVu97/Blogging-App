//
//  PayWallDescriptionView.swift
//  BloggingApp
//
//  Created by Linh Vu on 28/10/24.
//

import UIKit

class PayWallDescriptionView: UIView {
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Join Blog Premium to read unlimited articles and browse thousands of posts."
        label.font = .systemFont(ofSize: 26, weight: .medium)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$2.99 / month"
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(descriptionLabel)
        addSubview(priceLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionLabel.frame = CGRect(x: 20, y: 0, width: width - 40, height: height/2)
        priceLabel.frame = CGRect(x: 10, y: height/2, width: width - 40, height: height/2)
    }
}
