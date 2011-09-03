//
//  Author.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/09/03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Author.h"
#import "Comic.h"
#import "TestDB.h"
#import "PgSQLQuery.h"

@interface Author ()
@property(nonatomic,retain,readwrite) NSMutableArray *toComics_;
@end

@implementation Author

@synthesize toComics_;

- (id)init {
    self = [super init];
    if (self) {
        self.tableName = @"author";
        self.pkeyName = @"author_id";
    }
    return self;
}

- (void)dealloc {
    self.toComics_ = nil;
    [super dealloc];
}

+ (NSArray*)loadAllObjects
{
    PgSQLQuery *aQuery = [PgSQLQuery queryWithTable:@"author"
                                              where:nil
                                           forClass:[self class]
                                            orderBy:nil
                                         connection:[[TestDB testDB] connection]];
    return [aQuery queryRecords];
}


- (NSArray*)toComics
{
    if ( toComics_ == nil ) {
        self.toComics_ = [[self toManyRelationships:@"comic"
                                         withFkey:@"author_id"
                                         forClass:[Comic class]
                                          forPkey:@"author_id"
                                       connection:[[TestDB testDB] connection]
                           ] mutableCopy];
    }
    return toComics_;
}

- (void)addObjectToComics:(Comic*)anObject
{
    anObject.authorId = self.authorId;
    [self.toComics_ addObject:anObject];
}

- (void)removeObjectFromToComics:(Comic*)anObject
{
    anObject.authorId = 0;
    [self.toComics_ removeObject:anObject];
}

- (NSInteger)authorId
{
    return [self int32ForColumnName:@"author_id"];
}

- (void)setAuthorId:(NSInteger)authorId
{
    [self setInt32:authorId forColumnName:@"author_id"];
}

- (NSString*)name
{
    return [self varcharForColumnName:@"name"];
}

- (void)setName:(NSString *)name
{
    [self setVarchar:name forColumnName:@"name"];
}

+ (NSArray*)relationshipNames
{
    return [NSArray arrayWithObjects:@"toComics", nil];
}

- (void)setObject:(id)object forColumnName:(NSString *)columnName
{
    if ( [columnName isEqualToString:@"name"] ) {
        if ( [object isKindOfClass:[NSString class]] ) {
            [self setName:object];
        }
    } else if ( [columnName isEqualToString:@"author_id"] ) {
        if ( [object isKindOfClass:[NSString class]] ||
            [object isKindOfClass:[NSNumber class]] ) {
            NSInteger val = [object integerValue];
            [self setAuthorId:val];
        }
    }
}

@end
