//
//  IOSUtils.m
//  IOSUtils
//
//  Created by jschoi on 2015. 12. 28..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "IOSUtils.h"

@implementation IOSUtils

/**
 * 주어진 문자열이 URL 형식인지 확인
 */
+ (BOOL)isValidateURL:(NSString *)string
{
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:string];
}

/**
 * alert controller 를 사용하여 메시지 박스를 출력한다. (OK 버튼만 있음)
 * iOS 8 부터 지원
 */
+ (UIAlertController *)messageBoxTitle:(NSString *)title
                           withMessage:(NSString *)message
                      onViewController:(UIViewController *)view
{
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil ];

    [alert addAction:ok];
    [view presentViewController:alert animated:YES completion:nil];
    
    return alert;
}

/**
 * alert controller 를 사용하여 메시지 박스를 출력한다. (OK,Cancel 버튼 있음)
 * iOS 8 부터 지원
 */
+ (UIAlertController *)messageBoxTitle:(NSString *)title
                           withMessage:(NSString *)message
                      onViewController:(UIViewController *)view
                    withOkButtonAction:(void (^)(UIAlertAction *action))okAction
                withCancelButtonAction:(void (^)(UIAlertAction *action))cancelAction
{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:okAction ];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleDefault
                                               handler:cancelAction ];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [view presentViewController:alert animated:YES completion:nil];
    
    return alert;
}

@end
