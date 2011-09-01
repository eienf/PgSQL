//
//  PgSQLStatement.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLCommand.h"

@interface PgSQLWhereCommand : PgSQLCommand
{
    NSString *whereStatement_;
}
@property(nonatomic,copy,readwrite) NSString *whereStatement;

@end
