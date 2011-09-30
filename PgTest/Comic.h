//
//  Comic.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/03.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLRecord.h"
#import "Author.h"

@interface Comic : PgSQLRecord
{
    Author *tmpAuthor_;
}
@property(nonatomic,assign,readwrite) int comicId;
@property(nonatomic,assign,readwrite) int authorId;
@property(nonatomic,assign,readwrite) NSString *title;
@property(nonatomic,retain,readwrite) Author *author;
@property(nonatomic,retain,readwrite) Author *tmpAuthor;

+ (NSArray*)loadAllObjects;
+ (NSArray*)relationshipNames;
+ (Comic*)comicWithTitle:(NSString*)aName authorId:(int32_t)authorId andId:(int32_t)anId;


@end
