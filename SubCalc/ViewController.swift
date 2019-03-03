//
//  ViewController.swift
//  SubCalc
//
//  Created by Eric Celeste on 2015.12.01.
//  Copyright © 2019 Tenseg LLC.
//

import UIKit
import WebKit
import MessageUI

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, MFMailComposeViewControllerDelegate {
	
	//MARK: Instance Vars
	
	/// Javascript commmand: callback (result, error)
	var javascriptQueue: [String: (Any?, Error?) -> Void] = [:]
	
	/// Layout constraints for iOS 10
	var ios10PortraitConstraints: [NSLayoutConstraint] = []
	var ios10LandscapeConstraints: [NSLayoutConstraint] = []
	
    //MARK: View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// load the react app if it is found in the app bundle
		if let htmlPath = Bundle.main.path(forResource: "react/index", ofType: "html") {
			// set up the web view and replace our view with it
			// there is nothing of substance in IB for this app's main GUI
			let webConfiguration = WKWebViewConfiguration()
			webConfiguration.websiteDataStore = WKWebsiteDataStore.default() // persistent
			let webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
			webView.isOpaque = false
			webView.backgroundColor = UIColor(red:0.558, green:0.092, blue:0.191, alpha:1) // red
			webView.navigationDelegate = self
			webView.uiDelegate = self
			
			// create the url components used to load the react app
			if var urlComps = URLComponents(url: URL(fileURLWithPath: htmlPath), resolvingAgainstBaseURL: false) {
				// attempt to migrate subcalc 2 data
				urlComps.queryItems = attemptToMigrateOldSubCalcDataWith([])
				
				// load the react app
				// we should always have a url since the urlcomps was made with one to even get here
				// but since it is an optional property we must insist on it being there
				webView.load(URLRequest(url: urlComps.url!))
				
				// add web view to the main view
				self.view.addSubview(webView)
				setUpConstraintsFor(webView)
			}
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	/// Set up the display constraints for the web view.
	///
	/// - Parameter webView: The web view to set up constraints for.
	func setUpConstraintsFor(_ webView: WKWebView) {
		webView.translatesAutoresizingMaskIntoConstraints = false
		// deal with layout
		if #available(iOS 11.0, *) {
			// safe area avoidance on iOS 11 and later
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
		} else {
			// just avoid the status bar prior to iOS 11
			ios10PortraitConstraints = [
				webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
				webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
				webView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor, constant: 22),
				webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
			]
			ios10LandscapeConstraints = [
				webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
				webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
				webView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor, constant: 0),
				webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
			]
			NSLayoutConstraint.activate(ios10PortraitConstraints)
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		if #available(iOS 11.0, *) {} else {
			if UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft {
				NSLayoutConstraint.deactivate(ios10PortraitConstraints)
				NSLayoutConstraint.activate(ios10LandscapeConstraints)
			} else {
				NSLayoutConstraint.deactivate(ios10LandscapeConstraints)
				NSLayoutConstraint.activate(ios10PortraitConstraints)
			}
		}
		super.viewWillTransition(to: size, with: coordinator)
	}
	
	
	/// We use keyboard shortcusts primarilly for debugging, but most are handy in production as well
	override var keyCommands: [UIKeyCommand]? {
		let commands = [
			UIKeyCommand(input: "p", modifierFlags: .command, action: #selector(printWebContent), discoverabilityTitle: "Print")
		]
		return commands
	}
	
	//MARK: Helpers
	
	/// This will try and migrate data from the old json file into the new local storage.
	///
	/// - Parameter query: Array of query items.
	/// - Returns: The modified array of query items.
	func attemptToMigrateOldSubCalcDataWith(_ query: Array<URLQueryItem>) -> Array<URLQueryItem> {
		var query = query // we must make the input a var so we can append to it later
		let oldFile = (NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as String) + "/subcalc.json"
		// if debugging print the path so we can examine the simulator's container in Finder
		#if DEBUG // see https://kitefaster.com/2016/01/23/how-to-specify-debug-and-release-flags-in-xcode-with-swift/
			print("--------Container path--------")
			print(oldFile)
			print("------------------------------")
		#endif
		// try to get json from the old file
		if let subcalcJSON = try? String(contentsOfFile: oldFile) {
			// queue the javascript to write out to local storage as a backup
            javascriptQueue["localStorage.setItem('iOSsubcalc2backup', \"\(subcalcJSON.replacingOccurrences(of: "\"", with: "\\\""))\")"] = {
                (result, error) in
				if error == nil {
					do {
						try FileManager.default.removeItem(at: URL(fileURLWithPath: oldFile))
					} catch {
						print("\(oldFile) deletion failed \n \(String(describing: error))")
					}
				} else {
					print("backup failed \n \(String(describing: error))")
				}
			}
			
			// add json to the query
			query.append(URLQueryItem(name: "subcalc2", value: subcalcJSON))
		}
		
		return query
	}
	
	/// Imports content into SubCalc.
	///
	/// - Parameters:
	///   - query: The array of query items to import.
	func importQuery(_ query: [URLQueryItem]?) {
		if let query = query {
			if let webView = self.view.subviews[1] as? WKWebView {
				if var urlComps = URLComponents(url: webView.url!, resolvingAgainstBaseURL: false) {
					if let queries = urlComps.queryItems {
						urlComps.queryItems = queries + query
					} else {
						urlComps.queryItems = query
					}
					webView.load(URLRequest(url: urlComps.url!))
				}
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
		activityViewController.popoverPresentationController?.sourceView = self.view
		activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	/// Create a file and sharse it using the iOS activity view controller.
	/// See: http://www.justindoan.com/tutorials/2016/9/9/creating-and-exporting-a-csv-file-in-swift
	///
	/// - Parameters:
	///   - fileContent: The CSV content to put in the file.
	///   - filename: The name to give the file. Defaults to "Export.csv".
	func shareFile(_ fileContent: String, toFile filename: String = "Export.csv") {
		// set up the temporary path
		let temporaryPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
		// try to write the csv to the file
		do {
			try fileContent.write(to: temporaryPath, atomically: true, encoding: String.Encoding.utf8)
			
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
			activityViewController.popoverPresentationController?.sourceView = self.view
			activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
			self.present(activityViewController, animated: true, completion: nil)
		} catch {
			let alertController = UIAlertController(title: "File Download Failed", message: "The file download has failed. Please try again.", preferredStyle: .alert)
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
	func sendEmailTo(_ to: String?, withSubject subject: String?, andBody body: String?) {
		// we want to send email feedback from native-land
		if MFMailComposeViewController.canSendMail() {
			let mailView = MFMailComposeViewController()
			mailView.mailComposeDelegate = self
			if (to != nil) {
				mailView.setToRecipients([to!])
			}
			if (subject != nil) {
				mailView.setSubject(subject!)
			}
			if (body != nil) {
				mailView.setMessageBody(body!, isHTML: false)
			}
			self.present(mailView, animated: true, completion: nil)
		} else {
			var appName = "this app"
			if let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String {
				appName = bundleName
			}
			let alertController = UIAlertController(title: "Cannot Send Email", message: "Please set up Mail before attempting to send email from \(appName).", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	/// Used to get the clipboard contents and pass it through to the web app via importing
	/// see https://stackoverflow.com/a/26377004
	func retrieveClipboardContents() {
		if let pastedString = UIPasteboard.general.string {
			if let urlComps = URLComponents(string: pastedString) {
				importQuery(urlComps.queryItems)
			} else {
				let alertController = UIAlertController(title: "Clipboard Not a URL", message: "Your clipboard isn't a URL. Only URLs work to be pasted into SubCalc.", preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alertController, animated: true, completion: nil)
			}
		} else {
			let alertController = UIAlertController(title: "Clipboard Empty", message: "There is nothing on your clipboard to paste.", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	
	/// Displays the print UI to allow the user to print the currently-displayed conents of the web view
	/// needs @objc because it is called, in part, from a keyboard shortcut
	/// see https://nshipster.com/uiprintinteractioncontroller/
	///
	/// - Parameters:
	///   - jobName: The name of the print job, may show up as PDF filename or on some printer displays.
	@objc func printWebContent(_ jobName: String = "SubCalc") {
		if let webView = self.view.subviews[1] as? WKWebView {
			// set up print info
			let printInfo = UIPrintInfo(dictionary: nil)
			printInfo.jobName = jobName
			printInfo.duplex = .longEdge
			printInfo.outputType = .grayscale
			
			// set up and display the print controller
			let printController = UIPrintInteractionController.shared
			printController.printInfo = printInfo
			printController.showsNumberOfCopies = true
			printController.printFormatter = webView.viewPrintFormatter()
			printController.present(animated: true, completionHandler: nil)
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
			shareFile(urlComps.path.deletePrefix("/"), toFile: "\(filename.ensureSuffix(".csv"))")
		}
		
		// used to import a snapshot:
		//
		// subcalc://import?snapshot=__json__
		//
		// the snapshot can be the json that gets produced from the "Download code" sharing option
		if urlComps.host == "import" {
			importQuery(urlComps.queryItems)
		}
		
		// used to get the clipboard contents
		//
		// subcalc://get-clipboard
		//
		// it will reload the web app with a get param that contains the clipboard contents
		if urlComps.host == "get-clipboard" {
			retrieveClipboardContents()
		}
		
		// used to trigger the print view
		//
		// subcalc://print
		//
		// you can also trigger printing with command-p
		if urlComps.host == "print" {
			let jobName = urlComps.queryValueFor("name") ?? "SubCalc"
			printWebContent(jobName)
		}
	}
    
    //MARK: WebKit Delegates
	
	// decide how to handle urls that are being loaded
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		if let urlString = navigationAction.request.url?.absoluteString {
			if let urlComps = URLComponents(string: urlString) {
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
					sendEmailTo(urlComps.path, withSubject: urlComps.queryValueFor("subject"), andBody: urlComps.queryValueFor("body"))
					decisionHandler(.cancel) // tells WKWebView to not actually get anything
				} else {
					UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
					decisionHandler(.cancel) // tells WKWebView to not actually get anything
				}
			}
		}
	}
	
	// run javascript that has been queued after loads finish
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		// loop all commands to run
		for command in javascriptQueue {
            webView.evaluateJavaScript(command.key) { (result, error) in
                command.value(result, error)
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
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
