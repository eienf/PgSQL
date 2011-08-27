//
//  PgSQLConnection.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLConnection.h"
#import "PgSQLResult.h"

#define BUFF_SIZE   (1024)

@implementation PgSQLConnection

@synthesize connectionInfo = connectionInfo_;
@synthesize conn = conn_;

- (void)dealloc
{
    self.connectionInfo = nil;
    [self disconnect];
    conn_ = NULL;
    [super dealloc];
}

- (void)connect
{
    char hostname[BUFF_SIZE];
    char port[BUFF_SIZE];
    char dbname[BUFF_SIZE];
    char username[BUFF_SIZE];
    char passname[BUFF_SIZE];
	PGconn *con = PQsetdbLogin(
                               [self.connectionInfo cHostname:hostname lenght:sizeof(hostname)],
                               [self.connectionInfo cPort:port lenght:sizeof(port)],
                               NULL, // pgoptions
                               NULL, // pgtty
                               [self.connectionInfo cDbname:dbname lenght:sizeof(dbname)],
                               [self.connectionInfo cUsername:username lenght:sizeof(username)],
                               [self.connectionInfo cPassword:passname lenght:sizeof(passname)]
                               );
	if ( PQstatus(con) == CONNECTION_BAD ) {
		fprintf(stderr,"connection failed.\n");
		fprintf(stderr,"%s\n",PQerrorMessage(con));
		PQfinish(con);
        return;
	}
	printf("CONNECTION SUCCESS!!\n");
    conn_ = con;
}

- (void)disconnect
{
    if ( [self connectionStatus] == CONNECTION_OK ) {
        PQfinish(conn_);
    }
}

- (void)reset
{
    if ( conn_ ) PQreset(conn_);
}

- (BOOL)isConnected
{
    return ( [self connectionStatus] == CONNECTION_OK );
}

- (int)connectionStatus
{
    if ( conn_ == NULL ) return CONNECTION_BAD;
    return PQstatus(conn_);
}

- (NSString*)connectionMessage
{
    if ( conn_ ) return nil;
    char *message = PQerrorMessage(conn_);
    return [NSString stringWithCString:message encoding:NSASCIIStringEncoding];
}

- (int)transactionStatus
{
    if ( conn_ == NULL ) return CONNECTION_BAD;
    return PQtransactionStatus(conn_);
}

- (PgSQLResult*)executeCommand:(PgSQLCommand*)aCommand
{
    const char *sql = "";
	PGresult *res = PQexecParams(conn_,
                                 sql,
                                 0, // int nNumParams,
                                 NULL,// const Oid *paramTypes,
                                 NULL, // const char * const *paramValues,
                                 NULL, // const int *paramLengths,
                                 NULL, // const int *paramFormats,
                                 1 // int resultFormat
                                 );
    ExecStatusType status = PQresultStatus(res);
	if ( status != PGRES_TUPLES_OK && status != PGRES_COMMAND_OK) {
		fprintf(stderr,"%s\n",PQresultErrorMessage(res));
		PQclear(res);
        return nil;
	}
    return [PgSQLResult resultWithResult:res];
}

- (PgSQLResult*)executeString:(NSString*)aString
{
    if ( ![self isConnected] ) return nil;
    const char *sql = [aString cStringUsingEncoding:NSUTF8StringEncoding];
	PGresult *res = PQexec(conn_,sql);
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
