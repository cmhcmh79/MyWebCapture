//
//  DataManager.h
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 21..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CapturedData.h"

@interface BookmarkData : NSObject <NSCopying>

@property (nonatomic) int no;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *iconFileName;
@property (strong, nonatomic) UIImage  *iconImage;
@property (nonatomic) int position;
@end

@interface DataManager : NSObject

@property (getter=getCount, readonly, nonatomic) NSUInteger count;     // 북마크 개수

// 갭쳐 데이터 읽기
@property (strong, nonatomic, readonly, getter=getCapturedDatas) NSArray<CapturedData *> *capturedDatas;

#pragma mark - class method
+ (DataManager *)GetSingleInstance;

#pragma mark - life cycle
- (instancetype)init;
- (void)dealloc;

#pragma mark - public method (captured data)
/**
 * 갭쳐 데이터를 주어진 항목을 기준으로 정렬하여 읽어온다.
 */
- (int)readCapturedData;
- (int)readCapturedDataOrderby:(NSString *)order withAscending :(BOOL)isAscending ;

/**
 * 새로운 갭처 데이터를 추가한다.
 */
- (int)addCapturedData:(CapturedData *)data withImage:(UIImage *)image;

/**
 * 주어진 갭처 데이터를 삭제한다.
 */
- (int)deleteCapturedData:(CapturedData *)data;


#pragma mark - public method (bookmark)
/**
 * 새로운 북마크를 마지막에 추가, 실패시 0보다 작은값 리턴
 */
- (int)addBookmark:(BookmarkData *)bookmark;

/**
 * 해당 위치(인덱스)에 있는 북마크 데이터 반환
 */
- (BookmarkData *)bookmarkAtIndex:(NSUInteger)index;

/**
 * 해당 북마트 데이터가 있는 인덱스 값을 반환
 */
- (NSInteger)indexOfBookmark:(BookmarkData *)bookmark;

/**
 * 해당 위치의 북마크 데이터를 변경한다. 실패시 0보다 작은 값 리턴
 */
- (int)updateBookmark:(BookmarkData *)bookmark atIndex:(NSInteger)index;

/**
 * 해당 위치의 북마크를 삭제한다. 실패시 0보다 작은 값 리턴
 */
- (int)deleteBookmarkAtIndex:(NSInteger)index;

/**
 * 북마크 위지청보를 수정한다.
 * 위치정보 기준으로 정렬된 리스트를 입력받아 저장하고 배열을 재정리 한다.
 */
- (int)updateBookmarkPositions:(NSArray<BookmarkData *> *)positions;
@end
