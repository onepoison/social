//
//  ViewController.swift
//  Social
//
//  Created by Kiwon on 2016. 12. 21..
//  Copyright © 2016년 mgrdoc. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField : FancyField!
    @IBOutlet weak var pwdField : FancyField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    


    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Yujin: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Yujin: Use cancelled Facebook authentication")
            } else {
                print("Yujin: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                self.firebaseAuth(credential)
            }
        }
        
        
        }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Yujin: Unable to authenticate with Firebase - \(error)")
            } else {
                print("Yujin: Successfully authenticated with Firebase")
                
                if let user = user {
                    
                    let userData = ["provider": credential.providerID]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
                
            }
        })
    }
    

    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let pwd = pwdField?.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Yujin: User email authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid,userData: userData)
                    }
                    
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("Yujin: Unable to autheticate with Firebase using email")
                        } else {
                            print("Yujin: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid,userData: userData)
                            }
                            
                        }
                    })

                }
            })
        }
    }
    
    func completeSignIn (id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Yujin : Data saved to Keychain \(keychainResult)")
        
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

