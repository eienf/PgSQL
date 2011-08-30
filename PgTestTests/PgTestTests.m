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


#if 1
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
                                           [PgSQLValue valueWithValue:[NSNumber numberWithInt:1] type:INT8OID]]
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
#endif

- (void)test03_Value
{
    PgSQLValue *anObject = [PgSQLValue valueWithValue:[NSNumber numberWithBool:YES] type:BOOLOID];
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
    [PgSQLCoder encodeVarchar:aString intoBuffer:buffer maxLength:sizeof(buffer)-1];
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

@end
