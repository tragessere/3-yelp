//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation

class BusinessesViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var businesses: [Business]!
  var locationManager: CLLocationManager!
  var location: CLLocation?
  
  var refreshControl: UIRefreshControl!
  
  var searchBar: UISearchBar!
  var searchBusinesses: [Business]?
  var isSearching: Bool = false
  var searchFilter: String?
  
  var loadingMoreView:InfiniteScrollView?
  var isLoading: Bool = false
  var isAtEnd: Bool = true
  
  var categories: [String]?
  var offset: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    
    searchBar = UISearchBar()
    searchBar.sizeToFit()
    navigationItem.titleView = searchBar
    searchBar.delegate = self
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
    
    let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollView.defaultHeight)
    loadingMoreView = InfiniteScrollView(frame: frame)
    loadingMoreView!.hidden = true
    tableView.addSubview(loadingMoreView!)
    
    var insets = tableView.contentInset
    insets.bottom += InfiniteScrollView.defaultHeight
    tableView.contentInset = insets
    
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = 200
    locationManager.requestWhenInUseAuthorization()
    
//    loadData()
    
    /* Example of Yelp search with more search options specified
    Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
    self.businesses/Users/evan/Documents/CS490/2-yelp/Yelp/MapViewController.swift = businesses
    
    for business in businesses {
    print(business.name!)
    print(business.address!)
    }
    }
    */
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if let identifier = segue.identifier {
      if identifier == "FilterSegue" {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
      } else if identifier == "MapSegue" {
        let navigationController = segue.destinationViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        mapViewController.businesses = self.businesses
      }
	}
  }
  

  func loadData() {
    Business.searchWithTerm(searchFilter, sort: nil, location: location, categories: categories, deals: nil, offset: offset) {
    (businesses: [Business]!, error: NSError!) -> Void in
      
      if error != nil {
        return
      }
      
      if self.offset == 0 {
        self.businesses = businesses
      } else {
        self.businesses = self.businesses! + businesses!
      }
      
      if businesses.count == 0 {
        self.isAtEnd = true
      } else {
        self.isAtEnd = false
      }
//      print("loaded \(businesses.count) items")
      
//      self.searchBar(self.searchBar, textDidChange: self.searchBar.text!)
      self.tableView.reloadData()
      
      self.refreshControl.endRefreshing()
      self.isLoading = false
      self.loadingMoreView?.stopAnimating()
    }
  }
  
  //Refreshing the page from the top will reset the loaded data and start from an offset of zero again
  func refresh(sender: AnyObject) {
    resetAndLoad()
  }
  
  func resetAndLoad() {
    offset = 0
    loadData()
  }
  
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, CLLocationManagerDelegate {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isSearching {
      if searchBusinesses != nil {
        return searchBusinesses!.count
      } else {
        return 0
      }
    } else {
      if businesses != nil {
        return businesses.count
      } else {
        return 0
      }
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
    
    if isSearching {
      cell.business = searchBusinesses![indexPath.row]
    } else {
      cell.business = businesses[indexPath.row]
    }
    
    return cell
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if !isLoading {
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      if scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging && !isAtEnd {
        isLoading = true
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
        
        offset = businesses.count
        
        loadData()
      }
    }
  }
  
//  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//    if searchText.isEmpty {
//      isSearching = false
//      searchBusinesses = nil
//    } else {
//      isSearching = true
//      searchBusinesses = businesses.filter({(data: Business) -> Bool in
//        return data.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
//      })
//      
//    }
//    tableView.reloadData()
//  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchFilter = nil
    
    resetAndLoad()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    if searchBar.text != nil && !searchBar.text!.isEmpty {
      searchFilter = searchBar.text!
    } else {
      searchFilter = nil
    }
    
    self.view.endEditing(true)
    resetAndLoad()
  }

  //Sets category filters and refreshes the tableview
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String]?) {
    categories = filters
    resetAndLoad()
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if locations.first != nil {
      location = locations.first
      resetAndLoad()
    }
    
//    if let location = locations.first {
//      let span = MKCoordinateSpanMake(0.1, 0.1)
//      let region = MKCoordinateRegionMake(location.coordinate, span)
//      mapView.setRegion(region, animated: false)
//      addAnnotationAtCoordinate(location.coordinate)
//    }
  }
}
