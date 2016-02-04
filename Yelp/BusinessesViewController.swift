//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var businesses: [Business]!
  
  var refreshControl: UIRefreshControl!
  
  var searchBar: UISearchBar!
  var searchBusinesses: [Business]?
  var isSearching: Bool = false
  
  var loadingMoreView:InfiniteScrollView?
  var isLoading: Bool = false
  var isAtEnd: Bool = false
  
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
    
    loadData()
    
    /* Example of Yelp search with more search options specified
    Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
    self.businesses = businesses
    
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
    let navigationController = segue.destinationViewController as! UINavigationController
    let filtersViewController = navigationController.topViewController as! FiltersViewController
    
    filtersViewController.delegate = self
  }
  

  func loadData() {
    Business.searchWithTerm("restaurants", sort: nil, categories: categories, deals: nil, offset: offset) {
    (businesses: [Business]!, error: NSError!) -> Void in
      
      if self.offset == 0 {
        self.businesses = businesses
      } else {
        self.businesses = self.businesses! + businesses!
      }
      
      if businesses.count == 0 {
        self.isAtEnd = true
      }
//      print("loaded \(businesses.count) items")
      
      self.searchBar(self.searchBar, textDidChange: self.searchBar.text!)
      
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
    isAtEnd = false
    loadData()
  }
  
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

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
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      isSearching = false
      searchBusinesses = nil
    } else {
      isSearching = true
      searchBusinesses = businesses.filter({(data: Business) -> Bool in
        return data.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
      })
      
    }
    tableView.reloadData()
  }

  //Sets category filters and refreshes the tableview
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String]?) {
    categories = filters
    resetAndLoad()
  }
}
