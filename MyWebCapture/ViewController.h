//
//  ViewController.h
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 19..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface ViewController : UIViewController

// 종료 콜백 정의
@property (strong, nonatomic) void (^completionCallback)();

// 시작 URL string
@property (strong, nonatomic) NSString *stringURL;

// 시작 북마트 정보
@property (nonatomic, copy) BookmarkData *bookmark;
@property (nonatomic) NSInteger bookmarkIndex;
@end

