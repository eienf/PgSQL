//
//  PgSQLContext.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLContext.h"
#import "PgSQLTransaction.h"
#import "PgSQLInsert.h"
#import "PgSQLUpdate.h"
#import "PgSQLDelete.h"

@implementation PgSQLContext

@synthesize allObjects;
@synthesize deletedObjects;
@synthesize connection;

- (id)init
{
	self = [super init];
	if ( self ) {
		self.allObjects = [NSMutableArray array];
		self.deletedObjects = [NSMutableArray array];
		insertedSet = [[NSMutableIndexSet alloc] init];
		updatedSet = [[NSMutableIndexSet alloc] init];
	}
	return self;
}

- (void)dealloc
{
	self.connection = nil;
	self.allObjects = nil;
	self.deletedObjects = nil;
	[insertedSet release];
	[updatedSet release];
	[super dealloc];
}

- (void)clear
{
	self.allObjects = [NSMutableArray array];
	self.deletedObjects = [NSMutableArray array];
	[insertedSet removeAllIndexes];
	[updatedSet removeAllIndexes];
}

- (BOOL)saveChanges
{
	NSArray *insertCommands = [PgSQLInsert insertCommandsFrom:[self insertedObjects]
												  connection:connection];
	NSArray *updatedCommands = [PgSQLUpdate updateCommandsFrom:[self updatedObjects]
												  connection:connection];
	NSArray *deletedCommands = [PgSQLDelete deleteCommandsFrom:[self deletedObjects]
												  connection:connection];
	PgSQLTransaction *aTransaction = [PgSQLTransaction transactionWith:insertCommands
															connection:connection];
	[aTransaction appendCommands:updatedCommands];
	[aTransaction appendCommands:deletedCommands];
	BOOL flag = [aTransaction run];
	if ( flag ) {
		self.deletedObjects = [NSMutableArray array];
		[insertedSet removeAllIndexes];
		[updatedSet removeAllIndexes];
	}
	return flag;
}

- (NSArray*)insertedObjects
{
	return [allObjects objectsAtIndexes:insertedSet];
}

- (NSArray*)updatedObjects
{
	return [allObjects objectsAtIndexes:updatedSet];
}

- (NSIndexSet*)addNotCountainedObjects:(NSArray*)anArray
{
	NSInteger count = [anArray count];
	NSMutableArray *shouldInsert = [NSMutableArray arrayWithCapacity:count];
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	[anArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
		NSUInteger index = [allObjects indexOfObject:obj];
		if ( index == NSNotFound ) {
			[shouldInsert addObject:obj];
			[indexSet addIndex:count + idx];
		} else {
			[indexSet addIndex:index];
		}
	}];
	[allObjects addObjectsFromArray:shouldInsert];
	return indexSet;
}

- (void)addFetchedObjects:(NSArray*)anArray
{
	[self addNotCountainedObjects:anArray];
}

- (void)addUpdatedObjects:(NSArray*)anArray
{
	NSIndexSet *indexSet = [self addNotCountainedObjects:anArray];
	[indexSet enumerateIndexesUsingBlock:^(NSUInteger idx,BOOL *stop){
		if ( ![insertedSet containsIndex:idx] ) {
			[updatedSet addIndex:idx];
		}
	}];
}

- (void)addInsertedObjects:(NSArray*)anArray
{
	NSIndexSet *indexSet = [self addNotCountainedObjects:anArray];
	[insertedSet addIndexes:indexSet];
}

- (void)addDeletedObjects:(NSArray*)anArray
{
	NSInteger count = [anArray count];
	NSMutableArray *shouldInsert = [NSMutableArray arrayWithCapacity:count];
	[anArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
		NSUInteger index = [deletedObjects indexOfObject:obj];
		if ( index == NSNotFound ) {
			[shouldInsert addObject:obj];
		}
		index = [allObjects indexOfObject:obj];
		if ( index != NSNotFound ) {
			[allObjects removeObjectAtIndex:index];
		}
	}];
	[deletedObjects addObjectsFromArray:shouldInsert];
}

- (void)addFetchedObject:(PgSQLRecord*)anObject
{
	NSUInteger index = [allObjects indexOfObject:anObject];
	if ( index == NSNotFound ) {
		[allObjects addObject:anObject];
	}
}

- (NSUInteger)addNotCountainedObject:(PgSQLRecord*)anObject
{
	NSUInteger index = [allObjects indexOfObject:anObject];
	if ( index == NSNotFound ) {
		[allObjects addObject:anObject];
		return [allObjects count]-1;
	} else {
		return index;
	}
}

- (void)addUpdatedObject:(PgSQLRecord*)anObject
{
	NSUInteger index = [self addNotCountainedObject:anObject];
	if ( ![insertedSet containsIndex:index] ) {
		[updatedSet addIndex:index];
	}
}

- (void)addInsertedObject:(PgSQLRecord*)anObject
{
	NSUInteger index = [self addNotCountainedObject:anObject];
	[insertedSet addIndex:index];
}

- (void)addDeletedObject:(PgSQLRecord*)anObject
{
	NSUInteger index = [deletedObjects indexOfObject:anObject];
	if ( index == NSNotFound ) {
		[deletedObjects addObject:anObject];
	}
	index = [allObjects indexOfObject:anObject];
	if ( index != NSNotFound ) {
		[allObjects removeObjectAtIndex:index];
	}
}

- (void)removeUpdatedObject:(PgSQLRecord *)anObject
{
	NSUInteger index = [allObjects indexOfObject:anObject];
	if ( index == NSNotFound ) {
        return;
	}
	if ( [updatedSet containsIndex:index] ) {
		[updatedSet removeIndex:index];
	}
}

@end
