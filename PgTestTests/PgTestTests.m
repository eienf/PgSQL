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
#import "PgSQLResult.h"
#import "PgSQLValue.h"
#import "PgSQLCoder.h"
#import "PgSQLQuery.h"
#import "PgSQLRecord.h"
#import "PgSQLInsert.h"
#import "PgSQLUpdate.h"
#import "PgSQLDelete.h"
#import "PgSQLTransaction.h"
#import "string.h"


@interface NSDateComponents (EasyConst)
- (NSDateComponents*)dateComponentYear:(int)year month:(int)month day:(int)day
                                  hour:(int)hour minute:(int)minute second:(int)second;
- (NSString*)description;
- (BOOL)isZero:(NSUInteger)uflags;
@end

@implementation NSDateComponents (EasyConst)
- (NSDateComponents*)dateComponentYear:(int)year month:(int)month day:(int)day
                                  hour:(int)hour minute:(int)minute second:(int)second
{
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setYear:year];
    [comp setMonth:month];
    [comp setDay:day];
    [comp setHour:hour];
    [comp setMinute:minute];
    [comp setSecond:second];
    return [comp autorelease];
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"%d/%d/%d %d:%d:%d",
            [self year],[self month],[self day],[self hour],[self minute],[self second]];
}
- (BOOL)isZero:(NSUInteger)uflags
{
    if ( (uflags & NSYearCalendarUnit) && [self year] != 0 ) return NO;
    if ( (uflags & NSMonthCalendarUnit) && [self month] != 0 ) return NO;
    if ( (uflags & NSDayCalendarUnit) && [self day] != 0 ) return NO;
    if ( (uflags & NSHourCalendarUnit) && [self hour] != 0 ) return NO;
    if ( (uflags & NSMinuteCalendarUnit) && [self minute] != 0 ) return NO;
    if ( (uflags & NSSecondCalendarUnit) && [self second] != 0 ) return NO;
    return YES;
}
@end

@interface NSCalendar (Compare)
- (NSComparisonResult)compare:(NSDate*)aDate withDate:(NSDate*)bDate byDateComponents:(NSUInteger)uflags;
@end

@implementation NSCalendar (Compare)
- (NSComparisonResult)compare:(NSDate*)aDate withDate:(NSDate*)bDate byDateComponents:(NSUInteger)uflags;
{
    NSDateComponents *comp = [self components:uflags fromDate:aDate toDate:bDate options:0];
    NSLog(@"[a]%@",aDate);
    NSLog(@"[b]%@",bDate);
    NSLog(@"[c]%@",comp);
    if ( [comp isZero:uflags] ) return NSOrderedSame;
    return NSOrderedAscending;
}
@end


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
    char *result;
    if ( res != nil ) {
        result = [res getValue];
        printf("[1]result = %s\n",result);
        STAssertTrue(result!=NULL&&strcmp(result,"8")==0,@"count does not match");
        result = [res getValue:0 column:0];
        printf("[2]result = %s\n",result);
        STAssertTrue(result!=NULL&&strcmp(result,"8")==0,@"count does not match");
        [res clear];
    }
    res = [PgSQLCommand executeTextFormat:@"select * from author where author_id = $1;"
                                   params:[NSArray arrayWithObject:@"1"]
                               connection:con];
    if ( res != nil ) {
        STAssertTrue([res numOfTuples]==1,@"numOfTuples");
        STAssertTrue([res numOfFields]==2,@"numOfFields");
        [res printResult];
        [res clear];
    }
    res = [PgSQLCommand executeBinaryFormat:@"select * from author where author_id = $1;"
                                   params:[NSArray arrayWithObject:
                                           [PgSQLValue valueWithObject:[NSNumber numberWithInt:1] type:INT8OID]]
                               connection:con];
    if ( res != nil ) {
        STAssertTrue([res numOfTuples]==1,@"numOfTuples");
        STAssertTrue([res numOfFields]==2,@"numOfFields");
        [res printResult];
        [res clear];
    }
    res = [PgSQLCommand executeBinaryFormat:@"select * from datatype;"
                                     params:nil
                                 connection:con];
    if ( res != nil ) {
        STAssertTrue([res numOfTuples]==4,@"numOfTuples");
        STAssertTrue([res numOfFields]==13,@"numOfFields");
        [res printResult];
        [res clear];
    }
    [con disconnect];
    [con release];
}

