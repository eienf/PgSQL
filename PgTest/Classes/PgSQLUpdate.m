//
//  PgSQLUpdate.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLUpdate.h"

@implementation PgSQLUpdate

+ (PgSQLUpdate*)updateCommandWith:(PgSQLRecord*)aRecord connection:(PgSQLConnection*)con
{
    if ( ![aRecord isKindOfClass:[PgSQLRecord class]] ) return nil;
    if ( aRecord.tableName == nil ) return nil;
    if ( aRecord.pkeyName == nil ) return nil;
    if ( [aRecord.attributes count] == 0 ) return nil;
    PgSQLUpdate *anObject = [[PgSQLUpdate alloc] init];
    anObject.conn = con;
    anObject.record = aRecord;
    return [anObject autorelease];
}

+ (NSArray*)updateCommandsFrom:(NSArray*)anArray connection:(PgSQLConnection*)con
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[anArray count]];
    [anArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
        PgSQLUpdate *anObject = [PgSQLUpdate updateCommandWith:obj connection:con];
        if ( anObject != nil ) {
            [result addObject:anObject];
        }
    }];
    return result;
}


- (PgSQLResult*)execute
{
    NSString *sql;
    NSMutableArray *keys;
    NSMutableArray *values;
	NSDictionary *attr;
    if ( ![self isBinary] ) return nil;
    if ( record_.tableName == nil ) return nil;
    if ( record_.pkeyName == nil ) return nil;
    if ( [record_.attributes count] == 0 ) return nil;
	if ( [record_.oldValues count] != 0 ) {
		attr = record_.oldValues;
	} else {
		attr = record_.attributes;
	}
    keys = [NSMutableArray arrayWithCapacity:[attr count]];
    [[attr allKeys] enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
        if ( ![obj isEqualToString:record_.pkeyName] ) {
            [keys addObject:obj];
        }
    }];
    NSString *keyList = [keys componentsJoinedByString:@", "];
    [keys addObject:record_.pkeyName];
    values = [[record_.attributes objectsForKeys:keys notFoundMarker:[NSNull null]] mutableCopy];
    [values addObject:record_.pkeyValue];
    self.params = values;
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:[keys count]];
    for ( int i = 0; i < [keys count]-1; i++ ) {
        [params addObject:[NSString stringWithFormat:@"$%d",i+1]];
    }
    NSString *paramList = [params componentsJoinedByString:@", "];
    NSString *whereStatement = [NSString stringWithFormat:@"%@ = $%ld",record_.pkeyName,(NSUInteger)[keys count]];
    sql = [NSString stringWithFormat:@"UPDATE %@ SET ( %@ ) = ( %@ ) WHERE %@;",
           record_.tableName, keyList, paramList, whereStatement ];
//    NSLog(@"%@",sql);
    PgSQLResult *aResult = [PgSQLCommand executeBinaryFormat:sql params:params_ connection:conn_];
    if ( [aResult isOK] ) {
        [record_ didSaveChanges];
    }
    return aResult;
}

@end
