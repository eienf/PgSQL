//
//  PgAppDelegate.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/17.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgAppDelegate.h"
#import "TestDB.h"
#import "Author.h"
#import "Comic.h"
#import "PgSQLInsert.h"
#import "PgSQLDelete.h"
#import "PgSQLUpdate.h"
#import "PgSQLResult.h"

@interface PgAppDelegate ()
- (void)preparePopups;
- (NSMenu*)preparePopup:(NSPopUpButton*)thePopupButton 
forList:(NSArray*)theList
hasNoselect:(BOOL)noselect;
- (void)makeTableColumns;
- (BOOL)updateRecord:(PgSQLRecord*)aRecord;
- (BOOL)insertRecord:(PgSQLRecord*)aRecord;
- (BOOL)deleteRecord:(PgSQLRecord*)aRecord;
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
        self.tableList = [[Author loadAllObjects] mutableCopy];
    } else if ( [aString isEqualToString:@"Comic"] ) {
        [self preparePopup:_relashonSelect
                   forList:[Comic relationshipNames] 
               hasNoselect:YES];
        self.tableList = [[Comic loadAllObjects] mutableCopy];
    }
    [_relashonSelect setEnabled:YES];
    [self makeTableColumns];
    [_tableView reloadData];
}

- (IBAction)tableDidChanged:(id)sender {
    [self updateAction:sender];
}

- (IBAction)relashonDidChanged:(id)sender {
    NSString *aString = [[_relashonSelect selectedItem] title];
    NSInteger rowIndex = [_tableView selectedRow];
    PgSQLRecord *aRecord = [tableList_ objectAtIndex:rowIndex];
    id relation = [aRecord performSelector:NSSelectorFromString(aString)];
    if ( relation == nil ) {
        [_relashonSelect selectItemAtIndex:0];
        return;
    }
    if ( ![relation isKindOfClass:[NSArray class]] ) {
        relation = [NSArray arrayWithObject:relation];
    }
    self.tableList = relation;
    aRecord = [relation objectAtIndex:0];
    for ( NSMenuItem *anItem in [_tableSelect itemArray] ) {
        if ( [[anItem title] compare:aRecord.tableName options:NSCaseInsensitiveSearch]
            == NSOrderedSame ) {
            [_tableSelect selectItem:anItem];
            break;
        }
    }
    aString = [[_tableSelect selectedItem] title];
    if ( [aString isEqualToString:@"Author"] ) {
        [self preparePopup:_relashonSelect
                   forList:[Author relationshipNames] 
               hasNoselect:YES];
    } else if ( [aString isEqualToString:@"Comic"] ) {
        [self preparePopup:_relashonSelect
                   forList:[Comic relationshipNames] 
               hasNoselect:YES];
    }
    [_relashonSelect setEnabled:YES];
    [self makeTableColumns];
    [_tableView reloadData];
}

- (IBAction)insertAction:(id)sender {
    __block NSInteger anId = 0;
    PgSQLRecord *aRecord;
    NSString *aString = [[_tableSelect selectedItem] title];
    if ( [aString isEqualToString:@"Author"] ) {
        [tableList_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ( anId < [obj authorId] ) anId = [obj authorId];
        }];
        aRecord = [Author authorWithName:@"" andId:anId+1];
    } else if ( [aString isEqualToString:@"Comic"] ) {
        [tableList_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ( anId < [obj comicId] ) anId = [obj comicId];
        }];
        aRecord = [Comic comicWithTitle:@"" authorId:0 andId:anId+1];
    }
    [self insertRecord:aRecord];
}

- (IBAction)deleteAction:(id)sender {
    NSInteger row = [_tableView selectedRow];
    PgSQLRecord *aRecord = [tableList_ objectAtIndex:row];
    [self deleteRecord:aRecord];
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

#pragma transaction

- (BOOL)updateRecord:(PgSQLRecord*)aRecord
{
    PgSQLUpdate *aCommand = [PgSQLUpdate updateCommandWith:aRecord
                                                connection:[[TestDB testDB] connection]];
    PgSQLResult *aResult = [aCommand execute];
    return [aResult isOK];
}

- (BOOL)insertRecord:(PgSQLRecord*)aRecord
{
    PgSQLInsert *aCommand = [PgSQLInsert insertCommandWith:aRecord
                                                connection:[[TestDB testDB] connection]];
    PgSQLResult *aResult = [aCommand execute];
    if ( [aResult isOK] ) {
        [tableList_ addObject:aRecord];
        [_tableView reloadData];
    }
    return [aResult isOK];
}

- (BOOL)deleteRecord:(PgSQLRecord*)aRecord
{
    PgSQLDelete *aCommand = [PgSQLDelete deleteCommandWith:aRecord
                                                connection:[[TestDB testDB] connection]];
    PgSQLResult *aResult = [aCommand execute];
    if ( [aResult isOK] ) {
        [tableList_ removeObject:aRecord];
        [_tableView reloadData];
    }
    return [aResult isOK];
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

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    PgSQLRecord *aReocrd = [tableList_ objectAtIndex:row];
    if ( [[tableColumn identifier] isEqualToString:aReocrd.pkeyName] ) return NO;
    return YES;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    PgSQLRecord *aRecord = [tableList_ objectAtIndex:row];
    NSString *columnName = [tableColumn identifier];
    if ( [columnName isEqualToString:aRecord.pkeyName] ) return;
    [aRecord setObject:object forColumnName:columnName];
    if ( ![self updateRecord:aRecord] ) {
        [aRecord revertChanges];
        [tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                             columnIndexes:nil];
    }
}

@end
