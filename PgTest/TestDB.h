//
//  TestDB.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/03.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PgSQLConnection.h"
#import "PgSQLConnectionInfo.h"

@interface TestDB : NSObject
{
    PgSQLConnection *connection_;
    PgSQLConnectionInfo *info_;
}
@property(nonatomic,retain,readwrite) PgSQLConnection *connection;
@property(nonatomic,retain,readwrite) PgSQLConnectionInfo *info;

+ (TestDB*)testDB;
- (BOOL)load;


@end
