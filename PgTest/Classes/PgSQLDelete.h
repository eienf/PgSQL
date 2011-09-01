//
//  PgSQLDelete.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLWhereCommand.h"

@interface PgSQLDelete : PgSQLWhereCommand
{
    NSArray *records_;
}
@property(nonatomic,retain,readwrite) NSArray *records;

@end
