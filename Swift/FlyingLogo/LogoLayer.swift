//
//  LogoLayer.swift
//  FlyingLogo
//
//  Created by Gergely Sánta on 19/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import ScreenSaver

protocol LogoLayerDelegate {
	func logoShouldBeRemoved(_ logo: LogoLayer)
}

class LogoLayer: CALayer {

	var logoDelegate: LogoLayerDelegate?

	private(set) var scaleAnimation: CABasicAnimation?
	private(set) var zposAnimation: CABasicAnimation?
	private(set) var moveAnimation: CABasicAnimation?

	var animationDuration:CGFloat = 5.0
	var fadeDuration:CGFloat = 1.0

	/////////////////////////////////////////////////////////////////////////
	// MARK: - Initialization

	init(withImage image: NSImage) {
		super.init()
		self.initialize(withImage: image)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func initialize(withImage image: NSImage) {
		self.contents = image
		self.frame.size = image.size
	}

	/////////////////////////////////////////////////////////////////////////
	// MARK: - Animating

	func setScaleAnimation(fromScale: CGFloat, toScale: CGFloat) {
		scaleAnimation = CABasicAnimation(keyPath: "transform.scale")

		// We just created the animation, it exists for sure
		// so we can forcewrap the optional in this method
		scaleAnimation!.fromValue = fromScale
		scaleAnimation!.toValue = toScale
		scaleAnimation!.duration = CFTimeInterval(animationDuration)

		// Set timing to animate slower at the beginning and faster at the end
		scaleAnimation!.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)

		// Don't do reverse animation
		scaleAnimation!.autoreverses = false

		// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
		// which means that just after the duration of the animation the layer will look as if the animation never happened.
		// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
		scaleAnimation!.fillMode = CAMediaTimingFillMode.forwards
		scaleAnimation!.isRemovedOnCompletion = false

		// Bigger logos are visually closer to camera so we need to animate also the z position
		zposAnimation = CABasicAnimation(keyPath: "zPosition")

		// We just created the animation, it exists for sure
		// so we can forcewrap the optional in this method
		zposAnimation!.fromValue = fromScale
		zposAnimation!.toValue = toScale
		zposAnimation!.duration = CFTimeInterval(animationDuration)

		// Set timing to animate slower at the beginning and faster at the end
		zposAnimation!.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)

		// Don't do reverse animation
		zposAnimation!.autoreverses = false

		// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
		// which means that just after the duration of the animation the layer will look as if the animation never happened.
		// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
		zposAnimation!.fillMode = CAMediaTimingFillMode.forwards
		zposAnimation!.isRemovedOnCompletion = false
	}

	func setMovementAnimation(fromPosition: CGPoint, toPosition: CGPoint, timing: CAMediaTimingFunctionName = .easeIn) {
		moveAnimation = CABasicAnimation(keyPath: "position")

		// We just created the animation, it exists for sure
		// so we can forcewrap the optional in this method
		moveAnimation!.fromValue = fromPosition
		moveAnimation!.toValue = toPosition
		moveAnimation!.duration = CFTimeInterval(animationDuration)

		// Set timing to animate slower at the beginning and faster at the end
		moveAnimation!.timingFunction = CAMediaTimingFunction(name: timing)

		// Don't do reverse animation
		moveAnimation!.autoreverses = false

		// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
		// which means that just after the duration of the animation the layer will look as if the animation never happened.
		// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
		moveAnimation!.fillMode = CAMediaTimingFillMode.forwards
		moveAnimation!.isRemovedOnCompletion = false

		// Set delegate to self, so 'animationDidStop' of this object will be called when movement ended
		moveAnimation!.delegate = self
	}

	func animate() {
		// Run animations
		if let animation = moveAnimation {
			self.add(animation, forKey: "MoveAnimation")
		}
		if let animation = zposAnimation {
			self.add(animation, forKey: "ZPosAnimation")
		}
		if let animation = scaleAnimation {
			self.add(animation, forKey: "ScaleAnimation")

			// Start to fade out before animation ends
			Timer.scheduledTimer(timeInterval: TimeInterval(animationDuration - fadeDuration),
								 target: self,
								 selector: #selector(fadeOut),
								 userInfo: nil,
								 repeats: false)
		}
	}
	
	@objc private func fadeOut() {
		let fadeAnimation = CABasicAnimation(keyPath: "opacity")

		fadeAnimation.toValue = 0.0
		fadeAnimation.duration = CFTimeInterval(fadeDuration)

		// Don't do reverse animation
		fadeAnimation.autoreverses = false

		// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
		// which means that just after the duration of the animation the layer will look as if the animation never happened.
		// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
		fadeAnimation.fillMode = CAMediaTimingFillMode.forwards
		fadeAnimation.isRemovedOnCompletion = false

		self.add(fadeAnimation, forKey: "FadeOutAnimation")
	}
	
}

extension LogoLayer: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		logoDelegate?.logoShouldBeRemoved(self)
	}

}
