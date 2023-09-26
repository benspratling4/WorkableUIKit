//
//  PageViewController.swift
//  WorkableUIKit
//
//  Created by Ben Spratling on 9/15/23.
//

import Foundation
import UIKit


public protocol PageControllerDatasource : AnyObject {
	
	func pageController(_ pageController:PageController, viewControllerAfter:UIViewController?)->UIViewController?
	
	func pageController(_ pageController:PageController, viewControllerBefore:UIViewController?)->UIViewController?
	
}


public protocol PageControllerDelegate : AnyObject {
	func pageController(_ pageController:PageController, didTransitionTo viewController:UIViewController?)
}



//WIP: drop-in replacement for UIPageViewController
//TODO: test what happens when animations are cancelled from view will / did disappear
public class PageController : UIViewController, UIScrollViewDelegate {
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
	}
	
	public weak var dataSource:PageControllerDatasource?
	
	public weak var delegate:PageControllerDelegate?
	
	public var mainViewController:UIViewController?
	
	public func setEmbeddedViewController(_ vc:UIViewController
								   , direction: UIPageViewController.NavigationDirection
								   , animated:Bool
								   , completion:((Bool)->())?) {
		if !animated {
			setUpNewControllers(vc: vc)
			completion?(true)
			return
		}
		cachedAnimationCompletions = (direction, completion)
		//if we're animating forward replace the next view controller
		switch direction {
		case .reverse:
			let didHavePrevious = previousViewController != nil
			removePreviousViewController()
			setUpPreviousController(vc)
			setPreviousFrame()
			if !didHavePrevious {
				setScrollViewContentSize()
				setMainFrame()
				setNextFrame()
				if let mainViewController {
					scrollView.setContentOffset(mainViewController.view.frame.origin, animated: false)
				}
			}
			scrollView.setContentOffset(vc.view.frame.origin, animated: true)
			//after scroll view animation completes, check out accountForManualScrollAnimationCompletion()
		
		case .forward:
			fallthrough
		default:
			removeNextViewController()
			setUpNextController(vc)
			setScrollViewContentSize()
			setNextFrame()
			//we're not messing with previous here, so no need to set main and previous frames and scroll without animation
			scrollView.setContentOffset(vc.view.frame.origin, animated: true)
			//after scroll view animation completes, check out accountForManualScrollAnimationCompletion()
		}
	}
	
	public lazy var scrollView:UIScrollView = {
		let scrollView = UIScrollView(frame: .zero).forAutoLayout()
		scrollView.isPagingEnabled = true
		scrollView.delegate = self
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	
	var cachedAnimationCompletions:(direction: UIPageViewController.NavigationDirection, completion:((Bool)->())?)?
	
	
	var previousViewController:UIViewController?
	
	var nextViewController:UIViewController?
	
	func setUpNewControllers( vc:UIViewController?) {
		
		//dismiss all previous controllers
		removePreviousViewController()
		removeNextViewController()
		removeMainViewController()
		
		//install new main controller
		mainViewController = vc
		
		if let mainViewController {
			addChild(mainViewController)
			mainViewController.view.translatesAutoresizingMaskIntoConstraints = true
			scrollView.addSubview(mainViewController.view)
			mainViewController.didMove(toParent: self)
		}
		
		//these methods side effect set nextViewController & previousViewController
		addOnPreviousController()
		addOnNextControllerIfPossible()
		
		if view.superview != nil {
			setScrollViewContentSize()
			setPreviousFrame()
			setMainFrame()
			setNextFrame()
		}
		previousViewController?.didMove(toParent: self)
		nextViewController?.didMove(toParent: self)
		
		let scrollOffset:CGFloat = mainViewController?.view.frame.origin.x ?? .zero
		scrollView.setContentOffset(CGPoint(x:scrollOffset, y: 0), animated: false)
	}
	
	func addOnNextControllerIfPossible() {
		guard let mainViewController else { return }
		guard let newController = dataSource?.pageController(self, viewControllerAfter: mainViewController) else { return }
		setUpNextController(newController)
		//we'll set frames after all controllers and views have been added
	}
	
	func setUpNextController(_ vc:UIViewController) {
		nextViewController = vc
		addChild(vc)
		vc.view.translatesAutoresizingMaskIntoConstraints = true
		vc.view.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
		scrollView.addSubview(vc.view)
	}
	
	func addOnPreviousController() {
		guard let mainViewController else { return }
		guard let newController = dataSource?.pageController(self, viewControllerBefore: mainViewController) else { return }
		setUpPreviousController(newController)
		//we'll set frames after all controllers and views have been added
	}
	
	func setUpPreviousController(_ vc:UIViewController) {
		previousViewController = vc
		addChild(vc)
		vc.view.translatesAutoresizingMaskIntoConstraints = true
		vc.view.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
		scrollView.addSubview(vc.view)
	}
	
	func removeMainViewController() {
		mainViewController?.willMove(toParent: nil)
		mainViewController?.view.removeFromSuperview()
		mainViewController?.removeFromParent()
		mainViewController = nil
	}
	
	func removePreviousViewController() {
		previousViewController?.willMove(toParent: nil)
		previousViewController?.view.removeFromSuperview()
		previousViewController?.removeFromParent()
		previousViewController = nil
	}
	
	func removeNextViewController() {
		nextViewController?.willMove(toParent: nil)
		nextViewController?.view.removeFromSuperview()
		nextViewController?.removeFromParent()
		nextViewController = nil
	}
	
	func moveControllersForward() {
		//get rid of previous view controller
		removePreviousViewController()
		
		//book keep main as previous
		previousViewController = mainViewController
		
		//book keep next as main
		mainViewController = nextViewController
		nextViewController = nil
		
		//add next view controller
		addOnNextControllerIfPossible()
		
		//reset frames
		setScrollViewContentSize()
		setPreviousFrame()
		setMainFrame()
		setNextFrame()
		nextViewController?.didMove(toParent: self)
		let offset = mainViewController?.view.frame.origin.x ?? .zero
		scrollView.contentOffset = CGPoint(x: offset, y: .zero)
	}
	
	func moveControllersBackward() {
		//get rid of next view controller
		removeNextViewController()
		
		//book keep main as previous
		nextViewController = mainViewController
		
		//book keep next as main
		mainViewController = previousViewController
		previousViewController = nil
		
		//add previous view controller
		addOnPreviousController()
		
		
		//reset frames
		setScrollViewContentSize()
		setPreviousFrame()
		setMainFrame()
		setNextFrame()
		previousViewController?.didMove(toParent: self)
		let offset = mainViewController?.view.frame.origin.x ?? .zero
		scrollView.contentOffset = CGPoint(x: offset, y: .zero)
	}
	
	func setScrollViewContentSize() {
		let viewControllerCount:Int = [
			previousViewController,
			mainViewController,
			nextViewController,
		]
			.compactMap({ $0 })
			.count
		let width = view.bounds.width * CGFloat(viewControllerCount)
		scrollView.contentSize = CGSize(width: width, height: view.bounds.height)
	}
	
	func setPreviousFrame() {
		guard let previousViewController else { return }
		//if we have one it's always first
		previousViewController.view.frame = CGRect(origin: .zero
												   , size: view.bounds.size)
		previousViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleRightMargin]
	}
	
	func setMainFrame() {
		guard let mainViewController else { return }
		let xOffset:CGFloat = previousViewController == nil ? .zero : view.bounds.width
		mainViewController.view.frame = CGRect(origin: CGPoint(x: xOffset, y: .zero)
											   , size: view.bounds.size)
		var springs:UIView.AutoresizingMask = [.flexibleHeight, .flexibleWidth]
		if previousViewController != nil {
			springs.insert(.flexibleLeftMargin)
		}
		if nextViewController != nil {
			springs.insert(.flexibleRightMargin)
		}
		mainViewController.view.autoresizingMask = springs
	}
	
	func setNextFrame() {
		guard let nextViewController else { return }
		//we always have a main,
		let xOffset:CGFloat = view.bounds.width * (previousViewController == nil ? 1.0 : 2.0)
		nextViewController.view.frame = CGRect(origin: CGPoint(x: xOffset, y: .zero)
											   , size: view.bounds.size)
		nextViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin]
	}
	
	func accountForScrollViewChange() {
		//if the offset is for the previous view,
		if let previousViewController {
			if abs(scrollView.contentOffset.x - previousViewController.view.frame.origin.x) < 4.0 {
				moveControllersBackward()
				delegate?.pageController(self, didTransitionTo: mainViewController)
				return
			}
		}
		
		//if the offset is for the next view
		if let nextViewController
			,abs(scrollView.contentOffset.x - nextViewController.view.frame.origin.x) < 4.0  {
			moveControllersForward()
			delegate?.pageController(self, didTransitionTo: mainViewController)
			return
		}
	}
	
	//called after scroll view .setContentOffset(:, animated:true)
	func accountForManualScrollAnimationCompletion() {
		guard let cachedAnimationCompletions else { return }
		defer {
			//dance so you call setEmbeddedViewController in the completion if needed
			let ani = self.cachedAnimationCompletions
			self.cachedAnimationCompletions = nil
			ani?.completion?(true)
		}
		switch cachedAnimationCompletions.direction {
		case .reverse:
			removeNextViewController()
			removeMainViewController()
			mainViewController = previousViewController
			previousViewController = nil
			
		case .forward:
			fallthrough
		default:
			removePreviousViewController()
			removeMainViewController()
			mainViewController = nextViewController
			nextViewController = nil
		}
		
		addOnPreviousController()
		addOnNextControllerIfPossible()
		setScrollViewContentSize()
		setPreviousFrame()
		setMainFrame()
		setNextFrame()
		previousViewController?.didMove(toParent: self)
		nextViewController?.didMove(toParent: self)
		let offset = mainViewController?.view.frame.origin.x ?? .zero
		scrollView.contentOffset = CGPoint(x: offset, y: .zero)
	}
	
	
	//MARK: - UIViewController overrides
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(scrollView)
		|-scrollView-|
		∫-scrollView-∫
		//should we do anything here?
	}
	
	@available(*, deprecated, message:"DO NOT CALL")
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		setScrollViewContentSize()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setScrollViewContentSize()
		setPreviousFrame()
		setMainFrame()
		setNextFrame()
		guard let mainViewController else { return }
		scrollView.setContentOffset(mainViewController.view.frame.origin, animated: false)
	}
	
	
	//MARK: - UIScrollViewDelegate
	
	// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		accountForManualScrollAnimationCompletion()
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			//this is the end
			accountForScrollViewChange()
		}
	}
	
	// called when scroll view grinds to a halt
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		accountForScrollViewChange()
	}
	
}
