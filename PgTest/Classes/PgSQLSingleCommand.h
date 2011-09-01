//
//  PgSQLSingleCommand.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/09/01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLCommand.h"
#import "PgSQLRecord.h"

@interface PgSQLSingleCommand : PgSQLCommand
{
    PgSQLRecord *record_;
}
@property(nonatomic,retain,readwrite) PgSQLRecord *record;

@end
