//
//  PgSQLRelationship.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PgSQLRecord.h"

@interface PgSQLRelationship : NSObject
{
    NSString *toOneName;
    NSString *toManyName;
    NSString *masterTableName;
    NSString *detailTableName;
    NSString *pkeyName;
    NSString *fkeyName;
    PgSQLRecord *master;
    NSMutableArray *details;
}

@end
