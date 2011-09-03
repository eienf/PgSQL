//
//  PgAppDelegate.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgAppDelegate.h"
#import "TestDB.h"
#import "Author.h"
#import "Comic.h"

@interface PgAppDelegate ()
- (void)preparePopups;
- (NSMenu*)preparePopup:(NSPopUpButton*)thePopupButton 
forList:(NSArray*)theList
hasNoselect:(BOOL)noselect;
- (void)makeTableColumns;
@end

@implementation PgAppDelegate

@synthesize window = _window;
@synthesize tableSelect = _tableSelect;
@synthesize relashonSelect = _relashonSelect;
@synthesize tableView = _tableView;
@synthesize tableList = tableList_;

- (void)dealloc {
    self.tableList = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[TestDB testDB] load];
    PgSQLConnection *con = [[TestDB testDB] connection];
    [con connect];
    if ( ![con isConnected] ) {
        NSLog(@"connection failed.");        
        return;
    }
    [self preparePopups];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    PgSQLConnection *con = [[TestDB testDB] connection];
    [con disconnect];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)updateAction:(id)sender {
    NSString *aString = [[_tableSelect selectedItem] title];
    if ( [aString isEqualToString:@"Author"] ) {
        [self preparePopup:_relashonSelect
                   forList:[Author relationshipNames] 
               hasNoselect:YES];
        self.tableList = [Author loadAllObjects];
    } else if ( [aString isEqualToString:@"Comic"] ) {
        [self preparePopup:_relashonSelect
                   forList:[Comic relationshipNames] 
               hasNoselect:YES];
        self.tableList = [Comic loadAllObjects];
    }
    [_relashonSelect setEnabled:YES];
    [self makeTableColumns];
    [_tableView reloadData];
}

- (IBAction)tableDidChanged:(id)sender {
    [self updateAction:sender];
}

- (IBAction)relashonDidChanged:(id)sender {
}

- (NSMenu*)preparePopup:(NSPopUpButton*)thePopupButton 
				forList:(NSArray*)theList
			hasNoselect:(BOOL)noselect
{
	NSEnumerator *e = [theList objectEnumerator];
	NSString *aString;
	NSInteger tag = 0;
	NSMenu *aMenu = [[[NSMenu alloc]
					  initWithTitle:@""]
					 autorelease];
	NSMenuItem *anItem;
	if ( noselect ) {
		anItem = [[[NSMenuItem alloc]
				   initWithTitle:@""
				   action:@selector(_popUpItemAction:)
				   keyEquivalent:@""]
				  autorelease];
		[anItem setTag:tag++];
		[anItem setTarget:self];
		[aMenu addItem:anItem];
	}
	while ( aString = [e nextObject] ) {
		anItem = [[[NSMenuItem alloc]
				   initWithTitle:aString
				   action:@selector(_popUpItemAction:)
				   keyEquivalent:@""]
				  autorelease];
		[anItem setTag:tag++];
		[anItem setTarget:self];
		[aMenu addItem:anItem];
	}
	[thePopupButton setMenu:aMenu];
	[thePopupButton selectItemAtIndex:0];
	return aMenu;
}

- (void)preparePopups
{
    [self preparePopup:_tableSelect
               forList:[NSArray arrayWithObjects:@"Author", @"Comic", nil] 
           hasNoselect:NO];
    [_tableSelect setEnabled:YES];
    NSArray *anArray = [NSArray arrayWithObjects:@"", nil];
    [self preparePopup:_relashonSelect
               forList:anArray 
           hasNoselect:YES];
    [_relashonSelect setEnabled:NO];
}

#pragma mark NSTableViewDelegate

- (void)makeTableColumns
{
    for ( NSTableColumn *tableColumn in [[_tableView tableColumns] reverseObjectEnumerator] ) {
        [_tableView removeTableColumn:tableColumn]; 
    }
    PgSQLRecord *aReocrd = [tableList_ objectAtIndex:0];
    for ( NSString *aKey in [aReocrd.attributes allKeys] ) {
        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:aKey];
        [[tableColumn headerCell] setStringValue:aKey];
        [_tableView addTableColumn:tableColumn];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.tableList count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    PgSQLRecord *aRecord = [self.tableList objectAtIndex:rowIndex];
    NSString *columnName = [aTableColumn identifier];
    return [aRecord objectForColumnName:columnName];
}

@end
