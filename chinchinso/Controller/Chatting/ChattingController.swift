//
//  ChattingController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 9..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import TLPhotoPicker
import MobileCoreServices
import Alamofire

class ChattingController: UIViewController {
    
//    fileprivate var isInitialLoading: Bool = true
    fileprivate var isLoading: Bool = false
    fileprivate var hasNext: Bool = true
    fileprivate var messageLimit: Int = 100
    fileprivate var page: Int = 1
    fileprivate var firstMessage: String?
    fileprivate var firstMessageInLoaded: String?
    fileprivate var inputContainerViewConstraint: NSLayoutConstraint?
    
    var selectedAssets = [TLPHAsset]()
    var blindId: String? {
        didSet{
            guard let blindId = blindId else { return }
            App.api.getUserInfo(firebaseId: blindId) { [weak self] (user: Chat.User) in
                guard let `self` = self else { return }
                if let url = user.profileUrl { self.blindProfileUrl = url }
            }
        }
    }
    var blind: Chat.User?
    var matchmakerId: String?
    var matchmaker: Chat.User?
    var blindProfileUrl: URL?
    
    var reference: DatabaseReference?
    let messageReference: DatabaseReference = Database.database().reference().child(FIREBASE_KEY.messages.rawValue)
    let userReference: DatabaseReference = Database.database().reference().child(FIREBASE_KEY.users.rawValue)
    let chattingReference: DatabaseReference = Database.database().reference().child(FIREBASE_KEY.chatting.rawValue)
    
    let imagePicker = UIImagePickerController()
    let cellName = "MessageCell"
    var datasource = [Chat.Message]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.background
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1
        textField.layer.borderColor = Color.shared.darkGreen.cgColor
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.delegate = self
        return textField
    }()
    
    lazy var inputContainerView: UIView = {
        /*
         * 키보드 닫혀 있을 때, 높이 : 70
         * 키보드 열 때, 높이 : 50
         */
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        let openPikcerView = UIImageView(image: #imageLiteral(resourceName: "icon_gallery"))
        openPikcerView.isUserInteractionEnabled = true
        openPikcerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPicture)))
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("전송", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = Color.shared.orangeYellow
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.layer.cornerRadius = 8
        sendButton.layer.masksToBounds = true
        
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = .darkGray
        
        /* Constraints */
        containerView.addSubview(seperatorLine)
        containerView.addSubview(self.inputTextField)
        containerView.addSubview(openPikcerView)
        containerView.addSubview(sendButton)
        
        sendButton.anchor(containerView.topAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 60, heightConstant: 30)
        openPikcerView.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        self.inputTextField.anchor(containerView.topAnchor, left: openPikcerView.rightAnchor, bottom: nil, right: sendButton.leftAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 30)
        seperatorLine.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        
        return containerView
    }()
    
    var timer: Timer?
    
    private func attemptToReload() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(reloadData), userInfo: nil, repeats: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initView()
        fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func initNavigationBar() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true       // bottom line hide
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }

    fileprivate func initView() {
        view.backgroundColor = Color.shared.background
        view.addSubview(inputContainerView)
        inputContainerViewConstraint = inputContainerView.anchorWithReturnAnchors(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)[3]
        
        view.addSubview(collectionView)
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: inputContainerView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resign)))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: cellName)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: -10, bottom: 10, right: -10)
        collectionView.scrollsToTop = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        
    }

}

