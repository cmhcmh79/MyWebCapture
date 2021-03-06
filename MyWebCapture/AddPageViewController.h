//
//  AddPageViewController.h
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 19..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarkData;

@interface AddPageViewController : UIViewController

@property (strong, nonatomic) NSString *stringTitle;
@property (strong, nonatomic) NSString *stringURL;
@property (strong, nonatomic) NSString *stringIconURL;

@property (strong, nonatomic) IBOutlet UITextField *textURL;
@property (strong, nonatomic) IBOutlet UITextField *textTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imageIcon;

// 이제 블럭변수
@property (nonatomic, strong) void (^complitCallback)();

// 화면 타이틀에 표시할 문자열
@property (nonatomic, strong) NSString *stringViewTitle;

// 편집할 북마크 정보
@property (nonatomic, copy) BookmarkData *bookmark;
@property (nonatomic) NSInteger bookmarkIndex;

@end
