//
//  DataController.swift
//  FoodTracker
//
//  Created by Diego Guajardo on 26/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let kUSDAItemCompleted = "USDAItemInstanceCompleted"

class DataController {
    
    class func jsonAsUSDAIdAndNameSearchResults(json: NSDictionary) -> [(name: String, idValue: String)] {
        // This function gets a NSDictionary and returns an array of tuples (key-value pairs), access them by doing 'dictionary name'.name (or .idValue)
        
        var usdaItemSearchResults:[(name: String, idValue: String)] = []
        var searchResult: (name: String, idValue:String)
        
        // The json NSDictionary will have several levels (ie dictionary with arrays that have dictionaries that have dictionaries, etc... If unsure of what to do, println() it
        if json["hits"] != nil {
            
            // We use AnyObject because the json dictionary has dictionaries, arrays, and strings. So it's easier to just say AnyObject rather than try to specify each one
            let results:[AnyObject] = json["hits"]! as! [AnyObject]
            
            for itemDictionary in results {
                
                if itemDictionary["_id"] != nil {
                    // We have an item idValue
                    
                    if itemDictionary["fields"] != nil {
                        
                        // We can unwrap idemDictionary["fields"] since we have already checked it is not nil
                        let fieldsDictionary = itemDictionary["fields"]! as! NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            // We have an item name
                            
                            let idValue:String = itemDictionary["_id"]! as! String
                            let name:String = fieldsDictionary["item_name"]! as! String
                            searchResult = (name : name, idValue : idValue)
                            usdaItemSearchResults += [searchResult]
                        }
                    }
                }
            }
        }
        
