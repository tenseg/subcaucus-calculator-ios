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
			webView.translatesAutoresizingMaskIntoConstraints = false
			webView.navigationDelegate = self
			webView.uiDelegate = self
			
			// attempt to load old SubCalc data file to local storage
			attemptToMigrateOldSubCalcDataTo(webView)
			
			// add web view to the main view
			self.view.addSubview(webView)
			
			// deal with safe area avoidance
			let margins = self.view.layoutMarginsGuide
			NSLayoutConstraint.activate([
				webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
				webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
				])
			let guide = self.view.safeAreaLayoutGuide
			webView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
			webView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
			webView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
			webView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
			
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
		let oldFile = (NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as String) + "/subcalc.json"
		if let subcalcJSON = try? String(contentsOfFile: oldFile) {
			// import json into local storage as for the old app, for the React app to migrate itself
			webView.evaluateJavaScript("localStorage.setItem('subcalc', \(subcalcJSON)") { (result, error) in
				// delete the file if succeeded
				if (error == nil) {
					do {
						try FileManager.default.removeItem(at: URL(fileURLWithPath: oldFile))
					} catch {
						print("\(oldFile) deletion failed")
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
	func shareCSV(_ csvContent: String, toFile filename: String?) {
		// ensure a valid filename
		var filename = filename // so that we can change it
		if filename == nil {
			filename = "Export.csv"
		}
		// set up the temporary path
		let temporaryPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename!)
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
					print("\(temporaryPath) deletion failed")
				}
			}
			self.present(activityViewController, animated: true, completion: nil)
		} catch {
			let alertController = UIAlertController(title: "CSV Download Failed", message: "The CSV download has failed. Please try again.", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	// used to send email within the app
	func shareEmail(_ to: String, withSubject subject: String?, andBody body: String?) {
		// we want to send email feedback from native-land
		if MFMailComposeViewController.canSendMail() {
			let mailView = MFMailComposeViewController()
			mailView.mailComposeDelegate = self
			mailView.setToRecipients([to])
			if (subject != nil) {
				mailView.setSubject(subject!)
			}
			if (body != nil) {
				mailView.setMessageBody(body!, isHTML: false)
			}
			self.present(mailView, animated: true, completion: nil)
		} else {
			let alertController = UIAlertController(title: "Cannot Send Email", message: "Please set up Mail before attempting to send email from SubCalc.", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	//MARK: Handling Our Own URL Scheme
	
	// we separate out handling of our url scheme from the webview delegate both to make it easier to find and change and so that the app delegate can use it to handle incoming urls from other apps
	func handleSubcalcURLComponents(_ urlComps: URLComponents) {
		// used to share text strings
		// can be used from Share > Download text and Share > Download code in the React app
		// may evenbe appropriate to not show Share > Email report in the ios app since Mail is an option from the activity controller used by the other download options
		// or Share > Email report may just be able to use the same mailto: as the web app, and use ios default behavior for those links to open a mail view
		if urlComps.host == "share-text" {
			if let text = urlComps.path.deletePrefix("/")?.removingPercentEncoding {
				shareText(text)
			}
		}
		// used to share csv content
		// can be used from Share > Download CSV in the React app
		// assumes that the input string is valid csv data
		if urlComps.host == "share-csv" {
			// pull the filename from the query items if it is there
			var filename = "Meeting.csv"
			if let queryItems = urlComps.queryItems {
				for item in queryItems {
					if item.name == "filename" {
						if let value = item.value {
							filename = value + ".csv"
						}
					}
				}
			}
			// share to csv
			if let csv = urlComps.path.deletePrefix("/")?.removingPercentEncoding {
				shareCSV(csv, toFile: filename)
			}
		}
	}
    
    //MARK: WebKit Delegates
	
	// decide how to handle urls that are being loaded
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		if let url = navigationAction.request.url  {
			let urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true)! // why is this an optional?
			// automatically load file URLs in this web view
			if urlComps.scheme == "file" {
				decisionHandler(.allow) // tells WKWebView to actually pick up this local file
			// this scheme is used to pass data between react and swift
			// use "subcalc://_action_/_data_" where _action_ is from the below options and _data_ is the text you want to pass on to the swift from React
			} else if urlComps.scheme == "subcalc" {
				handleSubcalcURLComponents(urlComps)
				decisionHandler(.cancel) // tells WKWebView to not actually get anything
			// open mailto urls in mailview instead of Safari
			} else if urlComps.scheme == "mailto" {
				// example link: "mailto:email@Mailto.co.uk?subject=Subject Using Mailto.co.uk&body=Email test"
				var subject: String? = nil
				var body: String? = nil
				if let queryItems = urlComps.queryItems {
					for item in queryItems {
						if item.name == "subject" {
							if let sub = item.value {
								subject = sub
							}
						}
						if item.name == "body" {
							if let bod = item.value {
								body = bod
							}
						}
					}
				}
				if let to = urlComps.path.removingPercentEncoding {
					shareEmail(to, withSubject: subject, andBody: body)
				}
				decisionHandler(.cancel) // tells WKWebView to not actually get anything
			} else {
				UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
				decisionHandler(.cancel) // tells WKWebView to not actually get anything
			}
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
	
	//MARK: Mail Delegate
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		self.dismiss(animated: true, completion: nil)
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
