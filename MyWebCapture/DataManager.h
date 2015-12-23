//
//  DataManager.h
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 21..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BookmarkData : NSObject <NSCopying>

@property (nonatomic) int no;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *iconFileName;
@property (strong, nonatomic) UIImage  *iconImage;

@end


@interface DataManager : NSObject

@property (getter=getCount, readonly, nonatomic) NSUInteger count;     // 북마크 개수

#pragma mark - class method
+ (DataManager *)GetSingleInstance;

#pragma mark - life cycle
- (instancetype)init;
- (void)dealloc;

#pragma mark - public method
/**
 * 새로운 북마크를 마지막에 추가, 실패시 0보다 작은값 리턴
 */
- (int)addBookmark:(BookmarkData *)bookmark;

/**
 * 해당 위치(인덱스)에 있는 북마크 데이터 반환
 */
- (BookmarkData *)bookmarkAtIndex:(NSUInteger)index;

/**
 * 해당 위치의 북마크 데이터를 변경한다. 실패시 0보다 작은 값 리턴
 */
- (int)updateBookmark:(BookmarkData *)bookmark atIndex:(NSInteger)index;

/**
 * 해당 위치의 북마크를 삭제한다. 실패시 0보다 작은 값 리턴
 */
- (int)deleteBookmarkAtIndex:(NSInteger)index;

@end
