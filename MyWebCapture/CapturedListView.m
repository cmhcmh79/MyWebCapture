//
//  CapturedListView.m
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 5..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import "CapturedListView.h"

@interface CapturedListView ()

@end

@implementation CapturedListView

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}


#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"index-row:%li section:%li", indexPath.row, indexPath.section);
    UITableViewCell *cell;
    
    static NSString *cellID = @"CapturedCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = @"capture ....";
    cell.imageView.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    // Configure the cell...
    return cell;
}

@end
