//
//  LoadingView.swift
//  Weather Test Task
//
//  Created by Alex173 on 28.04.2022.
//

import UIKit
import NVActivityIndicatorView

class LoadingView: UIView {
    
    private let loadingIndicator = NVActivityIndicatorView(
        frame: CGRect(
            x: 0,
            y: 0,
            width: 80,
            height: 80),
        type: .ballRotateChase,
        color: UIColor.white,
        padding: 1.0)
    
    func createLoadingView<T: UIView>(parentView: T) {
        setupLoadingIndicator()
        loadingIndicator.startAnimating()
        self.backgroundColor = UIColor.darkBlue
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: parentView,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1,
            constant: 0)
        let bottomConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.bottom,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: parentView,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1,
            constant: 0)
        let leadingConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.leading,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: parentView,
            attribute: NSLayoutConstraint.Attribute.leading,
            multiplier: 1,
            constant: 0)
        let trailingConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.trailing,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: parentView,
            attribute: NSLayoutConstraint.Attribute.trailing,
            multiplier: 1,
            constant: 0)
        NSLayoutConstraint.activate(
            [topConstraint,
             bottomConstraint,
             leadingConstraint,
             trailingConstraint])
    }
    
    func showLoadingView() {
        loadingIndicator.startAnimating()
        self.isHidden = false
    }
    
    func hideLoadingView() {
        loadingIndicator.stopAnimating()
        self.isHidden = true
    }
    
    private func setupLoadingIndicator() {
        self.addSubview(loadingIndicator)
        loadingIndicator.layer.opacity = 0.8
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = NSLayoutConstraint(
            item: loadingIndicator,
            attribute: NSLayoutConstraint.Attribute.centerX,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.centerX,
            multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(
            item: loadingIndicator,
            attribute: NSLayoutConstraint.Attribute.centerY,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.centerY,
            multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        
    }
}
