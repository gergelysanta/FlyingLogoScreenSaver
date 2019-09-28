//
//  HorizontalFlowScene.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 19/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Cocoa

class HorizontalFlowScene: ScreenSaverScene {

	var rightToLeft = true

	private var logoImage:NSImage?

	private var logoArray = [LogoLayer]()
	private let maximumNumberOfLogos = 20

	private var mainLogo:LogoLayer?

	private var logoGeneratingTimer:Timer?
	private var mainLogoGeneratingTimer:Timer?

	private var logoMinimumHeight:CGFloat = 0
	private var logoMaximumHeight:CGFloat = 0
	private var mainLogoHeight:CGFloat = 0

	var randomTimeInterval:TimeInterval {
		get {
			return TimeInterval(arc4random_uniform(600) + 900) / 1000			// Between 0.6s and 1.5s
		}
	}

	var randomMainLogoTimeInterval:TimeInterval {
		get {
			return TimeInterval(arc4random_uniform(6000) + 4000) / 1000			// Between 6s and 10s
		}
	}

	var randomHeight:CGFloat {
		get {
			return logoMinimumHeight + CGFloat(arc4random_uniform(UInt32(logoMaximumHeight - logoMinimumHeight)))
		}
	}

	/////////////////////////////////////////////////////////////////////////
	// MARK: - Initialization

	override init() {
		super.init()

		// Set background to black
		self.backgroundColor = NSColor.black.cgColor

		// Load logo image from bundle
		logoImage = self.loadImage(withName: "SimpleLogoFull")
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/////////////////////////////////////////////////////////////////////////
	// MARK: - ScreenSaverView overrided methods

	override var frame: CGRect {
		didSet {
			logoMinimumHeight = self.frame.size.height / 30.0
			logoMaximumHeight = self.frame.size.height / 10.0
			mainLogoHeight = self.frame.size.height / 3.0
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
		if mainLogoGeneratingTimer == nil {
			mainLogoGeneratingTimer = Timer.scheduledTimer(timeInterval: randomMainLogoTimeInterval,
														   target: self,
														   selector: #selector(generateMainLogo),
														   userInfo: nil,
														   repeats: false)
		}
	}

	override func stop() {
		logoGeneratingTimer?.invalidate()
		logoGeneratingTimer = nil

		mainLogoGeneratingTimer?.invalidate()
		mainLogoGeneratingTimer = nil

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

			// Create new logo
			let logo = generateFlowingLogo(withImage: image, height: randomHeight)
			logoArray.append(logo)
			#if DEBUG
			print("DEBUG: \(logoArray.count) logos")
			#endif
		}

		// Tick timer
		logoGeneratingTimer = Timer.scheduledTimer(timeInterval: randomTimeInterval,
												   target: self,
												   selector: #selector(randomizeNewLogo),
												   userInfo: nil,
												   repeats: false)
	}

	@objc func generateMainLogo() {
		guard let image = logoImage else { return }

		// Remove old main logo if still exists
		mainLogo?.removeFromSuperlayer()

		// Create new logo
		mainLogo = generateFlowingLogo(withImage: image, height: mainLogoHeight, animationDuration: 15.0)
		mainLogo?.zPosition = 10.0
	}

	func generateFlowingLogo(withImage logoImage:NSImage, height: CGFloat, animationDuration: CGFloat? = nil) -> LogoLayer {

		let scale = height / logoImage.size.height
		let xOffset = (logoImage.size.width * scale) / 2

		// Generate random position for logo
		let startPosition = CGPoint(x: rightToLeft ? self.frame.size.width + xOffset : -xOffset,
									y: CGFloat(arc4random() % UInt32(self.frame.size.height - logoImage.size.height)) + logoImage.size.height/2)
		let endPosition = CGPoint(x: rightToLeft ? -xOffset : self.frame.size.width + xOffset,
								  y: startPosition.y)

		// Create new logo
		let newLogo = LogoLayer(withImage: logoImage)

		// Add layer for making logo darker
		let darkLayer = CALayer()
		darkLayer.frame.size = newLogo.frame.size
		darkLayer.backgroundColor = CGColor.black
		switch height {
		case ...logoMinimumHeight:
			darkLayer.opacity = 1.0
		case logoMaximumHeight...:
			darkLayer.opacity = 0.0
		default:
			darkLayer.opacity = 1.0 - (Float((height - logoMinimumHeight) / logoMaximumHeight) * 0.8)
		}
		darkLayer.mask = LogoLayer(withImage: logoImage)
		newLogo.addSublayer(darkLayer)

		// Setup logo layer
		newLogo.position = startPosition
		newLogo.zPosition = scale * 10
		newLogo.transform = CATransform3DMakeScale(scale, scale, 1)
		if let duration = animationDuration {
			newLogo.animationDuration = duration
		}
		else {
			newLogo.animationDuration /= CGFloat(scale)
		}

		newLogo.setMovementAnimation(fromPosition: startPosition, toPosition: endPosition, timing: .linear)

		// Add to layer and start animating
		self.addSublayer(newLogo)

		newLogo.logoDelegate = self
		newLogo.animate()

		return newLogo
	}

}

// MARK: - LogoLayer delegate method

extension HorizontalFlowScene: LogoLayerDelegate {

	func logoShouldBeRemoved(_ logo: LogoLayer) {
		if let logoIndex = logoArray.firstIndex(of: logo) {
			logoArray.remove(at: logoIndex)
		}
		logo.removeFromSuperlayer()

		if let mainLogo = mainLogo,
			logo == mainLogo
		{
			// Set timer for starting new main logo
			mainLogoGeneratingTimer = Timer.scheduledTimer(timeInterval: randomMainLogoTimeInterval,
														   target: self,
														   selector: #selector(generateMainLogo),
														   userInfo: nil,
														   repeats: false)
		}
	}

}
