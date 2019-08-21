//
//  SpaceFlyScene.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 14/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Cocoa

class SpaceFlyScene: ScreenSaverScene {

	private var logoImage:NSImage?
	private var logoImageFull:NSImage?

	private var logoArray = [LogoLayer]()
	private let maximumNumberOfLogos = 70

	private var logoGeneratingTimer:Timer?
	private var logoFullGeneratingTimer:Timer?

	private var screenCenterPosition = CGPoint()

	private var logoStartSmallFrame = CGRect()
	private var logoStartBigFrame = CGRect()

	private let spreadFactor:CGFloat = 0.15		// at 1.0 logos won't move at all, decreasin this will move logos away from center (must be greater than 0.0)

	private var logoStartingSizeMultiplier:CGFloat = 0.1
	private var logoEndingSizeMultiplier:CGFloat = 0.8

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

	override init() {
		super.init(withAnimationTimeInterval: 1/30.0)

		// Set background to black
		self.backgroundColor = NSColor.black.cgColor

		// Load logo images from bundle
		logoImage = self.loadImage(withName: "SimpleLogo")
		logoImageFull = self.loadImage(withName: "SimpleLogoFull")
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/////////////////////////////////////////////////////////////////////////
	// MARK: - ScreenSaverView overrided methods

	override var frame: CGRect {
		didSet {
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
		}
	}

	override func start() {
		if logoGeneratingTimer == nil {
			logoGeneratingTimer = Timer.scheduledTimer(timeInterval: randomTimeInterval,
													   target: self,
													   selector: #selector(randomizeNewLogo),
													   userInfo: nil,
													   repeats: false)
		}
		if logoFullGeneratingTimer == nil {
			logoFullGeneratingTimer = Timer.scheduledTimer(timeInterval: randomFullLogoTimeInterval,
														   target: self,
														   selector: #selector(generateFullLogo),
														   userInfo: nil,
														   repeats: false)
		}
	}

	override func stop() {
		logoGeneratingTimer?.invalidate()
		logoGeneratingTimer = nil

		logoFullGeneratingTimer?.invalidate()
		logoFullGeneratingTimer = nil

		// ScreenSaver stopped, all animations must be removed (SystemPreferences.app will crash otherwise)
		for logo in logoArray {
			logo.removeAllAnimations()
		}
	}

	/////////////////////////////////////////////////////////////////////////
	// MARK: - Logo management

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

		// Create new logo
		let newLogo = LogoLayer(withImage: logoImage)
		newLogo.position = startPosition

		newLogo.setScaleAnimation(fromScale: logoStartingSizeMultiplier, toScale: logoEndingSizeMultiplier * scaleTo)
		newLogo.setMovementAnimation(fromPosition: startPosition, toPosition: endPosition)

		// Add to layer and start animating
		self.addSublayer(newLogo)

		newLogo.logoDelegate = self
		newLogo.animate()

		return newLogo
	}

}

// MARK: - LogoLayer delegate method

extension SpaceFlyScene: LogoLayerDelegate {

	func logoShouldBeRemoved(_ logo: LogoLayer) {
		if let logoIndex = logoArray.firstIndex(of: logo) {
			logoArray.remove(at: logoIndex)
		}
		logo.removeFromSuperlayer()
	}

}
