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
}

@end
