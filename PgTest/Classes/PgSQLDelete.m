//
//  PgSQLDelete.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLDelete.h"
#import "PgSQLRecord.h"

@implementation PgSQLDelete

@synthesize records = records_;

- (void)dealloc {
    self.records = nil;
    [super dealloc];
}

- (PgSQLResult*)execute
{
    if ( ![self isBinary] ) return nil;
    PgSQLRecord *aRecord = [records_ lastObject];
    if ( aRecord == nil ) return nil;
    NSString *tableName = aRecord.tableName;
    NSString *pkeyName = aRecord.pkeyName;
    NSMutableArray *paramList = [NSMutableArray arrayWithCapacity:[records_ count]];
    NSMutableArray *anArray = [NSMutableArray arrayWithCapacity:[records_ count]];
    [records_ enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
        [paramList addObject:aRecord.pkeyValue];
        [anArray addObject:[NSString stringWithFormat:@"$%d",idx+1]];
    }];
    NSString *pkeyList = [anArray componentsJoinedByString:@" , "];
    NSString *sql;
    sql = [NSString stringWithFormat:@"DELETE * FROM %@ WHERE %@ IN ( %@ )",tableName,pkeyName,pkeyList];
    return [PgSQLCommand executeBinaryFormat:sql params:params_ connection:conn_];
}

@end
