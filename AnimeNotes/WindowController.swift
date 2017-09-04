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
    
    @IBOutlet weak var tagSelectorButton: NSPopUpButton!
    
    
    let TagSelectorToolbarItemID = "tagSelector"
    
    let tagTitles = ["Trash", "Masterpiece", "2Deep4Me", "WTF", "HypeTrain", "Filler"]
    
    let DefaultFontSize : Int   = 14
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        self.toolBar.allowsUserCustomization = true
        self.toolBar.autosavesConfiguration = true
        self.toolBar.displayMode = .iconOnly
        
        addTagTitles()
    }
    
    func addTagTitles(){
        self.tagSelectorButton.addItem(withTitle: "")
        let item = self.tagSelectorButton.item(at: 0)
        item?.image = NSImage(named: "TagIcon")
        self.tagSelectorButton.addItems(withTitles: tagTitles)
    }
    
    @IBAction func addTag(_ sender: NSButton) {
        let tagTitle = tagSelectorButton.titleOfSelectedItem
        if let vc = self.window?.contentViewController as? ViewController{
            vc.animeNotesView.string = vc.animeNotesView.string! + tagTitle!
        }
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
        return toolbarItem
        
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [TagSelectorToolbarItemID]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [TagSelectorToolbarItemID,NSToolbarSpaceItemIdentifier,
                NSToolbarFlexibleSpaceItemIdentifier,
                NSToolbarPrintItemIdentifier]
    }
    

    
}
