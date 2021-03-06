//
//  ViewController.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 19..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "ViewController.h"
#import "AddPageViewController.h"
#import "IOSUtils.h"

@interface ViewController ()

@property (strong, nonatomic) NSTimer *timerWeb;

@property (nonatomic) BOOL updateBookmark;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIWebView *webPage;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"View Controller Load");
    self.dataManager = [DataManager GetSingleInstance];
    
    
    NSURL *url = nil;
    self.updateBookmark = NO;
    
    if( self.bookmark && self.bookmark.no > 0 ) {
        // 북마크 페이지 표시
        url = [NSURL URLWithString:self.bookmark.url];
        self.updateBookmark = YES;
    }
    else if( self.stringURL && self.stringURL.length > 0 ) {
        url = [NSURL URLWithString:self.stringURL];
    }
    
    if( url ) {
        self.searchBar.text = url.absoluteString;
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.webPage loadRequest:requestObj];
    }
    /*
    NSURL *url = [NSURL URLWithString:@"http://m.naver.com"];
    //NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    //NSURL *url = [NSURL URLWithString:@"http://m.daum.net"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webPage loadRequest:requestObj];
    */
    
    // 진행표시 생성
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview : self.activityIndicator];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (self.preCompletionCallback) {
        NSLog(@"====");
        self.preCompletionCallback();
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 아이폰에서 화면 전환 방법 2가지
 1. 그냥 화면에서는 Modal하는 방법이 있고
 2. Navigation 에서는 Push 하는 방법
 
 지금 스토리 보드에 보면 AddPage를 Present Modal로 설정이 되 있어서 이건 모달로 뛰운거
 (소스로 쓰면   [ self presentViewController:viewcontroler animated:YES completion:^{//성공코드}]; )

 
 전 페이지로 돌아가려면
 1. Modal일 경우 dismissViewControllerAnimated 이거 하면 되고
 2. Navigation Push로 들어오거면 Naviagtion Pop을 하면 되고(요건 스택 개념)
 
 나 이거 이해하는데 1년 걸렸음 ㅋㅋㅋㅋ
 
 */


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s > %@", __FUNCTION__, segue.identifier);
    if( [segue.identifier isEqualToString:@"AddPage"]) {
        AddPageViewController *destVeiw = segue.destinationViewController;
        destVeiw.stringViewTitle = @"Add Bookmark";
        destVeiw.stringTitle = [self.webPage stringByEvaluatingJavaScriptFromString:@"document.title"];
        destVeiw.stringURL = self.searchBar.text;
        NSString *stringIconURL = [self.webPage stringByEvaluatingJavaScriptFromString:@"(function() {var links = document.querySelectorAll('link'); for (var i=0; i<links.length; i++) {if (links[i].rel.substr(0, 16) == 'apple-touch-icon') return links[i].href;} return "";})();"];
        destVeiw.stringIconURL = stringIconURL;
        
        NSLog(@"url:%@ title:%@ icon:%@", destVeiw.stringURL, destVeiw.stringTitle, stringIconURL );
        
        /*
        destVeiw.complitCallback = ^(){
            NSLog(@"여기는 즐겨찾기 화면이 닫히면 실행이 됨");
            NSLog(@"할것이 있으면 하고 아니면 안해도 되고..");

        };
        */
    }
}


#pragma mark - UIWebViewDelegate protocol

/**
 * UIWebViewDelegate protocol
 */
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"web load srtart (loading:%i) < %@ >",
          webView.loading, webView.request.URL);

    [self.activityIndicator startAnimating];

    if( [webView.request.URL.absoluteString hasPrefix:@"file:///"] )
        return;
    //_searchBar.text = [NSString stringWithFormat:@"%@", webView.request.URL];
    
    if(webView.request.URL.absoluteString && webView.request.URL.absoluteString.length) {
        self.searchBar.text = webView.request.URL.absoluteString;
    }
    
    /*
    if( self.timerWeb == nil ) {
        self.timerWeb = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        NSLog("Start timer >>>>");
    }
    */
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"web load finish (loading:%i)< %@ >", webView.loading, webView.request.URL);
//    _searchBar.text = [NSString stringWithFormat:@"%@", webView.request.URL];
    
    if(![webView.request.URL.absoluteString hasPrefix:@"file:///"] &&
       webView.request.URL.absoluteString && webView.request.URL.absoluteString.length)
        self.searchBar.text = webView.request.URL.absoluteString;
    
    if( !webView.loading ) {
        NSLog(@"loading finished");
        
        // 업데이트는 처음 한번만
        if( self.updateBookmark ) {
            // 아이콘 이미지 다운로드
            NSString *stringIconURL = [self.webPage stringByEvaluatingJavaScriptFromString:@"(function() {var links = document.querySelectorAll('link'); for (var i=0; i<links.length; i++) {if (links[i].rel.substr(0, 16) == 'apple-touch-icon') return links[i].href;} return "";})();"];
            NSURL  *url = [NSURL URLWithString:stringIconURL];
            NSData *icon = [NSData dataWithContentsOfURL:url];
            if ( icon && icon.length ){
                self.bookmark.iconImage = [UIImage imageWithData:icon];
                [[DataManager GetSingleInstance] updateBookmark:self.bookmark atIndex:self.bookmarkIndex];
                NSLog(@"download %libyte", icon.length);
            }
        }
        
        self.updateBookmark = NO;
    }
    
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailLoadWithError");
    [self.activityIndicator stopAnimating];
    if (error.code == -999) {
        return;
    }
    [self.webPage loadHTMLString:[NSString stringWithFormat:@"<html><head><meta id=\"viewport\" name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/></head><body style=\"padding-top:50px;font-size:20px;text-align:center;\">%@</body></html>", [error localizedDescription]]
                         baseURL:[[webView request] URL]];
}

