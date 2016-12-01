//
//  MainViewController.swift
//  PerkingOpera
//
//  Created by admin on 29/11/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = Repository.sharedInstance.user
        print(user?.token ?? "Unknown User")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showNoticeList(_ sender: Any) {
        self.performSegue(withIdentifier: "showNoticeList", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
