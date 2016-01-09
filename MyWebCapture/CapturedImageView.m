//
//  CapturedImageView.m
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 5..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import "CapturedImageView.h"
#import "IOSUtils.h"
#import "ViewController.h"

// 2메가픽셀
static const CGFloat MEGAPIXCEL_2 = 1024 * 1024 * 2;

@interface CapturedImageView ()

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIView *scaleView;

@end

@implementation CapturedImageView

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 타이틀 적용
    self.navigationBar.topItem.title = self.capturedData.title;
    
    // 이미지 뷰 생성
    UIImage *image = [UIImage imageWithContentsOfFile:[IOSUtils pathDocumentsWithFilename:self.capturedData.filename]];
    self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    // 이미지를 가로를 기준으로 세로를 2메가픽셀 크기로 자름
    CGFloat height = round(MEGAPIXCEL_2 / image.size.width);
    CGFloat remainHeight = image.size.height;
    NSLog(@"image height:%f -> %f", remainHeight, height);
    int count = 0;
    while( remainHeight > 0 ) {
        // 자를 영역
        CGRect rect = CGRectMake(0, count * height, image.size.width, (height > remainHeight) ? remainHeight: height);
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
        
        // 자른 이미지로 뷰 생성
        UIImageView *view = [[UIImageView alloc] initWithFrame:rect];
        view.image = [UIImage imageWithCGImage:imageRef];
        //[self.scrollView addSubview:view];
        [self.scaleView addSubview:view];
        
        /*
         view.layer.borderColor = [UIColor redColor].CGColor;
         view.layer.borderWidth = 1;
         */
        // 다음 영역 준비
        count++;
        remainHeight -= height;
        
        NSLog(@"view[%i] %f %f %f %f",
              count, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    }
    [self.scrollView addSubview:self.scaleView];
    self.scrollView.contentSize = image.size;
    
    // 스케일 범위 설정
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 2.0;
    
    NSLog(@"subview:%li  size:%f-%f  scale:%f-%f:%f", self.scrollView.subviews.count,
          self.scrollView.contentSize.width ,
          self.scrollView.contentSize.height,
          self.scrollView.minimumZoomScale,
          self.scrollView.maximumZoomScale,
          self.scrollView.zoomScale);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - button event

- (IBAction)pressedBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pressedDeleteButton:(id)sender {
    [IOSUtils messageBoxTitle:@"Really Deelte?"
                  withMessage:nil
             onViewController:self
       withCancelButtonAction:nil
           withOkButtonAction:^(UIAlertAction *action) {
               [[DataManager GetSingleInstance] deleteCapturedData:self.capturedData];
               [self dismissViewControllerAnimated:YES completion:nil];               
           }];
}
- (IBAction)pressedWebsiteButton:(id)sender {
    NSLog("web %@", self.capturedData.url);
    ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    view.stringURL = self.capturedData.url;
    /*
    view.completionCallback = ^() {
        [self dismissViewControllerAnimated:NO completion:nil];
    };
     */
    [self presentViewController:view animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSLog();
    return self.scaleView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //NSLog(@"%s", __FUNCTION__);
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    //NSLog(@"%s", __FUNCTION__);
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //NSLog(@"%s", __FUNCTION__);
    [self centerScrollViewContents];
}

// 축소한 이미지를 센터로 이동
- (void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.scaleView.frame;
    
    if( contentsFrame.size.width < boundsSize.width ) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0;
    }
    else {
        contentsFrame.origin.x = 0;
    }
    
    if( contentsFrame.size.height < boundsSize.height ) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0;
    }
    else {
        contentsFrame.origin. y = 0;
    }
    
    self.scaleView.frame = contentsFrame;
}

@end
