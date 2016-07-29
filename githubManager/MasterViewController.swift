//
//  MasterViewController.swift
//  githubManager
//
//  Created by Bruno Paulino on 7/23/16.
//  Copyright © 2016 brunojppb. All rights reserved.
//

import UIKit
import Kingfisher

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var gists = [Gist]()
    var nextPageString: String?
    var isLoading = false
    var dateFormatter = NSDateFormatter()
        
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadGists(nil)
        
        GithubAPIManager.sharedInstance.printMyStarredGistWithBasicAuth()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        // setup refresh control
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(self.refresh), forControlEvents: .ValueChanged)
            self.dateFormatter.dateStyle = .ShortStyle
            self.dateFormatter.timeStyle = .LongStyle
        }
    }
    
    // MARK: pull to refresh gists
    func refresh(sender: AnyObject) {
        nextPageString = nil
        self.loadGists(nextPageString)
    }
    

    func loadGists(urlToLoad: String?) {
        self.isLoading = true
        GithubAPIManager.sharedInstance.getPublicGists(urlToLoad) { (result, nextPage) in
            self.isLoading = false
            // hide refresh control if refreshing
            if self.refreshControl != nil && (self.refreshControl?.refreshing)! {
                self.refreshControl?.endRefreshing()
            }
            self.nextPageString = nextPage
            guard result.error == nil else {
                print(result.error)
                // TODO: Display Error
                return
            }
            
            if let fetchedGists = result.value {
                if self.nextPageString != nil {
                    self.gists += fetchedGists
                } else {
                    self.gists = fetchedGists
                }
            }
            
            // update the last time we use the refresh control
            let now = NSDate()
            let updateString = "Last updated at \(self.dateFormatter.stringFromDate(now))"
            self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
            
            self.tableView.reloadData()
        }
    }

    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "Not implemented", message: "Can't create new gists yet, will implement later", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let gist = self.gists[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = gist
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gists.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let gist = gists[indexPath.row]
        cell.textLabel?.text = gist.description
        cell.detailTextLabel?.text = gist.ownerLogin
        if let imageURL = gist.ownerAvatarURL,
            url = NSURL(string: imageURL) {
            cell.imageView?.kf_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        } else {
            cell.imageView?.image = UIImage(named: "placeholder")
        }
        
        // check if we are at the end of the table
        // and request more gists from the API
        let rowsToLoadFromBottom = 5
        let rowsLoaded = gists.count
        if let nextPage = self.nextPageString {
            if(!isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                self.loadGists(nextPage)
            }
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            gists.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

