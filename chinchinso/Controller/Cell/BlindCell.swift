//
//  BlindCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 24..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import AlamofireImage
import LBTAComponents

class BlindCell: UICollectionViewCell {
   
    let blindImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(blindImageView)
        blindImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


extension BlindCell: CellProtocol {
    typealias Item = URL
    func update(data url: Item) {
        blindImageView.af_setImage(withURL: url)
    }
}
