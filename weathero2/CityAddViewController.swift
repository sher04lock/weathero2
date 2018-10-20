//
//  CityAddViewController.swift
//  weathero2
//
//  Created by John Doe on 20/10/2018.
//  Copyright © 2018 John Doe. All rights reserved.
//

import UIKit

class CityAddViewController: UIViewController {

    var city: String = ""
    
    @IBOutlet weak var cityName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSegue" {
            city = cityName.text!
        }
    }
    

   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
