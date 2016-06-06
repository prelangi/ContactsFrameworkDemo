//
//  ViewController.swift
//  ContactsFramework
//
//  Created by Prasanthi Relangi on 4/27/16.
//  Copyright © 2016 prasanthi. All rights reserved.
//

import UIKit
//import ContactsUI
import Contacts

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
    
    var allContacts:[CNContact] = []
    var contacts:[CNContact] = []
    var orderedContacts = [String:[CNContact]]() //Contacts ordered by lastName
    var contactIndex = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0)}
    var sortedKeys = [String]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContacts()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func fetchContacts() {
        fetchAllContacts()
        
        //fetch contacts where givenName is not ""
        for contact in allContacts {
            if contact.givenName != "" {
                contacts.append(contact)
                
                var firstLetter:String = "#"
                
                if contact.familyName != "" {
                    firstLetter = getKey(String(contact.familyName[contact.familyName.startIndex]).uppercaseString)
                    
                    
                    //print("Adding contact: \(contact.givenName) with key: \(firstLetter)")
                    
                    if self.orderedContacts[firstLetter] == nil {
                        self.orderedContacts[firstLetter] = []
                    }
                    self.orderedContacts[firstLetter]?.append(contact)
                }
            }
        }
        
        //Store all keys from the dictionary in an ordered manner
        sortedKeys = Array(self.orderedContacts.keys).sort(<)
        if sortedKeys[0] == "#" {
            sortedKeys.removeAtIndex(0)
            sortedKeys.append("#")
        }
        //print(sortedKeys)
        
    }
    
    func getKey(inpString: String) -> String {
        let letters = NSCharacterSet.letterCharacterSet()
        let range = inpString.rangeOfCharacterFromSet(letters)
        
        // range will be nil if no letters is found
        if range != nil {
            //print("letters found")
            return inpString
        }
        else {
            //print("letters not found")
            return "#"
        }
    }
    
    func fetchAllContacts() {
        
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) in
            if accessGranted {
                let contactsStore = AppDelegate.getAppDelegate().contactStore
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                                 CNContactEmailAddressesKey,
                                CNContactPhoneNumbersKey]
                let predicate = CNContact.predicateForContactsInContainerWithIdentifier(contactsStore.defaultContainerIdentifier())
                var message:String!

                
                do {
                    self.allContacts = try contactsStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                    if self.allContacts.count == 0 {
                        message = "No contacts with a phone number"
                    }
                    self.tableView.reloadData()
                }
                catch {
                    message = "Unable to fetch contacts"
                }
                
                if message != nil {
                    dispatch_async(dispatch_get_main_queue(), { ()-> Void in
                        AppDelegate.getAppDelegate().showMessage(message)
                    })
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDisplayName(indexPath:NSIndexPath)->NSAttributedString {
        
        let key = sortedKeys[indexPath.section]
        
        let firstName = self.orderedContacts[key]![indexPath.row].givenName
        let lastName  = self.orderedContacts[key]![indexPath.row].familyName
        let fullName  = firstName + " " + lastName
        let displayName = makeBold(fullName, location: firstName.characters.count+1, length: lastName.characters.count)
        
        return displayName
        
    }
    
    func makeBold(givenString: String, location: Int, length: Int )->NSAttributedString{
        
        let attributedString = NSMutableAttributedString(string: givenString)
        //print("1. GivenString: \(givenString) Input: \(attributedString)")
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFontOfSize(17)]
        
        // Part of string to be bold
        let range1 = NSRange(location: location, length: length)
        attributedString.addAttributes(boldFontAttribute, range: range1)
        
        //print("Input: \(givenString) Output: \(attributedString)")
        return attributedString
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section]
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sortedKeys[section]
        return orderedContacts[key]?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
    
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        let displayName = getDisplayName(indexPath)
        cell.textLabel!.attributedText = displayName
        
        return cell
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedKeys.count ?? 0
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sortedKeys
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        let section = (sortedKeys.indexOf(title)) ?? 0
        return section
    }
    

    


}

