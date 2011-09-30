//
//  PgSQLConnection.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
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
	if ( [self isConnected] ) return;
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
		conn_ = NULL;
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
    if ( conn_ == NULL ) return nil;
    char *message = PQerrorMessage(conn_);
    return [NSString stringWithCString:message encoding:NSASCIIStringEncoding];
}

- (int)transactionStatus
{
    if ( conn_ == NULL ) return CONNECTION_BAD;
    return PQtransactionStatus(conn_);
}

@end