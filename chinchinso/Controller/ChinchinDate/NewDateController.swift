//
//  NewDateController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 14..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewDateController: UIViewController {
    let triangleView: UIView = UIView()
    let imageViewWidth: CGFloat = 70.0
    let cellName: String = "NewDateCell"
    
    var homeController: HomeController?
    var selectedMatchmaker: Model.User?
    var selectedBlind: Model.User?
    var isSelectedMatchmaker: Bool = false
    var myProfileUrl: URL? {
        didSet {
            guard let url = myProfileUrl else { return }
            myImageView.af_setImage(withURL: url)
        }
    }
    
    let myImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.cornerRadius = 35
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    let matchmakerImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.cornerRadius = 35
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    let blindImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.cornerRadius = 35
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    
    let mentionLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.text = "소개팅을 주선해 줄 친구를 선택해주세요."
        lb.textAlignment = .center
        lb.alpha = 0
        return lb
    }()
    
    let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = Color.shared.background
        cv.showsVerticalScrollIndicator = true
        cv.alwaysBounceVertical = true
        cv.alpha = 0
        return cv
    }()
    
    lazy var pickMatchmakerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("선택하기", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(Color.shared.orangeYellow, for: .normal)
        btn.backgroundColor = .white
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = Color.shared.orangeYellow.cgColor
        btn.addTarget(self, action: #selector(pickMatchmaker), for: .touchUpInside)
        btn.alpha = 0
        return btn
    }()
    
    var datasource = [Model.User]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.shared.background
        initNavigationBar()
        initTriangleView()
        loadAnimation {
            self.initCollectionView()
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseInOut, animations: {
                self.collectionView.alpha = 1
                self.mentionLabel.alpha = 1
            }, completion: nil)
        }
        
        App.api.getMatchmakerList { [weak self] (dataResponse: DataResponse<Model.MatchmakerList>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case.success(let data):
                self.datasource = data.matchmakers
            case .failure(let err):
                print(err)
            }
        }
    }
    
    fileprivate func initNavigationBar() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true       // bottom line hide
        
        self.title = "주선자 고르기"
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
}


extension NewDateController {
    @objc func back() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func pickMatchmaker() {
        
        if isSelectedMatchmaker {
            guard let blind = self.selectedBlind, let matchmaker = self.selectedMatchmaker else { return }
            App.api.pickBlind(matchmaker: matchmaker, blind: blind, handler: { [weak self] (dataResponse: DataResponse<Model.ChinchinDate>) in
                guard let `self` = self else { return }
                switch dataResponse.result {
                case .success(let data):
                    let blindController = BlindController()
                    blindController.date = data
                    blindController.homeController = self.homeController
                    self.present(blindController, animated: true, completion: { self.back() })
                case .failure(let err):
                    print(err)
                }
            })
            
        }
        else {
            guard let matchmaker = self.selectedMatchmaker else { return }
            debugPrint("matchmaker : \(matchmaker.sid)")
            App.api.pickMatchmaker(matchmaker: matchmaker) { [weak self] (dataResponse: DataResponse<Model.BlindList>) in
                guard let `self` = self else { return }
                switch dataResponse.result {
                case .success(let data):
                    self.mentionLabel.text = "\(matchmaker.name) 님의 친구를 선택해주세요."
                    self.datasource = data.blinds               // datasource를 소개팅 상대 리스트로 리세팅한다.
                    self.navigationItem.leftBarButtonItem = nil // 주선자를 선택하게 되면, 뒤로 돌아갈 수 없도록 한다.
                    self.isSelectedMatchmaker = true            //
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    
}

extension NewDateController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func initCollectionView() {
        view.addSubview(mentionLabel)
        view.addSubview(collectionView)
        view.addSubview(pickMatchmakerButton)
        mentionLabel.anchor(triangleView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 30)
        collectionView.anchor(mentionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 210)
        pickMatchmakerButton.anchor(collectionView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 100, bottomConstant: 0, rightConstant: 100, widthConstant: 0, heightConstant: 40)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NewDateCell.self, forCellWithReuseIdentifier: cellName)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? NewDateCell else { return NewDateCell() }
        let data = self.datasource[indexPath.row]
        cell.update(data: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if pickMatchmakerButton.alpha == 0 { UIView.animate(withDuration: 1) { self.pickMatchmakerButton.alpha = 1 } }
        if isSelectedMatchmaker {   // 소개팅 상대 고르기
            let blind = self.datasource[indexPath.row]
            self.selectedBlind = blind
            if let url = blind.profileUrl {
                blindImageView.af_setImage(withURL: url)
            }
        }
        else { // 주선자 고르기
            let matchmaker = self.datasource[indexPath.row]
            self.selectedMatchmaker = matchmaker
            if let url = matchmaker.profileUrl {
                matchmakerImageView.af_setImage(withURL: url)
            }
        }
    }
}


// 삼각형 뷰
extension NewDateController {
    fileprivate func initTriangleView() {
        view.addSubview(triangleView)
        triangleView.frame =  CGRect(x: 0, y: 0, width: 250, height: 220)
        initTriangleLayer()
        triangleView.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        initImageViewsIntoTriangleView()
    }
    
    fileprivate func initImageViewsIntoTriangleView() {
        triangleView.addSubview(myImageView)
        triangleView.addSubview(matchmakerImageView)
        triangleView.addSubview(blindImageView)
        
        myImageView.anchor(nil, left: triangleView.leftAnchor, bottom: triangleView.bottomAnchor, right: nil, topConstant: 0, leftConstant: -10, bottomConstant: -10, rightConstant: 0, widthConstant: imageViewWidth, heightConstant: imageViewWidth)
        matchmakerImageView.anchor(triangleView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: imageViewWidth, heightConstant: imageViewWidth)
        matchmakerImageView.anchorCenterXToSuperview()
        blindImageView.anchor(nil, left: nil, bottom: triangleView.bottomAnchor, right: triangleView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -10, rightConstant: -10, widthConstant: imageViewWidth, heightConstant: imageViewWidth)
    }
    fileprivate func initTriangleLayer() {
        if let sublayers = triangleView.layer.sublayers, !sublayers.isEmpty { sublayers[0].removeFromSuperlayer() }
        
        let layer = CAShapeLayer()
        layer.fillColor = Color.shared.darkGreen.cgColor
        layer.path = triangleView.createTrianglePath(radius: 30)
        layer.position = triangleView.center
        triangleView.layer.addSublayer(layer)
    }
    
    @objc fileprivate func loadAnimation(handler: @escaping (()->Void)) {
        UIView.animate(withDuration: 2.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.triangleView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.triangleView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 150)
        }, completion: nil )
        handler()
    }
}
