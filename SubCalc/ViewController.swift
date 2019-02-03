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
	
	/// This will try and migrate data from the old json file into the new local storage.
	///
	/// - Parameter webView: The webview to import into.
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
						print("\(oldFile) deletion failed \n \(String(describing: error))")
					}
				}
			}
		}
	}
	
	/// Imports JSON of a snapshot into local storage.
	///
	/// - Parameters:
	///   - data: The string data to import.
	///   - webView: The webview to import into.
	func importData(_ data: String, to webView: WKWebView) {
		// import json into local storage as for the old app, for the React app to migrate itself
		webView.evaluateJavaScript("localStorage.setItem('import', \(data)") { (result, error) in
			// delete the file if succeeded
			if (error == nil) {
				print("import failed: \(data) \n \(String(describing: error))")
			}
		}
	}
	
	//MARK: Actions from React App
	
	/// Share a text string using the iOS activity view controller.
	///
	/// - Parameter textContent: The text to share.
	func shareText(_ textContent: String) {
		let activityViewController = UIActivityViewController(activityItems: [textContent], applicationActivities: nil)
		activityViewController.completionWithItemsHandler = {
			(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
			self.dismiss(animated: true, completion: nil)
		}
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	/// Create a csv file and sharse it using the iOS activity view controller.
	/// See: http://www.justindoan.com/tutorials/2016/9/9/creating-and-exporting-a-csv-file-in-swift
	///
	/// - Parameters:
	///   - csvContent: The CSV content to put in the file.
	///   - filename: The name to give the file. Defaults to "Export.csv".
	func shareCSV(_ csvContent: String, toFile filename: String = "Export.csv") {
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
	
	/// Use to send email within the app.
	///
	/// - Parameters:
	///   - to: Recipient email address.
	///   - subject: Email subject.
	///   - body: Email body.
	func sendEmail(_ to: String, withSubject subject: String?, andBody body: String?) {
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
	
	/// We separate out handling of our url scheme from the webview delegate to let the app delegate use it to handle incoming urls from other apps.
	///
	/// - Parameter urlComps: The URL components object that has the details of the URL that was used.
	func handleSubcalcURLComponents(_ urlComps: URLComponents) {
		// used to share text strings
		// can be used from Share > Download text and Share > Download code in the React app as:
		//
		// subcalc://share-text/__text__
		//
		if urlComps.host == "share-text" {
			if let text = urlComps.path.deletePrefix("/") {
				shareText(text)
			}
		}
		
		// used to share csv content
		// can be used from Share > Download CSV in the React app as:
		//
		// subcalc://share-csv/__csv__?filename=__name__
		//
		// assumes that the path string is valid csv data
		if urlComps.host == "share-csv" {
			// share to csv
			if let csv = urlComps.path.deletePrefix("/") {
				let filename = urlComps.queryValueFor("filename") ?? "Meeting"
				shareCSV(csv, toFile: "\(filename.deleteExtensionComponent()).csv")
			}
		}
		
		// used to import a snapshot:
		//
		// subcalc://import/__json__
		//
		// the snapshot can be the json that gets produced from the "Download code" sharing option
		if urlComps.host == "import" {
			if let data = urlComps.path.deletePrefix("/") {
				if let webView = self.view.subviews[1] as? WKWebView {
					importData(data, to: webView)
				}
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
				sendEmail(urlComps.host!, withSubject: urlComps.queryValueFor("subject"), andBody: urlComps.queryValueFor("body"))
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
	/// Deletes the prefix if it has that prefix.
	/// See: https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
	///
	/// - Parameter prefix: The string to look for and delete.
	/// - Returns: An optional string withe the prefix removed if found. If not found this returns nil.
	func deletePrefix(_ prefix: String) -> String? {
		guard self.hasPrefix(prefix) else { return nil }
		return String(self.dropFirst(prefix.count))
	}
	
	
	/// Deletes the portion of the text after the last period. Meant to remove any possible file extension.
	///
	/// - Returns: The string with the extension removed or the original string if no extension found.
	func deleteExtensionComponent() -> String {
		var components = self.components(separatedBy: ".")
		if components.count > 1 { // If there is a file extension
			components.removeLast()
			return components.joined(separator: ".")
		} else {
			return self
		}
	}
}

extension URLComponents {
	/// Get the value for the passed query key if one exists.
	///
	/// The return value gets any percent encoding done for usability in a URL removed before being returned.
	///
	/// - Parameter key: The key to look for.
	/// - Returns: The string value in the query for the key that was passed or nil if not found.
	func queryValueFor(_ key: String) -> String? {
		if let queryItems = self.queryItems {
			for item in queryItems {
				if item.name == key {
					if let value = item.value?.removingPercentEncoding {
						return value
					}
				}
			}
		}
		return nil
	}
}
