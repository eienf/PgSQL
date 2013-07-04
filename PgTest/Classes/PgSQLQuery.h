//
//  PgSQLQuery.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLWhereCommand.h"

@interface PgSQLQuery : PgSQLWhereCommand
{
    Class recordClass_;
    NSString *orderBy_;
    NSString *tableName_;
    int32_t limit;
    int32_t offset;
}
@property(nonatomic,assign,readwrite) Class recordClass;
@property(nonatomic,copy,readwrite) NSString *orderBy;
@property(nonatomic,copy,readwrite) NSString *tableName;
@property(nonatomic,assign,readwrite) int32_t limit;
@property(nonatomic,assign,readwrite) int32_t offset;

+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                        where:(NSString*)whereString
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                   connection:(PgSQLConnection*)connection;
+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                   columnNames:(NSArray*)columnNames
                       params:(NSArray*)params
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                   connection:(PgSQLConnection*)connection;
+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                        where:(NSString*)whereString
                       params:(NSArray*)params
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                   connection:(PgSQLConnection*)connection;
+ (PgSQLQuery*)queryWithTable:(NSString*)tableName
                        where:(NSString*)whereString
                       params:(NSArray*)params
                     forClass:(Class)recordClass
                      orderBy:(NSString*)orderBy
                        limit:(int32_t)limit
                       offset:(int32_t)offset
                   connection:(PgSQLConnection*)connection;

- (NSArray*)queryRecords;

@end
