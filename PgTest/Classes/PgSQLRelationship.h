//
//  PgSQLRelationship.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
