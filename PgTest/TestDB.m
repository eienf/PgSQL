//
//  TestDB.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/03.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "TestDB.h"

static TestDB *testDB_;

@implementation TestDB

@synthesize connection = connection_;
@synthesize info = info_;

+ (TestDB*)testDB
{
    @synchronized(testDB_) {
        if ( testDB_ == nil ) {
            testDB_ = [[TestDB alloc] init];
        }
    }
    return testDB_;
}

- (BOOL)load
{
    NSURL *aUrl = [[NSBundle mainBundle] URLForResource:@"TestDB" withExtension:@"plist"];
    self.info = [PgSQLConnectionInfo connectionInfoWithURL:aUrl];
    self.connection = [[[PgSQLConnection alloc] init] autorelease];
    self.connection.connectionInfo = self.info;
    return YES;
}

@end
