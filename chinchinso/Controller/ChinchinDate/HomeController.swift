//
//  ViewController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 10. 20..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import QuartzCore
import Alamofire
import Lottie

class HomeController: BaseViewController {
    
//    var hasTriangleAnimation: Bool = true
    let lottieView = LOTAnimationView(name: "circle_datedlist")
    let imageViewWidth: CGFloat = 50.0
    var myProfileUrl: URL?
    
    let myImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.cornerRadius = 25
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    let matchmakerImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.cornerRadius = 25
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    let blindImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var newDateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("새로운 소개팅", for: .normal)
        btn.setTitleColor(Color.shared.orangeYellow, for: .normal)
        btn.layer.cornerRadius = 5
        btn.backgroundColor = .white
        btn.layer.borderColor = Color.shared.orangeYellow.cgColor
        btn.layer.borderWidth = 1
        btn.addTarget(self, action: #selector(handleNewDate), for: .touchUpInside)
        return btn
    }()
    
    let cellName = "HomeCell"
    var dataIndex = 0
    var datasource = [Model.ChinchinDate]() {
        didSet {
            collectionView.reloadData()
            dataIndex = 0
            if datasource.count > 0 { update(data: datasource[dataIndex]); pageControl.numberOfPages = datasource.count }
        }
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.background
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.layer.masksToBounds = true
        cv.layer.cornerRadius = 5
        cv.clipsToBounds = true
        return cv
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = Color.shared.orangeYellow
        pc.hidesForSinglePage = true
        pc.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        return pc
    }()
    
    lazy var leftArrow: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "left_arrow"), for: .normal)
        btn.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
        return btn
    }()
    
    lazy var rightArrow: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "right_arrow"), for: .normal)
        btn.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        if GlobalState.instance.uid == 0 || GlobalState.instance.uid == -1 { present(LoginController(), animated: true, completion: nil) }
        else { self.getDatedList() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        comebackhome()
        if GlobalState.instance.uid != -1 { getDatedList() }
    }
    
    override func handleChat() {
        let chatListController = ChatListController()
        chatListController.homeController = self
        self.navigationController?.pushViewController(chatListController, animated: true)
    }
    
    @objc private func handleNewDate() {
        toggleAnimation {
            let newDateController = NewDateController()
            if let url = self.myProfileUrl { newDateController.myProfileUrl = url }
            newDateController.homeController = self
            self.navigationController?.pushViewController(newDateController, animated: false)
        }
    }
    
}

extension HomeController {
    func update(data date: Model.ChinchinDate) {
        if let matchmakerUrl = date.matchmaker.profileUrl { matchmakerImageView.af_setImage(withURL: matchmakerUrl) }
        else { matchmakerImageView.image = #imageLiteral(resourceName: "profile")}
        if let blindUrl = date.blind.user.profileUrl { blindImageView.af_setImage(withURL: blindUrl) }
        else { blindImageView.image = #imageLiteral(resourceName: "profile")}
    }
    
    func getDatedList() {
        App.api.getDatedList(handler: { [weak self] (dataResponse: DataResponse<Model.DatedList>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case.success(let data):
                print(data)
                self.datasource = data.list
                if let url = data.myProfileUrl { self.myProfileUrl = url; self.myImageView.af_setImage(withURL: url) }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? HomeCell else { return HomeCell() }
        cell.update(data: datasource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / collectionView.frame.width)
        pageControl.currentPage = pageNumber
        self.update(data: datasource[pageNumber])
    }
}

extension HomeController {
    fileprivate func initView() {
        initLottieView()
        view.addSubview(newDateButton)
        view.addSubview(collectionView)
        view.addSubview(leftArrow)
        view.addSubview(rightArrow)
        view.addSubview(pageControl)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: cellName)
        
        collectionView.anchor(nil, left: nil, bottom: pageControl.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 250, heightConstant: 100)
        collectionView.anchorCenterXToSuperview()
        leftArrow.anchor(nil, left: nil, bottom: nil, right: collectionView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 25, heightConstant: 30)
        leftArrow.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        rightArrow.anchor(nil, left: collectionView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 25, heightConstant: 30)
        rightArrow.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        pageControl.anchor(nil, left: view.leftAnchor, bottom: lottieView.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 70, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
        newDateButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 100, rightConstant: 0, widthConstant: 110, heightConstant: 30)
        newDateButton.anchorCenterXToSuperview()
    }
    
    fileprivate func initLottieView() {
        view.addSubview(lottieView)
        lottieView.contentMode = .scaleAspectFill
        lottieView.frame =  CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: view.frame.width * 0.75)
        lottieView.center = CGPoint(x: view.center.x, y: view.center.y + 40)
        initImageViewIntoLottieView()
    }
    
    fileprivate func initImageViewIntoLottieView() {
        lottieView.addSubview(blindImageView)
        lottieView.addSubview(myImageView)
        lottieView.addSubview(matchmakerImageView)
        
        myImageView.anchor(nil, left: nil, bottom: lottieView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: imageViewWidth, heightConstant: imageViewWidth)
        myImageView.anchorCenterXToSuperview(constant: -1 * lottieView.frame.width * 0.18)
        blindImageView.anchorCenterSuperview()
        blindImageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: lottieView.frame.width * 0.62, heightConstant: lottieView.frame.width * 0.62)
        blindImageView.layer.cornerRadius = lottieView.frame.width * 0.31
        matchmakerImageView.anchor(nil, left: nil, bottom: lottieView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: imageViewWidth, heightConstant: imageViewWidth)
        matchmakerImageView.anchorCenterXToSuperview(constant: lottieView.frame.width * 0.18)
        
    }
    
    func comebackhome() { toggleAnimation {} }
    
    @objc fileprivate func toggleAnimation(handler: @escaping (() -> Void)) {
        if !lottieView.isAnimationPlaying {
            lottieView.play()
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.lottieView.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width * 0.65, height: self.view.frame.width * 0.65)
                self.lottieView.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 40)
            }, completion: nil)
        } else{
            lottieView.stop()
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.lottieView.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width * 0.4, height: self.view.frame.width * 0.4)
                self.lottieView.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 10)
            }, completion: nil)
        }
        
        handler()
    }
    
}

extension HomeController {
    @objc func moveLeft() {
        guard datasource.count > 0 else { return }
        if dataIndex == 0 { dataIndex = datasource.count - 1 }
        else { dataIndex -= 1 }
        self.update(data: datasource[dataIndex])
        collectionView.scrollToItem(at: IndexPath(item: dataIndex, section: 0), at: .left, animated: true)
        pageControl.currentPage = dataIndex
    }
    
    @objc func moveRight() {
        guard datasource.count > 0 else { return }
        if dataIndex == datasource.count - 1 { dataIndex = 0 }
        else { dataIndex += 1 }
        self.update(data: datasource[dataIndex])
        collectionView.scrollToItem(at: IndexPath(item: dataIndex, section: 0), at: .right, animated: true)
        pageControl.currentPage = dataIndex
    }
}


