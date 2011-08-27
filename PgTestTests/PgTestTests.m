//
//  PgTestTests.m
//  PgTestTests
//
//  Created by 黒木 政幸 on 11/08/17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgTestTests.h"
#import "PgSQLConnectionInfo.h"

@implementation PgTestTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testConnectionInfo
{
    NSURL *aUrl = [[NSBundle mainBundle] URLForResource:@"TestDB" withExtension:@"plist"];
    PgSQLConnectionInfo *info = [PgSQLConnectionInfo connectionInfoWithURL:aUrl];
    STAssertNotNil(info,@"info object should be allocated in PgTestTests");
    STAssertTrue([info.hostname isEqualToString:@"localhost"],@"Hostname does not match");
    STAssertTrue([info.port isEqualToString:@"5432"],@"Hostname does not match");
    STAssertTrue([info.dbname isEqualToString:@"TestDB"],@"Hostname does not match");
    STAssertTrue([info.username isEqualToString:@"testuser"],@"Hostname does not match");
    STAssertTrue([info.password isEqualToString:@"testtest"],@"Hostname does not match");
}

@end
