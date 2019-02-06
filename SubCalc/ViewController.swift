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
	
	//MARK: Instance Vars
	
	/// Javascript commmand: callback (result, error)
	var javascriptQueue: [[String: (Any?, Any?) -> Void]] = [[:]]
	
    //MARK: View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// load the react app
		// this should always get the components to the react app, but needs if var to unwrap everything
		if var urlComps = URLComponents(url: URL(fileURLWithPath: Bundle.main.path(forResource: "react/index", ofType: "html") ?? ""), resolvingAgainstBaseURL: false) {
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
			attemptToMigrateOldSubCalcData()
			
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
			if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
				queryItems.append(URLQueryItem(name: "version", value: String(describing: version)))
			}
			if let build = Bundle.main.infoDictionary?["CFBundleVersion"] {
				queryItems.append(URLQueryItem(name: "build", value: String(describing: build)))
			}
			#if DEBUG // see https://kitefaster.com/2016/01/23/how-to-specify-debug-and-release-flags-in-xcode-with-swift/
				queryItems.append(URLQueryItem(name: "debug", value: "yes"))
			#endif
			urlComps.queryItems = queryItems
			
			// load the react app
			// we should always have a url since the urlcomps was made with one to even get here
			// but since it is an optional property we must insist on it being there
			webView.load(URLRequest(url: urlComps.url!))
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	//MARK: Helpers
	
	/// This will try and migrate data from the old json file into the new local storage.
	func attemptToMigrateOldSubCalcData() {
		let oldFile = (NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as String) + "/subcalc.json"
		// if debugging print the path so we can examine the simulator's container in Finder
		#if DEBUG
			print("--------Container path--------")
			print(oldFile)
			print("------------------------------")
		#endif
		if let subcalcJSON = try? String(contentsOfFile: oldFile) {
			javascriptQueue.append(["localStorage.setItem('subcalc', '\(subcalcJSON)'": { (result, error) in
				if error == nil {
					// do { // TODO: uncomment
//						try FileManager.default.removeItem(at: URL(fileURLWithPath: oldFile))
//					} catch {
//						print("\(oldFile) deletion failed \n \(String(describing: error))")
//					}
				}
				}])
		}
	}
	
	/// Imports JSON of a snapshot into local storage.
	///
	/// - Parameters:
	///   - data: The string data to import.
	///   - webView: The webview to import into.
	func importData(_ data: String) {
		javascriptQueue.append(["localStorage.setItem('import', '\(data))'": { (result, error) in
			if error == nil {
				print("import failed: \(data) \n \(String(describing: error))")
			}
		}])
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
			shareText(urlComps.path.deletePrefix("/"))
		}
		
		// used to share csv content
		// can be used from Share > Download CSV in the React app as:
		//
		// subcalc://share-csv/__csv__?filename=__name__
		//
		// assumes that the path string is valid csv data
		if urlComps.host == "share-csv" {
			let filename = urlComps.queryValueFor("filename") ?? "Meeting"
			shareCSV(urlComps.path.deletePrefix("/"), toFile: "\(filename.ensureSuffix(".csv"))")
		}
		
		// used to import a snapshot:
		//
		// subcalc://import/__json__
		//
		// the snapshot can be the json that gets produced from the "Download code" sharing option
		if urlComps.host == "import" {
			importData(urlComps.path.deletePrefix("/"))
		}
	}
    
    //MARK: WebKit Delegates
	
	// decide how to handle urls that are being loaded
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		if let urlComps = URLComponents(string: navigationAction.request.url?.absoluteString ?? "") {
			// automatically load file URLs in this web view
			if urlComps.scheme == "file" {
				decisionHandler(.allow) // tells WKWebView to actually pick up this local file
			// this scheme is used to pass data between react and swift
			} else if urlComps.scheme == "subcalc" {
				handleSubcalcURLComponents(urlComps)
				decisionHandler(.cancel) // tells WKWebView to not actually get anything
			// open mailto urls in mailview instead of Safari
			} else if urlComps.scheme == "mailto" {
				// example url: "mailto:email@Mailto.co.uk?subject=Subject Using Mailto.co.uk&body=Email test"
				sendEmail(urlComps.host!, withSubject: urlComps.queryValueFor("subject"), andBody: urlComps.queryValueFor("body"))
				decisionHandler(.cancel) // tells WKWebView to not actually get anything
			} else {
				UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
				decisionHandler(.cancel) // tells WKWebView to not actually get anything
			}
		}
	}
	
	// run javascript that has been queued after loads finish
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		// loop all commands to run
		for command in javascriptQueue {
			if command.keys.count > 0 {
				let javascript = command.keys[command.startIndex]
				webView.evaluateJavaScript(javascript) { (result, error) in
					command[javascript]!(result, error)
				}
			}
		}
		javascriptQueue.removeAll()
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
	/// Deletes the prefix if it exists.
	/// See: https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
	///
	/// - Parameter prefix: The string to look for and delete.
	/// - Returns: A string withe the prefix removed if found. If not found this returns the original string.
	func deletePrefix(_ prefix: String) -> String {
		guard self.hasPrefix(prefix) else { return self }
		return String(self.dropFirst(prefix.count))
	}
	
	
	/// Deletes the suffix if it exists.
	/// See: https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
	///
	/// - Parameter suffix: The string to look for and delete.
	/// - Returns: A string withe the suffix removed if found. If not found this returns the original string.
	func deleteSuffix(_ suffix: String) -> String {
		guard self.hasSuffix(suffix) else { return self }
		return String(self.dropLast(suffix.count))
	}
	
	
	/// Make sure the string has the given suffix.
	///
	/// - Parameter suffix: The desired suffix.
	/// - Returns: The string with the suffix.
	func ensureSuffix(_ suffix: String) -> String {
		guard self.hasSuffix(suffix) else { return self + suffix }
		return self
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
