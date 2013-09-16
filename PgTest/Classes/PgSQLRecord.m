//
//  PgSQLRecord.m
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import "PgSQLRecord.h"
#import "PgSQLValue.h"
#import "PgSQLQuery.h"

@implementation PgSQLRecord

@synthesize attributes = attributes_;// PgSQLValue
@synthesize oldValues = oldValues_;// PgSQLValue
@synthesize changedNames = changedNames_;
@synthesize tableName = tableName_;
@synthesize pkeyName = pkeyName_;
@synthesize pkeySequenceName = pkeySequenceName_;
@synthesize registeredObjects = registeredObjects_;

- (void)dealloc {
    self.changedNames = nil;
    self.attributes = nil;
    self.oldValues = nil;
    self.tableName = nil;
    self.pkeyName = nil;
    self.pkeySequenceName = nil;
    self.registeredObjects = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.attributes = [NSMutableDictionary dictionary];
        self.registeredObjects = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isTemp
{
    if ( [self.pkeyName length] == 0 ) return NO;
    PgSQLValue *aValue = [self valueforColumnName:self.pkeyName];
    if ( aValue == nil || [aValue isNullValue] ) return YES;
    return NO;
}

- (BOOL)isDirty
{
    return [self.oldValues count] > 0;
}

- (BOOL)isEqualTo:(id)object
{
    if ( [self isTemp] || [object isTemp] ) return NO;
    NSNumber *myPK = [self primaryKey];
    NSNumber *hisPK = [object primaryKey];
    return [myPK isEqualToNumber:hisPK];
}

- (NSNumber*)primaryKey
{
    if ( [self.pkeyName length] == 0 ) return nil;
    PgSQLValue *aValue = [self valueforColumnName:self.pkeyName];
    if ( aValue == nil || [aValue isNullValue] ) return nil;
    return [NSNumber numberWithLongLong:[aValue longLongValue]];
}

- (PgSQLValue*)pkeyValue
{
    return [self valueforColumnName:pkeyName_];
}

#pragma mark Accessor

- (Oid)guessType:(id)object
{
    if ( [object isKindOfClass:[NSString class]] )
    {
        return VARCHAROID;
    }
    if ( [object isKindOfClass:[NSNumber class]] )
    {
        return INT4OID;
    }
    if ( [object isKindOfClass:[NSDate class]] )
    {
        return TIMESTAMPTZOID;
    }
    return INVALID_OID;
}

- (void)setObject:(id)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [attributes_ objectForKey:columnName];
    [self value:aValue willChangeForColumnName:columnName];
    Oid type;
    if ( aValue == nil ) {
        if ( (type = [self guessType:object]) == INVALID_OID ) return;
        aValue = [PgSQLValue valueWithObject:object type:type];
    } else {
        type = aValue.type;
        [aValue setObject:object type:type];
    }
    [attributes_ setObject:aValue forKey:columnName];
    [self value:aValue didChangeForColumnName:columnName];
}

- (id)objectForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [attributes_ objectForKey:columnName];
    return [aValue objectValue];
}

- (PgSQLValue*)valueToChangeforColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [attributes_ objectForKey:columnName];
    [self value:aValue willChangeForColumnName:columnName];
    if ( aValue == nil ) {
        aValue = [[[PgSQLValue alloc] init] autorelease];
    }
    [attributes_ setObject:aValue forKey:columnName];// not needed?
    return aValue;
}

- (PgSQLValue*)valueforColumnName:(NSString*)columnName
{
    return [attributes_ objectForKey:columnName];
}

- (void)setValue:(PgSQLValue*)value forColumnName:(NSString*)columnName
{
    [self value:nil willChangeForColumnName:columnName];
    [attributes_ setObject:value forKey:columnName];
    [self value:value didChangeForColumnName:columnName];
}

- (void)setBinary:(const char *)val ofType:(Oid)type forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [PgSQLValue valueWithBinary:val type:type];
    [self setValue:aValue forColumnName:columnName];
}

