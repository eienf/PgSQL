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

- (id)init {
    self = [super init];
    if (self) {
        self.records = [NSMutableArray array];
    }
    return self;
}

+ (PgSQLDelete*)deleteCommandWith:(PgSQLRecord*)aRecord connection:(PgSQLConnection*)con
{
    if ( ![aRecord isKindOfClass:[PgSQLRecord class]] ) return nil;
    PgSQLDelete *anObect = [[PgSQLDelete alloc] init];
    anObect.conn = con;
    [anObect.records addObject:aRecord];
    return [anObect autorelease];
}

+ (PgSQLDelete*)deleteCommandFrom:(NSArray*)anArray connection:(PgSQLConnection*)con
{
    PgSQLDelete *anObect = [[PgSQLDelete alloc] init];
    anObect.conn = con;
    [anObect.records addObjectsFromArray:anArray];
    return [anObect autorelease];
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
    sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ IN ( %@ )",tableName,pkeyName,pkeyList];
    return [PgSQLCommand executeBinaryFormat:sql params:paramList connection:conn_];
}

@end
