//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Diego Guajardo on 22/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import HealthKit

class DetailViewController: UIViewController {
    
    var usdaItem:USDAItem?

    @IBOutlet weak var textView: UITextView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // This ViewController is now listening to the kUSDAItemCompleted notification (sent by the DataController). When it gets the notification it will run the 'usdaItemDidComplete' function. It is written in the initialiser rather than the viewDidLoad because we want the DetailViewController to start 'listening' for these notifications AS SOON as it is loaded into memory, rather than wait until the view loads.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        requestAuthorisationForHealthStore()
        
        if usdaItem != nil {
            // Make sure we already have a usdaItem, otherwise update it in 'usdaItemDidComplete'
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }
    
    deinit {
        // Remove the notification when the DetailViewController is deinitialised so we do not try to send messages to a ViewController thaat no longer exists
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func usdaItemDidComplete(notification: NSNotification) {
        
        println("usdaItemDidComplete in DetailViewController")
        
        // The notification is passing the selected usdaItem as the object (Check the bottom of 'saveUSDAItemForId' in DataController)
        self.usdaItem = notification.object as? USDAItem
        
        if self.isViewLoaded() && self.view.window != nil {
            // If the view has loaded already when the usdaItemDidComplete then the textView was NOT setup in viewDidLoad, so set it up here
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }
    
    @IBAction func eatItBarButtonItemPressed(sender: UIBarButtonItem) {
        saveFoodItem(self.usdaItem!)
    }
    
    func createAttributedString(usdaItem: USDAItem) -> NSAttributedString {
        
        // Create an instance of the NSMutableAttributedString (an NSAttributedString is a string that can have a format, pretty much)
        var itemAttributedString = NSMutableAttributedString()
        
        // Setup a parragraph style
        var centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = NSTextAlignment.Center
        centeredParagraphStyle.lineSpacing = 10.0
        
        // Setup the attributes for the string
        var titleAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(22.0),
            NSParagraphStyleAttributeName : centeredParagraphStyle]
        
        // Create the NSAttributedString
        let titleString = NSAttributedString(string: "\(usdaItem.name)\n", attributes: titleAttributesDictionary)
        
        // Append the created string to the NSMutableAttributedString 'itemAttributedString' created at the beginning of the function
        itemAttributedString.appendAttributedString(titleString)
        
        // Create a new paragraph style
        var leftAllignedParagraphStyle = NSMutableParagraphStyle()
        leftAllignedParagraphStyle.alignment = NSTextAlignment.Left
        leftAllignedParagraphStyle.lineSpacing = 20.0
        
        // Setup some new attributes
        var styleFirstWordAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignedParagraphStyle]
        
        var style1AttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.darkGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignedParagraphStyle]
        
