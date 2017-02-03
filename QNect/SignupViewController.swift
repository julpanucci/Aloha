//
//  SignupViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import CoreData
import ParseTwitterUtils
import CRToast
import AddressBook
import ReachabilitySwift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SignupViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    //MARK: Strings
    
    let kRemoveCurrentPhoto = "Remove Current Photo"
    let kPhotoLibrary = "Photo Library"
    let kCancel = "Cancel"
    let kHeaderHeight:CGFloat = 40.0
    let kProfileImageRadius:CGFloat = 60.0
    let kProfileImageBorderWidth:CGFloat = 2.0
    
    var didChooseProfileImage = false
    
    //MARK: Properties
    
    var isLinkingFromTwitter = false
    fileprivate let twitterAuthToken = "3405826337-M41HSjmdGo1op7rh65mt2wTr0Ngwif36cmx4w8V"
    fileprivate let twitterAuthTokenSecret = "xAVtjvbknWFtlmBnAYoT8PKxlPJ0EX1lpdjscHB9sLS0W"
    
    
    let errorImage = UIImage(named: "error_icon")
    let checkImage = UIImage(named: "check_icon")
    let segueIdentifier = "UserDetailsSegue"
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let imagePicker = UIImagePickerController()
    let defaultProfileImage = UIImage(named: "default_profile_image")
    
    //MARK: Actions
    
    @IBAction func signUp(_ sender: AnyObject) {
        signUpUser()
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var usernameField: UITextField!{
        didSet{self.usernameField.delegate = self}
    }
    @IBOutlet weak var qnectEmailField: UITextField! {
        didSet{self.qnectEmailField.delegate = self}
    }
    @IBOutlet weak var passwordField: UITextField! {
        didSet{self.passwordField.delegate = self}
    }
    @IBOutlet weak var firstNameField: UITextField! {
        didSet{self.firstNameField.delegate = self}
    }
    @IBOutlet weak var lastNameField: UITextField! {
        didSet{self.lastNameField.delegate = self}
    }
    @IBOutlet weak var socialEmailField: UITextField! {
        didSet{self.socialEmailField.delegate = self}
    }
    @IBOutlet weak var socialPhoneField: UITextField! {
        didSet{self.socialPhoneField.delegate = self}
    }
 
    @IBOutlet weak var usernameImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var firstNameImageView: UIImageView!
    @IBOutlet weak var lastNameImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet{
            self.profileImageView.layer.cornerRadius = kProfileImageRadius
            self.profileImageView.layer.borderColor = UIColor.white.cgColor
            self.profileImageView.layer.masksToBounds = true
            self.profileImageView.layer.borderWidth = kProfileImageBorderWidth
        }}
    
    @IBAction func setProfileImageAction(_ sender: AnyObject) {
        present(actionSheet, animated: true, completion: nil)
    }
    
    func configureViewController(_ isLinkingFromTwitter:Bool)
    {
        self.isLinkingFromTwitter = isLinkingFromTwitter
    }
    
    
    
    //MARK: LifeCycleMethods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if isLinkingFromTwitter == true {
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignupViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignupViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        
        createActionSheet()
        
        checkTextFields(usernameField)
        checkTextFields(passwordField)
        checkTextFields(qnectEmailField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurpleColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkToEnableNavButton()
    }
    
    //MARK:UI Methods

    fileprivate func checkToEnableNavButton()
    {
        let images = [usernameImageView.image, emailImageView.image, passwordImageView.image, firstNameImageView.image, lastNameImageView.image]
        var count = 0
        for image in images {
            if image == checkImage {
                count += 1
            }
        }
        
        if count == 5 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    //MARK: Action Sheet Methods
    fileprivate func createActionSheet()
    {
        let cancelAction = UIAlertAction(title: kCancel, style: .cancel) { (action) in
        }
        
        let removePhotoAction = UIAlertAction(title: kRemoveCurrentPhoto, style: .destructive) { (action) -> Void in
            self.didChooseProfileImage = false
            self.setProfileImage()
            
        }
        
        let addPhotoAction = UIAlertAction(title: kPhotoLibrary, style: .default) { (action) -> Void in
            self.selectProfileImage()
        }
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(removePhotoAction)
        actionSheet.addAction(addPhotoAction)
    }
    
    //MARK: Profile Image Methods
    
    fileprivate func setProfileImage()
    {
        if !didChooseProfileImage {
            if let firstName = firstNameField.text {
                if firstName.characters.count > 0 && lastNameField.text?.characters.count > 0{
                    profileImageView.image = ProfileImage.createProfileImage(firstName, last: lastNameField.text)
                }
            }
        }
    }
    
    
    fileprivate func selectProfileImage()
    {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.navigationBar.barTintColor = UIColor.qnBlueColor()
        imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        imagePicker.navigationBar.tintColor = UIColor.white
        present(imagePicker, animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.image = image
        
        didChooseProfileImage = true
    
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    //MARK: TextField Delegate Functions
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setProfileImage()
        checkTextFields(textField)
        checkToEnableNavButton()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTextFields(textField)
        queryForTextFields(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        checkTextFields(textField)
        if textField == usernameField {
            qnectEmailField.becomeFirstResponder()
        }else if textField == qnectEmailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            firstNameField.becomeFirstResponder()
        } else if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            socialEmailField.becomeFirstResponder()
        } else if textField == socialEmailField {
            socialPhoneField.becomeFirstResponder()
        }
        
        return true
    }
    
    fileprivate func queryForTextFields(_ textField:UITextField)
    {
        if textField == usernameField {
            if textField.text?.isEmpty == true{
                self.usernameImageView.image = self.errorImage
            }else {
                let query = User.query()
                query?.whereKey("username", equalTo: textField.text!)
                query?.getFirstObjectInBackground(block: { (object, error) -> Void in
                    if object == nil {
                        self.usernameImageView.image = self.checkImage
                    } else {
                        self.usernameImageView.image = self.errorImage
                        CRToastManager.showNotification(options: AlertOptions.statusBarOptionsWithMessage("Username already exists", withColor: UIColor.red), completionBlock: { () -> Void in
                        })
                        self.usernameImageView.image = self.errorImage
                    }
                })
            }
        }
        
        if textField == qnectEmailField {
            if textField.text?.isEmpty == true {
                self.emailImageView.image = self.errorImage
            }else {
                let query = User.query()
                query?.whereKey("email", equalTo: textField.text!)
                query?.getFirstObjectInBackground(block: { (object, error) -> Void in
                    if object == nil {
                        self.emailImageView.image = self.checkImage
                    } else {
                        self.emailImageView.image = self.errorImage
                        CRToastManager.showNotification(options: AlertOptions.statusBarOptionsWithMessage("Email already exists", withColor: UIColor.red), completionBlock: { () -> Void in
                        })
                        self.emailImageView.image = self.errorImage
                    }
                    
                    self.checkTextFields(textField)
                })
            }
        }
    }
    
    fileprivate func checkTextFields(_ textField:UITextField)
    {
        if textField == usernameField {
            if textField.text!.utf8.count <= 1 || textField.text!.isEmpty{
                usernameImageView.image = errorImage
            } else {
                usernameImageView.image = checkImage
            }
        }
        
        if textField == qnectEmailField {
            if !isValidEmail(textField.text!) {
                emailImageView.image = errorImage
            } else {
                emailImageView.image = checkImage
            }
        }
        
        if textField == passwordField {
            if textField.text!.utf8.count <= 4 {
                passwordImageView.image = errorImage
            }else{
                passwordImageView.image = checkImage
            }
        }
        if textField == firstNameField{
            if textField.text!.utf8.count <= 1 || textField.text!.isEmpty{
                firstNameImageView.image = errorImage
            } else {
                firstNameImageView.image = checkImage
            }
        }
        if textField == lastNameField {
            if textField.text!.utf8.count <= 1 || textField.text!.isEmpty {
                lastNameImageView.image = errorImage
            }else {
                lastNameImageView.image = checkImage
            }
        }
    }
    
    fileprivate func isValidEmail(_ testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK: User Functions
    
    fileprivate func linkTwitterUser()
    {
        let user = User.current()!
        
        user.username = usernameField.text
        user.email = qnectEmailField.text
        user.password = passwordField.text
        user.firstName = firstNameField.text!
        user.lastName = lastNameField.text!
        user.socialEmail = socialEmailField.text
        user.socialPhone = socialPhoneField.text
        
        user.twitterScreenName = PFTwitterUtils.twitter()?.screenName
        
        
        let imageData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.5)
        let imageFile = PFFile(name: "profileImage", data: imageData!)
        
        
            user.profileImage = imageFile
            user.saveInBackground(block: { (success, error) -> Void in
                if error == nil {
                    self.segueToMainApp()
                }
            })
    }
    
    fileprivate func signUpUser()
    {
        if Reachability.isConnectedToInternet() {
            if isLinkingFromTwitter == true {
                linkTwitterUser()
            } else {
                let user = createUser()
                
                let imageData = UIImageJPEGRepresentation(self.profileImageView.image!, 50)
                let imageFile = PFFile(name: "profileImage", data: imageData!)
                
        
                    user.profileImage = imageFile
                    user.signUpInBackground(block: { (success, error) -> Void in
                        if error == nil {
                            self.segueToMainApp()
                        }
                })
                
            }
        } else {
            CRToastManager.showNotification(options: AlertOptions.statusBarOptionsWithMessage(AlertMessages.Internet, withColor: nil), completionBlock: { () -> Void in
            })
        }
        
    }
    
    func createUser() -> User
    {
        let user = User()
        user.username = usernameField.text
        user.email = qnectEmailField.text
        
        user.password = passwordField.text
        
        user.firstName = firstNameField.text!
        user.lastName = lastNameField.text!
        
        user.socialEmail = socialEmailField.text
        user.socialPhone = socialPhoneField.text
        
        
        return user
    }
    
    //MARK:Segue
    
    func segueToMainApp()
    {
        self.performSegue(withIdentifier: SegueIdentifiers.Signedup, sender: self)
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        
        let installation = PFInstallation.current()!
        installation["user"] = User.current()
        installation["username"] = User.current()!.username!
        installation.saveInBackground()
        
        switch authorizationStatus {
        case .denied, .restricted:
            //1
            print("Denied")
        case .authorized:
            //2
            print("Authorized")
        case .notDetermined:
            //3
            print("Not Determined")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderHeight
    }
    
    
    //MARK: Keyboard Functions
    
    func keyboardWillShow(_ notification:Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + keyboardSize.height/2 , right: 0)
            
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = contentInsets;
        }
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
        let rate = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        
        UIView.animate(withDuration: rate.doubleValue, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.zero;
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero;
        })
    }
}