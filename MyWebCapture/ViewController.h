//
//  ViewController.h
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 19..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// 종료 콜백 정의
@property (strong, nonatomic) void (^completionCallback)();

@end

