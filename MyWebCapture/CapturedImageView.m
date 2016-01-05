//
//  CapturedImageView.m
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 5..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import "CapturedImageView.h"

@interface CapturedImageView ()

@end

@implementation CapturedImageView

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}
- (IBAction)pressedWebsiteButton:(id)sender {
}
@end