extension ChattingController {
    fileprivate func fetchMessages() {
        guard let user = GlobalState.instance.firebaseId, let blind = blindId, let matchmaker = matchmakerId else { return }
        isLoading = true
        reference = Database.database().reference().child(FIREBASE_KEY.chatting.rawValue).child(user).child(matchmaker).child(blind)
        guard let reference = reference else { return }
        reference.observe(.childAdded) { [weak self] (snapshot: DataSnapshot) in
            guard let `self` = self else { return }
            self.messageReference.child(snapshot.key).observeSingleEvent(of: .value, with: { [weak self] (messageSnapshot: DataSnapshot) in
                guard let `self` = self else { return }
                guard let data = messageSnapshot.value else { return }
                var message = Chat.Message(json: JSON(data))
                message.setMessageId(id: snapshot.key)
                self.datasource.append(message)
                self.collectionView.reloadData()
                let indexPath = IndexPath(item: self.datasource.count - 1, section: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
            })
        }
    }
    
    fileprivate func fetchMessages(initial: Bool) {
        guard let user = GlobalState.instance.firebaseId, let blind = blindId, let matchmaker = matchmakerId else { return }
        isLoading = true
        if initial {
            reference = Database.database().reference().child(FIREBASE_KEY.chatting.rawValue).child(user).child(matchmaker).child(blind)
            reference?.queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in self.firstMessage = snapshot.key })
        }
        guard let reference = reference else { return }
        if initial {
            datasource.removeAll()
            reference.queryLimited(toLast: UInt(messageLimit)).observe(.childAdded) { [weak self] (snapshot2) in
                guard let `self` = self else { return }
                self.messageReference.child(snapshot2.key).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                    guard let `self` = self else { return }
                    guard let data = snapshot.value else { return }
                    var message = Chat.Message(json: JSON(data))
                    message.setMessageId(id: snapshot.key)
                    self.datasource.append(message)
                    self.isLoading = false
                    if self.messageLimit == self.datasource.count {
                        self.firstMessageInLoaded = snapshot2.key
                        
                    }
                })
            }
        }
        else {
            guard let message = self.firstMessageInLoaded else { self.isLoading = false; return }
//            let storedIndex = self.datasource.count
            self.datasource.removeAll()
            reference.queryEnding(atValue: message).queryLimited(toLast: UInt(messageLimit * page)).observe(.childAdded) { [weak self] (snapshot) in
                guard let `self` = self else { return }
                guard let first = self.firstMessage else { self.isLoading = false; return }
                if snapshot.key == first { self.hasNext = false; self.isLoading = false; return }
                self.messageReference.child(snapshot.key).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                    guard let `self` = self else { return }
                    guard let data = snapshot.value else { return }
                    var message = Chat.Message(json: JSON(data))
                    message.setMessageId(id: snapshot.key)
                    self.datasource.append(message)
                    if self.datasource.count == self.messageLimit * self.page {
                        self.collectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                            let indexPath = IndexPath(item: storedIndex, section: 0)
//                            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
                            self.isLoading = false
                        })
                    }
                })
            }
        }
    }
    
    func more() {
        debugPrint("hasNext : \(hasNext), isLoading : \(isLoading)")
        guard hasNext && !isLoading else { return }
        page += 1
        fetchMessages(initial: false)
    }
}

extension ChattingController: UITextFieldDelegate {
    
    override var canBecomeFirstResponder: Bool { return true }
    
    @objc fileprivate func handleKeyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo, let constraint = inputContainerViewConstraint else { return }
        guard let duration = info[UIKeyboardAnimationDurationUserInfoKey].unsafelyUnwrapped as? TimeInterval else { return }
        let frame = info[UIKeyboardFrameEndUserInfoKey].debugDescription
        let height = CGRectFromString(frame).height
        
        UIView.animate(withDuration: duration) {
            constraint.constant = 20 + height
            self.view.layer.layoutIfNeeded()
        }
        
        collectionView.scrollToItem(at: IndexPath(item: datasource.count - 1, section: 0), at: .top, animated: true)
    }
    
    @objc fileprivate func handleKeyboardWillHide(notification: NSNotification) {
        guard let info = notification.userInfo, let constraint = inputContainerViewConstraint else { return }
        guard let duration = info[UIKeyboardAnimationDurationUserInfoKey].unsafelyUnwrapped as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            constraint.constant = 50
            self.view.layer.layoutIfNeeded()
        }
    }
    
}

extension ChattingController {
    
    @objc fileprivate func sendMessage() {
        guard let message = inputTextField.text else { return }
        sendMessageWithProperties(properties: ["text": message])
    }
    
    @objc fileprivate func sendImageMessage(url: String, image: UIImage) {
        let properties = ["imageUrl" : url, "imageWidth" : image.size.width, "imageHeight" : image.size.height] as [String : Any]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        guard let blindId = blindId, let matchmakerId = matchmakerId, let myId = GlobalState.instance.firebaseId else { return }
        let newMessageReference = messageReference.childByAutoId()
        var values = ["toId" : blindId, "fromId" : myId, "timestamp" : ServerValue.timestamp(), "matchId" : matchmakerId ] as [String : Any]
        properties.forEach({values[$0] = $1})
        newMessageReference.updateChildValues(values) { [weak self] (error, updateReference) in
            guard error == nil else { print(error?.localizedDescription ?? ""); return }
            guard let `self` = self else { return }
            
            self.inputTextField.text = ""
            
            let newMessage = [updateReference.key: 1]
            self.chattingReference.child(blindId).child(matchmakerId).child(myId).updateChildValues(newMessage)
            self.chattingReference.child(myId).child(matchmakerId).child(blindId).updateChildValues(newMessage)
            
            if properties.keys.contains("text") { self.sendPush(message: properties["text"] as? String ?? "") }
            else { self.sendPush(message: "사진") }
            
            self.attemptToReload()
        }
    }
    
    private func sendPush(message: String) {
        guard let blind = blind else { return }
        let fcmToken = blind.fcmToken
        App.api.pushNotification(message: message, fcmToken: fcmToken) { }
    }
    
