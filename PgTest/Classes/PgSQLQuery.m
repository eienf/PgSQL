//
//  PgSQLQuery.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLQuery.h"
#import "PgSQLResult.h"
#import "PgSQLValue.h"
#import "PgSQLRecord.h"

@implementation PgSQLQuery

@synthesize recordClass = recordClass_;
@synthesize orderBy = orderBy_;
@synthesize tableName = tableName_;
@synthesize limit;
@synthesize offset;

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
            NSString *aString = [NSString stringWithFormat:@"(%@ = $%ld)",obj,idx+1];
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

+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                        where:(NSString*)whereString
                       params:(NSArray*)params
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                        limit:(int32_t)limit
                       offset:(int32_t)offset
                   connection:(PgSQLConnection*)connection;
{
    PgSQLQuery *aCommand = [PgSQLQuery queryWithTable:tableName
                                                where:whereString
                                             forClass:recordClass
                                              orderBy:orderBy
                                           connection:connection];
    aCommand.params = params;
    aCommand.limit = limit;
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
    if ( limit > 0 ) {
        sql = [sql stringByAppendingFormat:@" LIMIT %d",limit];
    }
    if ( offset > 0 ) {
        sql = [sql stringByAppendingFormat:@" OFFSET %d",offset];
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
        NSLog(@"%s NO DATA AVAILABLE in %@ where %@",__func__,self.tableName,self.whereStatement);
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
			if ( [result getIsNull:row column:col] ) {
                PgSQLValue *aValue = [PgSQLValue nullValue];
                [dict setObject:aValue forKey:[nameList objectAtIndex:col]];
			} else if ( isBinary ) {
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
