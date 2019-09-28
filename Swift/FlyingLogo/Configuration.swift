//
//  Configuration.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 28/09/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Cocoa
import ScreenSaver

class Configuration {

	static let shared = Configuration()

	enum SceneType:Int {
		case spaceFly
		case horizontalFlow
	}

	let sceneNames = [ "SpaceFly", "HorizontalFlow" ]
	let scenes:[String:SceneType] = [
		"SpaceFly":       .spaceFly,
		"HorizontalFlow": .horizontalFlow
	]

	var sceneType:SceneType {
		get {
			return Configuration.SceneType(rawValue: defaults.integer(forKey: "sceneType")) ?? .spaceFly
		}
		set {
			defaults.set(newValue.rawValue, forKey: "sceneType")
			defaults.synchronize()
		}
	}

	private let defaults:UserDefaults

	private init() {
		if let identifier = Bundle(for: Configuration.self).bundleIdentifier {
			defaults = ScreenSaverDefaults(forModuleWithName: identifier) ?? ScreenSaverDefaults()
		} else {
			defaults = ScreenSaverDefaults()
		}
	}

}
