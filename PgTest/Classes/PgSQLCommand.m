//
//  PgSQLCommand.m
//  PgTest
//
//  Created by 黒木 政幸 on 11/08/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PgSQLCommand.h"
#import "PgSQLValue.h"

@interface NSString (cString)
- (char *)cStringWithMalloc;
@end

@implementation NSString (cString)
- (char *)cStringWithMalloc
{
    const char *tmp = [self UTF8String];
    size_t len = strlen(tmp);
    char *sql = malloc(len+1);
    strlcpy(sql, tmp, len+1);
    return sql;
}
@end

@implementation PgSQLCommand

@synthesize isBinary = isBinary_;
@synthesize conn = conn_;
@synthesize format = format_;
@synthesize params = params_;


- (id)init {
    self = [super init];
    if (self) {
        isBinary_ = YES;
    }
    return self;
}

- (void)dealloc
{
    self.conn = nil;
    self.format = nil;
    self.params = nil;
    [super dealloc];
}

+ (PgSQLResult*)executeString:(NSString*)aString connection:(PgSQLConnection*)conn
{
    if ( ![conn isConnected] ) return nil;
    const char *sql = [aString cStringUsingEncoding:NSUTF8StringEncoding];
	PGresult *res = PQexec([conn conn],sql);
    ExecStatusType status = PQresultStatus(res);
	if ( status != PGRES_TUPLES_OK && status != PGRES_COMMAND_OK) {
		fprintf(stderr,"%s\n",PQresultErrorMessage(res));
		PQclear(res);
        return nil;
	}
	printf("EXECUTE SUCCESS!!\n");
    return [PgSQLResult resultWithResult:res];
}

+ (PgSQLResult*)executeBinaryFormat:(NSString*)aFormat params:(NSArray*)anArray connection:(PgSQLConnection*)conn
{
    int nNumParams = [anArray count];
    if ( nNumParams == 0 ) {
        return [PgSQLCommand executeString:aFormat connection:conn];
    }
    char **paramValues = (char**)malloc(nNumParams*sizeof(char*));
    Oid *paramTypes = (Oid*)malloc(nNumParams*sizeof(Oid));
    int *paramLengths = (int*)malloc(nNumParams*sizeof(int));
    int *paramFormats = (int*)malloc(nNumParams*sizeof(int));
    for ( int i = 0; i < nNumParams; i++ ) {
        size_t size = [(PgSQLValue*)[anArray objectAtIndex:i] getBufferSize];
        paramValues[i] = malloc(size);
        [(PgSQLValue*)[anArray objectAtIndex:i] getBinary:paramValues[i] maxSize:size];
        paramTypes[i] = [(PgSQLValue*)[anArray objectAtIndex:i] type];
        paramLengths[i] = [(PgSQLValue*)[anArray objectAtIndex:i] getBinarySize];
        paramFormats[i] = 1;
    }
	PGresult *res = PQexecParams([conn conn],
                                 [aFormat UTF8String],
                                 nNumParams, // int nNumParams,
                                 paramTypes,// const Oid *paramTypes,
                                 (const char * const *)paramValues, // const char * const *paramValues,
                                 paramLengths, // const int *paramLengths,
                                 paramFormats, // const int *paramFormats,
                                 1 // int resultFormat
                                 );
    ExecStatusType status = PQresultStatus(res);
    for ( int i = 0; i < nNumParams; i++ ) {
        free(paramValues[i]);
    }
    free(paramValues);
    free(paramTypes);
    free(paramLengths);
    free(paramFormats);
	if ( status != PGRES_TUPLES_OK && status != PGRES_COMMAND_OK) {
		fprintf(stderr,"%s\n",PQresultErrorMessage(res));
		PQclear(res);
        return nil;
	}
    return [PgSQLResult resultWithResult:res];
}

+ (PgSQLResult*)executeTextFormat:(NSString*)aFormat params:(NSArray*)anArray connection:(PgSQLConnection*)conn
{
    int nNumParams = [anArray count];
    if ( nNumParams == 0 ) {
        return [PgSQLCommand executeString:aFormat connection:conn];
    }
    char *sql = [aFormat cStringWithMalloc];
    char **paramValues = (char**)malloc(nNumParams*sizeof(char*));
    for ( int i = 0; i < nNumParams; i++ ) {
        paramValues[i] = [[anArray objectAtIndex:i] cStringWithMalloc];
    }
	PGresult *res = PQexecParams([conn conn],
                                 sql,
                                 nNumParams, // int nNumParams,
                                 NULL,// const Oid *paramTypes,
                                 (const char * const *)paramValues, // const char * const *paramValues,
                                 NULL, // const int *paramLengths,
                                 0, // const int *paramFormats,
                                 0 // int resultFormat
                                 );
    for ( int i = 0; i < nNumParams; i++ ) {
        free(paramValues[i]);
    }
    free(paramValues);
    free(sql);
    ExecStatusType status = PQresultStatus(res);
	if ( status != PGRES_TUPLES_OK && status != PGRES_COMMAND_OK) {
		fprintf(stderr,"%s\n",PQresultErrorMessage(res));
		PQclear(res);
        return nil;
	}
    return [PgSQLResult resultWithResult:res];
}

- (PgSQLResult*)execute
{
    if ( [params_ count] == 0 ) {
        return [PgSQLCommand executeString:format_ connection:conn_];
    }
    if ( isBinary_ ) {
        return [PgSQLCommand executeBinaryFormat:format_ params:params_ connection:conn_];
    } else {
        return [PgSQLCommand executeTextFormat:format_ params:params_ connection:conn_];
    }
}


@end
