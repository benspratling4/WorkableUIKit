//
//  NSUserActivity+DocumentUrl.swift
//  CommonUI
//
//  Created by Ben Spratling on 4/4/21.
//  Copyright © 2021 Sing Accord LLC. All rights reserved.
//

import Foundation
import UIKit

public let activityDocumentUrlKey:String = "docurl"

extension NSUserActivity {
	
	public var documentUrl:URL? {
		get {
			if let urlBookmarkData = userInfo?[activityDocumentUrlKey] as? Data {
				var isStale:Bool = true
				if let url:URL = try? URL(resolvingBookmarkData: urlBookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
				   ,!isStale {
					return url
				}
			}
			if let directUrl = userInfo?[UIDocument.userActivityURLKey] as? URL {
				return directUrl
			}
			return nil
		}
		set {
//			print("set documentUrl \(newValue)")
			#if targetEnvironment(macCatalyst)
			let bookmarkData:Data? = try? newValue?.bookmarkData(options: [ .withSecurityScope ], includingResourceValuesForKeys: nil, relativeTo: nil)
			#else
			let bookmarkData:Data? = try? newValue?.bookmarkData(options: [ .minimalBookmark ], includingResourceValuesForKeys: nil, relativeTo: nil)
			#endif
			
			//you still put in nil if it is nil
			if let docUrl = newValue {
				addUserInfoEntries(from: [UIDocument.userActivityURLKey:docUrl])
			}
								   
			if let data = bookmarkData {
				addUserInfoEntries(from: [activityDocumentUrlKey:data])
			}
		}
	}
	
}
