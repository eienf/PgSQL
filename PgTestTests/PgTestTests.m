//
//  PgTestTests.m
//  PgTestTests
//
//  Created by 黒木 政幸 on 11/08/17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgTestTests.h"
#import "PgSQLConnectionInfo.h"
#import "PgSQLConnection.h"
#import "PgSQLCommand.h"
#import "string.h"

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

- (void)test01_ConnectionInfo
{
    NSURL *aUrl = [[NSBundle mainBundle] URLForResource:@"TestDB" withExtension:@"plist"];
    PgSQLConnectionInfo *info = [PgSQLConnectionInfo connectionInfoWithURL:aUrl];
    STAssertNotNil(info,@"info object should be allocated in PgTestTests");
    STAssertTrue([info.hostname isEqualToString:@"localhost"],@"Hostname does not match");
    STAssertTrue([info.port isEqualToString:@"5432"],@"Hostname does not match");
    STAssertTrue([info.dbname isEqualToString:@"TestDB"],@"Hostname does not match");
    STAssertTrue([info.username isEqualToString:@"testuser"],@"Hostname does not match");
    STAssertTrue([info.password isEqualToString:@"testtest"],@"Hostname does not match");
    char buff[1024];
    STAssertTrue(strcmp([info cHostname:buff lenght:sizeof(buff)],"localhost")==0,@"Hostname does not match");
    STAssertTrue(strcmp([info cPort:buff lenght:sizeof(buff)],"5432")==0,@"Hostname does not match");
    STAssertTrue(strcmp([info cDbname:buff lenght:sizeof(buff)],"TestDB")==0,@"Hostname does not match");
    STAssertTrue(strcmp([info cUsername:buff lenght:sizeof(buff)],"testuser")==0,@"Hostname does not match");
    STAssertTrue(strcmp([info cPassword:buff lenght:sizeof(buff)],"testtest")==0,@"Hostname does not match");
}


- (void)test02_Connection
{
    NSURL *aUrl = [[NSBundle mainBundle] URLForResource:@"TestDB" withExtension:@"plist"];
    PgSQLConnectionInfo *info = [PgSQLConnectionInfo connectionInfoWithURL:aUrl];
    PgSQLConnection *con = [[PgSQLConnection alloc] init];
    con.connectionInfo = info;
    [con connect];
    STAssertTrue([con connectionStatus]==CONNECTION_OK,@"connection failed.");
    PgSQLResult *res = [PgSQLCommand executeString:@"select count(*) from author" connection:con];
    STAssertNotNil(res,@"res must be allocated.");
    if ( res == nil ) return;
    char *result;
    result = [res getValue];
    printf("[1]result = %s\n",result);
    STAssertTrue(result!=NULL&&strcmp(result,"8")==0,@"count does not match");
    result = [res getValue:0 column:0];
    printf("[2]result = %s\n",result);
    STAssertTrue(result!=NULL&&strcmp(result,"8")==0,@"count does not match");
    [con disconnect];
    [con release];
}

@end
