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
    
    @IBOutlet weak var animeTitle: NSTextField!
    
    @IBOutlet weak var animeEpisode: NSTextField!
    
    @IBOutlet var animeNotesView: NSTextView!
    
    @IBOutlet var animeTagsView: NSTextView!
    
    let userDefaults = UserDefaults.standard
    
    lazy var malAnimeEntries:[NSDictionary]? = {
        return CFPreferencesCopyValue("malEntries" as CFString, "com.lucy.anime" as CFString, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? [NSDictionary]
    }()
    
    
    var selectedAnimeTitle:String!
    var selectedAnimeEpisode:String!
    
    var filterMode:Bool! = false
    var filteredEntries:[Any]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.backgroundColor = NSColor.clear
        animeNotesView.textContainerInset = NSMakeSize(15, 15)
        animeTagsView.textContainerInset = NSMakeSize(3, 3)
        animeNotesView.delegate = self
        animeTagsView.delegate = self
        
        NSApp.windows.first?.isOpaque = false
        NSApp.windows.first?.backgroundColor = NSColor(calibratedWhite: 40, alpha: 0.95)
        
        
        // Just for debugging, clear user defaults
//        if let bundle = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundle)
//        }

    }
    
    override func viewDidAppear() {
        outlineView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        updateTextView()
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
            if (filterMode)
            {
                if let entry = item as? (Any, Any){
                    print(entry)
                    if let title = entry.0 as? String{
                        print(title)
                        cellView.textField?.stringValue = title
                    }
                }
                else
                {
                    cellView.textField?.stringValue = "Filtered anime no title"
                }
            }
            else
            {
                if let entry = item as? NSDictionary{
                    cellView.textField?.stringValue = entry["title"] as! String
                }
                else if let entry = item as? String
                {
                    cellView.textField?.stringValue = entry
                }
            }
        }
        return cellView
    }
}

extension ViewController: NSOutlineViewDataSource
{
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        var children:Int! = 0
        if (filterMode){
            // No children
            children = self.filteredEntries.count
        }
        else
        {
            if let entry = item as? NSDictionary{
                children = entry["total_episodes"] as! NSInteger
            }
            else if (self.malAnimeEntries != nil){
                children = self.malAnimeEntries!.count
            }
        }
        return children
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (filterMode)
        {
            return self.filteredEntries[index]
        }
        else
        {
            if (item as? NSDictionary) != nil
            {
                return String((index + 1))
            }
            else if (self.malAnimeEntries != nil)
            {
                return self.malAnimeEntries![index]
            }
        }
        return "Error - nothing"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        if (filterMode) {return false}
        else{
            return ((item as? NSDictionary) != nil)
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if (filterMode)
        {
            
        }
        else
        {
            updateTextView()
        }
    }
    
    func updateTextView(){
        if (outlineView.selectedRow < 0)
        {
            return
        }
        let outlineItem = outlineView.item(atRow: outlineView.selectedRow)
        if let item = outlineView.view(atColumn: 0, row: outlineView.selectedRow, makeIfNecessary: false) as? NSTableCellView{
            if (Int((item.textField?.stringValue)!) == nil)
            {
                selectedAnimeTitle = (item.textField?.stringValue)!
                animeTitle.stringValue = selectedAnimeTitle
                selectedAnimeEpisode = "-"
                animeEpisode.stringValue = "Episode: " + selectedAnimeEpisode
                
            } else {
                if let parent = outlineView.parent(forItem: outlineItem) as? NSDictionary{
                    selectedAnimeTitle = parent["title"] as! String
                }
                selectedAnimeEpisode = (item.textField?.stringValue)!
                animeEpisode.stringValue = "Episode: " + selectedAnimeEpisode
                animeTitle.stringValue = selectedAnimeTitle
            }
            
            // Update the text view notes
            if (selectedAnimeEpisode != nil || selectedAnimeTitle != nil)
            {
                if let notes  = userDefaults.object(forKey: selectedAnimeTitle + selectedAnimeEpisode) as? [String:Any]{
                    if let note = notes["notes"] as? String{
                        animeNotesView.string = note
                    }
                    if let tagsString = notes["tags"] as? String{
                        animeTagsView.textStorage?.append(NSAttributedString(string: tagsString))
                    }
                } else {
                    animeNotesView.string = ""
                    animeTagsView.string = ""
                }
            }
        }
        
    }
    
}

extension ViewController:NSTextViewDelegate
{
    override func controlTextDidChange(_ obj: Notification) {
        let data = ["type":"AnimeNotesEntry", "notes":animeNotesView.string!, "tags":animeTagsView.attributedString().string] as [String : Any]

        userDefaults.set(data, forKey: selectedAnimeTitle + selectedAnimeEpisode)
        
    }
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        let data = ["type":"AnimeNotesEntry", "notes":animeNotesView.string!, "tags":animeTagsView.attributedString().string] as [String : Any]
        
        userDefaults.set(data, forKey: selectedAnimeTitle + selectedAnimeEpisode)
        
        return false
    }
}