#pragma mark - UISearchBarDelegate protocol

/**
 * UISearchBarDelegate protocol
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%s %@", __FUNCTION__, self.searchBar.text);
    
    // 키보드 숨기기
    [searchBar resignFirstResponder];
    
    NSString *url = [self.searchBar.text lowercaseString];
    if( ![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] ) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    // 유효한 형식의 url 확인
    if( ![IOSUtils isValidateURL:url] ) {
        url = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", self.searchBar.text];
    }
    NSLog(@"URL > %@", url);
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webPage loadRequest:requestObj];
}

#pragma mark - timer action

/**
 * timer action
 */
- (void)timerAction:(NSTimer *)timer
{
    //NSLog(@"tick");
    if( !self.webPage.loading ) {
        NSLog(@"loading finished");
        [self.timerWeb invalidate];
        self.timerWeb = nil;
        
        // 업데이트는 처음 한번만
        if( self.updateBookmark ) {
            // 아이콘 이미지 다운로드
            NSString *stringIconURL = [self.webPage stringByEvaluatingJavaScriptFromString:@"(function() {var links = document.querySelectorAll('link'); for (var i=0; i<links.length; i++) {if (links[i].rel.substr(0, 16) == 'apple-touch-icon') return links[i].href;} return "";})();"];
            NSURL  *url = [NSURL URLWithString:stringIconURL];
            NSData *icon = [NSData dataWithContentsOfURL:url];
            if ( icon && icon.length ){
                self.bookmark.iconImage = [UIImage imageWithData:icon];
                [[DataManager GetSingleInstance] updateBookmark:self.bookmark atIndex:self.bookmarkIndex];
                NSLog(@"download %libyte", icon.length);
            }
        }
        
        self.updateBookmark = NO;
    }
}

#pragma mark - button action

/**
 * button action
 */
- (IBAction)pressedHomeButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    // 네비게이션 컨트롤 이용
    if( self.navigationController ) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^{
            if( self.completionCallback ) {
                self.completionCallback();
            }
            
        }];
    }
}
- (IBAction)pressedBackwardButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self.webPage goBack];
}
- (IBAction)pressedForward:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self.webPage goForward];
}
- (IBAction)pressedStopButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self.webPage stopLoading];
}
- (IBAction)pressedReloadButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self.webPage reload];
}
- (IBAction)pressedActionButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil /* @"My Alert" */
                                                                   message:nil /* @"delete ?." */
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 50);
    
    
    UIAlertAction *actionAddPage = [UIAlertAction actionWithTitle:@"Add Bookmark" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSLog(@"AlertAction add page");
                                                              [self performSegueWithIdentifier:@"AddPage" sender:action];
                                                          }];
    
    UIAlertAction *actionCapture = [UIAlertAction actionWithTitle:@"Capture View Size" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         NSLog(@"Capture View Size");
                                                         [self captureViewSize];
                                                     }];

    UIAlertAction *actionCaptureFull = [UIAlertAction actionWithTitle:@"Capture Full Size" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSLog(@"Capture Full Size");
                                                              [self captureFullSize];
                                                          }];
    /*
    UIAlertAction *actionDownload = [UIAlertAction actionWithTitle:@"Download Image" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSLog(@"AlertAction down image");
                                                              }];
     */

    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
                                                         NSLog(@"AlertAction cancel");
                                                     }];
    [alert addAction:actionAddPage];
    [alert addAction:actionCapture];
    [alert addAction:actionCaptureFull];
    //[alert addAction:actionDownload];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
}

// 보이는 화면 갭쳐
- (void)captureViewSize
{
    NSLog();
    [self.activityIndicator startAnimating];

    CGRect webFrame = self.webPage.frame;
    
    UIGraphicsBeginImageContext(self.webPage.frame.size);
    [self.webPage.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
    [self.webPage setFrame:webFrame];
    
    // 캡쳐 데이터 저장
    CapturedData *captured = [[CapturedData alloc] init];
    captured.title = [self.webPage stringByEvaluatingJavaScriptFromString:@"document.title"];
    captured.url = self.searchBar.text;
    captured.fullScreen = NO;
    [self.dataManager addCapturedData:captured withImage:viewImage];
    
    [self.activityIndicator stopAnimating];
    [IOSUtils messageBoxTitle:nil withMessage:@"Saved Captured Imaage" onViewController:self ];
}

// 웹페이지 모두 갭쳐
- (void)captureFullSize
{
    NSLog();
    [self.activityIndicator startAnimating];
    
    UIScrollView *scrollView;
    for(UIView *subView in self.webPage.subviews) {
        if([subView isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)subView;
            //[scrollView setDelegate:self];
        }
    }
    
    CGRect webFrame = self.webPage.frame;
    
    [self.webPage sizeToFit];
    
    UIGraphicsBeginImageContext(scrollView.contentSize);
    [self.webPage.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.webPage setFrame:webFrame];
    
    //UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
    // 캡쳐 데이터 저장
    CapturedData *captured = [[CapturedData alloc] init];
    captured.title = [self.webPage stringByEvaluatingJavaScriptFromString:@"document.title"];
    captured.url = self.searchBar.text;
    captured.fullScreen = YES;
    [self.dataManager addCapturedData:captured withImage:viewImage];
    
    [self.activityIndicator stopAnimating];
    [IOSUtils messageBoxTitle:nil withMessage:@"Saved Captured Imaage" onViewController:self ];
}

@end
