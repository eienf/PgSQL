//
//  PgSQLInsert.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLInsert.h"

@implementation PgSQLInsert

+ (PgSQLInsert*)insertCommandWith:(PgSQLRecord*)aRecord connection:(PgSQLConnection*)con
{
    if ( ![aRecord isKindOfClass:[PgSQLRecord class]] ) return nil;
    PgSQLInsert *anInsert = [[PgSQLInsert alloc] init];
    anInsert.conn = con;
    anInsert.record = aRecord;
    return [anInsert autorelease];
}

+ (NSArray*)insertCommandsFrom:(NSArray*)anArray connection:(PgSQLConnection*)con
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[anArray count]];
    [anArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
        PgSQLInsert *anObject = [PgSQLInsert insertCommandWith:obj connection:con];
        if ( anObject != nil ) {
            [result addObject:anObject];
        }
    }];
    return result;
}

- (PgSQLResult*)execute
{
    NSString *sql;
    NSArray *keys;
    NSArray *values;
    if ( record_.tableName == nil ) return nil;
    if ( [record_.attributes count] == 0 ) return nil;
    keys = [record_.attributes allKeys];
    values = [record_.attributes objectsForKeys:keys notFoundMarker:[NSNull null]];
    self.params = values;
    NSString *keyList = [keys componentsJoinedByString:@", "];
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:[keys count]];
    for ( int i = 0; i < [keys count]; i++ ) {
        [params addObject:[NSString stringWithFormat:@"$%d",i+1]];
    }
    NSString *paramList = [params componentsJoinedByString:@", "];
    sql = [NSString stringWithFormat:@"INSERT INTO %@ ( %@ ) VALUES ( %@ );",
           record_.tableName, keyList, paramList ];
    if ( [self isBinary] ) {
        return [PgSQLCommand executeBinaryFormat:sql params:params_ connection:conn_];
    } else {
        return [PgSQLCommand executeTextFormat:sql params:params_ connection:conn_];
    }
    return nil;
}

- (PgSQLRecord*)insertedRecord
{
    PgSQLResult *aResult = [self execute];
    if ( ![aResult isOK] ) return nil;
    PgSQLCommand *aCommand = [[PgSQLCommand alloc] init];
    aCommand.conn = self.conn;
    aCommand.isBinary = self.isBinary;
    aCommand.format = [NSString stringWithFormat:@"SELECT currval(%@);",record_.pkeySequenceName];
    aResult = [aCommand execute];
    char *val = [aResult getValue:0 column:0];
    int type = [aResult getType:0];
    [record_ setBinary:val ofType:type forColumnName:record_.pkeyName];
    return record_;
}

@end
