//
//  PgSQLSingleCommand.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/01.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLSingleCommand.h"

@implementation PgSQLSingleCommand

@synthesize record = record_;

- (void)dealloc {
    self.record = nil;
    [super dealloc];
}

@end
