//
//  ViewController.swift
//  AnimeNotes
//
//  Created by Lucy Zhang on 9/3/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    
    lazy var malAnimeEntries:[NSDictionary] = {
        print(CFPreferencesCopyValue("malEntries" as CFString, "com.lucy.anime" as CFString, kCFPreferencesCurrentUser, kCFPreferencesAnyHost))
        return CFPreferencesCopyValue("malEntries" as CFString, "com.lucy.anime" as CFString, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as! [NSDictionary]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: NSOutlineViewDelegate
{
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cellView: NSTableCellView!
        if (tableColumn?.identifier == "AnimeEntryColumn")
        {
            cellView = outlineView.make(withIdentifier: "AnimeEntry", owner: nil) as! NSTableCellView
            if let entry = item as? NSDictionary{
                cellView.textField?.stringValue = entry["title"] as! String
            }
            else if let entry = item as? String
            {
                cellView.textField?.stringValue = entry
            }
            
        }
        return cellView
    }
}

extension ViewController: NSOutlineViewDataSource
{
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        print(item.debugDescription)
        if let entry = item as? NSDictionary{
            return entry["total_episodes"] as! NSInteger
        }
        else{
            return self.malAnimeEntries.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item as? NSDictionary) != nil
        {
            return String(index)
        }
        else
        {
            return self.malAnimeEntries[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return ((item as? NSDictionary) != nil)
    }
}
