//
//  PgSQLCommand.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libpq-fe.h"

#import "PgSQLResult.h"
#import "PgSQLConnection.h"

@interface PgSQLCommand : NSObject
{
    PgSQLConnection *conn_;
    NSString *format_;
    NSArray *params_; // array of PgSQLValue/NSString
    BOOL isBinary_;
}
@property(nonatomic,assign,readwrite) PgSQLConnection *conn;
@property(nonatomic,assign,readwrite) BOOL isBinary;
@property(nonatomic,copy,readwrite) NSString *format;
@property(nonatomic,copy,readwrite) NSArray *params;

+ (PgSQLResult*)executeString:(NSString*)aString connection:(PgSQLConnection*)conn;
+ (PgSQLResult*)executeTextFormat:(NSString*)aFormat params:(NSArray*)anArray connection:(PgSQLConnection*)conn;
+ (PgSQLResult*)executeBinaryFormat:(NSString*)aFormat params:(NSArray*)anArray connection:(PgSQLConnection*)conn;
- (PgSQLResult*)execute;

@end
