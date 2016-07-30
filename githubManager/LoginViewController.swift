//
//  LoginViewController.swift
//  githubManager
//
//  Created by Bruno Paulino on 7/30/16.
//  Copyright © 2016 brunojppb. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
    func didTapLoginButton()
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewDelegate?
    
    @IBAction func TappedLoginButton(obj: AnyObject) {
        // TODO: Implement
        if let delegate = self.delegate {
            delegate.didTapLoginButton()
        }
    }
    
    @IBAction func cancelLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}