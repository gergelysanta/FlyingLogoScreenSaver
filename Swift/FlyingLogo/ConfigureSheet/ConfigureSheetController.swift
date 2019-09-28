//
//  ConfigureSheetController.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 28/09/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Cocoa

class ConfigureSheetController: NSWindowController {

	@IBOutlet var sceneTypeSelector: NSPopUpButton!
	
	override var windowNibName: NSNib.Name? {
		return "ConfigureSheet"
	}

	override func windowDidLoad() {
		super.windowDidLoad()

		// Create new menu for sceneTypeSelector
		let sceneTypesMenu = NSMenu()

		// Fill up menu with available scene names
		for name in Configuration.shared.sceneNames {
			let item = NSMenuItem()
			item.title = name
			item.action = #selector(sceneTypeSelected(menuItem:))
			item.tag = (Configuration.shared.scenes[name] ?? Configuration.SceneType.spaceFly).rawValue
			sceneTypesMenu.addItem(item)
		}

		// Set new menu for selector and select actually configured value
		self.sceneTypeSelector.menu = sceneTypesMenu
		self.sceneTypeSelector.selectItem(withTag: Configuration.shared.sceneType.rawValue)
	}

	@objc func sceneTypeSelected(menuItem: NSMenuItem) {
		// Store selection
		Configuration.shared.sceneType = Configuration.SceneType(rawValue: menuItem.tag) ?? Configuration.SceneType.spaceFly
	}

	@IBAction func closeButtonPressed(_ sender: NSButton) {
		if let window = self.window {
			NSApp.endSheet(window)
		}
	}
	
}
