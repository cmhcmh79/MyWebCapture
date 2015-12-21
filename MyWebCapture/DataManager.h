//
//  DataManager.h
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 21..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BookmarkData : NSObject

@property (nonatomic) int no;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *iconFileName;
@property (strong, nonatomic) UIImage  *iconImage;

@end


@interface DataManager : NSObject

#pragma mark - class method
+ (DataManager *)GetSingleInstance;

#pragma mark - life cycle
- (instancetype)init;
- (void)dealloc;

#pragma mark - public method

@end
