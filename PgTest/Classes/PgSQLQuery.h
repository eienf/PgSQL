//
//  PgSQLQuery.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLWhereCommand.h"

@interface PgSQLQuery : PgSQLWhereCommand
{
    Class recordClass_;
    NSString *orderBy_;
    NSString *tableName_;
}
@property(nonatomic,assign,readwrite) Class recordClass;
@property(nonatomic,copy,readwrite) NSString *orderBy;
@property(nonatomic,copy,readwrite) NSString *tableName;

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

- (NSArray*)queryRecords;

@end
