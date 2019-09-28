//
//  ConfigureSheetController.m
//  FlyingLogo
//
//  Created by Gergely Sánta on 25/09/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

#import "ConfigureSheetController.h"
#import "Configuration.h"

@interface ConfigureSheetController ()

@property (strong) IBOutlet NSPopUpButton *sceneTypeSelector;

@end

@implementation ConfigureSheetController

- (NSNibName) windowNibName {
	return @"ConfigureSheet";
}

- (void) windowDidLoad {
	[super windowDidLoad];

	// Create new menu for sceneTypeSelector
	NSMenu *sceneTypesMenu = [NSMenu new];

	// Fill up menu with available scene names
	for (NSString *name in Configuration.shared.sceneNames) {
		NSMenuItem *item = [NSMenuItem new];
		item.title = name;
		item.action = @selector(sceneTypeSelected:);
		item.tag = [(NSNumber*)[Configuration.shared.scenes valueForKey:name] intValue];
		[sceneTypesMenu addItem:item];
	}

	// Set new menu for selector and select actually configured value
	self.sceneTypeSelector.menu = sceneTypesMenu;
	[self.sceneTypeSelector selectItemWithTag:Configuration.shared.sceneType];
}

- (void) sceneTypeSelected:(NSMenuItem*)menuItem {
	// Store selection
	Configuration.shared.sceneType = menuItem.tag;
}

- (IBAction) closeButtonPressed:(NSButton *)sender {
	[NSApp endSheet:self.window];
}

@end
