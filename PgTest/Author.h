//
//  Author.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/03.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLRecord.h"

@class Comic;

@interface Author : PgSQLRecord
{
    NSMutableArray *toComics_;
}
@property(nonatomic,assign,readwrite) NSInteger authorId;
@property(nonatomic,assign,readwrite) NSString *name;
@property(nonatomic,assign,readonly) NSArray *toComics;

- (void)addObjectToComics:(Comic*)anObject;
- (void)removeObjectFromToComics:(Comic*)anObject;
+ (NSArray*)loadAllObjects;
+ (NSArray*)relationshipNames;
+ (Author*)authorWithName:(NSString*)aName andId:(NSInteger)anId;
   
@end