- (void)test03_Value
{
    PgSQLValue *anObject = [PgSQLValue valueWithObject:[NSNumber numberWithBool:YES] type:BOOLOID];
    STAssertTrue([anObject boolValue],@"boolValue");
    NSInteger size = [anObject getBinarySize];
    STAssertTrue(size==1,@"boolValue size");
    char byte;
    [anObject getBinary:&byte maxSize:sizeof(byte)];
    NSDate *aDate = [NSDate date];
    [anObject setDate:aDate];
    STAssertTrue([anObject type]==TIMESTAMPOID,@"TIMESTAMPOID");
    STAssertTrue([anObject timetValue]==(time_t)[aDate timeIntervalSince1970],@"timeIntervalSince1970");
    [anObject setLongLongValue:9876543210];
    STAssertTrue([anObject longLongValue]==9876543210,@"Long Long");
    char buffer[1024];
    STAssertTrue([anObject getBinarySize]==sizeof(long long),@"long long size");
    [anObject getBinary:buffer maxSize:sizeof(buffer)];
    [PgSQLValue valueWithBinary:buffer type:INT8OID];
    STAssertTrue([anObject longLongValue]==9876543210,@"Long Long");
    [anObject setString:@"string value test."];
    const char *temp = [anObject cStringValue];
    size = [anObject getBufferSize];
    STAssertEquals(strncmp(temp, [@"string value test." UTF8String], size-1), 0, @"cStringValue");
    printf("temp = %s\n",temp);
    free((void*)temp);
}

- (void)test04_Coder
{
    char byte;
    [PgSQLCoder encodeBool:YES intoBuffer:&byte maxSize:sizeof(byte)];
    STAssertTrue([PgSQLCoder decodeBool:&byte],@"BOOL");
    char buffer[1024];
    [PgSQLCoder encodeInt16:1234 intoBuffer:buffer maxSize:sizeof(buffer)];
    STAssertTrue([PgSQLCoder decodeInt16:buffer]==1234,@"Int16");
    [PgSQLCoder encodeInt32:12345678 intoBuffer:buffer maxSize:sizeof(buffer)];
    STAssertTrue([PgSQLCoder decodeInt32:buffer]==12345678,@"Int32");
    [PgSQLCoder encodeInt64:9876543210 intoBuffer:buffer maxSize:sizeof(buffer)];
    STAssertTrue([PgSQLCoder decodeInt64:buffer]==9876543210,@"Int64");
    [PgSQLCoder encodeFloat:12345678.0f intoBuffer:buffer maxSize:sizeof(buffer)];
    STAssertTrue([PgSQLCoder decodeFloat:buffer]==12345678.0f,@"Float32");
    [PgSQLCoder encodeDouble:9876543210.0 intoBuffer:buffer maxSize:sizeof(buffer)];
    STAssertTrue([PgSQLCoder decodeDouble:buffer]==9876543210.0,@"Float64");
    NSString *aString = @"Ascii";
    [PgSQLCoder encodeVarchar:aString intoBuffer:buffer maxSize:sizeof(buffer)-1];
    STAssertTrue([aString isEqualToString:[PgSQLCoder decodeVarchar:buffer]],@"Varchar");
    [PgSQLCoder encodeText:aString intoBuffer:buffer maxLength:sizeof(buffer)-1];
    STAssertTrue([aString isEqualToString:[PgSQLCoder decodeText:buffer]],@"Text");
    NSDate *aDate = [NSDate date];
    NSDate *bDate;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    [PgSQLCoder encodeDate:aDate intoBuffer:buffer maxSize:sizeof(buffer)];
    bDate = [PgSQLCoder decodeDate:buffer];
    STAssertTrue([theCalendar compare:aDate
                             withDate:bDate
                     byDateComponents:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit]==NSOrderedSame
                 ,@"Date");
    [PgSQLCoder encodeTime:aDate intoBuffer:buffer maxSize:sizeof(buffer)];
    bDate = [PgSQLCoder decodeTime:buffer];
    STAssertTrue([theCalendar compare:aDate
                             withDate:bDate
                     byDateComponents:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit]==NSOrderedSame
                 ,@"Date");
    [PgSQLCoder encodeTimestamp:aDate intoBuffer:buffer maxSize:sizeof(buffer)];
    bDate = [PgSQLCoder decodeTimestamp:buffer];
    STAssertTrue([theCalendar compare:aDate
                             withDate:bDate
                     byDateComponents:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                  |NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit]==NSOrderedSame
                 ,@"Date");
    [PgSQLCoder encodeTimestampTZ:aDate intoBuffer:buffer maxSize:sizeof(buffer)];
    bDate = [PgSQLCoder decodeTimestampTZ:buffer];
    STAssertTrue([theCalendar compare:aDate
                             withDate:bDate
                     byDateComponents:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                  |NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit]==NSOrderedSame
                 ,@"Date");
}

