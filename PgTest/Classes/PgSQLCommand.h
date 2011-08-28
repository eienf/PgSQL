//
//  PgSQLCommand.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libpq-fe.h"

#import "PgSQLResult.h"
#import "PgSQLConnection.h"

@interface PgSQLCommand : NSObject
{
    
}

+ (PgSQLResult*)executeString:(NSString*)aString connection:(PgSQLConnection*)conn;

@end
