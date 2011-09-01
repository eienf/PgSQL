//
//  PgSQLInsert.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLSingleCommand.h"

@interface PgSQLInsert : PgSQLSingleCommand
{

}

+ (PgSQLInsert*)insertCommandWith:(PgSQLRecord*)aRecord connection:(PgSQLConnection*)con;
- (PgSQLRecord*)insertedRecord;

@end