- (void)test05_Query
{
    NSURL *aUrl = [[NSBundle mainBundle] URLForResource:@"TestDB" withExtension:@"plist"];
    PgSQLConnectionInfo *info = [PgSQLConnectionInfo connectionInfoWithURL:aUrl];
    PgSQLConnection *con = [[PgSQLConnection alloc] init];
    con.connectionInfo = info;
    [con connect];
    if ( con.isConnected ) {
        PgSQLQuery *aQuery = [PgSQLQuery queryWithTable:@"author" where:nil forClass:nil orderBy:nil connection:con];
        PgSQLResult *res = [aQuery execute];
        STAssertNotNil(res,@"res must be allocated.");
        STAssertTrue([res numOfTuples]==8,@"numOfTuples");
        STAssertTrue([res numOfFields]==2,@"numOfFields");
        [res printResult];
        [res clear];

        aQuery = [PgSQLQuery queryWithTable:@"author" where:@"author_id = 1" forClass:nil orderBy:nil connection:con];
        res = [aQuery execute];
        STAssertNotNil(res,@"res must be allocated.");
        STAssertTrue([res numOfTuples]==1,@"numOfTuples");
        STAssertTrue([res numOfFields]==2,@"numOfFields");        
        [res printResult];
        [res clear];

        aQuery = [PgSQLQuery queryWithTable:@"author"
                                      where:@"author_id > $1" 
                                     params:[NSArray arrayWithObject:[PgSQLValue valueWithObject:[NSNumber numberWithInt:100] type:INT4OID]]
                                   forClass:nil
                                    orderBy:@"author_id"
                                 connection:con];
        res = [aQuery execute];
        STAssertNotNil(res,@"res must be allocated.");
        STAssertTrue([res numOfTuples]==2,@"numOfTuples");
        STAssertTrue([res numOfFields]==2,@"numOfFields");        
        [res printResult];
        [res clear];

        aQuery = [PgSQLQuery queryWithTable:@"author"
                                columnNames:[NSArray arrayWithObject:@"author_id"]
                                     params:[NSArray arrayWithObject:[PgSQLValue valueWithObject:[NSNumber numberWithInt:101] type:INT4OID]]
                                   forClass:nil
                                    orderBy:@"author_id"
                                 connection:con];
        res = [aQuery execute];
        STAssertNotNil(res,@"res must be allocated.");
        STAssertTrue([res numOfTuples]==1,@"numOfTuples");
        STAssertTrue([res numOfFields]==2,@"numOfFields");        
        [res printResult];
        [res clear];

        [con disconnect];
    }
    [con release];
}

- (void)test06_Insert
{
    NSURL *aUrl = [[NSBundle mainBundle] URLForResource:@"TestDB" withExtension:@"plist"];
    PgSQLConnectionInfo *info = [PgSQLConnectionInfo connectionInfoWithURL:aUrl];
    PgSQLConnection *con = [[PgSQLConnection alloc] init];
    con.connectionInfo = info;
    [con connect];
    if ( con.isConnected ) {
        PgSQLResult *aResult;
        PgSQLQuery *aQuery;
        NSArray *anArray;
        PgSQLRecord *bRecord;
        PgSQLRecord *aRecord = [[[PgSQLRecord alloc] init] autorelease];
        aRecord.tableName = @"author";
        aRecord.pkeyName = @"author_id";
        [aRecord setInt32:201 forColumnName:@"author_id"];
        [aRecord setVarchar:@"Tim Cook,CEO" forColumnName:@"name"];
        STAssertEquals([aRecord int32ForColumnName:@"author_id"], 201, @"PgSQLRecord author_id");
        STAssertTrue([[aRecord varcharForColumnName:@"name"] isEqualToString:@"Tim Cook,CEO"], @"PgSQLRecord name");
        NSLog(@"%@",aRecord.attributes);

        PgSQLInsert *anInsert = [PgSQLInsert insertCommandWith:aRecord connection:con];
        aResult = [anInsert executeInsert];
        STAssertTrue([aResult isOK], @"PgSQLInsert execute");
        [aResult clear];

        aQuery = [PgSQLQuery queryWithTable:@"author" where:@"author_id = 201" forClass:nil orderBy:nil connection:con];
        anArray = [aQuery queryRecords];
        NSLog(@"after inserted [%d]",[anArray count]);
        STAssertEquals([anArray count], (NSUInteger)1, @"after inserted author_id");
        bRecord = [anArray objectAtIndex:0];
        NSLog(@"    %@",bRecord);
        STAssertEquals([bRecord int32ForColumnName:@"author_id"], 201, @"PgSQLRecord author_id");
        STAssertTrue([[bRecord varcharForColumnName:@"name"] isEqualToString:@"Tim Cook,CEO"], @"PgSQLRecord name");
        bRecord.tableName = aRecord.tableName;
        bRecord.pkeyName = aRecord.pkeyName;

        [bRecord setVarchar:@"Barak Obama" forColumnName:@"name"];
        STAssertTrue([[bRecord varcharForColumnName:@"name"] isEqualToString:@"Barak Obama"], @"PgSQLRecord name");

        PgSQLUpdate *anUpdate = [PgSQLUpdate updateCommandWith:bRecord connection:con];
        aResult = [anUpdate execute];
        STAssertTrue([aResult isOK], @"PgSQLUpdate execute");
        [aResult clear];

        aQuery = [PgSQLQuery queryWithTable:@"author" where:@"author_id = 201" forClass:nil orderBy:nil connection:con];
        anArray = [aQuery queryRecords];
        NSLog(@"after updated [%d]",[anArray count]);
        STAssertEquals([anArray count], (NSUInteger)1, @"after updated author_id");
        bRecord = [anArray objectAtIndex:0];
        NSLog(@"    %@",bRecord);
        STAssertEquals([bRecord int32ForColumnName:@"author_id"], 201, @"PgSQLRecord author_id");
        STAssertTrue([[bRecord varcharForColumnName:@"name"] isEqualToString:@"Barak Obama"], @"PgSQLRecord name");

        PgSQLDelete *aDelete = [PgSQLDelete deleteCommandFrom:[NSArray arrayWithObject:aRecord] connection:con];
        aResult = [aDelete execute];
        STAssertTrue([aResult isOK], @"PgSQLDelete execute");
        [aResult clear];

        aQuery = [PgSQLQuery queryWithTable:@"author" where:@"author_id = 201" forClass:nil orderBy:nil connection:con];
        aResult = [aQuery execute];
        STAssertNotNil(aResult,@"aResult must be allocated.");
        STAssertTrue([aResult numOfTuples]==0,@"numOfTuples");
        [aResult clear];

        [con disconnect];
    } else {
        STAssertFalse(YES, @"connection failed");
    }
    [con release];
}

