//
//  AddPageViewController.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 19..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "AppDelegate.h"
#import "AddPageViewController.h"
#import "DataManager.h"


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
        /*
        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"tmp.png"];
        [_urlData writeToFile:filePath atomically:YES];
        */
        
        _imageIcon.image = [UIImage imageWithData:_urlData];

        //NSLog(@"download : %@ (%ldbyte)", filePath, _urlData.length);
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


#pragma mark - Button Event


- (IBAction)clickCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"화면 닫길때 코드");
    }];
    
}

- (IBAction)clickSave:(id)sender {
    NSLog("save");
    DataManager *manager = [DataManager GetSingleInstance];
    BookmarkData *bookmark = [[BookmarkData alloc] init];
    
    bookmark.url = self.textURL.text;
    bookmark.title = self.textTitle.text;
    bookmark.iconImage = self.imageIcon.image;
    bookmark.no = 0;
    
    if( [manager addBookmark:bookmark ] < 0 )
        NSLog(@"Add Fail.");
    //NSAssert(NO, @"save fail");
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"화면 닫길때 코드");
        
        /* 여기서 화면이 닫기는게 성공을 하면
            나를 호출했던 ViewController에게 변경되었다고 알려줘야 할때
         
         1. Notification을 이용한다.
         2. Delegate를 이용한다.
         3. Block Coding을 이용한 Callbac을 이용한다.
         
         1번은 프로젝트가 개판이 될 수 있으니깐 되도록 안쓰는게 좋고
         2번은 ViewController에 보면 UIWebViewDelegate protocol 로 주석 달린게 Delegate를 사용한건데
            Delegate를 많이 쓰다보니 실제로 호출하는 곳과 처리하는 곳이 떨어져 소스 해석이 거지 같아지더라구
         그래서 Xcode에서 블럭코딩을 많이 쓰는 추세더라구..
         [self dismissViewControllerAnimated:YES completion:^{}]; <-- 이것도 결국 블럭코딩 아마 ios 6.0 이후부터는
         이걸 사용하라고 많이 권장하는 듯.. 싶다.
         
         */
        
        
        if (self.complitCallback) {
            self.complitCallback();
        }
        
    }];

    
    
    
}



@end
