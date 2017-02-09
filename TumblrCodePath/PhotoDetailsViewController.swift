//
//  PhotoDetailsViewController.swift
//  TumblrCodePath
//
//  Created by Micah Peoples on 2/8/17.
//  Copyright © 2017 micah. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    var imageURL: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: imageURL)
        posterView.setImageWith(url!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
