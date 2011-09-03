//
//  PgSQLTransaction.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PgSQLConnection.h"

@interface PgSQLTransaction : NSObject
{
    NSMutableArray *commands_;
    PgSQLConnection *conn_;
}
@property(nonatomic,retain,readwrite) NSMutableArray *commands;
@property(nonatomic,retain,readwrite) PgSQLConnection *conn;


+ (PgSQLTransaction*)transactionWith:(NSArray*)anArray connection:(PgSQLConnection*)con;
- (void)appendCommand:(PgSQLCommand*)aCommand;
- (void)appendCommands:(NSArray*)anArray;
- (BOOL)run;
- (BOOL)beginTransaction;
- (BOOL)execute;
- (BOOL)commitEditing;
- (void)rollback;

@end
