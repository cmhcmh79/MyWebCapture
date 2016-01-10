//
//  CZPickerMultiView.h
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 8..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import "CZPickerView.h"


@interface CZPickerMultiView : CZPickerView

/**
 * 입력한 문자열들로 픽커 항목 구성
 */
- (void)addStrings:(NSArray<NSString *> *)strings withDefaultSelect:(NSInteger)seleted;

/**
 * confirm 버튼 클릭시 동작을 등록한다.
 */
- (void)setConfirmButtonAction:(void (^)(NSArray *selectedStrings, NSArray<NSNumber *> *selectedRows))action;
@end
