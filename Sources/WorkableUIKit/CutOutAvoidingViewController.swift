//
//  CutOutAvoidingViewController.swift
//  
//
//  Created by Ben Spratling on 3/1/23.
//

import Foundation
import UIKit



///A view controller which shades the screen to display another view controller, and shades the rest
///but uses a cutout view to avoid shading over a particular avoided view
open class CutOutAvoidingViewController : UIViewController {
	
	public init(
		///The VC for the content which will be drawn
		contentViewController:UIViewController

		///The subview from a presenting VC which will not be covered by the contentViewController
		,avoiding view:UIView

		///The general shape of the of the
		,shape:CutOutShadeView.CutOutShape = .rect
	) {
		self.contentViewController = contentViewController
		self.avoidedView = view
		self.shape = shape
		super.init(nibName: nil, bundle: nil)
		modalPresentationStyle = .overFullScreen
		modalTransitionStyle = .crossDissolve
	}
	
	///the view controller's whose contents are shown in a small panel over the shade
	public let contentViewController:UIViewController
	
	///a subview in the presenting view controller's view which we want to avoid covering with the shade
	public let avoidedView:UIView
	
	///if true, tap gestures in the shade will cause a dismiss
	///if false, tap gestures in the shade will be ignored
	open var tappingInShadeDismisses:Bool = false {
		didSet {
			if tappingInShadeDismisses {
				shadeView.isUserInteractionEnabled = true
				if shadeTapRecognizer.view != shadeView {
					shadeView.addGestureRecognizer(shadeTapRecognizer)
				}
			}
			else {
				shadeView.isUserInteractionEnabled = false
				shadeTapRecognizer.view?.removeGestureRecognizer(shadeTapRecognizer)
			}
		}
	}
	
	open var shadeColor:UIColor = .black {
		didSet {
			shadeView.shadeColor = shadeColor
		}
	}
	
	open var shape:CutOutShadeView.CutOutShape {
		didSet {
			shadeView.shape = shape
		}
	}
	
	///The distance away from the cut out (and the outset) and screen edges at which the content modal is presented
	open var contentMargin:CGFloat = 20.0 {
		didSet {
			establishConstraintsForContentViewController()
		}
	}
	
	//requires overriding hit test in the cut out shape view to return the avoided view
//	var allowPassThrowToAvoidedView:Bool = false
	
