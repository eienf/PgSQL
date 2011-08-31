//
//  PgSQLUpdate.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLStatement.h"
#import "PgSQLRecord.h"

@interface PgSQLUpdate : PgSQLStatement
{
    PgSQLRecord *record_;
}
@property(nonatomic,retain,readwrite) PgSQLRecord *record;


@end
