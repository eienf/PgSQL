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
+ (const char *)encodeValue:(id)value type:(Oid)type intoBuffer:(char *)buff maxSize:(size_t)maxSize;

+ (BOOL)decodeBool:(const char *)binary;
+ (int16_t)decodeInt16:(const char *)binary;
+ (int32_t)decodeInt32:(const char *)binary;
+ (int64_t)decodeInt64:(const char *)binary;
+ (float)decodeFloat:(const char *)binary;
+ (double)decodeDouble:(const char *)binary;
+ (NSDate*)decodeDate:(const char *)binary;
+ (NSDate*)decodeTime:(const char *)binary;
+ (NSDate*)decodeTimestamp:(const char *)binary;
+ (NSDate*)decodeTimestampTZ:(const char *)binary;
+ (NSString*)decodeVarchar:(const char *)binary;
+ (NSString*)decodeText:(const char *)binary;
+ (NSData*)decodeBlob:(const char *)binary size:(size_t)size;

+ (size_t)encodeBool:(BOOL)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeInt16:(int16_t)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeInt32:(int32_t)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeInt64:(int64_t)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeFloat:(float)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeDouble:(double)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeDate:(NSDate*)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeTime:(NSDate*)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeTimestamp:(NSDate*)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeTimestampTZ:(NSDate*)val intoBuffer:(char *)buff maxSize:(size_t)maxSize;
+ (size_t)encodeVarchar:(NSString*)invalue intoBuffer:(char *)outval maxLength:(size_t)size;
+ (size_t)encodeText:(NSString*)invalue intoBuffer:(char *)outval maxLength:(size_t)size;
+ (size_t)encodeBlob:(NSData*)invalue intoBuffer:(char *)outval maxSize:(size_t)size;


@end
