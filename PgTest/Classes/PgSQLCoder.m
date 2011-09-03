//
//  PgSQLCoder.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLCoder.h"
#import "PgSQLValue.h"

static void ntohll(char outval[8], const char* val)
{
#if defined (__LITTLE_ENDIAN__)
    *(uint32_t*)&outval[4] = ntohl(*(uint32_t*)val);
    *(uint32_t*)&outval[0] = ntohl(*(uint32_t*)(val+4));
#else
    memcpy(outval, val, 8)
#endif
}

static void htonll(char outval[8], const char* val)
{
#if defined (__LITTLE_ENDIAN__)
    *(uint32_t*)&outval[4] = htonl(*(uint32_t*)val);
    *(uint32_t*)&outval[0] = htonl(*(uint32_t*)(val+4));
#else
    memcpy(outval, val, 8)
#endif
}

static NSInteger secondsFromGMT_ = 32400;

@implementation PgSQLCoder

+ (void)setSecondsFromGMT:(NSInteger)seconds
{
    secondsFromGMT_ = seconds;
}

+ (NSInteger)secondsFromGMT
{
    return secondsFromGMT_;
}

+ (NSInteger)hoursFromGMT
{
    return secondsFromGMT_ / 3600;
}


+ (id)decodeBinary:(const char *)binary type:(Oid)type
{
    //NULL対応
    if ( binary == NULL ) return nil;
    //
    switch(type){
        case BOOLOID:
        {
            BOOL val = [self decodeBool:binary];
            return [NSNumber numberWithBool:val];
        }
            break;
        case INT2OID:
        {
            int16_t val = [self decodeInt16:binary ];
            return [NSNumber numberWithInt:val];
        }
            break;
        case INT4OID:
        {
            int32_t val = [self decodeInt32:binary ];
            return [NSNumber numberWithInt:val];
        }
            break;
        case INT8OID:
        {
            int64_t val = [self decodeInt64:binary ];
            return [NSNumber numberWithLongLong:val];
        }
            break;
        case FLOAT4OID:
        {
            float val = [self decodeFloat:binary ];
            return [NSNumber numberWithFloat:val];
        }
            break;
        case FLOAT8OID:
        {
            double val = [self decodeDouble:binary ];
            return [NSNumber numberWithDouble:val];
        }
            break;
        case VARCHAROID:
        {
            return [NSString stringWithCString:binary encoding:NSUTF8StringEncoding];
        }
            break;
        case TEXTOID:
        {
            return [NSString stringWithCString:binary encoding:NSUTF8StringEncoding];
        }
            break;
        case DATEOID:
        {
            return [self decodeDate:binary];
        }
            break;
        case TIMEOID:
        {
            return [self decodeTime:binary];
        }
            break;
        case TIMESTAMPOID:
        {
            return [self decodeTimestamp:binary];
        }
            break;
        case TIMESTAMPTZOID:
        {
            return [self decodeTimestampTZ:binary];
        }
            break;
        default:
            NSLog(@"NOT A SUPPORTED TYPE : %d",type);
    }
    return nil; 
}

