//
//  SQLiteClass.h
//  SQLiteTool
//
//  Created by jschoi on 2015. 12. 20..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "RecordSet.h"

@interface SQLite3Class : NSObject
{
    sqlite3 *mDB;
}
@property (strong, nonatomic) NSString *stringFilePath;     // DB 파일 이름
@property (strong, nonatomic) NSString *stringAttribute;    // DB 연결 속성

#pragma mark - class method
/**
 * SQLite 기본 속성값을 반한한다.
 */
+ (NSString*)GetDefaultAttribute;

#pragma mark - life cycle
/**
 * 파일 이름을 설정하고 초기화 한다. (속성은 기본값으로 설정)
 */
- (instancetype)initWithFilePath:(NSString *)path;
- (void)dealloc;

#pragma mark - public method
/**
 * DB파일을 연결한다. 실패시 @throw 발생
 */
- (void)open;

/**
 * DB파일 연결을 종료한다.
 */
- (void)close;

/**
 * SQL문을 실행시킨다. 결과를 RecodeSet형태로 반환한다.
 * 에러 발생시 @throw 발생
 */
- (RecordSet *)executeWithSQL:(NSString *)sql;


/**
 * 트랜잭션을 사용하여 DB를 연결하고 해제
 */
- (void)openAndTransaction;
- (void)closeBeforCommit;
- (void)closeBeforRollback;
@end
