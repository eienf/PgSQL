//
//  PgSQLValue.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLValue.h"
#import "PgSQLCoder.h"

@implementation PgSQLValue

@synthesize value = value_;
@synthesize type = type_;

- (void)dealloc {
    self.value = nil;
    [super dealloc];
}

- (id)initWithBinary:(const char *)val type:(Oid)type
{
    self = [super init];
    if (self) {
        self.value = [PgSQLCoder decodeBinary:val type:type];
        if ( self.value != nil ) {
            self.type = type;
        } else {
            self.type = INVALID_OID;
        }
    }
    return self;
}

- (id)initWithObject:(id)val type:(Oid)type
{
    self = [super init];
    if (self) {
        [self setObject:val type:type];
    }
    return self;
}

+ (PgSQLValue*)valueWithBinary:(const char *)val type:(Oid)type
{
    PgSQLValue *aValue = [[PgSQLValue alloc] initWithBinary:val type:type];
    return [aValue autorelease];
}

+ (PgSQLValue*)valueWithObject:(id)val type:(Oid)type
{
    PgSQLValue *aValue = [[PgSQLValue alloc] initWithObject:val type:type];
    return [aValue autorelease];
}

- (void)setObject:(id)val type:(Oid)type
{
    if ( [val isKindOfClass:[NSNumber class]] ||
        [val isKindOfClass:[NSString class]] ||
        [val isKindOfClass:[NSDate class]] ) {
        self.value = val;
        self.type = type;
    } else {
        self.type = INVALID_OID;
        self.value = nil;
    }
}


- (size_t)getBinarySize
{
    switch (type_) {
        case BOOLOID:   // NSNumber
            return 1;
        case INT2OID:   // NSNumber
            return 2;
        case INT4OID:   // NSNumber
        case FLOAT4OID: // NSNumber
        case DATEOID:   // NSDate
            return 4;
        case INT8OID:   // NSNumber
        case FLOAT8OID: // NSNumber
        case TIMEOID:      // NSDate
        case TIMESTAMPOID:      // NSDate
        case TIMESTAMPTZOID:    // NSDate
            return 8; 
        case VARCHAROID:    // NSString
        case TEXTOID:       // NSString
        default:
            return -1;
    }
}

- (size_t)getBufferSize
{
    switch (type_) {
        case VARCHAROID: case TEXTOID:
            return [(NSString*)value_ lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    }
    return [self getBinarySize];
}

- (size_t)getBinary:(char *)buff maxSize:(size_t)size;
{
    size_t aSize = [self getBufferSize];
    if ( aSize > size ) return 0;
    [PgSQLCoder encodeValue:value_ type:type_ intoBuffer:buff maxSize:size];
    return aSize;
}

- (id)objectValue
{
    return self.value;
}

- (char *)cStringValue // must free
{
    NSString *aString = [self stringValue];
    size_t size = [aString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char *buff = malloc(size+1);
    BOOL result = [aString getCString:buff maxLength:size+1 encoding:NSUTF8StringEncoding];
    if ( result ) return buff;
    free(buff);
    return NULL;
}

- (BOOL)boolValue
{
    if ( type_ == BOOLOID ) return [(NSNumber*)value_ boolValue];
    return NO;
}
     

- (int32_t)intValue
{
    if ( [value_ isKindOfClass:[NSNumber class]] ) return [value_ intValue];
    return 0;
}

- (int64_t)longLongValue
{
    if ( [value_ isKindOfClass:[NSNumber class]] ) return [value_ longLongValue];
    return 0;
}

- (float)floatValue
{
    if ( [value_ isKindOfClass:[NSNumber class]] ) return [value_ floatValue];
    return 0.0f;
}

- (double)doubleValue
{
    if ( [value_ isKindOfClass:[NSNumber class]] ) return [value_ doubleValue];
    return 0.0;
}

- (time_t)timetValue
{
    if ( [value_ isKindOfClass:[NSDate class]] ) {
        NSLog(@"%s %f",__func__,[value_ timeIntervalSince1970]);
        return (time_t)[value_ timeIntervalSince1970];
    }
    return 0;
}

- (NSDate*)dateValue
{
    if ( [value_ isKindOfClass:[NSDate class]] ) {
        return value_;
    }
    return nil;
}

- (NSString*)stringValue
{
    if ( [value_ isKindOfClass:[NSDate class]] ) {
        return [value_ description];
    }
    if ( [value_ isKindOfClass:[NSString class]] ) {
        return value_;
    }
    return [value_ stringValue];
}

- (void)setBoolValue:(BOOL)val
{
    self.value = [NSNumber numberWithBool:val];
    self.type = BOOLOID;
}

- (void)setByteValue:(int8_t)val
{
    self.value = [NSNumber numberWithChar:val];
    self.type = INVALID_OID;
}

- (void)setShortValue:(int16_t)val
{
    self.value = [NSNumber numberWithShort:val];
    self.type = INT2OID;
}

- (void)setIntValue:(int32_t)val
{
    self.value = [NSNumber numberWithInt:val];
    self.type = INT4OID;
}

- (void)setLongLongValue:(int64_t)val
{
    self.value = [NSNumber numberWithLongLong:val];
    self.type = INT8OID;
}

- (void)setFloatValue:(float)val
{
    self.value = [NSNumber numberWithFloat:val];
    self.type = FLOAT4OID; 
}

- (void)setDoubleValue:(double)val
{
    self.value = [NSNumber numberWithDouble:val];
    self.type = FLOAT8OID; 
}

- (void)setDate:(NSDate*)aDate
{
    self.value = aDate;
    self.type = TIMESTAMPOID;
}

- (void)setTime:(NSDate*)aDate
{
    self.value = aDate;
    self.type = TIMEOID;
}

- (void)setTimestamp:(NSDate*)aDate
{
    self.value = aDate;
    self.type = TIMESTAMPOID;
}

- (void)setTimestampTZ:(NSDate*)aDate
{
    self.value = aDate;
    self.type = TIMESTAMPTZOID;
}

- (void)setString:(NSString*)aString
{
    self.value = [aString copy];
    self.type = VARCHAROID;
}

- (void)setText:(NSString*)aString
{
    self.value = [aString copy];
    self.type = TEXTOID;
}

- (void)setData:(NSData*)object
{
}

- (NSData*)dataValue
{
    return nil;
}

- (NSString*)oidName
{
    switch (type_) {
        case BOOLOID:
            return @"BOOL";
        case INT2OID:
            return @"INT2";
        case INT4OID:
            return @"INT4";
        case FLOAT4OID:
            return @"FLOAT4";
        case DATEOID:
            return @"DATE";
        case INT8OID:
            return @"INT8";
        case FLOAT8OID:
            return @"FLOAT8";
        case TIMEOID:
            return @"TIME";
        case TIMESTAMPOID:
            return @"TIMESTAMP";
        case TIMESTAMPTZOID:
            return @"TIMESTAMPTZ";
        case VARCHAROID:
            return @"VARCHAR";
        case TEXTOID:
            return @"TEXT";
        default:
            return @"unknown";
    }
}

- (BOOL)isNullValue
{
    return (value_ == nil) || (value_ == [NSNull null]);
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@> %@:%@",[self className],[self oidName],self.value];
}

@end
