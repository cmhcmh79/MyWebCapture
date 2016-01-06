//
//  CapturedListView.m
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 5..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import "CapturedListView.h"
#import "DataManager.h"

/**
 *  테이블 뷰 셀안에 있는 뷰들의 테그 번호 정의
 */
static const int TAG_CELL_IMAGE = 101;
static const int TAG_CELL_TITLE = 102;
static const int TAG_CELL_URL   = 103;
static const int TAG_CELL_DATE  = 104;

@interface CapturedListView ()

@property (strong, nonatomic) DataManager *dataManager;
@end

@implementation CapturedListView

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataManager = [DataManager GetSingleInstance];
    [self.dataManager readCapturedData];
    NSLog("captured count:%li", self.dataManager.capturedDatas.count);
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
    return self.dataManager.capturedDatas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"index-row:%li section:%li", indexPath.row, indexPath.section);
    UITableViewCell *cell;
    
    static NSString *cellID = @"CapturedCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    UIImageView *imageView = [cell viewWithTag:TAG_CELL_IMAGE];
    UILabel *labelTitle = [cell viewWithTag:TAG_CELL_TITLE];
    UILabel *labelURL = [cell viewWithTag:TAG_CELL_URL];
    UILabel *labelDate = [cell viewWithTag:TAG_CELL_DATE];

    /*
    imageView.image = [UIImage imageNamed:@"picture.png"];
    labelTitle.text = @"Title...";
    labelURL.text = @"http://.....";
    labelDate.text = @"2016/1/1...";
     */
    labelTitle.text = self.dataManager.capturedDatas[indexPath.row].title;
    labelURL.text = self.dataManager.capturedDatas[indexPath.row].url;
    labelDate.text = self.dataManager.capturedDatas[indexPath.row].datetime;

    return cell;
}

@end