- (void)setBOOL:(BOOL)val forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setBoolValue:val];
    [self value:aValue didChangeForColumnName:columnName];
}

- (BOOL)boolForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue boolValue];
}

- (void)setInt16:(int16_t)val forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setShortValue:val];
    [self value:aValue didChangeForColumnName:columnName];
}

- (int16_t)int16ForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return (int16_t)[aValue intValue];
}

- (void)setInt32:(int32_t)val forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setIntValue:val];
    [self value:aValue didChangeForColumnName:columnName];
}

- (int32_t)int32ForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue intValue];
}

- (void)setInt64:(int64_t)val forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setLongLongValue:val];
    [self value:aValue didChangeForColumnName:columnName];
}

- (int64_t)int64ForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue longLongValue];
}

- (void)setFloat:(float)val forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setFloatValue:val];
    [self value:aValue didChangeForColumnName:columnName];
}

- (float)floatForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue floatValue];
}

- (void)setDouble:(double)val forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setDoubleValue:val];
    [self value:aValue didChangeForColumnName:columnName];
}

- (double)doubleForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue doubleValue];
}

- (void)setDate:(NSDate*)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setDate:object];
    [self value:aValue didChangeForColumnName:columnName];
}

- (NSDate*)dateForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue dateValue];
}

- (void)setTime:(NSDate*)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setTime:object];
    [self value:aValue didChangeForColumnName:columnName];
}

- (NSDate*)timeForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue dateValue];
}

- (void)setTimestamp:(NSDate*)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setTimestamp:object];
    [self value:aValue didChangeForColumnName:columnName];
}

- (NSDate*)timestampForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue dateValue];
}

- (void)setTimestampTZ:(NSDate*)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setTimestampTZ:object];
    [self value:aValue didChangeForColumnName:columnName];
}

- (NSDate*)timestampTZForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue dateValue];
}

- (void)setVarchar:(NSString*)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setString:object];
    [self value:aValue didChangeForColumnName:columnName];
}

- (NSString*)varcharForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue stringValue];
}

- (void)setText:(NSString*)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setText:object];
    [self value:aValue didChangeForColumnName:columnName];
}

- (NSString*)textForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue stringValue];
}

- (void)setData:(NSData*)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueToChangeforColumnName:columnName];
    [aValue setData:object];
    [self value:aValue didChangeForColumnName:columnName];
}

- (NSData*)dataForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [self valueforColumnName:columnName];
    return [aValue dataValue];
}


#pragma mark Accessor_Addition

- (void)setString:(NSString*)object forColumnName:(NSString*)columnName
{
    [self setVarchar:object forColumnName:columnName];
}

- (NSString*)stringForColumnName:(NSString*)columnName
{
    NSString *aString = [self varcharForColumnName:columnName];
    if ( aString == nil ) {
        aString = @"";
    }
    return aString;
}

- (void)setNullforColumnName:(NSString*)columnName
{
    [self setObject:nil forColumnName:columnName];
}

- (BOOL)isNullForColumnName:(NSString*)columnName
{
    id object = [self objectForColumnName:columnName];
    return (object==nil)||(object==[NSNull null]);   
}

#pragma mark Relationship

- (PgSQLRecord*)toOneRelationship:(NSString*)tableName 
                         withPkey:(NSString*)pkeyName 
                         forClass:(Class)recordClass 
                          forFkey:(NSString*)fkeyName
                       connection:(PgSQLConnection*)con
{
    NSString *whereString = [NSString stringWithFormat:@"%@ = $1",pkeyName];
	id param = [self valueforColumnName:fkeyName];
	if ( param == nil ) return nil;
    PgSQLQuery *aQuery = [PgSQLQuery queryWithTable:tableName
                                              where:whereString
                                             params:[NSArray arrayWithObject:param]
                                           forClass:recordClass
                                            orderBy:nil
                                         connection:con];
    NSArray *anArray = [aQuery queryRecords];
    if ( [anArray count] == 0 ) return nil;
    return [anArray objectAtIndex:0];
}

