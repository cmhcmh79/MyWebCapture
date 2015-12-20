//
//  RecodeSet.m
//  SQLiteTool
//
//  Created by jschoi on 2015. 12. 20..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "RecordSet.h"

@implementation RecordData
/**
 * 초기화, 해제
 */
- (id)initWithString:(NSString *)value
{
    self = [super init];
    if( self )
        mStringValue = value;
    
    return self;
}
- (void)dealloc
{
}

/**
 * 레코드 데이터가 비어있으면 YES 리턴
 */
- (BOOL)isNull
{
    if(mStringValue == nil || mStringValue.length == 0)
        return YES;
    return NO;
}

/**
 * 데이터를 원하는 형태로 변환하여 리턴한다.
 */
- (NSString *)getString
{
    return mStringValue;
}
- (int)getInt
{
    return [mStringValue intValue];
}
- (float)getFloat
{
    return [mStringValue floatValue];
}

@end

@implementation RecordSet

/**
 * 초기화, 해제
 */
- (id)init
{
    self = [super init];
    if(self) {
        mDataSet = [[NSMutableArray alloc] init];
        mFieldName = [[NSMutableArray alloc] init];
        mRowIndex = 0;
    }
    NSLog(@"%s(%p)", __FUNCTION__, self);

    return self;
}
- (void)dealloc
{
    NSLog(@"%s(%p)", __FUNCTION__, self);
}

/**
 * 필드명과 데이터를 입력한다.
 */
- (void)setCollectData:(NSString*)value withName:(NSString *)name atColumn:(int)column
{
    NSMutableArray *columnSet;
    
    if( mFieldName.count <= column) {
        // 새로운 컬럼(필드) 삽입
        [mFieldName addObject:name];
        columnSet = [[NSMutableArray alloc] init];
        [mDataSet addObject:columnSet];
    }
    
    // 데이터 추가
    columnSet = mDataSet[column];
    [columnSet addObject:value];
    [mDataSet replaceObjectAtIndex:column withObject:columnSet];
 }

/**
 * 현재 row에서 주어진 컬럼명의 데이터를 반환한다.
 */
- (RecordData *)getCollectDataAtColumnName:(NSString *)column
{

    RecordData *data = nil;
    int indexOfColumn = -1;
    
    // 컬럼 이름 찾기
    for(int i = 0; mFieldName.count; ++i) {
        if( [mFieldName[i] isEqualToString:column] ) {
            indexOfColumn = i;
            break;
        }
    }
    if( indexOfColumn < 0 )
        return nil;
    
    // record 데이터 생성
    data = [[RecordData alloc] initWithString:[mDataSet[indexOfColumn] objectAtIndex:mRowIndex]];
    
    return data;
}

/**
 * 데이터의 끝에 도달하면 YES 리턴
 */
- (BOOL)isEndofRecord
{
    if( mRowIndex >= [self getRowCount])
        return YES;
    return NO;
}

/**
 * 데이터를 읽을 위치를 다음 row로 이동한다.
 */
- (void)next
{
    ++mRowIndex;
}

/**
 * 데이터를 읽을 위치를 처음으로 되돌린다.
 */
- (void)reset
{
    mRowIndex = 0;
}

/**
 * 모든 데이터를 최기화 한다.
 */
- (void)clear
{
    mRowIndex = 0;
    
    while(mFieldName.count > 0)
        [mFieldName removeObjectAtIndex:0];
    
    while(mDataSet.count > 0)
        [mDataSet removeObjectAtIndex:0];
}

/**
 * 레코드의 column, row 개수를 확인한다.
 */
- (unsigned long)getColumnCount
{
    return mFieldName.count;
}
- (unsigned long)getRowCount
{
    if(mDataSet.count == 0)
        return 0;
    
    return [mDataSet[0] count];
}

/**
 * 컬럼(필드) 이름을 확인한다.
 */
- (NSString *)getColumnNameAtIndex:(int)index
{
    return [mFieldName objectAtIndex:index];
}
@end
