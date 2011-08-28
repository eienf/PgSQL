//
//  PgSQLCoder.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "libpq-fe.h"

@interface PgSQLCoder : NSObject

+ (id)decodeBinary:(const char *)binary type:(Oid)type;
+ (const char *)encodeValue:(id)value type:(Oid)type;

@end
