//
//  RecodeSet.h
//  SQLiteTool
//
//  Created by jschoi on 2015. 12. 20..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordData : NSObject
{
    NSString *mStringValue;
}
/**
 * 초기화, 해제
 */
- (id)initWithString:(NSString *)value;
- (void)dealloc;

/**
 * 레코드 데이터가 비어있으면 YES 리턴
 */
- (BOOL)isNull;

/**
 * 데이터를 원하는 형태로 변환하여 리턴한다.
 */
- (NSString *)getString;
- (int)getInt;
- (float)getFloat;

@end

@interface RecordSet : NSObject
{
    NSMutableArray *mDataSet;   // 이중 배열로 이루어진 데이터 집합
    NSMutableArray *mFieldName;  // 데이터의 필드(컬럼) 이름
    int             mRowIndex;  // 데이터를 읽을 row 위치
}

/**
 * 초기화, 해제
 */
- (id)init;
- (void)dealloc;

/**
 * 필드명과 데이터를 입력한다.
 */
- (void)setCollectData:(NSString *)value withName:(NSString *)name atColumn:(int)column;

/**
 * 현재 row에서 주어진 컬럼명의 데이터를 반환한다.
 */
- (RecordData *)getCollectDataAtColumnName:(NSString *)column;

/**
 * 데이터의 끝에 도달하면 TRUE 리턴
 */
- (BOOL)isEndofRecord;

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
 * 레코드의 column, row 개수를 확인한다.
 */
- (unsigned long)getColumnCount;
- (unsigned long)getRowCount;

/**
 * 컬럼(필드) 이름을 확인한다.
 */
- (NSString *)getColumnNameAtIndex:(int)index;
@end
