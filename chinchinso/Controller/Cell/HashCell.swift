//
//  HashCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 1. 25..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HashCell: UITableViewCell {

    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "#해쉬태그"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textColor = Color.shared.font
        return lb
    }()
    
    lazy var modifyButton: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "plus"))    // default +
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(modifyHash)))
        return iv
    }()
    
    let addHashInput: UITextField = {
        let tf = UITextField()
        return tf
    }()
    
    var isMain: Bool = false
    var hashId: Int = -1
    var delegate: MyHashControllerDelegate?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(nameLabel)
        addSubview(modifyButton)
        
        nameLabel.anchor(nil, left: leftAnchor, bottom: nil, right: modifyButton.leftAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 40)
        nameLabel.anchorCenterYToSuperview()
        modifyButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 32, heightConstant: 32)
        modifyButton.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension HashCell: CellProtocol {
    typealias Item = Model.Hash
    func update(data: Model.Hash) {
        nameLabel.text = "#\(data.hash_name)"
        modifyButton.image = data.open == 0 ? #imageLiteral(resourceName: "plus") : #imageLiteral(resourceName: "minus")
        isMain = data.open == 1
        hashId = data.sid
    }
    
    @objc fileprivate func modifyHash() {
        guard hashId != -1, let count = GlobalState.instance.hashCount else { return }
        if !isMain && count == 3 { print("사용할 해쉬가 꽉찼습니다."); return }
        App.api.modHash(hashId: hashId, open: isMain ? 0 : 1, handler: { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                guard let delegate = self.delegate else { return }
                if data["result"].intValue == 0 { delegate.refresh() }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        })
    }
}
