//
//  PgSQLConnection.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libpq-fe.h"

#import "PgSQLConnectionInfo.h"
#import "PgSQLCommand.h"
#import "PgSQLResult.h"

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
- (PgSQLResult*)executeCommand:(PgSQLCommand*)aCommand;
- (PgSQLResult*)executeString:(NSString*)aString;

@end
