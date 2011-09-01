//
//  PgSQLUpdate.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLUpdate.h"

@implementation PgSQLUpdate

- (PgSQLResult*)execute
{
    NSString *sql;
    NSArray *keys;
    NSArray *values;
    if ( ![self isBinary] ) return nil;
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
    NSString *whereStatement = [NSString stringWithFormat:@"%@ = %@",record_.pkeyName,[keys count]+1];
    sql = [NSString stringWithFormat:@"UPDATE %@ SET ( %@ ) = ( %@ ) WHERE %@;",
           record_.tableName, keyList, paramList, whereStatement ];
    return [PgSQLCommand executeBinaryFormat:sql params:params_ connection:conn_];
}

@end
