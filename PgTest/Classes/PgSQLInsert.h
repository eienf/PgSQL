//
//  PgSQLInsert.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLSingleCommand.h"

@interface PgSQLInsert : PgSQLSingleCommand
{

}

+ (NSArray*)insertCommandsFrom:(NSArray*)anArray connection:(PgSQLConnection*)con;
+ (PgSQLInsert*)insertCommandWith:(PgSQLRecord*)aRecord connection:(PgSQLConnection*)con;
- (PgSQLResult*)executeInsert;
- (PgSQLRecord*)insertedRecord;

@end
