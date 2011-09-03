//
//  PgSQLUpdate.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLSingleCommand.h"
#import "PgSQLRecord.h"

@interface PgSQLUpdate : PgSQLSingleCommand
{

}

+ (PgSQLUpdate*)updateCommandWith:(PgSQLRecord*)aRecord connection:(PgSQLConnection*)con;
+ (NSArray*)updateCommandsFrom:(NSArray*)anArray connection:(PgSQLConnection*)con;

@end
