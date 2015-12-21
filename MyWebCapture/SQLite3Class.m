//
//  SQLiteClass.m
//  SQLiteTool
//
//  Created by jschoi on 2015. 12. 20..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "SQLite3Class.h"

@implementation SQLite3Class

/**
 * SQLite 기본 속성값
 */
static NSString* const StringAttributeDefault = @"PRAGMA encoding = UTF8; PRAGMA foreign_keys = ON;";

#pragma mark - class method
/**
 * SQLite 기본 속성값을 반한한다.
 */
+ (NSString*)GetDefaultAttribute
{
    return StringAttributeDefault;
}

#pragma mark - life cycle
/**
 * 파일 이름을 설정하고 초기화 한다. (속성은 기본값으로 설정)
 */
- (instancetype) initWithFilePath:(NSString *)path
{
    self = [super init];
    if(self) {
        _stringFilePath = path;
        _stringAttribute = StringAttributeDefault;
        
        mDB = NULL;
    }

    NSLog(@"%s<%p>", __FUNCTION__, self);

    return self;
}
- (void) dealloc
{
    NSLog(@"%s<%p>", __FUNCTION__, self);
    [self close];
}

#pragma mark - public method
/**
 * DB파일을 연결한다. 실패시 throw 발생
 */
- (void)open
{
    // 이미 연결된 DB는 종료
    [self close];
    
    // DB 이름 확인
    if( self.stringFilePath.length == 0) {
        @throw [NSException exceptionWithName:@"File Path Fail" reason:@"File Path Empty" userInfo:nil];
        return;
    }
    
    // 디비 연결
    if(sqlite3_open(self.stringFilePath.UTF8String, &mDB) != SQLITE_OK )
    {
        // 연결 실패시 바로 닫음
        [self close];
        NSString *stringError = [NSString stringWithFormat:@"%s", sqlite3_errmsg(mDB)];
        @throw [NSException exceptionWithName:@"SQLite Open Fail" reason:stringError userInfo:nil];
        return;
    }
    
    // 속성 설정
    if( self.stringAttribute.length > 0 )
        [self executeWithSQL:_stringAttribute];
}

/**
 * DB파일 연결을 종료한다.
 */
- (void)close
{
    if(mDB)
        sqlite3_close(mDB);
    
    mDB = NULL;
}

/**
 * SQL 실행결과를 받는 콜백함수
 */
static int ExecCallback(void *pParam, int nCount, char **values, char **names)
{
    RecordSet *record = (__bridge RecordSet *)pParam;
    for(int i = 0; i < nCount; ++i) {
        NSString *value = [NSString stringWithFormat:@"%s", values[i]];
        NSString *name = [NSString stringWithFormat:@"%s", names[i]];
        [record setCollectData:value withName:name atColumn:i];
    }
    
    return 0;
}

/**
 * SQL문을 실행시킨다.
 */
- (RecordSet *)executeWithSQL:(NSString *)sql
{
    RecordSet *record = [[RecordSet alloc] init];
    char *zErrMsg = NULL;
    
    if( mDB == NULL ) {
        @throw [NSException exceptionWithName:@"SQLite not opened" reason:nil userInfo:nil];
        return nil;
    }
    
    if( sqlite3_exec(mDB, sql.UTF8String, ExecCallback, (__bridge void *)(record), &zErrMsg) != SQLITE_OK ) {
        NSString *stringError = [NSString stringWithFormat:@"%s", zErrMsg];
        sqlite3_free(zErrMsg);
        @throw [NSException exceptionWithName:@"SQL Execute Fail" reason:stringError userInfo:nil];
        return nil;
    }
    
    return record;
}

/**
 * 트랜잭션을 사용하여 DB를 연결하고 해제
 */
- (void)openAndTransaction
{
    [self open];
    [self executeWithSQL:@"BEGIN TRANSACTION;"];
}
- (void)closeBeforCommit
{
    [self executeWithSQL:@"COMMIT;"];
    [self close];
}
- (void)closeBeforRollback
{
    if(mDB == NULL)
        return;
    
    [self executeWithSQL:@"ROLLBACK;"];
    [self close];
}
@end
