//
//  BlindController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 24..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import AlamofireImage
import Firebase

class BlindController: UIViewController {

    var date: Model.ChinchinDate? {
        didSet {
            guard let blind = date?.blind, let matchmaker = date?.matchmaker else { return }
            if let matchmakerProfileUrl = matchmaker.profileUrl {
                self.matchmakerIV.af_setImage(withURL: matchmakerProfileUrl)
            }
            blind_firebaseId = blind.user.firebase_id
            matchmaker_firebaseId = matchmaker.firebase_id
            matchmakerNameLabel.text = matchmaker.name
            
            datasource = blind.user.profileUrlList
            blindNameLabel.attributedText = NSMutableAttributedString(string: blind.user.name, attributes: [.kern: 10])
            blindFriendLabel.text = "\(matchmaker.name)님의 친구"
            
            for i in 0..<blind.user.hashlist.count {
                if i == 0 { hashLabel1.text = "# \(blind.user.hashlist[i].hash_name)" }
                else if i == 1 { hashLabel2.text = "# \(blind.user.hashlist[i].hash_name)" }
                else if i == 2 { hashLabel3.text = "# \(blind.user.hashlist[i].hash_name)" }
                else { break }
            }
        }
    }
    var blind_firebaseId: String?
    var matchmaker_firebaseId: String?
    let cellName: String = "BlindCell"
    var datasource = [URL]() {
        didSet {
            collectionView.reloadData()
            if datasource.count > 0 { pageControl.numberOfPages = datasource.count }
        }
    }
    var homeController: HomeController?
    
