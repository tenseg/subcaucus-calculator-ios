//
//  ViewController.swift
//  SubCalc
//
//  Created by Eric Celeste on 15.12.01.
//  Copyright © 2015 Eric Celeste. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, MFMailComposeViewControllerDelegate {

    //MARK: Vars and Lets
    @IBOutlet weak var scWebView: WKWebView!
    
    //MARK: View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
		// attempt to load local data from user defaults
		loadWebViewData()
		
		// save local data when we are no longer active
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(saveWebViewData),
			name: UIApplication.willResignActiveNotification,
			object: nil)
		
		// load the react app
        if let htmlPath = Bundle.main.path(forResource: "react/index", ofType: "html") {
            let urlString = URL(fileURLWithPath: htmlPath).absoluteString + "?app=1"
			scWebView.load(URLRequest(url: URL(string: urlString)!))
			scWebView.navigationDelegate = self
			scWebView.uiDelegate = self
        }
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    //MARK: Helpers
    func tensegDeviceSystemProfile() -> String { // designed to eventually go into TensegHelpers and be usable across any iOS app we develop
        let device = UIDevice.current
        let infoPlist = Bundle.main.infoDictionary
		return "<---Please don't delete the following system information--->\n\(String(describing: infoPlist!["CFBundleName"])) Version: \(String(describing: infoPlist!["CFBundleShortVersionString"])) (\(String(describing: infoPlist!["CFBundleVersion"])))\nDevice: \(device.model)\niOS Version: \(device.systemVersion))\n<------------------------------------------------>"
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
			let jsString = "localStorage.getItem('\(key)')";
			scWebView.evaluateJavaScript(jsString, completionHandler: { (result, error) in
				// TODO: debug and finish once react app is actually saving data
//				if result != nil {
//					UserDefaults.standard.set(result, forKey: key)
//				}
			})
		}
	}
	
	// load data from user defaults to the web view
	func loadWebViewData() {
		for key in storageKeys {
			if let localData = UserDefaults.standard.string(forKey: key) {
				// @link https://stackoverflow.com/a/20965724
				// TODO: debug and finish once react app is actually saving data
//				let jsString = "localStorage.setItem('\(key)', \(localData)"
//				scWebView.evaluateJavaScript(jsString, completionHandler: nil )
			}
		}
	}
	
	//MARK: Actions from React App
	func shareString(content: String) {
		let activityViewController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}
	
	func emailTenseg() {
		// we want to send email feedback from native-land
		if MFMailComposeViewController.canSendMail() {
			let mailView = MFMailComposeViewController()
			mailView.mailComposeDelegate = self
			mailView.setToRecipients(["efc@tenseg.net"]) // should we really send the iOS email to subcalc@tenseg.net instead?
			mailView.setSubject("SubCalc Feedback")
			mailView.setMessageBody("\n\n\n \(tensegDeviceSystemProfile())", isHTML: false)
			self.present(mailView, animated: true, completion: nil)
		} else {
			let cantSendMailAlert = UIAlertController(title: "Cannot Send Mail", message: "You must first set up Mail before you can send feedback to Tenseg.", preferredStyle: UIAlertController.Style.alert)
			cantSendMailAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
			self.present(cantSendMailAlert, animated: true, completion: nil)
		}
	}
    
    //MARK: Delegates
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		// automatically load file URLs in this web view
		if navigationAction.request.url?.scheme == "file" {
			decisionHandler(.allow) // tells WKWebView to actually pick up this local file
		} else if navigationAction.request.url?.scheme == "subcalc-extension" {
			// this is used for passing data between react and swift
			if let incomingString = navigationAction.request.url?.path {
				if ( incomingString.hasPrefix("//share/" ) ) {
					shareString(content: incomingString.deletePrefix("//share/"))
				} else if ( incomingString == "//feedback-email" ) {
					emailTenseg()
				}
			}
			decisionHandler(.cancel) // tells WKWebView to not actually get anything
		} else {
			UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil) // anything else goes to Safari
			decisionHandler(.cancel) // tells WKWebView to not actually get anything
		}
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

// see https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
extension String {
	func deletePrefix(_ prefix: String) -> String {
		guard self.hasPrefix(prefix) else { return self }
		return String(self.dropFirst(prefix.count))
	}
}
