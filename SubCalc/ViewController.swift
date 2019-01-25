//
//  ViewController.swift
//  SubCalc
//
//  Created by Eric Celeste on 15.12.01.
//  Copyright © 2015 Eric Celeste. All rights reserved.
//

import UIKit
import WebKit

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
			
			// attempt to load old SubCalc data file to local storage
			attemptToMigrateOldSubCalcDataTo(webView)
			
			// replace the view with the web view
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
	
	//MARK: Helpers
	
	// this will try and migrate data from the old json file into the new local storage
	func attemptToMigrateOldSubCalcDataTo(_ webView: WKWebView) {
		let docDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as String)
		if let subcalcJSON = try? String(contentsOfFile: docDirectory + "/subcalc.json") {
			// import json into local storage as for the old app, for the React app to migrate itself
			webView.evaluateJavaScript("localStorage.setItem('subcalc', \(subcalcJSON)") { (result, error) in
				// delete the file if succeeded
				if (error == nil) {
					do {
						try FileManager.default.removeItem(at: URL(fileURLWithPath: docDirectory + "/subcalc.json"))
					} catch {
						print("file deletion failed")
					}
				}
			}
		}
	}
	
	//MARK: Actions from React App
	
	// share a text string using ios activity view controller
	func shareText(_ textContent: String) {
		let activityViewController = UIActivityViewController(activityItems: [textContent], applicationActivities: nil)
		activityViewController.completionWithItemsHandler = {
			(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
			self.dismiss(animated: true, completion: nil)
		}
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	// create a csv file and share it
	//based on http://www.justindoan.com/tutorials/2016/9/9/creating-and-exporting-a-csv-file-in-swift
	func shareCSV(_ csvContent: String, toFile filename: String) {
		// set up the temporary path
		let temporaryPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
		// try to write the csv to the file
		do {
			try csvContent.write(to: temporaryPath, atomically: true, encoding: String.Encoding.utf8)
			
			// offer options to share the csv file
			let activityViewController = UIActivityViewController(activityItems: [temporaryPath], applicationActivities: [])
			activityViewController.completionWithItemsHandler = {
				(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
				self.dismiss(animated: true, completion: nil)
				// delete the temporary file
				do {
					try FileManager.default.removeItem(at: temporaryPath)
				} catch {
					print("file deletion failed")
				}
			}
			self.present(activityViewController, animated: true, completion: nil)
		} catch {
			let alertController = UIAlertController(title: "CSV Download Failed", message: "The CSV download has failed. Please try again.", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
	}
    
    //MARK: WebKit Delegates
	
	// decide how to handle urls that are being loaded
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		// automatically load file URLs in this web view
		if navigationAction.request.url?.scheme == "file" {
			decisionHandler(.allow) // tells WKWebView to actually pick up this local file
		// this scheme is used internally to passing data between react and swift
		// use "subcalc-extension://_action_/_data_" where _action_ is from the below options and _data_ is the text you want to pass on to the swift from React
		} else if navigationAction.request.url?.scheme == "subcalc-extension" {
			if let incomingString = navigationAction.request.url?.path {
				// used to share text strings
				// can be used from Share > Download text and Share > Download code in the React app
				// may evenbe appropriate to not show Share > Email report in the ios app since Mail is an option from the activity controller used by the other download options
				// or Share > Email report may just be able to use the same mailto: as the web app, and use ios default behavior for those links to open a mail view
				if let textString = incomingString.deletePrefix("//share-text/" ) {
					shareText(textString)
				}
				// used to share csv content
				// can be used from Share > Download CSV in the React app
				// assumes that the input string is valid csv data
				if let csvString = incomingString.deletePrefix("//share-csv/" ) {
					shareCSV(csvString, toFile: "Caucus.csv") // TODO: make a better filename w/ further input parsing? perhaps there is a filename, then another delimeter, then csv content?
				}
			}
			decisionHandler(.cancel) // tells WKWebView to not actually get anything
		// everything else uses the default ios handling, which may means Safari, Mail, Phone, etc.
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