    let mentionLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = .white
        lb.text = "아래로 스크롤하세요."
        lb.textAlignment = .center
        return lb
    }()
    
    let matchmakerLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = .white
        lb.text = "오늘의 주선자"
        lb.textAlignment = .center
        return lb
    }()
    
    let matchmakerNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    lazy var matchmakerIV: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.cornerRadius = 60
        iv.layer.borderColor = UIColor.init(r: 246, g: 221, b: 175).cgColor
        iv.layer.borderWidth = 15
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleFadeOutSlideView)))
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    
    let slideView: UIView = { return UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)) }()
    
    /*------------------------------------------------------------------------------------------------------------------------------------*/
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.background
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
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
    
    let blindFriendLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textAlignment = .left
        return lb
    }()
    
    let blindNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .left
        return lb
    }()
    
    let hashLabel1: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lb.textAlignment = .left
        return lb
    }()
    
    let hashLabel2: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lb.textAlignment = .left
        return lb
    }()
    
    let hashLabel3: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lb.textAlignment = .left
        return lb
    }()
    
    lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    lazy var startDateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.setTitle("대화하기", for: .normal)
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.layer.borderColor = Color.shared.font.cgColor
        btn.layer.borderWidth = 1
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleStartDate), for: .touchUpInside)
        return btn
    }()
    
    /*------------------------------------------------------------------------------------------------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSlideView()
        initBlindView()
        setAlphas(alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initSlideView() {
        view.addSubview(slideView)
//        slideView.backgroundColor = Color.shared.orangeYellow
        setupGradientLayer(view: slideView)
        slideView.addSubview(mentionLabel)
        slideView.addSubview(matchmakerIV)
        slideView.addSubview(matchmakerLabel)
        slideView.addSubview(matchmakerNameLabel)
        
        mentionLabel.anchor(slideView.topAnchor, left: slideView.leftAnchor, bottom: nil, right: slideView.rightAnchor, topConstant: 80, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        matchmakerIV.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 120)
        matchmakerIV.anchorCenterXToSuperview()
        matchmakerIV.anchorCenterYToSuperview(constant: -70)
        matchmakerLabel.anchor(nil, left: slideView.leftAnchor, bottom: matchmakerNameLabel.topAnchor, right: slideView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 15, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        matchmakerNameLabel.anchor(nil, left: slideView.leftAnchor, bottom: slideView.bottomAnchor, right: slideView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 80, rightConstant: 0, widthConstant: 0, heightConstant: 30)
    }
    
    fileprivate func initBlindView() {
        view.backgroundColor = Color.shared.background
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(blindFriendLabel)
        view.addSubview(blindNameLabel)
        view.addSubview(hashLabel1)
        view.addSubview(hashLabel2)
        view.addSubview(hashLabel3)
        view.addSubview(startDateButton)
        view.addSubview(closeButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BlindCell.self, forCellWithReuseIdentifier: cellName)
        
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.width * 1.05)
        pageControl.anchor(nil, left: view.leftAnchor, bottom: collectionView.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        blindFriendLabel.anchor(collectionView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        blindNameLabel.anchor(blindFriendLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashLabel1.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 130, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashLabel2.anchor(hashLabel1.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashLabel3.anchor(hashLabel2.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        startDateButton.anchor(nil, left: nil, bottom: hashLabel3.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 90, heightConstant: 40)
        closeButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 20, heightConstant: 20)
    }
    
}

extension BlindController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? BlindCell else { return BlindCell() }
        cell.update(data: datasource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / collectionView.frame.width)
        pageControl.currentPage = pageNumber
    }
}


extension BlindController {
    
    fileprivate func setupGradientLayer(view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        gradientLayer.colors = [UIColor.init(r: 255, g: 162, b: 66).cgColor, UIColor.init(r: 245, g: 182, b: 66).cgColor, UIColor.init(r: 245, g: 202, b: 126).cgColor, UIColor.init(r: 245, g: 202, b: 126).cgColor]
        gradientLayer.locations = [0.1, 0.4, 0.9, 1]
        view.layer.addSublayer(gradientLayer)
    }
    
    @objc func handleFadeOutSlideView(gesture: UIPanGestureRecognizer) {
        guard let target = gesture.view else { return }
        var y: CGFloat = 298
        var fadeOutY: CGFloat = 500
        if UIDevice.current.userInterfaceIdiom == .phone &&
          (UIScreen.main.bounds.size.height == 568 || UIScreen.main.bounds.size.width == 320) {
            y = 214
            fadeOutY = 380
        }
        
        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: self.view)
            if target.center.y + translation.y < y { } // Do Nothing
            else if target.center.y + translation.y > fadeOutY {
                gesture.isEnabled = false
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                    self.slideView.alpha = 0
                }, completion: nil)
            }
            else {
                target.center = CGPoint(x: target.center.x, y: target.center.y + translation.y)
                DispatchQueue.main.async { gesture.setTranslation(.zero, in: self.view) }
                let alphaValue = 1 - (target.center.y - y) / (fadeOutY - y)
//                DispatchQueue.main.async { }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.setAlphas(alpha: alphaValue)
                })
            }
        default:  break
        }
    }
    
    fileprivate func setAlphas(alpha: CGFloat) {
        slideView.alpha = alpha
        matchmakerNameLabel.alpha = alpha
        matchmakerIV.alpha = alpha
        matchmakerLabel.alpha = alpha
        mentionLabel.alpha = alpha
        
        collectionView.alpha = 1 - alpha
        pageControl.alpha = 1 - alpha
        blindFriendLabel.alpha = 1 - alpha
        blindNameLabel.alpha = 1 - alpha
        hashLabel1.alpha = 1 - alpha
        hashLabel2.alpha = 1 - alpha
        hashLabel3.alpha = 1 - alpha
        
        closeButton.isHidden = alpha > 0.1
        startDateButton.isHidden = alpha > 0.1
        
    }
    
    @objc func handleClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleStartDate() {
        guard let blind = blind_firebaseId, let matchmaker = matchmaker_firebaseId else { return }
        dismiss(animated: true) {
            let chatListController = ChatListController()
            let chattingController = ChattingController()
            chattingController.blindId = blind
            chattingController.matchmakerId = matchmaker
            chattingController.title = self.date?.blind.user.name ?? ""
            
            if let homeController = self.homeController, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                DispatchQueue.main.async { appDelegate.rootNavigationController?.setViewControllers([homeController, chatListController, chattingController], animated: false) }
            }
        }
    }
    
}
