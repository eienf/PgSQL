//
//  PgSQLContext.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PgSQLRecord.h"

@interface PgSQLContext : NSObject {
	NSMutableArray *allObjects;
	NSMutableArray *deletedObjects;
	NSMutableIndexSet *insertedSet;
	NSMutableIndexSet *updatedSet;
}
@property(nonatomic,retain,readwrite) NSMutableArray *allObjects;
@property(nonatomic,retain,readwrite) NSMutableArray *deletedObjects;
@property(nonatomic,retain,readonly) NSArray *insertedObjects;
@property(nonatomic,retain,readonly) NSArray *updatedObjects;

- (void)addFetchedObjects:(NSArray*)anArray;
- (void)addUpdatedObjects:(NSArray*)anArray;
- (void)addInsertedObjects:(NSArray*)anArray;
- (void)addDeletedObjects:(NSArray*)anArray;
- (void)addFetchedObject:(PgSQLRecord*)anObject;
- (void)addUpdatedObject:(PgSQLRecord*)anObject;
- (void)addInsertedObject:(PgSQLRecord*)anObject;
- (void)addDeletedObject:(PgSQLRecord*)anObject;

- (void)clear;
- (BOOL)saveChanges;

@end
