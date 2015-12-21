//
//  RecodeSet.m
//  SQLiteTool
//
//  Created by jschoi on 2015. 12. 20..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "RecordSet.h"

@implementation RecordData

#pragma mark - life cycle
/**
 * 초기화, 해제
 */
- (instancetype)initWithString:(NSString *)value
{
    self = [super init];
    if( self )
        _stringValue = value;
    
    return self;
}
- (void)dealloc
{
}

#pragma mark - getter
/**
 * 레코드 데이터가 비어있으면 YES 리턴
 */
- (BOOL)isNull
{
    if(self.stringValue == nil || self.stringValue.length == 0)
        return YES;
    return NO;
}

- (int)getInt
{
    return [self.stringValue intValue];
}
- (float)getFloat
{
    return [self.stringValue floatValue];
}

#pragma mark

@end


@interface RecordSet ()

@property (strong, nonatomic) NSMutableArray<NSMutableArray<NSString *> *> *dataSet;      // 이중 배열로 이루어진 데이터 집합
@property (strong, nonatomic) NSMutableArray<NSString *> *fieldNames;   // 데이터의 필드(컬럼) 이름
@property (nonatomic) int rowIndex;     // 데이터를 읽을 row 위치

@end

@implementation RecordSet

#pragma mark - life cycle
/**
 * 초기화, 해제
 */
- (id)init
{
    self = [super init];
    if(self) {
        _dataSet = [[NSMutableArray alloc] init];
        _fieldNames = [[NSMutableArray alloc] init];
        _rowIndex = 0;
    }
    NSLog(@"%s(%p)", __FUNCTION__, self);

    return self;
}
- (void)dealloc
{
    _dataSet = nil;
    _fieldNames = nil;
    
    NSLog(@"%s(%p)", __FUNCTION__, self);
}


#pragma mark - getter
/**
 * 데이터의 끝에 도달하면 YES 리턴
 */
- (BOOL)isEndofRecord
{
    if( self.rowIndex >= self.rowCount)
        return YES;
    return NO;
}

/**
 * 레코드의 column, row 개수를 확인한다.
 */
- (unsigned long)getColumnCount
{
    return self.fieldNames.count;
}
- (unsigned long)getRowCount
{
    if(self.dataSet.count == 0)
        return 0;
    
    return [self.dataSet[0] count];
}

#pragma mark - public method
/**
 * 필드명과 데이터를 입력한다.
 */
- (void)setCollectData:(NSString*)value withName:(NSString *)name atColumn:(int)column
{
    NSMutableArray *columnSet;
    
    if( self.fieldNames.count <= column) {
        // 새로운 컬럼(필드) 삽입
        [self.fieldNames addObject:name];
        columnSet = [[NSMutableArray alloc] init];
        [self.dataSet addObject:columnSet];
    }
    
    // 데이터 추가
    columnSet = self.dataSet[column];
    [columnSet addObject:value];
    [self.dataSet replaceObjectAtIndex:column withObject:columnSet];
 }

/**
 * 현재 row에서 주어진 컬럼명의 데이터를 반환한다.
 */
- (RecordData *)getCollectDataAtColumnName:(NSString *)column
{

    RecordData *data = nil;
    int indexOfColumn = -1;
    
    // 컬럼 이름 찾기
    for(int i = 0; self.fieldNames.count; ++i) {
        if( [self.fieldNames[i] isEqualToString:column] ) {
            indexOfColumn = i;
            break;
        }
    }
    if( indexOfColumn < 0 )
        return nil;
    
    // record 데이터 생성
    data = [[RecordData alloc] initWithString:[self.dataSet[indexOfColumn] objectAtIndex:self.rowIndex]];
    
    return data;
}

/**
 * 데이터를 읽을 위치를 다음 row로 이동한다.
 */
- (void)next
{
    ++self.rowIndex;
}

/**
 * 데이터를 읽을 위치를 처음으로 되돌린다.
 */
- (void)reset
{
    self.rowIndex = 0;
}

/**
 * 모든 데이터를 최기화 한다.
 */
- (void)clear
{
    self.rowIndex = 0;
    while(self.fieldNames.count > 0)
        [self.fieldNames removeObjectAtIndex:0];
    
    while(self.dataSet.count > 0)
        [self.dataSet removeObjectAtIndex:0];
}

/**
 * 컬럼(필드) 이름을 확인한다.
 */
- (NSString *)getColumnNameAtIndex:(int)index
{
    return [self.fieldNames objectAtIndex:index];
}
@end
