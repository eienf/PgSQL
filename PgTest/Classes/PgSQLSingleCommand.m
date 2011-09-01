//
//  PgSQLSingleCommand.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/09/01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLSingleCommand.h"

@implementation PgSQLSingleCommand

@synthesize record = record_;

- (void)dealloc {
    self.record = nil;
    [super dealloc];
}

@end