        var style2AttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.lightGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignedParagraphStyle]
        
        // Write down the Calcium
        let calciumTitleString = NSAttributedString(string: "Calcium ", attributes: styleFirstWordAttributesDictionary)
        let calciumBodyString = NSAttributedString(string: "\(usdaItem.calcium)mg \n", attributes: style1AttributesDictionary)
        itemAttributedString.appendAttributedString(calciumTitleString)
        itemAttributedString.appendAttributedString(calciumBodyString)
        
        // Write down the Carbohydrates
        let carbohydrateTitleString = NSAttributedString(string: "Carbohydrate ", attributes: styleFirstWordAttributesDictionary)
        let carbohydrateBodyString = NSAttributedString(string: "\(usdaItem.carbohydrate)g \n", attributes: style2AttributesDictionary)
        itemAttributedString.appendAttributedString(carbohydrateTitleString)
        itemAttributedString.appendAttributedString(carbohydrateBodyString)
        
        // Write down the Cholesterol
        let cholesterolTitleString = NSAttributedString(string: "Cholesterol ", attributes: styleFirstWordAttributesDictionary)
        let cholesterolBodyString = NSAttributedString(string: "\(usdaItem.cholesterol)mg \n", attributes: style1AttributesDictionary)
        itemAttributedString.appendAttributedString(cholesterolTitleString)
        itemAttributedString.appendAttributedString(cholesterolBodyString)
        
        // Write down the Energy
        let energyTitleString = NSAttributedString(string: "Energy ", attributes: styleFirstWordAttributesDictionary)
        let energyBodyString = NSAttributedString(string: "\(usdaItem.energy)kcal \n", attributes: style2AttributesDictionary)
        itemAttributedString.appendAttributedString(energyTitleString)
        itemAttributedString.appendAttributedString(energyBodyString)
        
        // Write down the Fat Total
        let fatTotalTitleString = NSAttributedString(string: "Fat Total ", attributes: styleFirstWordAttributesDictionary)
        let fatTotalBodyString = NSAttributedString(string: "\(usdaItem.fatTotal)g \n", attributes: style1AttributesDictionary)
        itemAttributedString.appendAttributedString(fatTotalTitleString)
        itemAttributedString.appendAttributedString(fatTotalBodyString)
        
        // Write down the protein
        let proteinTitleString = NSAttributedString(string: "Protein ", attributes: styleFirstWordAttributesDictionary)
        let proteinBodyString = NSAttributedString(string: "\(usdaItem.protein)g \n", attributes: style2AttributesDictionary)
        itemAttributedString.appendAttributedString(proteinTitleString)
        itemAttributedString.appendAttributedString(proteinBodyString)
        
        // Write down the Sugar
        let sugarTitleString = NSAttributedString(string: "Sugar ", attributes: styleFirstWordAttributesDictionary)
        let sugarBodyString = NSAttributedString(string: "\(usdaItem.sugar)g \n", attributes: style1AttributesDictionary)
        itemAttributedString.appendAttributedString(sugarTitleString)
        itemAttributedString.appendAttributedString(sugarBodyString)
        
        // Write down the Vitamin C
        let vitaminCTitleString = NSAttributedString(string: "Vitamin C ", attributes: styleFirstWordAttributesDictionary)
        let vitaminCBodyString = NSAttributedString(string: "\(usdaItem.vitaminC)mg \n", attributes: style2AttributesDictionary)
        itemAttributedString.appendAttributedString(vitaminCTitleString)
        itemAttributedString.appendAttributedString(vitaminCBodyString)
        
        return itemAttributedString
    }
    
    // MARK: Health Kit
    // HealthStore contains very private information, so you have to request for the information individually rather than get it all at once
    
    func requestAuthorisationForHealthStore() {
        let dataTypesToWrite = [
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC)]
        
        // We are not going to read anything in this app, but here it is just in case I need it for another app in the future
        let dataTypesToRead = [
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC)]
        
        // Create an instance of the HealthStoreConstant class, which creates a health store constant
        var store: HealthStoreConstant = HealthStoreConstant()
        store.healthStore?.requestAuthorizationToShareTypes(NSSet(array: dataTypesToWrite) as! Set<NSObject>, readTypes: NSSet(array: dataTypesToRead) as! Set<NSObject>, completion: { (success, error) -> Void in
            if success {
                println("User completed authorisation request")
            } else {
                println("User cancelled the request, error: \(error)")
            }
        })
    }
    
    func saveFoodItem(foodItem: USDAItem) {
        
        if HKHealthStore.isHealthDataAvailable() {
            // Check that the device is authorised to access the health data
            
            // Create an instance to store the time
            let timeFoodWasEntered = NSDate()
            
            // Create a dictionary to store the metadata
            let foodMetaData = [
                HKMetadataKeyFoodType : foodItem.name,
                "HKBrandName" : "USDAItem",
                "HKFoodTypeID" : foodItem.idValue]
            
            // Create a calcium unit (mg) and calcium consumed
            let calciumUnit = HKQuantity(unit: HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli), doubleValue: (foodItem.calcium as NSString).doubleValue)
            let calcium = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium), quantity: calciumUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create a carbohydrate unit (g) and carbohydrate consumed
            let carbohydrateUnit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: (foodItem.carbohydrate as NSString).doubleValue)
            let carbohydrates = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates), quantity: carbohydrateUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create a cholesterol unit (mg) and cholesterol consumed
            let cholesterolUnit = HKQuantity(unit: HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli), doubleValue: (foodItem.cholesterol as NSString).doubleValue)
            let cholesterol = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol), quantity: cholesterolUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create an energy unit (kcal) and save the calories consumed
            let energyUnit = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: (foodItem.energy as NSString).doubleValue)
            let calories = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed), quantity: energyUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create a fat total unit (g) and fat total consumed
            let fatTotalUnit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: (foodItem.fatTotal as NSString).doubleValue)
            let fatTotal = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal), quantity: fatTotalUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create a protein unit (g) and protein consumed
            let proteinUnit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: (foodItem.protein as NSString).doubleValue)
            let protein = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein), quantity: proteinUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create a sugar unit (g) and sugar consumed
            let sugarUnit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: (foodItem.sugar as NSString).doubleValue)
            let sugar = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar), quantity: sugarUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create a vitamin C unit (mg) and vitamin C consumed
            let vitaminCUnit = HKQuantity(unit: HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli), doubleValue: (foodItem.vitaminC as NSString).doubleValue)
            let vitaminC = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC), quantity: vitaminCUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            // Create an NSSet to store all the data
            let foodDataSet = NSSet(array: [calcium, carbohydrates, cholesterol, calories, fatTotal, protein, sugar, vitaminC])
            
            // Create a food correlation
            let foodCorrelation = HKCorrelation(type: HKCorrelationType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood), startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, objects: foodDataSet as! Set<NSObject>, metadata: foodMetaData)
            
            // Save the item to the HealthStore. Get access to the healthStore constant from our HealthStoreConstant class
            var store:HealthStoreConstant = HealthStoreConstant()
            store.healthStore?.saveObject(foodCorrelation, withCompletion: { (success, error) -> Void in
                if success {
                    println("Saved Successfully")
                } else {
                    println("Error Occured: \(error)")
                }
            })
            
        } else {
            // HealthKit is not available so do some error handling
        }
    }
}















