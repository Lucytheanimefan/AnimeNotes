//
//  WindowController.swift
//  AnimeNotes
//
//  Created by Lucy Zhang on 9/3/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSToolbarDelegate {

    @IBOutlet weak var toolBar: NSToolbar!
    
    @IBOutlet var tagView: NSView!
    @IBOutlet var searchView: NSView!
    
    @IBOutlet weak var tagSelectorButton: NSPopUpButton!
    
    @IBOutlet weak var searchField: NSSearchField!
    
    let TagSelectorToolbarItemID = "tagSelector"
    let SearchFieldToolbarItemID = "searchField"
    
    let tagTitles = ["Trash", "Masterpiece", "2Deep4Me", "WTF", "HypeTrain", "Filler"]
    
    
    let tagToImageDict = ["Trash":#imageLiteral(resourceName: "Trash")]
    
    let DefaultFontSize : Int   = 14
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        self.toolBar.allowsUserCustomization = true
        self.toolBar.autosavesConfiguration = true
        self.toolBar.displayMode = .iconOnly
        setupTag()
    }
    
    func setupTag(){
        self.tagSelectorButton.addItem(withTitle: "")
        let item = self.tagSelectorButton.item(at: 0)
        //item?.title = "Tag"
        item?.image = NSImage(named: "TagIcon")
        
        self.tagSelectorButton.addItems(withTitles: Array(tagToImageDict.keys))
    }
    
    
    @IBAction func addTag(_ sender: NSButton) {       
        let tagTitle = tagSelectorButton.titleOfSelectedItem
        if let vc = self.window?.contentViewController as? ViewController{
            let attachmentCell = NSTextAttachmentCell(imageCell: tagToImageDict[tagTitle!])
            let attachment = NSTextAttachment()
            attachment.attachmentCell = attachmentCell
            let attributedString = NSAttributedString(attachment: attachment)
            vc.animeTagsView.textStorage?.append(attributedString)
        }
    }
    
    // Action occurs on enter
    @IBAction func searchFieldChange(_ sender: NSSearchField) {
        let searchString = sender.stringValue
        
        let entries = UserDefaults.standard.dictionaryRepresentation()
        
        
        var animeEntries:[Any] = entries.filter { (tuple: (key: String, value: Any)) -> Bool in
            if let val = tuple.value as? [String:Any]
            {
                if let type = val["type"] as? String{
                    return (type == "AnimeNotesEntry")
                }
            }
            return false
        }
        
        print(animeEntries)
        // Just search for tags for now
        let filteredEntries = animeEntries.filter { (object) -> Bool in
            //print(object)
            if let item = object as? (Any, Any){
                //print(item)
                if let value = item.1 as? [String:Any]{
                    //print(value)
                    if let tags = value["tags"] as? String{
                        if (tags.contains(searchString)){ return true }
                    }
                    if let notes = value["notes"] as? String{
                        if (notes.contains(searchString)){ return true }
                    }
                }
            }
            return false
        }
        
        print("Filtered entries!")
        print(filteredEntries)
    }
    
    
    // MARK: ToolbarDelegate
     func customToolbarItem(itemForItemIdentifier itemIdentifier: String, label: String, paletteLabel: String, toolTip: String, target: AnyObject, itemContent: AnyObject, action: Selector?, menu: NSMenu?) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        toolbarItem.target = target
        toolbarItem.action = action
        
        // Set the right attribute, depending on if we were given an image or a view.
        if (itemContent is NSImage) {
            let image: NSImage = itemContent as! NSImage
            toolbarItem.image = image
        }
        else if (itemContent is NSView) {
            let view: NSView = itemContent as! NSView
            toolbarItem.view = view
        }
        else {
            assertionFailure("Invalid itemContent: object")
        }
        
        /* If this NSToolbarItem is supposed to have a menu "form representation" associated with it
         (for text-only mode), we set it up here.  Actually, you have to hand an NSMenuItem
         (not a complete NSMenu) to the toolbar item, so we create a dummy NSMenuItem that has our real
         menu as a submenu.
         */
        // We actually need an NSMenuItem here, so we construct one.
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = menu
        menuItem.title = label
        toolbarItem.menuFormRepresentation = menuItem
        
        return toolbarItem
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem = NSToolbarItem()
        
        if (itemIdentifier == TagSelectorToolbarItemID) {
            // 1) Font style toolbar item.
            toolbarItem = customToolbarItem(itemForItemIdentifier: TagSelectorToolbarItemID, label: "Font Style", paletteLabel:"Tag Selector", toolTip: "Change your tag selector", target: self, itemContent: self.tagView, action: nil, menu: nil)!
        }
        else if (itemIdentifier == SearchFieldToolbarItemID) {
            toolbarItem = customToolbarItem(itemForItemIdentifier: SearchFieldToolbarItemID, label: "Search", paletteLabel:"Search field", toolTip: "Search by tag", target: self, itemContent: self.searchView, action: nil, menu: nil)!
        }
        return toolbarItem
        
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [TagSelectorToolbarItemID, SearchFieldToolbarItemID]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [TagSelectorToolbarItemID, SearchFieldToolbarItemID,NSToolbarSpaceItemIdentifier,
                NSToolbarFlexibleSpaceItemIdentifier,
                NSToolbarPrintItemIdentifier]
    }
    
}

