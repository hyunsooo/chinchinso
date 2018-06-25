//
//  GetHashCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 1. 25..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import Alamofire
import SwiftyJSON

class GetHashCell: UICollectionViewCell {
    
    var hashId: Int?
    var delegate: MyHashControllerDelegate?
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "#해쉬태그"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textColor = Color.shared.font
        return lb
    }()
    
    lazy var getButton: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "plus").fillColor(Color.shared.orangeYellow))    // default +
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getHash)))
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.shared.background
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        addSubview(nameLabel)
        addSubview(getButton)
        
        nameLabel.anchor(nil, left: leftAnchor, bottom: nil, right: getButton.leftAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 40)
        nameLabel.anchorCenterYToSuperview()
        getButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 32, heightConstant: 32)
        getButton.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension GetHashCell: CellProtocol {
    typealias Item = Model.Hash
    func update(data: Model.Hash) {
        nameLabel.text = data.hash_name
        hashId = data.sid
    }
    
    @objc fileprivate func getHash() {
        guard let hash = hashId else { return }
        App.api.getHash(hashId: hash) { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                guard let delegate = self.delegate else { return }
                if data["result"].intValue == 0 { delegate.refresh() }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
}