+ (const char *)encodeValue:(id)value type:(Oid)type intoBuffer:(char *)buff maxSize:(size_t)maxSize
{
    //NULL対応
    if ( buff == NULL || maxSize == 0 ) return NULL;
    //
    switch(type){
        case BOOLOID:
        {
            BOOL val = [value boolValue];
            [self encodeBool:val intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case INT2OID:
        {
            int16_t val = [value shortValue];
            [self encodeInt16:val intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case INT4OID:
        {
            int32_t val = [value longValue];
            [self encodeInt32:val intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case INT8OID:
        {
            int64_t val = [value longLongValue];
            [self encodeInt64:val intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case FLOAT4OID:
        {
            float val = [value floatValue];
            [self encodeFloat:val intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case FLOAT8OID:
        {
            double val = [value doubleValue];
            [self encodeDouble:val intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case VARCHAROID:
        {
            [self encodeVarchar:value intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case TEXTOID:
        {
            [self encodeText:value intoBuffer:buff maxLength:maxSize-1];
            return buff;
        }
            break;
        case DATEOID:
        {
            [self encodeDate:value intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case TIMEOID:
        {
            [self encodeTime:value intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case TIMESTAMPOID:
        {
            [self encodeTimestamp:value intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        case TIMESTAMPTZOID:
        {
            [self encodeTimestampTZ:value intoBuffer:buff maxSize:maxSize];
            return buff;
        }
            break;
        default:
            NSLog(@"NOT A SUPPORTED TYPE : %d",type);
    }
    return nil; 
}


#pragma mark decode

+ (BOOL)decodeBool:(const char *)binary
{
	unsigned char st = *binary;
    return st;
}

+ (int16_t)decodeInt16:(const char *)binary
{
    uint16_t st = ntohs(*(uint16_t*) binary);
    return *(int16_t*)&st;
}

+ (int32_t)decodeInt32:(const char *)binary
{
    uint32_t st = ntohl(*((uint32_t*) binary));
    return *(int32_t*)&st;
}

+ (int64_t)decodeInt64:(const char *)binary
{
    char tmp[8];
    htonll(tmp, binary);
    return *(int64_t*)tmp;
}

+ (float)decodeFloat:(const char *)binary
{
    uint32_t st = ntohl(*(uint32_t*)binary);
    return *(float*)&st;
}

+ (double)decodeDouble:(const char *)binary
{
    char tmp[8];
    htonll(tmp, binary);
    return *(double*)tmp;
}

+ (NSDate*)decodeDate:(const char *)binary
{
    uint32_t st = ntohl(*((uint32_t*) binary));
    struct tm tmp;
    tmp.tm_sec =0;
    tmp.tm_min = 0;
    tmp.tm_hour = 0;
    tmp.tm_mday = st+1;
    tmp.tm_mon = 0;
    tmp.tm_year = 100;
    tmp.tm_isdst = -1;
    time_t t = mktime(&tmp);
    return [NSDate dateWithTimeIntervalSince1970:t];
}

+ (NSDate*)decodeTime:(const char *)binary
{
	int64_t d = [self decodeInt64:binary];
	d /= 1000000;
	//
    struct tm tmp;
    tmp.tm_sec = (int)d;
    tmp.tm_min = 0;
    tmp.tm_hour = 0;
    tmp.tm_mday = 1;
    tmp.tm_mon = 0;
    tmp.tm_year = 100;
    tmp.tm_isdst = -1;
    time_t t = mktime(&tmp);
    return [NSDate dateWithTimeIntervalSince1970:t];
}

+ (NSDate*)decodeTimestamp:(const char *)binary
{
    return [self decodeTime:binary];
}

+ (NSDate*)decodeTimestampTZ:(const char *)binary
{
	int64_t d = [self decodeInt64:binary];
	d /= 1000000;
	//
    struct tm tmp;
    tmp.tm_sec = (int)d;
    tmp.tm_min = 0;
    tmp.tm_hour = 9;
    tmp.tm_mday = 1;
    tmp.tm_mon = 0;
    tmp.tm_year = 100;
    tmp.tm_isdst = -1;
    time_t t = mktime(&tmp);
    return [NSDate dateWithTimeIntervalSince1970:t];
}

+ (NSString*)decodeVarchar:(const char *)binary
{
    return [NSString stringWithCString:binary encoding:NSUTF8StringEncoding];
}

+ (NSString*)decodeText:(const char *)binary
{
    return [NSString stringWithCString:binary encoding:NSUTF8StringEncoding];
}

+ (NSData*)decodeBlob:(const char *)binary size:(size_t)size
{
    return [NSData dataWithBytes:binary length:size];
}


#pragma mark encode

+ (size_t)encodeBool:(BOOL)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    if ( outval == NULL || maxSize < sizeof(unsigned char)) {
        return 0;
    }
    memcpy(outval,(const char *)&invalue,sizeof(unsigned char));
    return sizeof(unsigned char);
}

+ (size_t)encodeInt16:(int16_t)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    if ( outval == NULL || maxSize < sizeof(int16_t)) {
        return 0;
    }
    int16_t st = htons(*(int16_t *)&invalue);
    memcpy(outval,(const char *)&st,sizeof(int16_t));
    return sizeof(int16_t);
}

+ (size_t)encodeInt32:(int32_t)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    if ( outval == NULL || maxSize < sizeof(int32_t)) {
        return 0;
    }
    uint32_t st = htonl(*((uint32_t*)&invalue));
    memcpy(outval,(const char *)&st,sizeof(int32_t));
    return sizeof(int32_t);
}

+ (size_t)encodeInt64:(int64_t)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    if ( outval == NULL || maxSize < sizeof(int64_t)) {
        return 0;
    }
    char tmp[8];
    htonll(tmp, (const char *)&invalue);
    memcpy(outval,(const char *)tmp,8);
    return 8;
}

+ (size_t)encodeFloat:(float)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    if ( outval == NULL || maxSize < sizeof(float)) {
        return 0;
    }
    uint32_t st = htonl(*((uint32_t*)&invalue));
    memcpy(outval,(const char *)&st,sizeof(float));
    return sizeof(float);
}

+ (size_t)encodeDouble:(double)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    if ( outval == NULL || maxSize < sizeof(double)) {
        return 0;
    }
    char tmp[8];
    htonll(tmp, (const char *)&invalue);
    memcpy(outval,(const char *)tmp,8);
    return 8;    
}

+ (size_t)encodeDate:(NSDate*)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    int32_t st;
    NSTimeInterval timei = [invalue timeIntervalSince1970];
    st = (int32_t)timei - (946684800 - 32400);// time_t:1970-, pg:2000- JST
    st = st / (3600 * 24);// seconds -> days
    printf("%s %d\n",__func__,st);
    return [self encodeInt32:st intoBuffer:outval maxSize:maxSize];
}

+ (size_t)encodeTime:(NSDate*)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    int64_t st;
    NSTimeInterval timei = [invalue timeIntervalSince1970];
    st = timei - (946684800 - 32400);// time_t:1970-, pg:2000- JST
    st *= 1000000LL;
    printf("%s %lld\n",__func__,st);
    return [self encodeInt64:st intoBuffer:outval maxSize:maxSize];
}

+ (size_t)encodeTimestamp:(NSDate*)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    return [self encodeTime:invalue intoBuffer:outval maxSize:maxSize];
}

+ (size_t)encodeTimestampTZ:(NSDate*)invalue intoBuffer:(char *)outval maxSize:(size_t)maxSize
{
    int64_t st;
    NSTimeInterval timei = [invalue timeIntervalSince1970];
    st = timei - (946684800);// time_t:1970-, pg:2000- JST
    st *= 1000000LL;
    printf("%s %lld\n",__func__,st);
    return [self encodeInt64:st intoBuffer:outval maxSize:maxSize];
}

+ (size_t)encodeVarchar:(NSString*)invalue intoBuffer:(char *)outval maxSize:(size_t)size
{
    size_t aSize = [invalue lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [invalue getCString:outval maxLength:size encoding:NSUTF8StringEncoding];
    if ( aSize > size ) aSize = size;
    return aSize;
}

+ (size_t)encodeText:(NSString*)invalue intoBuffer:(char *)outval maxLength:(size_t)size
{
    return [self encodeVarchar:invalue intoBuffer:outval maxSize:size];
}

+ (size_t)encodeBlob:(NSData*)invalue intoBuffer:(char *)outval maxSize:(size_t)size
{
    size_t aSize = [invalue length];
    [invalue getBytes:outval length:size];
    if ( aSize > size ) aSize = size;
    return aSize;
}


@end
