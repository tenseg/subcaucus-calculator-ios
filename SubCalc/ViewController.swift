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
    
    //MARK: View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        // set status bar style
		UIApplication.shared.statusBarStyle = .lightContent
		
		// attempt to load local data from user defaults
		loadWebViewData()
		
		// save local data when we are no longer active
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(saveWebViewData),
			name: UIApplication.willResignActiveNotification,
			object: nil)
        
        // To communicate with this webview... http://stackoverflow.com/questions/15983797/can-a-uiwebview-interact-communicate-with-the-app
        if let htmlPath = Bundle.main.path(forResource: "react/index", ofType: "html") {
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
	
	//MARK: Persistence
	
	// keys used in local storage by the web app
	// TODO: add the correct key(s)
	private let storageKeys = [
		"caucuses"
	]
	
	// Save data from the webview to user defaults
	@objc func saveWebViewData() {
		for key in storageKeys {
			// @link https://stackoverflow.com/a/20965724
			let jsString = "localStorage.getItem('\(key)')"; // TODO: make this the correct storage type
			if let localData = scWebView.stringByEvaluatingJavaScript(from: jsString) {
				UserDefaults.standard.set(localData, forKey: key)
			}
		}
	}
	
	// load data from user defaults to the web view
	func loadWebViewData() {
		for key in storageKeys {
			if let localData = UserDefaults.standard.string(forKey: key) {
				// @link https://stackoverflow.com/a/20965724
				let jsString = "localStorage.setItem('\(key)', \(localData)" // TODO: make this the correct storage type
				scWebView.stringByEvaluatingJavaScript(from: jsString)
			}
		}
	}
    
    //MARK: Delegates
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        // automatically load file URLs in this web view
        if request.url?.scheme == "file" {
            // returns the actual files (like HTML, CSS, JS, etc.)
            return true // tells UIWebView to actually pick up this local file
        } else if request.url?.scheme == "subcalc-extension" {
            // this is used for passing data between js and swift
            let incomingString = request.url?.path
            if incomingString == nil {
                return false; // just give up if there is no real incomming string
            }
           if ( incomingString!.hasPrefix("//share/" ) ) { // NOT YET LIVE
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
	
	//MARY: Take down
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

