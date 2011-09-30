//
//  Comic.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/03.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "Comic.h"
#import "TestDB.h"
#import "PgSQLQuery.h"

@implementation Comic

@synthesize tmpAuthor = tmpAuthor_;

- (id)init {
    self = [super init];
    if (self) {
        self.tableName = @"comic";
        self.pkeyName = @"comic_id";
    }
    return self;
}

- (void)dealloc {
    self.tmpAuthor = nil;
    [super dealloc];
}

+ (NSArray*)loadAllObjects
{
    PgSQLQuery *aQuery = [PgSQLQuery queryWithTable:@"comic"
                                              where:nil
                                           forClass:[self class]
                                            orderBy:nil
                                         connection:[[TestDB testDB] connection]];
    return [aQuery queryRecords];
}

- (NSNumber*)primaryKey
{
    return [NSNumber numberWithLongLong:[self comicId]];
}

- (int)comicId
{
    return [self int32ForColumnName:@"comic_id"];
}

- (void)setComicId:(int)value
{
    [self setInt32:value forColumnName:@"comic_id"];
}

- (Author*)author
{
    if ( tmpAuthor_ == nil ) {
        self.tmpAuthor = (Author*)[self toOneRelationship:@"author"
                                     withPkey:@"author_id"
                                     forClass:[Author class]
                                      forFkey:@"author_id"
                                        connection:[[TestDB testDB] connection]];
    }
    return self.tmpAuthor;
}

- (void)setAuthor:(Author *)author
{
    if ( tmpAuthor_ && ![tmpAuthor_ isEqualTo:author]) {
        [tmpAuthor_ removeObjectFromToComics:self];
    }
    self.tmpAuthor = author;
    [author addObjectToComics:self];
}

- (int)authorId
{
    return [self int32ForColumnName:@"author_id"];
}

- (void)setAuthorId:(int)authorId
{
    [self setInt32:authorId forColumnName:@"author_id"];
}

- (NSString*)title
{
    return [self varcharForColumnName:@"title"];
}

- (void)setTitle:(NSString *)title
{
    [self setVarchar:title forColumnName:@"title"];
}

+ (NSArray*)relationshipNames
{
    return [NSArray arrayWithObjects:@"author", nil];
}

- (void)setObject:(id)object forColumnName:(NSString *)columnName
{
    if ( [columnName isEqualToString:@"title"] ) {
        if ( [object isKindOfClass:[NSString class]] ) {
            [self setTitle:object];
        }
    } else if ( [columnName isEqualToString:@"author_id"] ) {
        if ( [object isKindOfClass:[NSString class]] ||
            [object isKindOfClass:[NSNumber class]] ) {
            int val = (int)[object integerValue];
            [self setAuthorId:val];
        }
    } else if ( [columnName isEqualToString:@"comic_id"] ) {
        if ( [object isKindOfClass:[NSString class]] ||
            [object isKindOfClass:[NSNumber class]] ) {
            int val = (int)[object integerValue];
            [self setComicId:val];
        }
    }
}

+ (Comic*)comicWithTitle:(NSString*)aName authorId:(int32_t)authorId andId:(int32_t)anId
{
    Comic *newObject = [[Comic alloc] init];
    [newObject setComicId:anId];
    [newObject setAuthorId:authorId];
    [newObject setTitle:aName];
    newObject.oldValues = nil;
    return [newObject autorelease];
}

@end
