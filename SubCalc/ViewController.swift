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

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    //MARK: View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// load the react app
		// this should always get the path, but needs if let to unwrap it
        if let htmlPath = Bundle.main.path(forResource: "react/index", ofType: "html") {
			// set up the web view and replace our view with it
			// there is nothing of substance in IB for this app's main GUI
			let webConfiguration = WKWebViewConfiguration()
			webConfiguration.websiteDataStore = WKWebsiteDataStore.default() // persistent
			let webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
			webView.backgroundColor = UIColor(red:0.558, green:0.092, blue:0.191, alpha:1) // red
			webView.navigationDelegate = self
			webView.uiDelegate = self
			self.view = webView
			
			// build the query items passing details about the ios app
			var queryItems = [
				URLQueryItem(name: "app", value: "yes"),
			]
			if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] {
				queryItems.append(URLQueryItem(name: "version", value: String(describing: version)))
			}
			if let build = Bundle.main.infoDictionary!["CFBundleVersion"] {
				queryItems.append(URLQueryItem(name: "build", value: String(describing: build)))
			}
			#if DEBUG // see https://kitefaster.com/2016/01/23/how-to-specify-debug-and-release-flags-in-xcode-with-swift/
				queryItems.append(URLQueryItem(name: "debug", value: "yes"))
			#endif
			
			// build the url to the react app
			var urlComps = URLComponents(url: URL(fileURLWithPath: htmlPath), resolvingAgainstBaseURL: false)!
			urlComps.queryItems = queryItems
			
			// load the react app
			webView.load(URLRequest(url: urlComps.url!))
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	//MARK: Actions from React App
	
	// share a string using ios activity view controller
	func shareString(content: String) {
		let activityViewController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}
    
    //MARK: WebKit Delegates
	
	// decide how to handle urls that are being loaded
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		// automatically load file URLs in this web view
		if navigationAction.request.url?.scheme == "file" {
			decisionHandler(.allow) // tells WKWebView to actually pick up this local file
		// this is used for passing data between react and swift
		} else if navigationAction.request.url?.scheme == "subcalc-extension" {
			if let incomingString = navigationAction.request.url?.path {
				// used to share plaintext strings
				if let shareableString = incomingString.deletePrefix("//share-string/" ) {
					shareString(content: shareableString)
				}
			}
			decisionHandler(.cancel) // tells WKWebView to not actually get anything
		} else {
			UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
			decisionHandler(.cancel) // tells WKWebView to not actually get anything
		}
	}
	
	// use ios alert controller for js alert panels instead of native js ones
	// see https://medium.com/@dakeshi/tips-for-wkwebview-that-will-keep-you-from-going-troubles-c1990851385c
	func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (() -> Void)) {
		
		let alertController = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
			completionHandler()
		}))
		self.present(alertController, animated: true, completion: nil)
	}
	
	// use ios alert controller for js confirm panels instead of native js ones
	// see https://medium.com/@dakeshi/tips-for-wkwebview-that-will-keep-you-from-going-troubles-c1990851385c
	func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		let alertController = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
			completionHandler(false)
		}))
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
			completionHandler(true)
		}))
		self.present(alertController, animated: true, completion: nil)
	}
	
	// use ios text input for js text input
	func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
		let alertController = UIAlertController(title: webView.url?.host, message: prompt, preferredStyle: .alert)
		alertController.addTextField { (textField: UITextField!) in
			textField.text = defaultText
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
			completionHandler(nil)
		}))
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
			if let text = alertController.textFields?.first?.text {
				completionHandler(text)
			} else {
				completionHandler(defaultText)
			}
		}))
		self.present(alertController, animated: true, completion: nil)
	}
    
    //MARK: Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension String {
	// deletes the prefix if it has that prefix
	// based on https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
	func deletePrefix(_ prefix: String) -> String? {
		guard self.hasPrefix(prefix) else { return nil }
		return String(self.dropFirst(prefix.count))
	}
}
