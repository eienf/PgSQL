//
//  PgAppDelegate.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PgAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *_window;
}
@property (assign) IBOutlet NSWindow *window;

@end
