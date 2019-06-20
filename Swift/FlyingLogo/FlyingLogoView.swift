//
//  FlyingLogoView.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 19/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import ScreenSaver

class FlyingLogoView: ScreenSaverView {

	var logoImage:NSImage?
	var logoImageFull:NSImage?

	var logoArray = [LogoLayer]()
	let maximumNumberOfLogos = 70

	var screenCenterPosition = CGPoint()

	var logoStartSmallFrame = CGRect()
	var logoStartBigFrame = CGRect()

	let spreadFactor:CGFloat = 0.15		// at 1.0 logos won't move at all, decreasin this will move logos away from center (must be greater than 0.0)

	var logoStartingSizeMultiplier:CGFloat = 0.1
	var logoEndingSizeMultiplier:CGFloat = 0.8

	var randomTimeInterval:TimeInterval {
		get {
			return TimeInterval(arc4random_uniform(50) + 50) / 1000		// Between 0.05s and 0.1s
		}
	}

	var randomFullLogoTimeInterval:TimeInterval {
		get {
			return TimeInterval(arc4random_uniform(8000) + 7000) / 1000				// Between 7.0s and 15.0s
		}
	}

	/////////////////////////////////////////////////////////////////////////
	// MARK: - Initialization

	override init?(frame: NSRect, isPreview: Bool) {
		super.init(frame: frame, isPreview: isPreview)

		self.animationTimeInterval = 1/30.0

		// Load logo images from bundle
		logoImage = self.loadImage(withName: "SimpleLogo")
		logoImageFull = self.loadImage(withName: "SimpleLogoFull")
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	private func loadImage(withName imageName: String) -> NSImage? {
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

	/////////////////////////////////////////////////////////////////////////
	// MARK: - ScreenSaverView overrided methods

	override func viewDidMoveToWindow() {
		// Create main CALayer displaying additional layers (floating logos)
		let mainLayer = CALayer()
		self.layer = mainLayer

		// As initially ScreenSaverView didn't have any backing CALayer, it have wantsLayer turned off
		// We just added backing layer and want to be used by our view, so we need to turn on wantsLayer property
		self.wantsLayer = true

		// Set background to black
		mainLayer.backgroundColor = NSColor.black.cgColor

		// Set layer size (fullscreen)
		mainLayer.frame = self.frame

		// Set starting and ending scale factors for logos
		if let logo = logoImage {
			let neededStartWidth = self.frame.size.width / 100.0
			let neededEndWidth = self.frame.size.width / 7.0

			logoStartingSizeMultiplier = neededStartWidth / logo.size.width
			logoEndingSizeMultiplier = neededEndWidth / logo.size.width
		}

		screenCenterPosition = CGPoint(x: self.frame.origin.x + self.frame.size.width/2,
									   y: self.frame.origin.y + self.frame.size.height/2)

		// Count small frame in the middle of the sceen (big logo will start from here)
		let startFrameSize = CGSize(width: self.frame.size.width * 0.1, height: self.frame.size.height * 0.1)
		logoStartSmallFrame = CGRect(x: (self.frame.size.width - startFrameSize.width) / 2,
									 y: (self.frame.size.height - startFrameSize.height) / 2,
									 width: startFrameSize.width,
									 height: startFrameSize.height)

		// Count bigger frame in the middle of the sceen (small logos will start from here)
		logoStartBigFrame = CGRect(x: self.frame.size.width * 0.25,
								   y: self.frame.size.height * 0.25,
								   width: self.frame.size.width * 0.5,
								   height: self.frame.size.height * 0.5)

		startRandomizedLogoGenerating()
	}

	override func startAnimation() {
		super.startAnimation()
	}

	override func stopAnimation() {
		// ScreenSaver stopped, all animations must be removed (SystemPreferences.app will crash otherwise)
		for logo in logoArray {
			logo.removeAllAnimations()
		}
		super.stopAnimation()
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

	/////////////////////////////////////////////////////////////////////////
	// MARK: - Logo management

	func startRandomizedLogoGenerating() {
		Timer.scheduledTimer(timeInterval: randomTimeInterval,
							 target: self,
							 selector: #selector(randomizeNewLogo),
							 userInfo: nil,
							 repeats: false)
		Timer.scheduledTimer(timeInterval: randomFullLogoTimeInterval,
							 target: self,
							 selector: #selector(generateFullLogo),
							 userInfo: nil,
							 repeats: false)
	}

	@objc func randomizeNewLogo() {

		if logoArray.count < maximumNumberOfLogos {

			guard let image = logoImage else { return }

			// Generate random position for logo
			let xPos = CGFloat(arc4random() % UInt32(logoStartBigFrame.size.width))
			let yPos = CGFloat(arc4random() % UInt32(logoStartBigFrame.size.height))

			// Create new logo
			let logo = generateNewLogo(withImage: image,
									   atPosition: CGPoint(x: logoStartBigFrame.origin.x + xPos,
														   y: logoStartBigFrame.origin.y + yPos))
			logoArray.append(logo)
#if DEBUG
			print("DEBUG: \(logoArray.count) logos")
#endif
		}
		// Tick timer
		Timer.scheduledTimer(timeInterval: randomTimeInterval,
							 target: self,
							 selector: #selector(randomizeNewLogo),
							 userInfo: nil,
							 repeats: false)
	}

	@objc func generateFullLogo() {
		guard let image = logoImageFull else { return }

		// Generate random position for logo
		let xPos = CGFloat(arc4random() % UInt32(logoStartSmallFrame.size.width))
		let yPos = CGFloat(arc4random() % UInt32(logoStartSmallFrame.size.height))

		// Create new logo
		let logo = generateNewLogo(withImage: image,
								   atPosition: CGPoint(x: logoStartSmallFrame.origin.x + xPos,
													   y: logoStartSmallFrame.origin.y + yPos),
								   scaleTo: 1.5)
		logoArray.append(logo)
#if DEBUG
		print("DEBUG: \(logoArray.count) logos")
#endif

		// Tick timer
		Timer.scheduledTimer(timeInterval: randomFullLogoTimeInterval,
							 target: self,
							 selector: #selector(generateFullLogo),
							 userInfo: nil,
							 repeats: false)
	}

	func generateNewLogo(withImage logoImage:NSImage, atPosition startPosition: CGPoint, scaleTo: CGFloat = 1.0) -> LogoLayer {

		// Count end position
		let endPosition = CGPoint(x: screenCenterPosition.x + (startPosition.x - screenCenterPosition.x)/spreadFactor,
								  y: screenCenterPosition.y + (startPosition.y - screenCenterPosition.y)/spreadFactor)

		// Create new logo with this colour
		let newLogo = LogoLayer(withImage: logoImage)
		newLogo.position = startPosition

		newLogo.setScaleAnimation(fromScale: logoStartingSizeMultiplier, toScale: logoEndingSizeMultiplier * scaleTo)
		newLogo.setMovementAnimation(fromPosition: startPosition, toPosition: endPosition)

		// Add to layer and start animating
		self.layer?.addSublayer(newLogo)

		newLogo.logoDelegate = self
		newLogo.animate()

		return newLogo
	}

}

extension FlyingLogoView: LogoLayerDelegate {

	func logoShouldBeRemoved(_ logo: LogoLayer) {
		if let logoIndex = logoArray.index(of: logo) {
			logoArray.remove(at: logoIndex)
		}
		logo.removeFromSuperlayer()
	}

}
