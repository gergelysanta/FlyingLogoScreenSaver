//
//  ScreenSaverScene.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 14/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Cocoa

class ScreenSaverScene: CALayer {

	private(set) var animationTimeInterval:TimeInterval = 1/60.0

	override init() {
		super.init()
	}

	init(withAnimationTimeInterval timeInterval: TimeInterval) {
		super.init()
		animationTimeInterval = timeInterval
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func loadImage(withName imageName: String) -> NSImage? {
		if let path = Bundle(for: self.classForCoder).path(forResource: imageName, ofType: "png") {
			// File exists and found -> load it's contents to NSData
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
				let image = NSImage(data: data)
			{
				return image
			}
		}
		return nil
	}

	func start() {
		// Override this method
	}

	func stop() {
		// Override this method
	}

}
