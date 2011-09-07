//
//  PgSQLRecord.h
//  PgTest
//
//  Created by eien.support@gmail.com on 11/08/27.
//  Copyright (c) 2011 "Eien Factory". All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PgSQLValue.h"
#import "PgSQLConnection.h"

@interface PgSQLRecord : NSObject
{
    NSMutableDictionary *attributes_; // NSString - PgSQLValue
    NSDictionary *oldValues_;// PgSQLValue
    NSString *tableName_;
    NSString *pkeyName_;
    NSString *pkeySequenceName_;
}
@property(nonatomic,retain,readwrite) NSMutableDictionary *attributes;// NSString
@property(nonatomic,retain,readwrite) NSDictionary *oldValues;// PgSQLValue
@property(nonatomic,copy,readwrite) NSString *tableName;
@property(nonatomic,copy,readwrite) NSString *pkeyName;
@property(nonatomic,copy,readwrite) NSString *pkeySequenceName;
@property(nonatomic,assign,readonly) BOOL isDirty;
@property(nonatomic,assign,readonly) BOOL isTemp;
@property(nonatomic,retain,readonly) PgSQLValue *pkeyValue;

- (BOOL)isEqualTo:(id)object;
- (NSNumber*)primaryKey;

- (void)setObject:(id)object forColumnName:(NSString*)columnName;
- (id)objectForColumnName:(NSString*)columnName;
- (void)setBOOL:(BOOL)val forColumnName:(NSString*)columnName;
- (BOOL)boolForColumnName:(NSString*)columnName;
- (void)setInt16:(int16_t)val forColumnName:(NSString*)columnName;
- (int16_t)int16ForColumnName:(NSString*)columnName;
- (void)setInt32:(int32_t)val forColumnName:(NSString*)columnName;
- (int32_t)int32ForColumnName:(NSString*)columnName;
- (void)setInt64:(int64_t)val forColumnName:(NSString*)columnName;
- (int64_t)int64ForColumnName:(NSString*)columnName;
- (void)setFloat:(float)val forColumnName:(NSString*)columnName;
- (float)floatForColumnName:(NSString*)columnName;
- (void)setDouble:(double)val forColumnName:(NSString*)columnName;
- (double)doubleForColumnName:(NSString*)columnName;
- (void)setDate:(NSDate*)object forColumnName:(NSString*)columnName;
- (NSDate*)dateForColumnName:(NSString*)columnName;
- (void)setTime:(NSDate*)object forColumnName:(NSString*)columnName;
- (NSDate*)timeForColumnName:(NSString*)columnName;
- (void)setTimestamp:(NSDate*)object forColumnName:(NSString*)columnName;
- (NSDate*)timestampForColumnName:(NSString*)columnName;
- (void)setTimestampTZ:(NSDate*)object forColumnName:(NSString*)columnName;
- (NSDate*)timestampTZForColumnName:(NSString*)columnName;
- (void)setVarchar:(NSString*)object forColumnName:(NSString*)columnName;
- (NSString*)varcharForColumnName:(NSString*)columnName;
- (void)setText:(NSString*)object forColumnName:(NSString*)columnName;
- (NSString*)textForColumnName:(NSString*)columnName;
- (void)setString:(NSString*)object forColumnName:(NSString*)columnName;
- (NSString*)stringForColumnName:(NSString*)columnName;
- (void)setData:(NSData*)object forColumnName:(NSString*)columnName;
- (NSData*)dataForColumnName:(NSString*)columnName;

- (void)setNullforColumnName:(NSString*)columnName;
- (BOOL)isNullForColumnName:(NSString*)columnName;

- (PgSQLValue*)valueforColumnName:(NSString*)columnName;
- (void)setValue:(PgSQLValue*)value forColumnName:(NSString*)columnName;
- (void)setBinary:(const char *)val ofType:(Oid)type forColumnName:(NSString*)columnName;

- (PgSQLRecord*)toOneRelationship:(NSString*)tableName 
                         withPkey:(NSString*)pkeyName 
                         forClass:(Class)recordClass 
                          forFkey:(NSString*)fkeyName
                       connection:(PgSQLConnection*)con;
- (NSArray*)toManyRelationships:(NSString*)tableName 
                       withFkey:(NSString*)pkeyName 
                       forClass:(Class)recordClass 
                        forPkey:(NSString*)fkeyName
                     connection:(PgSQLConnection*)con;

- (void)valueWillChangeForColumnName:(NSString*)columnName;
- (void)valueDidChangeForColumnName:(NSString*)columnName;
- (void)relatedValue:(PgSQLRecord*)aRecord willChangeForColumnName:(NSString*)columnName;
- (void)relatedValue:(PgSQLRecord*)aRecord didChangeForColumnName:(NSString*)columnName;
- (void)revertChanges;
- (void)didSaveChanges;

@end