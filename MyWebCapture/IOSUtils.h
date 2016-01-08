//
//  IOSUtils.h
//  IOSUtils
//
//  Created by jschoi on 2015. 12. 28..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * IOS에서 유용한 API 모음
 */

@interface IOSUtils : NSObject

/**
 * 주어진 문자열이 URL 형식인지 확인
 */
+ (BOOL)isValidateURL:(NSString *)string;

/**
 * alert controller 를 사용하여 메시지 박스를 출력한다. (OK 버튼만 있음)
 * iOS 8 부터 지원
 */
+ (UIAlertController *)messageBoxTitle:(NSString *)title
                           withMessage:(NSString *)message
                      onViewController:(UIViewController *)view ;

/**
 * alert controller 를 사용하여 메시지 박스를 출력한다. (OK,Cancel 버튼 있음)
 * iOS 8 부터 지원
 */
+ (UIAlertController *)messageBoxTitle:(NSString *)title
                           withMessage:(NSString *)message
                      onViewController:(UIViewController *)view
                withCancelButtonAction:(void (^)(UIAlertAction *action))cancelAction
                    withOkButtonAction:(void (^)(UIAlertAction *action))okAction ;


/**
 * 앱에서 접근하는 다큐멘트 디렉토리를 확인한다.
 */
+ (NSString *)pathDocuments;

/**
 * 앱에서 접근하는 다큐멘트 디렉토리의 파일 이름의 패스를 리턴한다.
 */
+ (NSString *)pathDocumentsWithFilename:(NSString *)filename;

@end
