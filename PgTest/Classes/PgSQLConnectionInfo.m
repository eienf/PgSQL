//
//  PgSQLConnectionInfo.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLConnectionInfo.h"

@interface PgSQLConnectionInfo ()
- (void)parseProperty:(NSDictionary*)aDict;
@end

@implementation PgSQLConnectionInfo

@synthesize hostname = hostname_;
@synthesize port = port_;
@synthesize dbname = dbname_;
@synthesize username = username_;
@synthesize password = password_;

- (void)dealloc
{
    self.hostname = nil;
    self.port = nil;
    self.dbname = nil;
    self.username = nil;
    self.password = nil;
    [super dealloc];
}

- (id)initWithURL:(NSURL*)aUrl
{
    self = [super init];
    if ( self ) {
        NSError *error;
        NSData *aData = [NSData dataWithContentsOfURL:aUrl];
        NSDictionary *aDict =
            [NSPropertyListSerialization propertyListWithData:aData
                                                      options:NSPropertyListImmutable
                                                       format:NULL
                                                        error:&error];
        if ( aDict != nil ) {
            [self parseProperty:aDict];
        }
    }
    return self;
}

- (void)parseProperty:(NSDictionary*)aDict
{
    self.hostname = [aDict objectForKey:@"hostname"];
    self.port = [aDict objectForKey:@"port"];
    self.dbname = [aDict objectForKey:@"dbname"];
    self.username = [aDict objectForKey:@"username"];
    self.password = [aDict objectForKey:@"password"];
}

+ (PgSQLConnectionInfo*)connectionInfoWithURL:(NSURL*)aUrl
{
    PgSQLConnectionInfo *anObject = [[PgSQLConnectionInfo alloc] initWithURL:aUrl];
    return [anObject autorelease];
}

@end
