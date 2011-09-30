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
@synthesize tableName = tableName_;
@synthesize pkeyName = pkeyName_;
@synthesize pkeySequenceName = pkeySequenceName_;

- (void)dealloc {
    self.attributes = nil;
    self.oldValues = nil;
    self.tableName = nil;
    self.pkeyName = nil;
    self.pkeySequenceName = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.attributes = [NSMutableDictionary dictionary];
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
    return [oldValues_ count] > 0;
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
    return -1;
}

- (void)setObject:(id)object forColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [attributes_ objectForKey:columnName];
    Oid type;
    if ( aValue == nil ) {
        if ( (type = [self guessType:object]) < 0 ) return;        
        aValue = [PgSQLValue valueWithObject:object type:type];
    } else {
        type = aValue.type;
        [aValue setObject:object type:type];
    }
    if ( [oldValues_ count] == 0 ) {
        self.oldValues = [[attributes_ copy] autorelease];
    }
    [attributes_ setObject:aValue forKey:columnName];
}

- (id)objectForColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [attributes_ objectForKey:columnName];
    return [aValue objectValue];
}

- (PgSQLValue*)valueToChangeforColumnName:(NSString*)columnName
{
    PgSQLValue *aValue = [attributes_ objectForKey:columnName];
    if ( aValue == nil ) {
        aValue = [[[PgSQLValue alloc] init] autorelease];
    }
    if ( [oldValues_ count] == 0 ) {
        self.oldValues = [[attributes_ copy] autorelease];
    }
    [attributes_ setObject:aValue forKey:columnName];
    return aValue;
}

- (PgSQLValue*)valueforColumnName:(NSString*)columnName
{
    return [attributes_ objectForKey:columnName];
}

- (void)setValue:(PgSQLValue*)value forColumnName:(NSString*)columnName
{
    if ( [oldValues_ count] == 0 ) {
        oldValues_ = [[attributes_ copy] autorelease];
    }
    [attributes_ setObject:value forKey:columnName];
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
    return [self varcharForColumnName:columnName];   
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
    PgSQLQuery *aQuery = [PgSQLQuery queryWithTable:tableName
                                              where:whereString
                                             params:[NSArray arrayWithObject:[self valueforColumnName:fkeyName]]
                                           forClass:recordClass
                                            orderBy:nil
                                         connection:con];
    NSArray *anArray = [aQuery queryRecords];
    if ( [anArray count] == 0 ) return nil;
    return [anArray objectAtIndex:0];
}

- (NSArray*)toManyRelationships:(NSString*)tableName 
                       withFkey:(NSString*)pkeyName 
                       forClass:(Class)recordClass 
                        forPkey:(NSString*)fkeyName
                     connection:(PgSQLConnection*)con
{
    NSString *whereString = [NSString stringWithFormat:@"%@ = $1",fkeyName];
    PgSQLQuery *aQuery = [PgSQLQuery queryWithTable:tableName
                                              where:whereString
                                             params:[NSArray arrayWithObject:[self valueforColumnName:pkeyName]]
                                           forClass:recordClass
                                            orderBy:nil
                                         connection:con];
    return [aQuery queryRecords];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@> %@(%@,%@) \n %@",
            [self className],self.tableName, self.pkeyName, self.pkeySequenceName ,attributes_];
}

- (void)valueWillChangeForColumnName:(NSString*)columnName
{
}

- (void)valueDidChangeForColumnName:(NSString*)columnName
{
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
}

- (void)didSaveChanges
{
    self.oldValues = nil;
}

@end