	private lazy var shadeTapRecognizer:UITapGestureRecognizer = {
		return UITapGestureRecognizer(target: self, action: #selector(Self.userDidTapDismissViaShade))
	}()
	
	@objc private func userDidTapDismissViaShade() {
		dismiss(animated: true)
	}
	
	private var cutOutRect:CGRect = .zero {
		didSet {
			shadeView.cutOutRect = cutOutRect
		}
	}
	
	private var oldLayoutSpecs:(bounds:CGRect, cutOutRect:CGRect)?
	
	private lazy var shadeView:CutOutShadeView = {
		let view = CutOutShadeView(cutOutRect: cutOutRect)
		return view.forAutoLayout()
	}()
	
	private func getNewCutOutFrame()->CGRect {
		return view.convert(avoidedView.bounds, from: avoidedView)
	}
	
	private func updateCutOutLocation() {
		establishConstraintsForContentViewController()
	}
	
	private func establishConstraintsForContentViewController() {
		//inside safe areas, compute the area for the most space, above, below, to the leading or to the trailing
		let cutOutRectOuterBounds = cutOutRect.inset(by: .init(top: -shadeView.cutOutOutset, left: -shadeView.cutOutOutset, bottom: -shadeView.cutOutOutset, right: -shadeView.cutOutOutset))
		
		view.removeConstraints(view.constraintsInvolving(contentViewController.view))
		//should we calculate a maximum area portion of the screen, instead of a max linear dimension?
		//then how do we pick a quadrant?
		//should we use a preferred edge, like popovers?
		
		//which side do we have more space on?
		
		let left = cutOutRectOuterBounds.minX - view.safeAreaInsets.left
		let top = cutOutRectOuterBounds.minY - view.safeAreaInsets.top
		let bottom = view.frame.height - view.safeAreaInsets.bottom - cutOutRectOuterBounds.maxY
		let right = view.frame.width  - view.safeAreaInsets.right - cutOutRectOuterBounds.maxX
		
		//which ever one of these has the most, we'll do?
		
		let maxSide = max(left, top, right, bottom)
		if maxSide == top {
			//on the side we're on, we want it pinned to the cut out
			contentViewController.view.bottomAnchor == view.topAnchor + (cutOutRectOuterBounds.minY - contentMargin)
			//the corresponding screen edge is then an inequality
			contentViewController.view.topAnchor >= view.topAnchor + (view.safeAreaInsets.top + contentMargin)
			//then we need to know if thre is more space to the left or right
			//and we'll try to align one edge of the
			let wideSide = max(left, right)
			
			//TODO: if the space is closer to equal, try to set the center of the modal view aligned with the center of the button
			if wideSide == left {
				//there's more space on the left
				//try to fix the right edge of the modal to the right edge of the cut out area, but at a low priority, and give the higher priority to the
				contentViewController.view.rightAnchor == view.leftAnchor + (cutOutRectOuterBounds.maxX + shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			else {
				//right
				//some of this math might make more sense if I created a layout guide for the cut out rect?
				contentViewController.view.leftAnchor == view.leftAnchor + (cutOutRectOuterBounds.minX - shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			contentViewController.view.rightAnchor <= view.rightAnchor - contentMargin
			contentViewController.view.leftAnchor >= view.leftAnchor + contentMargin
		}
		else if maxSide == left {
			//on the side we're on, we want it pinned
			contentViewController.view.rightAnchor == view.leftAnchor + (cutOutRectOuterBounds.minX - contentMargin)
			//the corresponding screen edge is then an inequality
			contentViewController.view.leftAnchor >= view.leftAnchor + (view.safeAreaInsets.left + contentMargin)
			let wideSide = max(top, bottom)
			//TODO: if the space is closer to equal, try to set the center of the modal view aligned with the center of the button
			if wideSide == top {
				contentViewController.view.bottomAnchor == view.topAnchor + (cutOutRectOuterBounds.maxY + shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			else {
				contentViewController.view.topAnchor == view.topAnchor + (cutOutRectOuterBounds.minY - shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			contentViewController.view.bottomAnchor <= view.bottomAnchor - contentMargin
			contentViewController.view.topAnchor >= view.topAnchor + contentMargin
		}
		else if maxSide == right {
			//on the side we're on, we want it pinned
			contentViewController.view.leftAnchor == view.leftAnchor + (cutOutRectOuterBounds.maxX - contentMargin)
			//the corresponding screen edge is then an inequality
			contentViewController.view.rightAnchor >= view.rightAnchor - (view.safeAreaInsets.right + contentMargin)
			let wideSide = max(top, bottom)
			//TODO: if the space is closer to equal, try to set the center of the modal view aligned with the center of the button
			if wideSide == top {
				contentViewController.view.bottomAnchor == view.topAnchor + (cutOutRectOuterBounds.maxY + shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			else {
				contentViewController.view.topAnchor == view.topAnchor + (cutOutRectOuterBounds.minY - shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			contentViewController.view.bottomAnchor <= view.bottomAnchor - contentMargin
			contentViewController.view.topAnchor >= view.topAnchor + contentMargin
		}
		else if maxSide == bottom {
			//on the side we're on, we want it pinned to the cut out
			contentViewController.view.topAnchor == view.topAnchor + (cutOutRectOuterBounds.maxX + contentMargin)
			//the corresponding screen edge is then an inequality
			contentViewController.view.bottomAnchor >= view.bottomAnchor - (view.safeAreaInsets.top + contentMargin)
			
			let wideSide = max(left, right)
			//TODO: if the space is closer to equal, try to set the center of the modal view aligned with the center of the button
			if wideSide == left {
				//there's more space on the left
				//try to fix the right edge of the modal to the right edge of the cut out area, but at a low priority, and give the higher priority to the
				contentViewController.view.rightAnchor == view.leftAnchor + (cutOutRectOuterBounds.maxX + shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			else {
				//right
				//some of this math might make more sense if I created a layout guide for the cut out rect?
				contentViewController.view.leftAnchor == view.leftAnchor + (cutOutRectOuterBounds.minX - shadeView.cutOutOutset) | UILayoutPriority.defaultHigh
			}
			contentViewController.view.rightAnchor <= view.rightAnchor - contentMargin
			contentViewController.view.leftAnchor >= view.leftAnchor + contentMargin
		}
	}
	
	
	//MARK: - UIViewController overrides
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .clear
		view.addSubview(shadeView)
		|-shadeView-|
		∫-shadeView-∫
		
		addChild(contentViewController)
		view.addSubview(contentViewController.view.forAutoLayout())
		contentViewController.didMove(toParent: self)
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		establishConstraintsForContentViewController()
	}
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		cutOutRect = getNewCutOutFrame()
		if let oldLayoutSpecs
			,oldLayoutSpecs != (view.bounds, cutOutRect) {
			updateCutOutLocation()
		}
		else if oldLayoutSpecs == nil {
			updateCutOutLocation()
		}
		oldLayoutSpecs = (view.bounds, cutOutRect)
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
