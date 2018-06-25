//
//  SlideMenu.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 10. 23..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase
import Alamofire

class SlideMenu: NSObject {
    
    static let shared: SlideMenu = SlideMenu()
    
    var homeController: HomeController?
    var openDateController: OpenDateController?
    var openDateControllerDelegate: OpenDateControllerDelegate?
    var manageBlindController: ManageBlindController?
    var myInfoController: MyInfoController?
    
    var baseDelegate: BaseViewController?
    var headerView: MenuHeaderView?
    var user: Model.User? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let blackView = UIView()
    let collectionView: UICollectionView = {
        let cv =  UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = Color.shared.menuBackground
        return cv
    }()
    
    var headerSize: CGSize = CGSize.zero
    let menuWidth: CGFloat = 270.0
    var isInitiated: Bool = true
    
    var menu: [Model.Menu] = []
    
    func showMenu() {
        if let window = UIApplication.shared.keyWindow {
            if (isInitiated) {
                
                window.addSubview(blackView)
                window.addSubview(collectionView)
                collectionView.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: window.frame.height)
                
                blackView.backgroundColor = Color.shared.darkTransparent
                blackView.frame = window.frame
                blackView.alpha = 0
                blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
                isInitiated = false
            }
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: 0, width: self.menuWidth, height: window.frame.height)
            }, completion: nil)
            
        }
    }
    
    @objc func handleDismiss() {
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.blackView.alpha = 0
                self.collectionView.frame = CGRect(x: -self.menuWidth, y: 0, width: self.menuWidth, height: window.frame.height)
            }, completion: nil)
        }
    }
    
    override init() {
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellName())
        collectionView.register(MenuHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MenuHeaderView")
        menu = [Model.Menu(title: "친구 소개", controller: .friendDate , isNew: false),
                Model.Menu(title: "공개 소개", controller: .openDate, isNew: false),
                Model.Menu(title: "내 친구 관리", controller: .friendManage, isNew: false),
                Model.Menu(title: "내 정보 관리", controller: .myInfoManage, isNew: false),
                Model.Menu(title: "로그아웃", controller: .logout, isNew: false)]
        
    }
}

extension SlideMenu: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName(), for: indexPath) as? MenuCell else { return MenuCell() }
        let item = menu[indexPath.item]
        cell.update(data: item)
        return cell
    }
    
    func cellName() -> String  {
        return "MenuCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MenuHeaderView", for: indexPath) as? MenuHeaderView ?? MenuHeaderView()
            if let user = user { headerView!.update(data: user) }
            return headerView!
        case UICollectionElementKindSectionFooter:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let rootNavigationController = appDelegate.rootNavigationController else { return }
        switch menu[indexPath.row].controller {
        case .friendDate:
            guard let homeController = homeController else {
                self.homeController = HomeController()
                self.baseDelegate = self.homeController!
                rootNavigationController.setViewControllers([self.homeController!], animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.handleDismiss() }
                return
            }
            baseDelegate = homeController
            rootNavigationController.setViewControllers([homeController], animated: false)
            
        case .openDate:
            guard let openDateController = openDateController else {
                self.openDateController = OpenDateController()
                self.openDateControllerDelegate = self.openDateController
                self.baseDelegate = self.openDateController!
                rootNavigationController.setViewControllers([self.openDateController!], animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.handleDismiss() }
                return
            }
            baseDelegate = openDateController
            openDateControllerDelegate = openDateController
            rootNavigationController.setViewControllers([openDateController], animated: false)
        case .friendManage:
            guard let manageBlindController = manageBlindController else {
                self.manageBlindController = ManageBlindController()
                self.baseDelegate = self.manageBlindController!
                rootNavigationController.setViewControllers([self.manageBlindController!], animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.handleDismiss() }
                return
            }
            baseDelegate = manageBlindController
            rootNavigationController.setViewControllers([manageBlindController], animated: false)
        case .myInfoManage:
            guard let myInfoController = myInfoController else {
                self.myInfoController = MyInfoController()
                self.baseDelegate = self.myInfoController!
                rootNavigationController.setViewControllers([self.myInfoController!], animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.handleDismiss() }
                return
            }
            baseDelegate = myInfoController
            rootNavigationController.setViewControllers([myInfoController], animated: false)
        case .logout :
            logout()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.handleDismiss() }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 180)
    }
}

extension SlideMenu {
    func refresh() {
        App.api.account { [weak self] (dataResponse: DataResponse<Model.User>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let user):
                self.user = user
                // 가장 최근에 등록된 img_url로 Firebase 업데이트 <- 가입 후, 사진 업로드 시
                if let fid = GlobalState.instance.firebaseId {
                    PumkitAPI.FIREBASE.child(FIREBASE_KEY.users.rawValue).child(fid).updateChildValues(["img_url": user.pic1])
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.logout()
            }
        }
    }
}

extension SlideMenu {
    fileprivate func logout() {
        guard let delegate = baseDelegate else { return }
        delegate.logout()
    }
}
