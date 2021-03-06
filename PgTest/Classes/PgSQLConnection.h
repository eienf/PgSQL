//
//  PgSQLConnection.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libpq-fe.h"

#import "PgSQLConnectionInfo.h"
#import "PgSQLResult.h"

@class PgSQLCommand;

@interface PgSQLConnection : NSObject
{
    PgSQLConnectionInfo *connectionInfo_;
    PGconn *conn_;
}
@property(nonatomic,retain,readwrite) PgSQLConnectionInfo *connectionInfo;
@property(nonatomic,assign,readonly) PGconn *conn;

- (void)connect;
- (void)disconnect;
- (BOOL)isConnected;
- (int)connectionStatus;
- (NSString*)connectionMessage;
- (int)transactionStatus;

@end
