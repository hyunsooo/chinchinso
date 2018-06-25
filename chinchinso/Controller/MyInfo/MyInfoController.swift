//
//  MyInfoController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 27..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import LBTAComponents
import SwiftyJSON

class MyInfoController: BaseViewController {

    var info: Model.MyInfo? {
        didSet {
            guard let info = info else { return }
            print(info)
            if let url = info.profileUrl { profileImageView.af_setImage(withURL: url) }
            nameLabel.attributedText = NSMutableAttributedString(string: info.name, attributes: [.kern: 2])
            settingSwitch1.isOn = info.isAgreeDate
            settingSwitch2.isOn = info.isAgreeDate ? info.isAgreeOpenDate : false
            settingSwitch1.thumbTintColor = settingSwitch1.isOn ? Color.shared.orangeYellow : Color.shared.darkGreen
            settingSwitch2.thumbTintColor = settingSwitch2.isOn ? Color.shared.orangeYellow : Color.shared.darkGreen
            dataSource = info.pokeToMe
        }
    }
    let cellName = "PokeCell"
    var dataSource = [Model.Poke]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 45
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(myProfile)))
        return iv
    }()
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()
    
    let settingLabel1: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textAlignment = .left
        lb.text = "친친소 참여"
        return lb
    }()
    
    lazy var settingSwitch1: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = Color.shared.transparentOrangeYellow
        sw.tintColor = sw.isOn ? Color.shared.orangeYellow : Color.shared.darkGreen
        sw.addTarget(self, action: #selector(handleSetting), for: .valueChanged)
        return sw
    }()
    
    let settingLabel2: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textAlignment = .left
        lb.text = "오픈소개팅 참여"
        return lb
    }()
    
    lazy var settingSwitch2: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = Color.shared.transparentOrangeYellow
        sw.tintColor = sw.isOn ? Color.shared.orangeYellow : Color.shared.darkGreen
        sw.addTarget(self, action: #selector(handleSetting2), for: .valueChanged)
        return sw
    }()
    
    let pokeToMeLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textAlignment = .left
        lb.text = "나의 콕찌르기"
        return lb
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.darkGreen
        cv.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        cv.layer.cornerRadius = 5
        cv.layer.masksToBounds = true
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        App.api.getMyInfo { [weak self] (dataResponse: DataResponse<Model.MyInfo>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                self.info = data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initView() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(settingLabel1)
        view.addSubview(settingLabel2)
        view.addSubview(settingSwitch1)
        view.addSubview(settingSwitch2)
        view.addSubview(pokeToMeLabel)
        view.addSubview(collectionView)
        
        profileImageView.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: 90)
        profileImageView.anchorCenterXToSuperview()
        nameLabel.anchor(profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 30)
        nameLabel.anchorCenterXToSuperview()
        settingLabel1.anchor(nameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        settingLabel1.anchorCenterXToSuperview(constant: -25)
        settingLabel2.anchor(settingLabel1.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        settingLabel2.anchorCenterXToSuperview(constant: -25)
        settingSwitch1.anchor(nameLabel.bottomAnchor, left: settingLabel1.rightAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 30)
        settingSwitch2.anchor(settingLabel1.bottomAnchor, left: settingLabel2.rightAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 30)
        pokeToMeLabel.anchor(settingLabel2.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 30, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 30)
        collectionView.anchor(pokeToMeLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 150)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PokeCell.self, forCellWithReuseIdentifier: cellName)
    }
}

extension MyInfoController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? PokeCell else { return PokeCell() }
        cell.update(data: dataSource[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}


extension MyInfoController {
    
    // 소개팅 설정
    @objc fileprivate func handleSetting() {
        App.api.modifyDateStatus(yn: settingSwitch1.isOn ? "y" : "n") { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                if data["result"].intValue == 0 {
                    print(data["yn"].stringValue == "y" ? "데이트를 합니다." : "데이트를 쉽니다.")
                    self.settingSwitch1.thumbTintColor = data["yn"].stringValue == "y" ? Color.shared.orangeYellow : Color.shared.darkGreen
                    if !self.settingSwitch1.isOn {
                        self.settingSwitch2.setOn(false, animated: true)
                        self.handleSetting2()
                        self.settingSwitch2.isEnabled = false
                    } else {
                        self.settingSwitch2.thumbTintColor = self.settingSwitch2.isOn ? Color.shared.orangeYellow : Color.shared.darkGreen
                        self.settingSwitch2.isEnabled = true
                    }
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
    // 오픈소개팅 설정
    @objc fileprivate func handleSetting2() {
        App.api.modifyOpenDateStatus(yn: settingSwitch2.isOn ? "y" : "n") { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                if data["result"].intValue == 0 {
                    print(data["yn"].stringValue == "y" ? "오픈 소개팅을 합니다." : "오픈 소개팅을 쉽니다.")
                    self.settingSwitch2.thumbTintColor = data["yn"].stringValue == "y" ? Color.shared.orangeYellow : Color.shared.darkGreen
                    if let delegate = SlideMenu.shared.openDateControllerDelegate { delegate.refresh() }    // 오픈소개팅 리로드
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
    @objc fileprivate func myProfile() {
        App.api.getMyProfile { [weak self] (dataResponse: DataResponse<Model.Profile>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                let myProfileController = MyProfileController()
                myProfileController.profile = data
                self.navigationController?.modalPresentationStyle = .overFullScreen
                self.navigationController?.pushViewController(myProfileController, animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

