//
//  PgSQLSingleCommand.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/01.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLCommand.h"
#import "PgSQLRecord.h"

@interface PgSQLSingleCommand : PgSQLCommand
{
    PgSQLRecord *record_;
}
@property(nonatomic,retain,readwrite) PgSQLRecord *record;

@end
