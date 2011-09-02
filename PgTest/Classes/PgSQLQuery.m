//
//  PgSQLQuery.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLQuery.h"
#import "PgSQLResult.h"
#import "PgSQLValue.h"
#import "PgSQLRecord.h"

@implementation PgSQLQuery

@synthesize recordClass = recordClass_;
@synthesize orderBy = orderBy_;
@synthesize tableName = tableName_;

- (void)dealloc
{
    self.tableName = nil;
    self.orderBy = nil;
    [super dealloc];
}

+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                        where:(NSString*)whereString
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                   connection:(PgSQLConnection*)connection
{
    PgSQLQuery *aCommand = [[PgSQLQuery alloc] init];
    aCommand.conn = connection;
    aCommand.orderBy = orderBy;
    aCommand.recordClass = [PgSQLRecord class];
    if ( [recordClass isSubclassOfClass:[PgSQLRecord class]] ) {
        aCommand.recordClass = recordClass;
    }
    aCommand.whereStatement = whereString;
    aCommand.tableName = tableName;
    aCommand.isBinary = YES;
    return [aCommand autorelease];
}

+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                   columnNames:(NSArray*)columnNames
                       params:(NSArray*)params
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                   connection:(PgSQLConnection*)connection
{
    PgSQLQuery *aCommand = [PgSQLQuery queryWithTable:tableName
                                                where:nil
                                               params:params
                                             forClass:recordClass
                                              orderBy:orderBy
                                           connection:connection];
    
    if ( [columnNames count] > 0 ) {
        NSMutableArray *anArray = [NSMutableArray arrayWithCapacity:[columnNames count]];
        [columnNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSString *aString = [NSString stringWithFormat:@"(%@ = $%d)",obj,idx+1];
            [anArray addObject:aString];
        }];
        aCommand.whereStatement = [anArray componentsJoinedByString:@" AND "];
    }
    return aCommand;
}

+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                        where:(NSString*)whereString
                       params:(NSArray*)params
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                   connection:(PgSQLConnection*)connection
{
    PgSQLQuery *aCommand = [PgSQLQuery queryWithTable:tableName
                                                where:whereString 
                                             forClass:recordClass
                                              orderBy:orderBy
                                           connection:connection];
    aCommand.params = params;
    return aCommand;
}

- (PgSQLResult*)execute
{
    NSString *sql;
    if ( whereStatement_ != nil ) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName_,whereStatement_];
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName_];
    }
    if ( orderBy_ != nil ) {
        sql = [sql stringByAppendingFormat:@" ORDER BY %@",orderBy_];        
    }
    if ( [self isBinary] ) {
        return [PgSQLCommand executeBinaryFormat:sql params:params_ connection:conn_];
    } else {
        return [PgSQLCommand executeTextFormat:sql params:params_ connection:conn_];
    }
    return nil;
}

- (NSArray*)queryRecords
{
    PgSQLResult *result = [self execute];
    if ( ![result isOK] ) {
        NSLog(@"%s (%d) %@",__func__,[result resultStatus],[result resultMessage]);
        return nil;   
    }
    if ( ![result resetRow] ) {
        NSLog(@"%s () NO DATA AVAILABLE",__func__);
        return nil;   
    }
    NSMutableArray *anArray = [NSMutableArray arrayWithCapacity:result.numOfTuples];
    NSMutableArray *nameList = [NSMutableArray arrayWithCapacity:result.numOfFields];
    for ( int i = 0; i < result.numOfFields; i++ ) {
        NSString *aString = [NSString stringWithUTF8String:[result getFieldName:i]];
        [nameList addObject:aString];
    }
    for ( int row = 0; row < result.numOfTuples; row++ ) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:result.numOfFields];
        for ( int col = 0; col < result.numOfFields; col++ ) {
            BOOL isBinary = [result getIsBinary:col];
            if ( [result getIsNull] ) {
                continue;
            }
            char *value = [result getValue:row column:col];
            int type = [result getType:col];
            if ( isBinary ) {
                PgSQLValue *aValue = [PgSQLValue valueWithBinary:value type:type];
                [dict setObject:aValue forKey:[nameList objectAtIndex:col]];
            } else {
                PgSQLValue *aValue = [PgSQLValue valueWithBinary:value type:TEXTOID];
                [dict setObject:aValue forKey:[nameList objectAtIndex:col]];
            }
        }
        PgSQLRecord *aRecord = [[[recordClass_ alloc] init] autorelease];
        [aRecord setAttributes:dict];
        [aRecord setTableName:self.tableName];
        [anArray addObject:aRecord];
    }
    [result clear];
    return anArray;
}


@end
