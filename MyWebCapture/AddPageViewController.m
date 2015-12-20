//
//  AddPageViewController.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 19..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "AppDelegate.h"
#import "AddPageViewController.h"


@interface AddPageViewController ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic) NSData *urlData;

@end

@implementation AddPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%s", __FUNCTION__);
    
    _textTitle.text = _stringTitle;
    _textURL.text = _stringURL;
    
    // 아이콘 파일 다운로드
    NSURL  *url = [NSURL URLWithString:_stringIconURL];
    _urlData = nil;
    _urlData = [NSData dataWithContentsOfURL:url];
    if ( _urlData )
    {
        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"tmp.png"];
        [_urlData writeToFile:filePath atomically:YES];
        
        _imageIcon.image = [UIImage imageWithData:_urlData];

        NSLog(@"download : %@ (%ldbyte)", filePath, _urlData.length);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"SavePage"]) {
        
    }
}


@end
