//
//  PgSQLResult.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libpq-fe.h"

@interface PgSQLResult : NSObject
{
    PGresult *result_;
    int numOfTuples_;
    int numOfFields_;
    int currentRow_;
    int currentField_;
}
@property(nonatomic,assign,readonly) int numOfTuples;
@property(nonatomic,assign,readonly) int numOfFields;
@property(nonatomic,assign,readonly) int currentRow;
@property(nonatomic,assign,readonly) int currentField;

+ (id)resultWithResult:(PGresult*)res;
- (void)setResult:(PGresult*)res;
- (void)clear;
- (int)resultStatus;
- (NSString*)resultMessage;
- (BOOL)resetRow;
- (BOOL)nextRow;
- (BOOL)hasNextRow;
- (BOOL)nextField;
- (BOOL)hasNexField;
- (char *)getFieldName:(int)column;
- (size_t)getLength;
- (size_t)getLength:(int)row column:(int)column;
- (int)getType;
- (int)getType:(int)column;
- (char *)getValue;
- (char *)getValue:(int)row column:(int)column;
- (BOOL)getIsNull;
- (BOOL)getIsNull:(int)row column:(int)column;
- (BOOL)getIsBinary;
- (BOOL)getIsBinary:(int)column;
- (BOOL)isOK;

- (void)printResult;

@end
