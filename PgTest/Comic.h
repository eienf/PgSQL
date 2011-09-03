//
//  Comic.h
//  PgTest
//
//  Created by 黒木 政幸 on 11/09/03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLRecord.h"
#import "Author.h"

@interface Comic : PgSQLRecord
{
    Author *author_;
}
@property(nonatomic,assign,readwrite) NSInteger comicId;
@property(nonatomic,assign,readwrite) NSInteger authorId;
@property(nonatomic,assign,readwrite) NSString *title;
@property(nonatomic,assign,readwrite) Author *author;

+ (NSArray*)loadAllObjects;
+ (NSArray*)relationshipNames;
+ (Comic*)comicWithTitle:(NSString*)aName authorId:(NSInteger)authorId andId:(NSInteger)anId;


@end
