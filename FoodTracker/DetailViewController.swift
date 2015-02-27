//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Diego Guajardo on 22/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var usdaItem:USDAItem?

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eatItBarButtonItemPressed(sender: UIBarButtonItem) {
    }
}
