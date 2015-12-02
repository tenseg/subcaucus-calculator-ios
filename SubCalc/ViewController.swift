//
//  ViewController.swift
//  SubCalc
//
//  Created by Eric Celeste on 15.12.01.
//  Copyright © 2015 Eric Celeste. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UIWebViewDelegate, MFMailComposeViewControllerDelegate {

    //MARK: Vars and Lets
    @IBOutlet weak var scWebView: UIWebView!
    var rootPath = ""
    let jsonFilename = "/subcalc.json"
    
    //MARK: View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // get documents path
        // something like ~/Library/Developer/CoreSimulator/Devices/5C595030-7E0F-4FB8-AEBE-9F7BC6D23844/data/Containers/Data/Application/89361389-672E-4F91-BDBC-EE94F6E45F89/Documents on simulator
        self.rootPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String)
        
        // To communicate with this webview... http://stackoverflow.com/questions/15983797/can-a-uiwebview-interact-communicate-with-the-app
        if let htmlPath = NSBundle.mainBundle().pathForResource("index", ofType: "html") {
            let htmlURL = NSURL.fileURLWithPath(htmlPath)
            let htmlRequest = NSURLRequest(URL: htmlURL)
            scWebView.loadRequest(htmlRequest)
        }
   }

    //MARK: Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Delegates
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        if request.URL!.scheme == "mailto" {
//            if let rawParts = request.URL?.resourceSpecifier.componentsSeparatedByString("?") {
//                if MFMailComposeViewController.canSendMail() {
//                    let mailView = MFMailComposeViewController()
//                    mailView.mailComposeDelegate = self
//                    mailView.setToRecipients([rawParts[0]])
//                    self.presentViewController(mailView, animated: true, completion: nil)
//                }
//            }
//            return false
//        } else if request.URL?.scheme == "file" {
        if request.URL?.scheme == "file" {
            return true
        } else if request.URL?.scheme == "silly-extension" {
//            let jsonData = try NSJSONSerialization.dataWithJSONObject(request.URL?.__somethong__!, options: NSJSONWritingOptions.PrettyPrinted)
//            jsonData.writeToFile(rootPath + jsonFilename, atomically: true)
            
            let alertController = UIAlertController(title: "Silly Here", message: request.URL?.absoluteString, preferredStyle: .ActionSheet)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // do nothing
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // do nothing
            }
            return false
        } else {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

