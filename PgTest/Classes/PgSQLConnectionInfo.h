//
//  PgSQLConnectionInfo.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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

@end
