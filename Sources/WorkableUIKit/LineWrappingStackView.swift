//
//  LineWrappingStackView.swift
//  WorkableUIKit
//
//  Created by Benjamin Spratling on 12/23/22.
//

import Foundation
import UIKit


///
public class LineWrappingStackView : UIView {
	
	public init(arrangedSubviews:[UIView]) {
		let sizes = arrangedSubviews
			.map({ $0.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize) })
		let maxWidth = sizes.map(\.width).reduce(0.0, max)
		let maxHeight = sizes.map(\.height).reduce(0.0, max)
		super.init(frame:CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))
		viewOwners = arrangedSubviews.map({ newViewOwner(view: $0) })
		didInit()
	}
	
	public var insets:NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0) {
		didSet {
			childNeedsLayout = true
			needsReLayoutCatchAll()
		}
	}
	
	public var spacing: CGFloat = 10.0 {
		didSet {
			childNeedsLayout = true
			needsReLayoutCatchAll()
		}
	}
	
	public var lineSpacing: CGFloat = 10.0 {
		didSet {
			childNeedsLayout = true
			needsReLayoutCatchAll()
		}
	}
	
	public var horizontalAlignment:UIStackView.Alignment = .leading {
		didSet {
			childNeedsLayout = true
			needsReLayoutCatchAll()
		}
	}
	
	public var verticalAlignment:UIStackView.Alignment = .bottom {
		didSet {
			childNeedsLayout = true
			needsReLayoutCatchAll()
		}
	}
	
	public var arrangedSubviews:[UIView] {
		return viewOwners.map(\.view)
	}
	
	public func insertArrangedSubview(_ view: UIView, at stackIndex: Int){
		childNeedsLayout = true
		if stackIndex == 0 {
			if viewOwners.count == 0 {
				addSubview(view)
			}
			else {
				insertSubview(view, belowSubview:viewOwners[stackIndex+1].view)
			}
		}
		else {
			insertSubview(view, aboveSubview:viewOwners[stackIndex-1].view)
		}
		viewOwners.insert(newViewOwner(view: view), at: stackIndex)
		needsReLayoutCatchAll()
	}
	
	
	//MARK: - implementation
	
	private func didInit() {
		viewOwners
			.map(\.view)
			.forEach { subview in
				subview.translatesAutoresizingMaskIntoConstraints = false
				subview.sizeToFit()
				addSubview(subview)
			}
		needsReLayoutCatchAll()
	}
	
	private var viewOwners:[ViewOwner] = []
	
	private func newViewOwner(view:UIView)->ViewOwner {
		let owner = ViewOwner(view: view)
		owner.onHiddenChange = { [weak self] owner in
			self?.viewIsHiddenDidChange(owner: owner)
		}
		return owner
	}
	
	//methods for inserting and removing arranged subviews
	private func viewIsHiddenDidChange(owner:ViewOwner) {
		childNeedsLayout = true
		needsReLayoutCatchAll()
	}
	
	private func needsReLayoutCatchAll() {
		setNeedsUpdateConstraints()
	}
	
	private func computeLayout(availableSize:CGSize)->LayoutDecisions {
		let availableHorizontalSpace:CGFloat = max(0.0, availableSize.width - (insets.leading + insets.leading))
		var finalLineDecisions:[LineDecisions] = []
		var currentLineTempDecisions:[(UIView, CGSize)] = []
		var remainingHorizontalSpace:CGFloat = availableHorizontalSpace
		
		func completeLine() {
			if currentLineTempDecisions.count == 0 { return }
			
			var itemDecisions:[ItemDecision] = []
			for (_, viewSize) in currentLineTempDecisions {
				itemDecisions.append(ItemDecision(size: viewSize))
			}
			finalLineDecisions.append(LineDecisions(items: itemDecisions))
			
			//reset state
			currentLineTempDecisions = []
			remainingHorizontalSpace = availableHorizontalSpace
		}
		
		for aView in arrangedSubviews {
			guard !aView.isHidden else {
				continue
			}
			//find out how big the view would be if it were as big as it could be
			let biggestSize = aView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize
															,withHorizontalFittingPriority:UILayoutPriority.fittingSizeLevel
															,verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
			//eventually call this method once we've found the size we want, and the size we'll allow
			func addViewToCurrent(size:CGSize) {
				currentLineTempDecisions.append((aView, size))
				remainingHorizontalSpace -= size.width + spacing
			}
			//if the view can fit in the remaining space, we can just take it as-is
			if biggestSize.width < remainingHorizontalSpace {
				addViewToCurrent(size:biggestSize)
				continue
			}
			//if there are other things on the line, jump to the next line
			if currentLineTempDecisions.count > 0 {
				completeLine()	//will update remainingHorizontalSpace
			}
			//we're on a line by itself
			//if the line has 0 items on it, let's see if we can get the thing to fit in the line
			if biggestSize.width > remainingHorizontalSpace {
				let smallerSize = aView.systemLayoutSizeFitting(CGSize(width: remainingHorizontalSpace
																	   ,height: UIView.layoutFittingExpandedSize.height)
																,withHorizontalFittingPriority:.defaultHigh + 1.0
																,verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
				if smallerSize.width <= remainingHorizontalSpace {
					addViewToCurrent(size:smallerSize)
					continue
				}
			}
			
			//fallback
			addViewToCurrent(size:biggestSize)
		}
		//finish off the last line if any
		completeLine()
		return layoutWithLines(finalLineDecisions)
	}
	
	private func layoutWithLines(_ lines:[LineDecisions])->LayoutDecisions {
		return LayoutDecisions(width: bounds.width, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, insets: insets, spacing: spacing, lineSpacing: lineSpacing, lines: lines)
	}
	
	private func applyLayoutDecisions(_ decisions:LayoutDecisions) {
		//remove existing constraints
		for guide in layoutGuides {
			removeLayoutGuide(guide)
		}
		removeConstraints(constraints)
		//remove width constraints
		var viewIndex:Int = 0
		var previousRowContainerGuide:UILayoutGuide?
		for (lineIndex, lineDecision) in decisions.lines.enumerated() {
			//the row container sets the top and bottom and horizontal insets
			let rowContainerGuide:UILayoutGuide = UILayoutGuide()
			addLayoutGuide(rowContainerGuide)
			rowContainerGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.leading).isActive = true
			trailingAnchor.constraint(equalTo: rowContainerGuide.trailingAnchor, constant: insets.trailing).isActive = true
			rowContainerGuide.identifier = "rowContainerGuide \(lineIndex)"
			//the alignment guide is zero-height, but tightly wraps the views horizontally
			let alignGuide:UILayoutGuide = UILayoutGuide()
			addLayoutGuide(alignGuide)
			alignGuide.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
			alignGuide.identifier = "alignGuide \(lineIndex)"
			
			if let oldContainer = previousRowContainerGuide {
				rowContainerGuide.topAnchor.constraint(equalTo: oldContainer.bottomAnchor, constant: lineSpacing).isActive = true
			}
			else {
				rowContainerGuide.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
			}
			previousRowContainerGuide = rowContainerGuide
			
			//iterate through the items and
			var previousViewInLine:UIView?
			for viewDecision in lineDecision.items {
				var aView:UIView
				repeat {
					//find the view
					aView = viewOwners[viewIndex].view
					viewIndex += 1
					//but skip over hidden views
				} while aView.isHidden
				
				//set top and bottom inequalities
				aView.topAnchor.constraint(greaterThanOrEqualTo: rowContainerGuide.topAnchor).isActive = true
				aView.bottomAnchor.constraint(lessThanOrEqualTo: rowContainerGuide.bottomAnchor).isActive = true
				
				//set the alignment equality
				if let previousView = previousViewInLine {
					aView.leadingAnchor.constraint(equalTo: previousView.trailingAnchor, constant: spacing).isActive = true
				}
				else {
					aView.leadingAnchor.constraint(equalTo: alignGuide.leadingAnchor).isActive = true
				}
				//if we just did isActive = true, it would add the constraint to the subview, but we want to keep it as one of ours
				let newWidthAnchor = aView.widthAnchor.constraint(equalToConstant: viewDecision.size.width)
				addConstraint(newWidthAnchor)
				
				aView.verticalAnchor(verticalAlignment).constraint(equalTo: alignGuide.topAnchor).isActive = true
				previousViewInLine = aView
			}
			
			if let aView = previousViewInLine {
				alignGuide.trailingAnchor.constraint(equalTo: aView.trailingAnchor).isActive = true
			}
			
			switch horizontalAlignment {
			case .fill, .center:
				rowContainerGuide.centerXAnchor.constraint(equalTo: alignGuide.centerXAnchor).isActive = true
				
			case .leading, .firstBaseline:
				alignGuide.leadingAnchor.constraint(equalTo: rowContainerGuide.leadingAnchor).isActive = true
				
			case .trailing, .lastBaseline:
				rowContainerGuide.trailingAnchor.constraint(equalTo: alignGuide.trailingAnchor).isActive = true
			}
		}
		
		if let lastGuide = previousRowContainerGuide {
			bottomAnchor.constraint(equalTo: lastGuide.bottomAnchor, constant: insets.bottom).isActive = true
		}
		super.setNeedsLayout()
	}
	
	var currentLayout:LayoutDecisions? {
		didSet {
			guard currentLayout != oldValue else { return }
			applyLayoutDecisions(currentLayout ?? layoutWithLines([]))
		}
	}
	
	private var childNeedsLayout:Bool = true
	
	
	//MARK: - UIView overrides
	
	@available(*, deprecated, message:"DO NOT CALL")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if previousTraitCollection?.layoutDirection != traitCollection.layoutDirection {
			childNeedsLayout = true
			needsReLayoutCatchAll()
		}
	}
	
	public override func willRemoveSubview(_ subview: UIView) {
		super.willRemoveSubview(subview)
		if let index = viewOwners.firstIndex(where: { $0.view === subview }) {
			viewOwners.remove(at: index)
			childNeedsLayout = true
			needsReLayoutCatchAll()
		}
	}
	
	public override func updateConstraints() {
		defer {
			super.updateConstraints()
		}
		guard childNeedsLayout else { return }
		currentLayout = computeLayout(availableSize: bounds.size)
	}
	
	public override var bounds: CGRect {
		didSet {
			childNeedsLayout = true
			guard bounds.width > 0.0 else { return }
			needsReLayoutCatchAll()
		}
	}
	
	public override var frame: CGRect {
		didSet {
			childNeedsLayout = true
			guard frame.width > 0.0 else { return }
			needsReLayoutCatchAll()
		}
	}
	
	public override func setNeedsLayout() {
		childNeedsLayout = true
		super.setNeedsLayout()
		super.setNeedsUpdateConstraints()
	}
	
	public override func setNeedsUpdateConstraints() {
		super.setNeedsUpdateConstraints()
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		childNeedsLayout = false
	}
	
}


