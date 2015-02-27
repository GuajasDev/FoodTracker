//
//  ViewController.swift
//  FoodTracker
//
//  Created by Diego Guajardo on 22/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    
    // Arrays
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    var apiSearchForFoods:[(name: String, idValue: String)] = []
    var favouritedUSDAItems:[USDAItem] = []
    var filteredFavouritedUSDAItems:[USDAItem] = []
    
    // Dictionaries
    var jsonResponse:NSDictionary!
    
    // Controllers
    var searchController:UISearchController!
    var dataController = DataController()
    
    // MARK:  Constants
    
    let kAppId = "6bf42fc3"
    let kAppKey = "5dca642720ae8737797223c4ea6b4df7"
    
    // MARK: - BODY
    
    // MARK: Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // searchResultsController means which controller willl be in charge of displaying the results. Setting it to nil means that the same tableView that exists in the ViewController will be in charge of displaying the results
        self.searchController = UISearchController(searchResultsController: nil)
        
        // Instead of delegate like we have been using in the past, in here we have to setup the results updater to self
        self.searchController.searchResultsUpdater = self
        
        // If set to true, it dims the background when searching for something
        self.searchController.dimsBackgroundDuringPresentation = false
        
        // This hides the navigation bar if it is set to true when the searchBar is pressed, ie the search bar moves up to where the nav bar was. When it is set to false the search bar stays in place
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
            self.searchController.searchBar.frame.origin.y,
            self.searchController.searchBar.frame.size.width,
            44.0)
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        // Set the scope button titles
        self.searchController.searchBar.scopeButtonTitles = self.scopeButtonTitles
        
        // Set the delegate
        self.searchController.searchBar.delegate = self
        
        // Ensures that the searchController is presented in the current ViewController
        self.definesPresentationContext = true
        
        self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicken breast", "chilli with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailVCSegue" {
            if sender != nil {
                // We passed in a USDAItem, which is comming from the 'Saved' USDAItems
                var detailVC = segue.destinationViewController as DetailViewController
                detailVC.usdaItem = sender as? USDAItem
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        var foodName:String
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            // We are in the 'Recommended' tab
            
            if self.searchController.active {
                // We are not searching, so return the filtered suggested search foods
                foodName = self.filteredSuggestedSearchFoods[indexPath.row]
            } else {
                // We are not searching, so return all the suggested search foods
                foodName = self.suggestedSearchFoods[indexPath.row]
            }
        } else if selectedScopeButtonIndex == 1 {
            // We are in the 'Search Results' tab
            
            // Get the name back from the tuple
            foodName = self.apiSearchForFoods[indexPath.row].name
        } else {
            // We are in the 'Saved' tab
            
            if self.searchController.active {
                // We are searching, so return the names of the filtered favourited USDA items
                foodName = self.filteredFavouritedUSDAItems[indexPath.row].name
            } else {
                // We are not searching, so return all the names of the favourited USDA items
                foodName = self.favouritedUSDAItems[indexPath.row].name
            }
        }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            // We are in the 'Recommended' tab
            
            if self.searchController.active {
                // We are not searching, so return the count of filtered suggested search foods
                return self.filteredSuggestedSearchFoods.count
            } else {
                // We are not searching, so return the count of all the suggested search foods
                return self.suggestedSearchFoods.count
            }
        } else if selectedScopeButtonIndex == 1 {
            // We are in the 'Search Results' tab
            
            return self.apiSearchForFoods.count
        } else {
            // We are in the 'Saved' tab
            
            if self.searchController.active {
                // We are searching, so return the count of the filtered favourited USDA items
                return self.filteredFavouritedUSDAItems.count
            } else {
                // We are not searching, so return the count of all the favourited USDA items
                return self.favouritedUSDAItems.count
            }
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Access the selectedScopeButtonIndex
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            // We are in the 'Recommended' tab
            
            var searchFoodName: String
            
            if self.searchController.active {
                searchFoodName = self.filteredSuggestedSearchFoods[indexPath.row]
            } else {
                searchFoodName = self.suggestedSearchFoods[indexPath.row]
            }
            
            // Change the selected scope button to 'Search Results'
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            
            // Make the POST request using the selected food name
            makeRequest(searchFoodName)
            
        } else if selectedScopeButtonIndex == 1 {
            // We are in the 'Search Results' tab
            
            // Go to the detailVC and dont pass anything, since the information hasn't been loaded yet
            self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
            
            // Get the idValue back from the tuple
            let idValue = apiSearchForFoods[indexPath.row].idValue
            
            // Save USDAItem to Core Data if it has not been saved yet (that functionality is defined in the DataController 'saveUSDAItemForId' function
            self.dataController.saveUSDAItemForId(idValue, json: self.jsonResponse)
            
            
        } else if selectedScopeButtonIndex == 2 {
            // We are in the 'Saved' tab
            
            if self.searchController.active {
                // We are searching
                let usdaItem = self.filteredFavouritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            } else {
                // We are not searching
                let usdaItem = self.favouritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            }
            
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Gets called each time there is a change in what you are typing in the search bar
        
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
    }
    
    // MARK:  UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // When the search button is clicked, go to the second scope button (hence selectedScopeButtonIndex = 1), which displays the Search Results
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        
        // Make a request with the text from the search bar
        makeRequest(searchBar.text)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // The selectedScopeButtonIndex changed
        
        // Every time the 'Saved' tab, we request the favourited (or saved) USDA items
        if selectedScope == 2 {
            requestFavouritedUSDAItems()
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: Helper Functions
    
    func filterContentForSearch(searchText: String, scope: Int) {
        
        if scope == 0 {
            // We are in the 'Recomended' tab
            
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food : String) -> Bool in
                // This closure iterates through the sugestedSearchFoods, calls each element 'food' and compares them to the 'searchText' string that was passed to the function. Then, if foodMatch is NOT nil (ie the searchText contains values of the food element) return true and add the element into the filteredSuggestedSearchFoods array, otherwise return false and don't add it
                var foodMatch = food.rangeOfString(searchText)
                return foodMatch != nil
            })
        } else if scope == 2 {
            // We are in the 'Saved' tab
            
            self.filteredFavouritedUSDAItems = self.favouritedUSDAItems.filter({ (item: USDAItem) -> Bool in
                // This closure iterates through the favouritedUSDAItems, calls each element 'item' and compares the name of that 'item' to the 'searchText' string that was passed to the function. Then, if stringMatch is NOT nil (ie the searchText contains values of the item element) return true and add the element into the filteredFavouritedUSDAItems array, otherwise return false and don't add it
                var stringMatch = item.name.rangeOfString(searchText)
                return stringMatch != nil
            })
        }
    }
    
    func makeRequest(searchString: String) {
        
        /*
        ========== How to Make a HTTP GET Request ==========
        
        // Setup a URL and add variables to it. These variables are the parameters that determine what information will be obtained from the GET request
        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
        
        // Setup an instance of the NSURLSession. This sets up a way that we can access our API. NSURLSession is setup by Apple and when it completes we get access to 'NSData!', 'NSURLResponse!', and 'NSError!', which we named 'data', 'response', and 'error', which we can then use to do something
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
        
        var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
        println(stringData)
        println(response)
        })
        
        // Executes the task (access the API)
        task.resume()
        */
        
        // ========== How to Make a HTTP POST Request ==========
        
        // Set it up as a Mutable request because later on we will be changing the URL (ie adding more search parameters)
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        
        // Create a session, it will be used to make the POST request
        let session = NSURLSession.sharedSession()
        
        // Specify the type of request
        request.HTTPMethod = "POST"
        
        // Define the params dictionary (look at documentation from the API for this)
        var params = [
            "appId" : kAppId,
            "appKey" : kAppKey,
            "fields" : [
                "item_name",
                "brand_name",
                "keywords",
                "usda_fields"
            ],
            "limit" : "50",
            "query" : searchString,
            "filters" : [
                "exists" : [
                    "usda_fields" : true
                ]
            ]
        ]
        
        // Setup an error in case there is an error during the request
        var error: NSError?
        
        // Converts the params into NSData so that it can be packaged with the request as part of the HTTPBody that will be sent
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        
        // Telling our request that we want to access json for both Content-Type and Accept
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Now we need to create our NSURLSessionDataTask. This will allow us to create our HTTP request using a URL and call a completionHandler when request this is completed. So we do it like this...
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            // Will evaluate AFTER the request is successful (even if it gets an error)
            
            // Convert the data into a string. It is not necessary but it is good to compare the stringData with the jsonDictionary to see why jsonDictionary is so much better (or at least easier to read)
            /* var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(stringData) */
            
            // Create an error
            var conversionError: NSError?
            
            // In 'options' we have '.MutableLeaves', this is syntax (or shortcut) for 'NSJSONReadingOptions.MutableLeaves', ie it is correct written both ways. Since the only type we can have there is 'NSJSONReadingOptions' we can shorten it by not writing it and it will be inferred. Also, we write 'as?' because jsonDictionary will be an Optional NSDictionary and when we are specifying 'as' something optional the correct syntax is 'as?' something
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary)
            
            // Error handling and saving the json results
            if conversionError != nil {
                // Check we can convert it to JSON (maybe it was passed back as XML, which would throw an error)
                println(conversionError!.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in parsing \(errorString)")
            } else {
                if jsonDictionary != nil {
                    // We're good
                    self.jsonResponse = jsonDictionary!
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
                    
                    // Make sure that reloadData is prioritised to the MAIN THREAD in order to avoid delays. If it is not clear, get 'self.reloadData()' out of the block and run it just after 'self.apiSearcForFoods = ...'
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                } else {
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error, Could not Parse JSON \(errorString)")
                }
            }
        })
        
        // Executes the task (access the API)
        task.resume()
    }
    
    // MARK: Setup Core Data
    
    func requestFavouritedUSDAItems() {
        // Create a request and pass it to the managedObjectContext when it executes the fetch request
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        self.favouritedUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
    }
}



















