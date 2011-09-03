//
//  PgSQLStatement.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
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
