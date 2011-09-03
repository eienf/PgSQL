//
//  PgAppDelegate.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PgAppDelegate : NSObject
    <NSApplicationDelegate,NSTableViewDelegate,NSTableViewDataSource>
{
    NSWindow *_window;
    NSPopUpButton *_tableSelect;
    NSPopUpButton *_relashonSelect;
    NSTableView *_tableView;
    NSArray *tableList_;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPopUpButton *tableSelect;
@property (assign) IBOutlet NSPopUpButton *relashonSelect;
@property (assign) IBOutlet NSTableView *tableView;
@property (nonatomic,retain,readwrite) NSArray *tableList;

- (IBAction)updateAction:(id)sender;
- (IBAction)tableDidChanged:(id)sender;
- (IBAction)relashonDidChanged:(id)sender;

@end
