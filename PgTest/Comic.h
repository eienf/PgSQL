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
@property(nonatomic,assign,readwrite) NSString *name;
@property(nonatomic,assign,readwrite) Author *author;

@end
