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
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        // get documents path
        // something like ~/Library/Developer/CoreSimulator/Devices/5C595030-7E0F-4FB8-AEBE-9F7BC6D23844/data/Containers/Data/Application/89361389-672E-4F91-BDBC-EE94F6E45F89/Documents on simulator
        self.rootPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String)
        print (self.rootPath)
        
        // To communicate with this webview... http://stackoverflow.com/questions/15983797/can-a-uiwebview-interact-communicate-with-the-app
        if let htmlPath = NSBundle.mainBundle().pathForResource("index", ofType: "html") {
            let htmlURL = NSURL.fileURLWithPath(htmlPath)
            let urlString = htmlURL.absoluteString
            let queryString = "?app=1" // to signal to the script that we are in-app
            let urlWithQuery = urlString + queryString;
            let finalURL = NSURL(string: urlWithQuery)
            let htmlRequest = NSURLRequest(URL: finalURL!)
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
            
            if #available(iOS 8.0, *) {
                let alertController = UIAlertController(title: "Silly Here", message: request.URL?.absoluteString, preferredStyle: .ActionSheet)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // do nothing
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    // do nothing
                }
            } else {
                // Fallback on earlier versions
            }
            return false
        } else if request.URL?.scheme == "subcalc-extension" {
            var incommingString = request.URL?.resourceSpecifier
            if ( incommingString == "//saved-caucuses") {
                // NSString* returnValue = [self.webView stringByEvaluatingJavaScriptFromString: "someJSFunction()"];
                let fileContent = try? String(contentsOfFile: rootPath + jsonFilename)
                var result = ""
                if (fileContent != nil) {
                    result = webView.stringByEvaluatingJavaScriptFromString("SCGetData("+fileContent!+")")!
                } else {
                    result = webView.stringByEvaluatingJavaScriptFromString("SCGetData(\"nothing\")")!
                }
                print(result)
                return false
            }
            incommingString?.removeRange((incommingString?.startIndex)!..<(incommingString?.startIndex.advancedBy(2))!)
            let jsonString = incommingString!.stringByRemovingPercentEncoding
            do {
                try jsonString?.writeToFile(rootPath + jsonFilename, atomically: true, encoding: NSUTF8StringEncoding)
            } catch _ {
                if #available(iOS 8.0, *) {
                    let alertController = UIAlertController(title: "Subcalc Here", message: jsonString, preferredStyle: .ActionSheet)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // do nothing
                    }
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true) {
                        // do nothing
                    }
                } else {
                    // Fallback on earlier versions
                }
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

