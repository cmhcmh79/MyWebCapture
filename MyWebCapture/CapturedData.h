//
//  CapturedData.h
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 2..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 갭처한 이미지를 관리하는 클래스
 */
@interface CapturedData : NSObject

@property (nonatomic) int no;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *datetime;
/// 풀스크린을 갭쳐한 경우 YES 입력
@property (nonatomic) BOOL fullScreen;
/// 갭쳐한 이미지를 저장한 파일 이름
@property (strong, nonatomic) NSString *filename;


@end
