//
//  MenuCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 12..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit

protocol CellProtocol {
    associatedtype Item
    func update(data: Item)
}

final class MenuCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        return lb
    }()
    let newImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "heart"))
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = isHighlighted ? .gray : .white
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .gray : .white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        self.addSubview(newImage)
        titleLabel.anchor(nil, left: leftAnchor, bottom: nil, right: newImage.leftAnchor, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 30)
        titleLabel.anchorCenterYToSuperview()
        newImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        newImage.anchor(nil, left: titleLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: 20, heightConstant: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MenuCell: CellProtocol {
    typealias Item = Model.Menu
    
    func update(data issue: Model.Menu) {
        titleLabel.text = issue.title
        newImage.isHidden = !issue.isNew
    }
}