- (void)test06_Transaction
{
    NSURL *aUrl = [[NSBundle mainBundle] URLForResource:@"TestDB" withExtension:@"plist"];
    PgSQLConnectionInfo *info = [PgSQLConnectionInfo connectionInfoWithURL:aUrl];
    PgSQLConnection *con = [[PgSQLConnection alloc] init];
    con.connectionInfo = info;
    [con connect];
    if ( con.isConnected ) {
        BOOL flag;
//        PgSQLResult *aResult;
        PgSQLTransaction *aTransaction;
        PgSQLQuery *aQuery;
        PgSQLRecord *aRecord;
        NSArray *anArray;
        NSArray *insertList;
        NSMutableArray *recordArray = [NSMutableArray arrayWithCapacity:2];
        aRecord = [[[PgSQLRecord alloc] init] autorelease];
        aRecord.tableName = @"author";
        aRecord.pkeyName = @"author_id";
        [aRecord setInt32:301 forColumnName:@"author_id"];
        [aRecord setVarchar:@"月亭八光" forColumnName:@"name"];
        [recordArray addObject:aRecord];
        aRecord = [[[PgSQLRecord alloc] init] autorelease];
        aRecord.tableName = @"author";
        aRecord.pkeyName = @"author_id";
        [aRecord setInt32:302 forColumnName:@"author_id"];
        [aRecord setVarchar:@"宇都宮まき" forColumnName:@"name"];
        [recordArray addObject:aRecord];

        insertList = [PgSQLInsert insertCommandsFrom:recordArray connection:con];
        aTransaction = [PgSQLTransaction transactionWith:insertList connection:con];
        flag = [aTransaction beginTransaction];
        STAssertTrue(flag, @"begin transaction");
        if ( !flag ) {
            goto FINISH;
        }
        flag = [aTransaction execute];
        STAssertTrue(flag, @"execuete transaction");
        if ( !flag ) {
            [aTransaction rollback];
            goto FINISH;
        }
        aQuery = [PgSQLQuery queryWithTable:@"author" where:@"author_id > 300" forClass:nil orderBy:nil connection:con];
        anArray = [aQuery queryRecords];
        NSLog(@"after insert [%d]",[anArray count]);
        STAssertEquals([anArray count], (NSUInteger)2, @"after updated author_id");
        NSLog(@"    %@",anArray);
        [aTransaction rollback];
        aQuery = [PgSQLQuery queryWithTable:@"author" where:@"author_id > 300" forClass:nil orderBy:nil connection:con];
        anArray = [aQuery queryRecords];
        NSLog(@"after rollback [%d]",[anArray count]);
        STAssertEquals([anArray count], (NSUInteger)0, @"after updated author_id");
    } else {
        STAssertFalse(YES, @"connection failed");
    }
FINISH:
    [con release];
}


@end