struct ItemDecision : Equatable {
	var size:CGSize
}


struct LineDecisions : Equatable {
	var items:[ItemDecision]
}


struct LayoutDecisions : Equatable {
	//overall width of the view
	var width:CGFloat
	
	var horizontalAlignment:UIStackView.Alignment
	var verticalAlignment:UIStackView.Alignment
	var insets:NSDirectionalEdgeInsets
	var spacing: CGFloat
	var lineSpacing: CGFloat
	
	var lines:[LineDecisions]
}



fileprivate class ViewOwner {
	var view:UIView
	
	init(view:UIView) {
		self.view = view
		self.wasHidden = view.isHidden
		didInit()
	}
	
	func didInit() {
		hiddenObserver = view.observe(\.isHidden, changeHandler: { [weak self] _, change in
			self?.didHideDidChange()
		})
	}
	
	func didHideDidChange() {
		guard wasHidden != view.isHidden else { return }
		onHiddenChange?(self)
		wasHidden = view.isHidden
	}
	
	var wasHidden:Bool
	
	var onHiddenChange:((ViewOwner)->())?
	
	private var hiddenObserver:Any?
	
}


extension UIView {
	
	fileprivate func verticalAnchor(_ alignment:UIStackView.Alignment)->NSLayoutYAxisAnchor {
		switch alignment {
		case .fill:
			//not supported?
			fatalError()
			
		case .top, .leading:
			return topAnchor
			
		case .firstBaseline:
			return firstBaselineAnchor
			
		case .center:
			return centerYAnchor
			
		case .bottom, .trailing:
			return bottomAnchor
			
		case .lastBaseline:
			return lastBaselineAnchor
		}
	}
	
}
