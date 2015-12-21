//
//  RecodeSet.h
//  SQLiteTool
//
//  Created by jschoi on 2015. 12. 20..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordData : NSObject

@property (strong, nonatomic, readonly) NSString *stringValue;
@property (getter=getInt, readonly, nonatomic) int intValue;
@property (getter=getFloat, readonly, nonatomic) float floatValue;
@property (getter=isNull, readonly, nonatomic) BOOL null;  // 데이터가 없으면 YES

#pragma mark - life cycle
/**
 * 초기화, 해제
 */
- (instancetype)initWithString:(NSString *)value;
- (void)dealloc;

@end

@interface RecordSet : NSObject

@property (getter=isEndofRecord, readonly, nonatomic) BOOL endOfRecord;
@property (getter=getColumnCount, readonly, nonatomic) unsigned long columnCount;
@property (getter=getRowCount, readonly, nonatomic) unsigned long rowCount;

#pragma mark - life cycle
/**
 * 초기화, 해제
 */
- (id)init;
- (void)dealloc;

#pragma mark - public method
/**
 * 필드명과 데이터를 입력한다.
 */
- (void)setCollectData:(NSString *)value withName:(NSString *)name atColumn:(int)column;

/**
 * 현재 row에서 주어진 컬럼명의 데이터를 반환한다.
 */
- (RecordData *)getCollectDataAtColumnName:(NSString *)column;

/**
 * 데이터를 읽을 위치를 다음 row로 이동한다.
 */
- (void)next;

/**
 * 데이터를 읽을 위치를 처음으로 되돌린다.
 */
- (void)reset;

/**
 * 모든 데이터를 최기화 한다.
 */
- (void)clear;

/**
 * 컬럼(필드) 이름을 확인한다.
 */
- (NSString *)getColumnNameAtIndex:(int)index;
@end
