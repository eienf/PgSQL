//
//  PgSQLStatement.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLCommand.h"

@interface PgSQLWhereCommand : PgSQLCommand
{
    NSString *whereStatement_;
}
@property(nonatomic,copy,readwrite) NSString *whereStatement;

@end
