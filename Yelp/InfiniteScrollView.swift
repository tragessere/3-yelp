//
//  InfiniteScrollView.swift
//  Yelp
//
//  Created by Evan on 2/3/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class InfiniteScrollView: UIView {

  var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
  static let defaultHeight: CGFloat = 60.0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupActivityIndicator()
  }
  
  override init(frame aRect: CGRect) {
    super.init(frame: aRect)
    setupActivityIndicator()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    activityIndicatorView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
  }
  
  func setupActivityIndicator() {
    activityIndicatorView.activityIndicatorViewStyle = .Gray
    activityIndicatorView.hidesWhenStopped = true
    self.addSubview(activityIndicatorView)
  }
  
  func startAnimating() {
    self.hidden = false
    self.activityIndicatorView.startAnimating()
  }
  
  func stopAnimating() {
    self.hidden = true
    self.activityIndicatorView.stopAnimating()
  }
}
