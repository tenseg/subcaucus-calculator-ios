//
//  Utilities.swift
//  SubCalc
//
//  Created by Alexander Celeste on 2/28/19.
//  Copyright © 2019 Tenseg LLC.
//

import Foundation

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
