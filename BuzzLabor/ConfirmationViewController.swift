//
//  ConfirmationViewController.swift
//  BuzzLabor
//
//  Created by Rio Balderas on 6/4/17.
//  Copyright © 2017 Jay Balderas. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var descriptionTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.disableKeybordWhenTapped = true

    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated:true, completion:nil)
    }
    

}
