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
        UIApplication.shared.statusBarStyle = .lightContent
        // get documents path
        // something like ~/Library/Developer/CoreSimulator/Devices/5C595030-7E0F-4FB8-AEBE-9F7BC6D23844/data/Containers/Data/Application/89361389-672E-4F91-BDBC-EE94F6E45F89/Documents on simulator
        self.scRootPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as String)
        print (self.scRootPath)
        
        // To communicate with this webview... http://stackoverflow.com/questions/15983797/can-a-uiwebview-interact-communicate-with-the-app
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let htmlURL = URL(fileURLWithPath: htmlPath)
            let urlString = htmlURL.absoluteString
            let queryString = "?app=1" // to signal to the script that we are in-app
            let urlWithQuery = urlString + queryString
            let finalURL = URL(string: urlWithQuery)
            let htmlRequest = URLRequest(url: finalURL!)
            scWebView.loadRequest(htmlRequest)
        }
   }
    
    //MARK: Helpers
    func tensegDeviceSystemProfile() -> String { // designed to eventually go into TensegHelpers and be usable across any iOS app we develop
        let device = UIDevice.current
        let infoPlist = Bundle.main.infoDictionary
		return "<---Please don't delete the following system information--->\n\(String(describing: infoPlist!["CFBundleName"])) Version: \(String(describing: infoPlist!["CFBundleShortVersionString"])) (\(String(describing: infoPlist!["CFBundleVersion"])))\nDevice: \(device.model)\niOS Version: \(device.systemVersion)\nTenseg Device Identifier: \(String(describing: device.identifierForVendor))\n<------------------------------------------------>"
    }
    
    //MARK: Delegates
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
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
        if request.url?.scheme == "file" {
            // returns the actual files (like HTML, CSS, JS, etc.)
            return true // tells UIWebView to actually pick up this local file
        } else if request.url?.scheme == "subcalc-extension" {
            // this is used for passing data between js and swift
            var incomingString = request.url?.path //TODO: Broken after Swift 3 migration, needs fixing before next release, was .resourceSpecifier, but none of compiler-suggested replacements seems to do what we want
            if incomingString == nil {
                return false; // just give up if there is no real incomming string
            }
            if ( incomingString == "//get-caucuses") {
                // to get caucus data from swift for js side
                // NSString* returnValue = [self.webView stringByEvaluatingJavaScriptFromString: "someJSFunction()"];
                let fileContent = try? String(contentsOfFile: scRootPath + scJsonFilename)
                var result = ""
                if (fileContent != nil) {
                    result = webView.stringByEvaluatingJavaScript(from: "SCGetData("+fileContent!+")")!
                } else {
                    result = webView.stringByEvaluatingJavaScript(from: "SCGetData(\"nothing\")")!
                }
                print(result)
            } else if ( incomingString!.hasPrefix("//set-caucuses/") ) {
                // to set the swift caucuses storage as instructed by the js side
				let localIncoming = incomingString
                incomingString?.removeSubrange((localIncoming?.startIndex)!..<(localIncoming?.index((localIncoming?.startIndex)!, offsetBy: 15))!)
                let jsonString = incomingString!.removingPercentEncoding
                do {
                    try jsonString?.write(toFile: scRootPath + scJsonFilename, atomically: true, encoding: String.Encoding.utf8)
                } catch _ {
                    if #available(iOS 8.0, *) {
                        let alertController = UIAlertController(title: "Subcalc Here", message: jsonString, preferredStyle: .actionSheet)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            // do nothing
                        }
                        alertController.addAction(OKAction)
                        
                        self.present(alertController, animated: true) {
                            // do nothing
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            } else if ( incomingString!.hasPrefix("//share/" ) ) { // NOT YET LIVE
                // this will be used to pass a caucus over to the standard sharing sheet as a replacement to the simplistic email this caucus function
				print(incomingString ?? "")
                //***we need to make sure that incomingString is the content that we had sent as the email contents before moving forward here, which will mean undoing url encoding of everything but the json link***
                let activityViewController = UIActivityViewController(activityItems: [incomingString!], applicationActivities: nil) // should we carry backwards our CSV export activity for this menu? that would require additional code to go from json to csv, but may be worth it
                present(activityViewController, animated: true, completion: nil)
            } else if ( incomingString == "//feedback-email" ) { // NOT YET LIVE
                // we want to send email feedback from native-land
                if MFMailComposeViewController.canSendMail() {
                    let mailView = MFMailComposeViewController()
                    mailView.mailComposeDelegate = self
                    mailView.setToRecipients(["efc@sd64dfl.org"]) // should we really send the iOS email to subcalc@tenseg.net instead?
                    mailView.setSubject("SubCalc Feedback")
                    mailView.setMessageBody("\n\n\n \(self.tensegDeviceSystemProfile())", isHTML: false)
                    self.present(mailView, animated: true, completion: nil)
                } else {
                    /***let user know that they must first set up Mail***/
                }
            }
        } else {
            // if we are passed any URL other than file:// or subcalc-extention://
            // then we just let iOS handle it in the usual way
            // though, note, this will NOT be handled in our own UIWebView
            // so it effectively hands off to Safari or other apps
            UIApplication.shared.openURL(request.url!)
        }
        return false // tells UIWebView to not actually get anything
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