        return usdaItemSearchResults
    }
    
    func saveUSDAItemForId(idValue: String, json: NSDictionary) {
        
        // The json NSDictionary will have several levels (ie dictionary with arrays that have dictionaries that have dictionaries, etc... If unsure of what to do, println() it
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]!  as! [AnyObject]
            
            for itemDictionary in results {
                if itemDictionary["_id"] != nil && itemDictionary["_id"] as! String == idValue {
                    // if the ID in the itemDictionary exists AND the ID (as a String) is the idValue we are passing in (so we only use this specific itemDictionary). We trust that the API will use unique IDs (which is usually the case)
                    
                    // Get ready to save in Core Data
                    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                    var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                    
                    // Create an itemDictionary ID and use it to check if we have already saved this item (with this ID value) to core data before
                    let itemDictionaryId = itemDictionary["_id"]! as! String
                    
                    // Create a NSPredicate instance (like a constraint, you can do checks). The format is idValue == (our second argument), ie does the idValue == itemDictionaryId. So if you already have something stored to Core Data with the same idValue then add that to our request
                    let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                    
                    // Add the predicate to our request
                    requestForUSDAItem.predicate = predicate
                    
                    // Create an error
                    var error: NSError?
                    
                    // Execute the request
                    var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)
                    
                    if items?.count != 0 {
                        // If the item exists (is already saved in Core Data) we don't want to write them down again
                        println("The item was already saved")
                        return
                    } else {
                        println("Lets save this to Core Data!")
                        
                        // Setup the entity
                        let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
                        
                        // Create the USDAItem
                        let usdaItem = USDAItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                        
                        // Save the idValue in the usdaItem
                        usdaItem.idValue = itemDictionary["_id"]! as! String
                        
                        // Update the the date added
                        usdaItem.dateAdded = NSDate()
                        
                        // Get into the 'fields' dictionary
                        if itemDictionary["fields"] != nil {
                            let fieldsDictionary = itemDictionary["fields"]! as! NSDictionary
                            
                            if fieldsDictionary["item_name"] != nil {
                                // Save the name of the usdaItem
                                usdaItem.name = fieldsDictionary["item_name"]! as! String
                            }
                            
                            if fieldsDictionary["usda_fields"] != nil {
                                // The fields dictionary exists, now index into that one to save all the required data
                                
                                let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as! NSDictionary
                                
                                // ----- Do Calcium! -----
                                if usdaFieldsDictionary["CA"] != nil {
                                    let calciumDictionary = usdaFieldsDictionary["CA"]! as! NSDictionary
                                    
                                    if calciumDictionary["value"] != nil {
                                        // Some values are saved as strings (ie "8.345") and others as Ints (ie 0), so specify anyObject for calciumValue AND THEN conver it into a String by String interpolation (note that doing string interpolation to a string still returns a string)
                                        let calciumValue: AnyObject = calciumDictionary["value"]!
                                        usdaItem.calcium = "\(calciumValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.calcium = "0"
                                }
                                
                                // ----- Do Carbohydrates! -----
                                if usdaFieldsDictionary["CHOCDF"] != nil {
                                    let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"]! as! NSDictionary
                                    
                                    if carbohydrateDictionary["value"] != nil {
                                        let carbohydrateValue: AnyObject = carbohydrateDictionary["value"]!
                                        usdaItem.carbohydrate = "\(carbohydrateValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.carbohydrate = "0"
                                }
                                    
                                // ----- Do Fat! -----
                                if usdaFieldsDictionary["FAT"] != nil {
                                    let fatTotalDictionary = usdaFieldsDictionary["FAT"]! as! NSDictionary
                                        
                                    if fatTotalDictionary["value"] != nil {
                                        let fatTotalValue: AnyObject = fatTotalDictionary["value"]!
                                        usdaItem.fatTotal = "\(fatTotalValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.fatTotal = "0"
                                }
                                
                                // ----- Do Cholesterol! -----
                                if usdaFieldsDictionary["CHOLE"] != nil {
                                    let cholesterolDictionary = usdaFieldsDictionary["CHOLE"]! as! NSDictionary
                                    
                                    if cholesterolDictionary["value"] != nil {
                                        let cholesterolValue: AnyObject = cholesterolDictionary["value"]!
                                        usdaItem.cholesterol = "\(cholesterolValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.cholesterol = "0"
                                }
                                
                                // ----- Do Protein! -----
                                if usdaFieldsDictionary["PROCNT"] != nil {
                                    let proteinDictionary = usdaFieldsDictionary["PROCNT"]! as! NSDictionary
                                    
                                    if proteinDictionary["value"] != nil {
                                        let proteinValue: AnyObject = proteinDictionary["value"]!
                                        usdaItem.protein = "\(proteinValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.protein = "0"
                                }
                                
                                // ----- Do Sugar! -----
                                if usdaFieldsDictionary["SUGAR"] != nil {
                                    let sugarDictionary = usdaFieldsDictionary["SUGAR"]! as! NSDictionary
                                    
                                    if sugarDictionary["value"] != nil {
                                        let sugarValue: AnyObject = sugarDictionary["value"]!
                                        usdaItem.sugar = "\(sugarValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.sugar = "0"
                                }
                                
                                // ----- Do Vitamin C! -----
                                if usdaFieldsDictionary["VITC"] != nil {
                                    let vitaminCDictionary = usdaFieldsDictionary["VITC"]! as! NSDictionary
                                    
                                    if vitaminCDictionary["value"] != nil {
                                        let vitaminCValue: AnyObject = vitaminCDictionary["value"]!
                                        usdaItem.vitaminC = "\(vitaminCValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.vitaminC = "0"
                                }
                                
                                // ----- Do Energy! -----
                                if usdaFieldsDictionary["ENERC_KCAL"] != nil {
                                    let energyDictionary = usdaFieldsDictionary["ENERC_KCAL"]! as! NSDictionary
                                    
                                    if energyDictionary["value"] != nil {
                                        let energyValue: AnyObject = energyDictionary["value"]!
                                        usdaItem.energy = "\(energyValue)"
                                    }
                                    
                                } else {
                                    // If it does not exist then it is zero
                                    usdaItem.energy = "0"
                                }
                                
                                // SAVE THE CHANGES TO CORE DATA!!
                                (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
                                
                                // Create an NSNotification. Any class or view controller 'listening' to the kUSDAItemCompleted notification will get access to the object usdaItem. It's like a radio station
                                NSNotificationCenter.defaultCenter().postNotificationName(kUSDAItemCompleted, object: usdaItem)
                            }
                        }
                    }
                }
            }
        }
    }
}

















