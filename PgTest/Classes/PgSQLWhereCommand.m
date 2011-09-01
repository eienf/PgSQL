//
//  PgSQLStatement.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLWhereCommand.h"

@implementation PgSQLWhereCommand

@synthesize whereStatement = whereStatement_;

- (void)dealloc
{
    self.whereStatement = nil;
    [super dealloc];
}

@end
