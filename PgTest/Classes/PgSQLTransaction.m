//
//  PgSQLTransaction.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLTransaction.h"
#import "PgSQLCommand.h"

@implementation PgSQLTransaction

@synthesize commands = commands_;
@synthesize conn = conn_;

- (void)dealloc {
    self.commands = nil;
    self.conn = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.commands = [NSMutableArray array];
    }
    return self;
}

+ (PgSQLTransaction*)transactionWith:(NSArray*)anArray connection:(PgSQLConnection*)con
{
    PgSQLTransaction *anObject = [[PgSQLTransaction alloc] init]; 
    anObject.conn = con;
    [anObject.commands addObjectsFromArray:anArray];
    return [anObject autorelease];
}

- (void)appendCommand:(PgSQLCommand*)aCommand
{
    if ( ![aCommand isKindOfClass:[PgSQLCommand class]] ) {
        return;
    }
    [self.commands addObject:aCommand];
}

- (void)appendCommands:(NSArray*)anArray
{
    [self.commands addObjectsFromArray:anArray];
}

- (BOOL)run
{
    if ( [self.commands count] == 0 ) return NO;
    if ( [self beginTransaction] ) return NO;
    if ( [self execute] ) {
        [self rollback];
        return NO;
    }
    [self commitEditing];
    return YES;
}

- (BOOL)beginTransaction
{
    PgSQLResult *aResult = [PgSQLCommand executeString:@"BEGIN TRANSACTION;" connection:self.conn];
    BOOL flag = [aResult isOK];
    [aResult clear];
    return flag;    
}

- (BOOL)execute
{
    for ( PgSQLCommand *aCommand in commands_ ) {
        PgSQLResult *aResult = [aCommand execute];
        if ( ![aResult isOK] ) {
            [aResult clear];
            return NO;
        }
        [aResult clear];
    }
    return YES;    
}

- (BOOL)commitEditing
{
    PgSQLResult *aResult = [PgSQLCommand executeString:@"COMMIT;" connection:self.conn];
    BOOL flag = [aResult isOK];
    [aResult clear];
    return flag;    
}

- (void)rollback
{
    PgSQLResult *aResult = [PgSQLCommand executeString:@"ROLLBACK;" connection:self.conn];
    [aResult clear];
}



@end