    fileprivate func uploadImageToFirebaseStorage(image: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child(STORAGE_KEY.images.rawValue).child("\(imageName).png")
        guard let upload = UIImageJPEGRepresentation(image, 0.2) else { return }
        ref.putData(upload, metadata: nil, completion: { [weak self] (metadata, error) in
            guard let metadata = metadata, error == nil else { print(error?.localizedDescription ?? "ERROR(:uploadImageToFirebaseStorage) OCCURED"); return }
            guard let `self` = self, let downloadUrl = metadata.downloadURL() else { return }
            self.sendImageMessage(url: downloadUrl.absoluteString, image: image)
        })
    }
    
    @objc func back() { self.navigationController?.popViewController(animated: true) }
    
    @objc func resign() { self.view.endEditing(true) }
    
    @objc func reloadData() { self.collectionView.reloadData() }
}

extension ChattingController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? MessageCell else { return MessageCell() }
        cell.update(data: datasource[indexPath.row])
        cell.updateBlindProfileUrl(url: blindProfileUrl)
        return cell
    }
    
    //TODO: Firebase로 페이징 처리가 쉽지 않다.
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
////        if indexPath.item == 0 && !isInitialLoading { more() }
////        if self.isInitialLoading { self.isInitialLoading = false }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 30    // default value
        let message = datasource[indexPath.row]
        let isFile: Bool = message.image_url.count > 0  /* 어떤 메시지인가? */
        if isFile { height = CGFloat(message.image_height.floatValue / message.image_width.floatValue * 200) }
        else { height = estimatedFrameForMessage(message: message.message).height + 10}
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    private func estimatedFrameForMessage(message: String) -> CGRect {
        let size = CGSize(width: 200, height: 0)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: message).boundingRect(with: size, options: options, attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
}

extension ChattingController: TLPhotosPickerViewControllerDelegate {
    
    @objc fileprivate func openPicture() {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 5
        configure.selectedColor = Color.shared.orangeYellow
        configure.cancelTitle = "취소"
        configure.doneTitle = "확인"
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.allowedLivePhotos = false
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        getSelectedImage()
    }
    
    func getSelectedImage() {
        self.selectedAssets.forEach { (asset: TLPHAsset) in
            guard let image = asset.fullResolutionImage else { return }
            var resize: (CGFloat, CGFloat) = (0.0, 0.0)
            if image.size.width > 200 || image.size.height > 450 {
                if image.size.width > image.size.height { resize = (200, 200 * image.size.height / image.size.width) }
                else { resize = ( 450 * image.size.width / image.size.height, 450) }
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: resize.0, height: resize.1), false, 0.0);
                image.draw(in: CGRect(x: 0, y: 0, width: resize.0, height: resize.1))
                let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                self.uploadImageToFirebaseStorage(image: newImage)
            } else { self.uploadImageToFirebaseStorage(image: image) }
        }
    }
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker dismiss completion
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "카메라 권한이 없습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "선택하실 수 있는 사진 개수를 초과했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}

// UIImagePicker는 이제 안씁니다. 2018년 2월 8일 목요일
//extension ChattingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    @objc fileprivate func openImagePicker() {
//        imagePicker.allowsEditing = true
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.mediaTypes = NSMutableArray(array: [kUTTypeImage]) as! [String]
//        imagePicker.modalPresentationStyle = .overFullScreen
//
//        self.inputTextField.resignFirstResponder()
//        self.present(imagePicker, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        guard let mediaType: String = info[UIImagePickerControllerMediaType] as? String else { return }
//        picker.dismiss(animated: true) {
//            if CFStringCompare(mediaType as CFString, kUTTypeImage, .compareCaseInsensitive) == .compareEqualTo {
//                guard let original = info["UIImagePickerControllerOriginalImage"] as? UIImage else { return }
//                var image: UIImage!
//                var resize: (CGFloat, CGFloat) = (0.0, 0.0)
//
//                if let editted = info["UIImagePickerControllerEditedImage"] as? UIImage { image = editted }
//                else { image = original }
//
//                if image.size.width > 200 || image.size.height > 450 {
//                    if image.size.width > image.size.height { resize = (200, 200 * image.size.height / image.size.width) }
//                    else { resize = ( 450 * image.size.width / image.size.height, 450) }
//
//                    UIGraphicsBeginImageContextWithOptions(CGSize(width: resize.0, height: resize.1), false, 0.0);
//                    image.draw(in: CGRect(x: 0, y: 0, width: resize.0, height: resize.1))
//                    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//                    UIGraphicsEndImageContext()
//
//                    self.uploadImageToFirebaseStorage(image: newImage)
//                } else { self.uploadImageToFirebaseStorage(image: image) }
//            }
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true, completion: nil) }
//}

