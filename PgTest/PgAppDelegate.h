//
//  PgAppDelegate.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/17.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PgAppDelegate : NSObject
    <NSApplicationDelegate,NSTableViewDelegate,NSTableViewDataSource>
{
    NSWindow *_window;
    NSPopUpButton *_tableSelect;
    NSPopUpButton *_relashonSelect;
    NSTableView *_tableView;
    NSMutableArray *tableList_;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPopUpButton *tableSelect;
@property (assign) IBOutlet NSPopUpButton *relashonSelect;
@property (assign) IBOutlet NSTableView *tableView;
@property (nonatomic,retain,readwrite) NSMutableArray *tableList;

- (IBAction)updateAction:(id)sender;
- (IBAction)tableDidChanged:(id)sender;
- (IBAction)relashonDidChanged:(id)sender;
- (IBAction)insertAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end
