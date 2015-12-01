//
//  ViewController.swift
//  SubCalc
//
//  Created by Eric Celeste on 15.12.01.
//  Copyright © 2015 Eric Celeste. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // To communicate with this webview... http://stackoverflow.com/questions/15983797/can-a-uiwebview-interact-communicate-with-the-app
        if let htmlPath = NSBundle.mainBundle().pathForResource("index", ofType: "html") {
            let htmlURL = NSURL.fileURLWithPath(htmlPath)
            let htmlRequest = NSURLRequest(URL: htmlURL)
            scWebView.loadRequest(htmlRequest)
        }
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

