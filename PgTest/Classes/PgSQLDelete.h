//
//  PgSQLDelete.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLWhereCommand.h"
#import "PgSQLRecord.h"

@interface PgSQLDelete : PgSQLWhereCommand
{
    NSMutableArray *records_;
}
@property(nonatomic,retain,readwrite) NSMutableArray *records;

+ (PgSQLDelete*)deleteCommandWith:(PgSQLRecord*)aRecord connection:(PgSQLConnection*)con;
+ (PgSQLDelete*)deleteCommandFrom:(NSArray*)anArray connection:(PgSQLConnection*)con;
+ (NSArray*)deleteCommandsFrom:(NSArray*)anArray connection:(PgSQLConnection*)con;

@end
