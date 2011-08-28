//
//  PgSQLCommand.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLCommand.h"

@implementation PgSQLCommand

+ (PgSQLResult*)executeString:(NSString*)aString connection:(PgSQLConnection*)conn
{
    if ( ![conn isConnected] ) return nil;
    const char *sql = [aString cStringUsingEncoding:NSUTF8StringEncoding];
	PGresult *res = PQexec([conn conn],sql);
    ExecStatusType status = PQresultStatus(res);
	if ( status != PGRES_TUPLES_OK && status != PGRES_COMMAND_OK) {
		fprintf(stderr,"%s\n",PQresultErrorMessage(res));
		PQclear(res);
        return nil;
	}
	printf("EXECUTE SUCCESS!!\n");
    return [PgSQLResult resultWithResult:res];
}

@end
