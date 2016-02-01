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
    var scRootPath = ""
    let scJsonFilename = "/subcalc.json"
    
    //MARK: View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        // get documents path
        // something like ~/Library/Developer/CoreSimulator/Devices/5C595030-7E0F-4FB8-AEBE-9F7BC6D23844/data/Containers/Data/Application/89361389-672E-4F91-BDBC-EE94F6E45F89/Documents on simulator
        self.scRootPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String)
        print (self.scRootPath)
        
        // To communicate with this webview... http://stackoverflow.com/questions/15983797/can-a-uiwebview-interact-communicate-with-the-app
        if let htmlPath = NSBundle.mainBundle().pathForResource("index", ofType: "html") {
            let htmlURL = NSURL.fileURLWithPath(htmlPath)
            let urlString = htmlURL.absoluteString
            let queryString = "?app=1" // to signal to the script that we are in-app
            let urlWithQuery = urlString + queryString
            let finalURL = NSURL(string: urlWithQuery)
            let htmlRequest = NSURLRequest(URL: finalURL!)
            scWebView.loadRequest(htmlRequest)
        }
   }
    
    //MARK: Helpers
    func tensegDeviceSystemProfile() -> String { // designed to eventually go into TensegHelpers and be usable across any iOS app we develop
        let device = UIDevice.currentDevice()
        let infoPlist = NSBundle.mainBundle().infoDictionary
        return "<---Please don't delete the following system information--->\n\(infoPlist!["CFBundleName"]) Version: \(infoPlist!["CFBundleShortVersionString"]) (\(infoPlist!["CFBundleVersion"]))\nDevice: \(device.model)\niOS Version: \(device.systemVersion)\nTenseg Device Identifier: \(device.identifierForVendor)\n<------------------------------------------------>"
    }
    
    //MARK: Delegates
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
          // perhaps send mailto URLs to the mail compose view controller
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
        // automatically load file URLs in this web view
        if request.URL?.scheme == "file" {
            // returns the actual files (like HTML, CSS, JS, etc.)
            return true // tells UIWebView to actually pick up this local file
        } else if request.URL?.scheme == "subcalc-extension" {
            // this is used for passing data between js and swift
            var incomingString = request.URL?.resourceSpecifier
            if incomingString == nil {
                return false; // just give up if there is no real incomming string
            }
            if ( incomingString == "//get-caucuses") {
                // to get caucus data from swift for js side
                // NSString* returnValue = [self.webView stringByEvaluatingJavaScriptFromString: "someJSFunction()"];
                let fileContent = try? String(contentsOfFile: scRootPath + scJsonFilename)
                var result = ""
                if (fileContent != nil) {
                    result = webView.stringByEvaluatingJavaScriptFromString("SCGetData("+fileContent!+")")!
                } else {
                    result = webView.stringByEvaluatingJavaScriptFromString("SCGetData(\"nothing\")")!
                }
                print(result)
            } else if ( incomingString!.hasPrefix("//set-caucuses/") ) {
                // to set the swift caucuses storage as instructed by the js side
                incomingString?.removeRange((incomingString?.startIndex)!..<(incomingString?.startIndex.advancedBy(15))!)
                let jsonString = incomingString!.stringByRemovingPercentEncoding
                do {
                    try jsonString?.writeToFile(scRootPath + scJsonFilename, atomically: true, encoding: NSUTF8StringEncoding)
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
            } else if ( incomingString!.hasPrefix("//share/" ) ) { // NOT YET LIVE
                // this will be used to pass a caucus over to the standard sharing sheet as a replacement to the simplistic email this caucus function
                print(incomingString)
                //***we need to make sure that incomingString is the content that we had sent as the email contents before moving forward here, which will mean undoing url encoding of everything but the json link***
                let activityViewController = UIActivityViewController(activityItems: [incomingString!], applicationActivities: nil) // should we carry backwards our CSV export activity for this menu? that would require additional code to go from json to csv, but may be worth it
                presentViewController(activityViewController, animated: true, completion: nil)
            } else if ( incomingString == "//feedback-email" ) { // NOT YET LIVE
                // we want to send email feedback from native-land
                if MFMailComposeViewController.canSendMail() {
                    let mailView = MFMailComposeViewController()
                    mailView.mailComposeDelegate = self
                    mailView.setToRecipients(["efc@sd64dfl.org"]) // should we really send the iOS email to subcalc@tenseg.net instead?
                    mailView.setSubject("SubCalc Feedback")
                    mailView.setMessageBody("\n\n\n \(self.tensegDeviceSystemProfile())", isHTML: false)
                    self.presentViewController(mailView, animated: true, completion: nil)
                } else {
                    /***let user know that they must first set up Mail***/
                }
            }
        } else {
            // if we are passed any URL other than file:// or subcalc-extention://
            // then we just let iOS handle it in the usual way
            // though, note, this will NOT be handled in our own UIWebView
            // so it effectively hands off to Safari or other apps
            UIApplication.sharedApplication().openURL(request.URL!)
        }
        return false // tells UIWebView to not actually get anything
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