- (NSArray*)toManyRelationships:(NSString*)tableName 
                       withFkey:(NSString*)fkeyName 
                       forClass:(Class)recordClass 
                        forPkey:(NSString*)pkeyName
                     connection:(PgSQLConnection*)con
{
    return [self toManyRelationships:tableName
                            withFkey:fkeyName
                            forClass:recordClass
                             forPkey:pkeyName
                           filtering:nil
                             orderBy:pkeyName
                          connection:con];
}

- (NSArray*)toManyRelationships:(NSString*)tableName
                       withFkey:(NSString*)fkeyName
                       forClass:(Class)recordClass
                        forPkey:(NSString*)pkeyName
                      filtering:(NSString*)filtering
                        orderBy:(NSString*)orderBy
                     connection:(PgSQLConnection*)con
{
    NSString *whereString = [NSString stringWithFormat:@"%@ = $1",fkeyName];
    if ( filtering ) {
        whereString = [NSString stringWithFormat:@"(%@) and (%@)",whereString,filtering];
    }
	id param = [self valueforColumnName:pkeyName];
	if ( param == nil ) return [NSArray array];
    PgSQLQuery *aQuery = [PgSQLQuery queryWithTable:tableName
                                              where:whereString
                                             params:[NSArray arrayWithObject:param]
                                           forClass:recordClass
                                            orderBy:orderBy
                                         connection:con];
    return [aQuery queryRecords];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@> %@(%@,%@) \n %@",
            [self className],self.tableName, self.pkeyName, self.pkeySequenceName ,attributes_];
}

- (NSDictionary*)makeDeepCopyAttribute:(NSDictionary*)inDict
{
    NSMutableDictionary *outDict = [NSMutableDictionary dictionaryWithCapacity:[inDict count]];
    for (NSString *aKey in inDict) {
        PgSQLValue *aValue = [inDict objectForKey:aKey];
        PgSQLValue *copiedValue = [[aValue copy] autorelease];
        [outDict setObject:copiedValue forKey:aKey];
    }
    return outDict;
}

- (void)value:(PgSQLValue*)oldValue willChangeForColumnName:(NSString*)columnName
{
    if ( [self.oldValues count] == 0 ) {
        self.oldValues = [self makeDeepCopyAttribute:self.attributes];
    }
    if ( [self.changedNames count] == 0 ) {
        changedNames_ = [[NSMutableSet alloc ] initWithCapacity:[self.attributes count]];
    }
}

- (void)value:(PgSQLValue*)newValue didChangeForColumnName:(NSString*)columnName
{
    [attributes_ setObject:newValue forKey:columnName];
    [self.changedNames addObject:columnName];
}

- (void)relatedValue:(PgSQLRecord*)aRecord willChangeForColumnName:(NSString*)columnName
{
    
}

- (void)relatedValue:(PgSQLRecord*)aRecord didChangeForColumnName:(NSString*)columnName
{
    
}

- (void)revertChanges
{
    self.attributes = [[self.oldValues mutableCopy] autorelease];
    self.oldValues = nil;
    self.changedNames = nil;
}

- (void)didSaveChanges
{
    self.oldValues = nil;
    self.changedNames = nil;
    [self propagateSequenceToObjects];
}

- (void)propagateSequence:(PgSQLRecord*)savedRecord
{
    
}

- (void)propagateSequenceToObjects
{
    for (PgSQLRecord *aRecord in self.registeredObjects) {
        [aRecord propagateSequence:self];
    }
    [self.registeredObjects removeAllObjects];
}

- (void)registerObject:(PgSQLRecord*)anObject ForSequenceKey:(NSString*)aName
{
    [self.registeredObjects addObject:anObject];
}

@end
