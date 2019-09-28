//
//  FlyingLogoView.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 19/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import ScreenSaver

class FlyingLogoView: ScreenSaverView {

	private var scene:ScreenSaverScene?

	/////////////////////////////////////////////////////////////////////////
	// MARK: - Initialization

	override init?(frame: NSRect, isPreview: Bool) {
		super.init(frame: frame, isPreview: isPreview)

		// Create main Scene displaying additional layers (floating logos)
		scene = SpaceFlyScene()
		self.layer = scene

		// As initially ScreenSaverView didn't have any backing CALayer, it have wantsLayer turned off
		// We just added backing layer and want to be used by our view, so we need to turn on wantsLayer property
		self.wantsLayer = true
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/////////////////////////////////////////////////////////////////////////
	// MARK: - ScreenSaverView overrided methods

	override func viewDidMoveToWindow() {
		// Set layer size (fullscreen)
		scene?.frame = self.frame;
	}

	override func startAnimation() {
		super.startAnimation()
		scene?.start()
	}

	override func stopAnimation() {
		super.stopAnimation()
		scene?.stop()
	}

	override func animateOneFrame() {
		// This function is called before each frame displayed
	}

	override var hasConfigureSheet: Bool {
		get {
			return false
		}
	}

	override var configureSheet: NSWindow? {
		get {
			return nil
		}
	}

}
