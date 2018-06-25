//
//  NewDateCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 16..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit

class NewDateCell: UICollectionViewCell {
    
    let nd_imageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()
    
    let nd_nameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16)
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(nd_imageView)
        self.addSubview(nd_nameLabel)
        self.layer.cornerRadius = 5
        nd_imageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        nd_imageView.anchorCenterYToSuperview()
        nd_imageView.anchorCenterXToSuperview(constant: -40)
        nd_nameLabel.centerYAnchor.constraint(equalTo: nd_imageView.centerYAnchor).isActive = true
        nd_nameLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 30)
        nd_nameLabel.anchorCenterXToSuperview(constant: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Color.shared.orangeYellow : Color.shared.background
        }
    }
}

extension NewDateCell: CellProtocol {
    typealias Item = Model.User
    func update(data date: Item) {
        nd_nameLabel.text = date.name
        if let url = date.profileUrl {
            nd_imageView.af_setImage(withURL: url)
        }
    }
}
