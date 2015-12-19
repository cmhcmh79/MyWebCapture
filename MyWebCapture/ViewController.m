//
//  ViewController.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 19..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSTimer *timerWeb;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIWebView *webPage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"View Controller Load");
    
    NSURL *url = [NSURL URLWithString:@"http://m.naver.com"];
    //NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    //NSURL *url = [NSURL URLWithString:@"http://m.daum.net"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webPage loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s > %@", __FUNCTION__, segue.identifier);
    if( [segue.identifier isEqualToString:@"SegueName"]) {
        
        //[segue.destinationViewController doSomthing];
    }
}

/**
 * UIWebViewDelegate protocol
 */
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"web load srtart (loading:%i) < %@ >",
          webView.loading, webView.request.URL);
    _searchBar.text = [NSString stringWithFormat:@"%@", webView.request.URL];
    
    if( timerWeb == nil )
        timerWeb = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"web load finish (loading:%i)< %@ >", webView.loading, webView.request.URL);
    _searchBar.text = [NSString stringWithFormat:@"%@", webView.request.URL];
}

/**
 * UISearchBarDelegate protocol
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%s %@", __FUNCTION__, _searchBar.text);
    
    // 키보드 숨기기
    [searchBar resignFirstResponder];
    
    NSURL *url = [NSURL URLWithString:_searchBar.text];
    NSLog(@"scheme>>%@", url.scheme);
    if( url.scheme == nil ) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", _searchBar.text]];
    }
    NSLog(@"URL > %@", url);
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webPage loadRequest:requestObj];
}

/**
 * timer action
 */
- (void)timerAction:(NSTimer *)timer
{
    if( _webPage.loading == 0 ) {
        NSLog(@"loading finished");
        [timerWeb invalidate];
        timerWeb = nil;
    }
}

/**
 * button action
 */
- (IBAction)pressedHomeButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
}
- (IBAction)pressedBackwardButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [_webPage goBack];
}
- (IBAction)pressedForward:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [_webPage goForward];
}
- (IBAction)pressedStopButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [_webPage stopLoading];
}
- (IBAction)pressedReloadButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [_webPage reload];
}
- (IBAction)pressedActionButton:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil /* @"My Alert" */
                                                                   message:nil /* @"delete ?." */
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionAddPage = [UIAlertAction actionWithTitle:@"시작 페이지 추가" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSLog(@"AlertAction add page");
                                                              [self performSegueWithIdentifier:@"AddPage" sender:action];
                                                          }];
    
    UIAlertAction *actionCapture = [UIAlertAction actionWithTitle:@"화면 갭쳐" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         NSLog(@"AlertAction capture");
                                                     }];

    UIAlertAction *actionCaptureFull = [UIAlertAction actionWithTitle:@"웹페이지 전체 갭쳐" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSLog(@"AlertAction capture full");
                                                          }];

    UIAlertAction *actionDownload = [UIAlertAction actionWithTitle:@"이미지 다운로드" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSLog(@"AlertAction down image");
                                                              }];

    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"취 소" style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
                                                         NSLog(@"AlertAction cancel");
                                                     }];
    [alert addAction:actionAddPage];
    [alert addAction:actionCapture];
    [alert addAction:actionCaptureFull];
    [alert addAction:actionDownload];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
