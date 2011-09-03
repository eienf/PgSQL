//
//  PgSQLConnectionInfo.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PgSQLConnectionInfo : NSObject
{
    NSString *hostname_;
    NSString *port_;
    NSString *dbname_;
    NSString *username_;
    NSString *password_;
}
@property(nonatomic,copy,readwrite) NSString *hostname;
@property(nonatomic,copy,readwrite) NSString *port;
@property(nonatomic,copy,readwrite) NSString *dbname;
@property(nonatomic,copy,readwrite) NSString *username;
@property(nonatomic,copy,readwrite) NSString *password;

- (id)initWithURL:(NSURL*)aUrl;
+ (PgSQLConnectionInfo*)connectionInfoWithURL:(NSURL*)aUrl;

- (const char *)cHostname:(char *)buff lenght:(size_t)length;
- (const char *)cPort:(char *)buff lenght:(size_t)length;
- (const char *)cDbname:(char *)buff lenght:(size_t)length;
- (const char *)cUsername:(char *)buff lenght:(size_t)length;
- (const char *)cPassword:(char *)buff lenght:(size_t)length;

@end
