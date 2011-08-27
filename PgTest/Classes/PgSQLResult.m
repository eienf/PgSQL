//
//  PgSQLResult.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLResult.h"

@implementation PgSQLResult

@synthesize numOfTuples = numOfTuples_;
@synthesize numOfFields = numOfFields_;
@synthesize currentRow = currentRow_;
@synthesize currentField = currentField_;

- (void)dealloc
{
    [self clear];
    [super dealloc];
}

+ (id)resultWithResult:(PGresult*)res
{
    PgSQLResult *aResult = [[PgSQLResult alloc] init];
    [aResult setResult:res];
    return [aResult autorelease];
}


- (void)setResult:(PGresult*)res
{
    result_ = res;
    numOfTuples_ = PQntuples(result_);
    numOfFields_ = PQnfields(result_);
    currentRow_ = 0;
    currentField_ = 0;
}

- (void)clear
{
    if ( result_ ) {
        PQclear(result_);
        result_ = NULL;
    }
}

- (int)resultStatus
{
    return PQresultStatus(result_);
}

- (NSString*)resultMessage
{
    return [NSString stringWithCString:PQresultErrorMessage(result_)
                              encoding:NSUTF8StringEncoding];
}

- (BOOL)firstRow
{
    if ( numOfTuples_ > 0 ) {
        currentRow_ = 0;
        currentField_ = 0;
        return YES;
    }
    return NO;
}

- (BOOL)nextRow
{
    currentRow_ ++;
    currentField_ = 0;
    if ( currentRow_ < numOfTuples_ ) {
        return YES;
    }
    return NO;
}

- (BOOL)hasNextRow
{
    if ( currentRow_ + 1 < numOfTuples_ ) {
        return YES;
    }
    return NO;
}

- (BOOL)nextField
{
    currentField_ ++;
    if ( currentField_ < numOfFields_ ) {
        return YES;
    }
    return NO;
}

- (BOOL)hasNexField
{
    if ( currentField_ + 1 < numOfFields_ ) {
        return YES;
    }
    return NO;
}

- (char *)getValue
{
    return PQgetvalue(result_, currentRow_, currentField_);
}

- (char *)getValue:(int)row column:(int)column
{
    return PQgetvalue(result_, row, column);
}


@end
