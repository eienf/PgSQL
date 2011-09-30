//
//  Author.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/09/03.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "Author.h"
#import "Comic.h"
#import "TestDB.h"
#import "PgSQLQuery.h"

@implementation Author

@synthesize toComics = toComics_;

- (id)init {
    self = [super init];
    if (self) {
        self.tableName = @"author";
        self.pkeyName = @"author_id";
    }
    return self;
}

- (void)dealloc {
    self.toComics = nil;
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

- (NSNumber*)primaryKey
{
    return [NSNumber numberWithLongLong:[self authorId]];
}

- (NSArray*)toComics
{
    if ( toComics_ == nil ) {
        self.toComics = [[[self toManyRelationships:@"comic"
                                         withFkey:@"author_id"
                                         forClass:[Comic class]
                                          forPkey:@"author_id"
                                       connection:[[TestDB testDB] connection]
                           ] mutableCopy] autorelease];
    }
    return toComics_;
}

- (void)addObjectToComics:(Comic*)anObject
{
    anObject.authorId = self.authorId;
    [self.toComics addObject:anObject];
}

- (void)removeObjectFromToComics:(Comic*)anObject
{
    anObject.authorId = 0;
    [self.toComics removeObject:anObject];
}

- (int)authorId
{
    return [self int32ForColumnName:@"author_id"];
}

- (void)setAuthorId:(int)authorId
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
            int val = (int)[object integerValue];
            [self setAuthorId:val];
        }
    }
}

+ (Author*)authorWithName:(NSString*)aName andId:(int32_t)anId
{
    Author *newObject = [[Author alloc] init];
    [newObject setAuthorId:anId];
    [newObject setName:aName];
    newObject.oldValues = nil;
    return [newObject autorelease];
}


@end
