//
//  CapturedListView.m
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 5..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import "CapturedListView.h"
#import "DataManager.h"
#import "IOSUtils.h"
#import "CapturedImageView.h"
#import "ViewController.h"

/**
 *  테이블 뷰 셀안에 있는 뷰들의 테그 번호 정의
 */
static const int TAG_CELL_IMAGE = 101;
static const int TAG_CELL_TITLE = 102;
static const int TAG_CELL_URL   = 103;
static const int TAG_CELL_DATE  = 104;

/**
 * 갭쳐 데이터 정열령을 위한 피커 뷰에 표시할 문자열
 */
static NSString * const stringOrder[2][2] = { {@"Time", @"Title"}, {@"Ascending", @"Descending"}};

@interface CapturedListView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonOrder;

// 픽커뷰 정의
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIButton *pickerButton;

// 정렬방식 정의
@property (nonatomic) NSInteger selectedOrder;
@property (nonatomic) NSInteger selectedDir;

@end

@implementation CapturedListView

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 정렬 방식 선택
    self.selectedOrder = 0;
    self.selectedDir = 1;
    
    self.dataManager = [DataManager GetSingleInstance];
    /*
    [self.dataManager readCapturedDataOrderby:[stringOrder[0][self.selectedOrder] lowercaseString]
                                withAscending:[stringOrder[1][self.selectedDir] isEqualToString:stringOrder[1][0]]];
    */
    self.buttonOrder.title = [NSString stringWithFormat:@"Order by %@ %@",
                              stringOrder[0][self.selectedOrder],
                              stringOrder[1][self.selectedDir] ];

    NSLog("captured count:%li", self.dataManager.capturedDatas.count);
    
    
    // 테이블뷰 높이 설정
    self.tableView.rowHeight = 100;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.dataManager readCapturedDataOrderby:[stringOrder[0][self.selectedOrder] lowercaseString]
                                withAscending:[stringOrder[1][self.selectedDir] isEqualToString:stringOrder[1][0]]];
    [self.tableView reloadData];
    NSLog("captured count:%li", self.dataManager.capturedDatas.count);
    
    int count = 0;
    for( UIViewController *view in self.navigationController.viewControllers ) {
        NSLog(@"stack[%i] %@", count++ , NSStringFromClass([view class]));
    }
    
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog();
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 삭제모드 정지
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CapturedImageView *dest = [segue destinationViewController];
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    dest.capturedData = self.dataManager.capturedDatas[indexPath.row];
    //dest.hidesBottomBarWhenPushed = YES;
}


#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataManager.capturedDatas.count;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
*/

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
    
    imageView.layer.borderColor = [UIColor blueColor].CGColor;
    imageView.layer.borderWidth = 0.5;

    /*
    imageView.image = [UIImage imageNamed:@"picture.png"];
    labelTitle.text = @"Title...";
    labelURL.text = @"http://.....";
    labelDate.text = @"2016/1/1...";
     */
    CapturedData *captured = self.dataManager.capturedDatas[indexPath.row];
    labelTitle.text = captured.title;
    labelURL.text = captured.url;
    labelDate.text = captured.datetime;
    
    NSLog(@"row[%li] label:%f-%f  cell:%f",
          indexPath.row, labelURL.frame.origin.x, labelURL.frame.size.width, cell.frame.size.width);
    
    // 이미지 로딩
    UIImage *image = [UIImage imageWithContentsOfFile:[IOSUtils pathDocumentsWithFilename:captured.filename]];
    
    // 가로 스케일 기준으로 세로 길이 계산
    CGFloat scale = imageView.frame.size.width / image.size.width;
    CGFloat heigth = imageView.frame.size.height / scale;
    
    // 세로 길이로 잘라 표시
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage],
                                                       CGRectMake(0, 0, image.size.width, MIN(heigth, image.size.height)));
    imageView.image = [UIImage imageWithCGImage:imageRef];

    // 악세사리뷰에 버튼 추가
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[UIImage imageNamed:@"domain.png"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, labelURL.frame.size.height, labelURL.frame.size.height);
    [button addTarget:self action:@selector(pressedWebsiteButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog();
    [IOSUtils messageBoxTitle:@"Really Delete?"
                  withMessage:nil
             onViewController:self
       withCancelButtonAction:nil
           withOkButtonAction:^(UIAlertAction *action) {
               [self.dataManager deleteCapturedData:self.dataManager.capturedDatas[indexPath.row]];
               [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
           } ];
}

#pragma mark - button action

// 웹사이트 연결 버튼
- (void)pressedWebsiteButton:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    NSLog("web[%li]-%@", index.row, self.dataManager.capturedDatas[index.row].url);
    ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    view.stringURL = self.dataManager.capturedDatas[index.row].url;
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)pressedOrderButton:(id)sender {
    NSLog();
    // 삭제 모드 해제
    [self.tableView setEditing:NO animated:YES];
    
    // 모든 뷰 상태 disable 만들기
    for(UIView *subView in self.view.subviews) {
        subView.userInteractionEnabled = NO;
        subView.alpha = 0.3;
    }

    // 픽커뷰 생성
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.center = self.view.center;
    self.pickerView.layer.borderColor = [UIColor grayColor].CGColor;
    self.pickerView.layer.borderWidth = 1;
    self.pickerView.layer.cornerRadius = 10;
    self.pickerView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.pickerView];
    
    // 현제 설정 선택
    [self.pickerView selectRow:self.selectedOrder inComponent:0 animated:NO];
    [self.pickerView selectRow:self.selectedDir inComponent:1 animated:NO];
    
    // 버튼 생성
    self.pickerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.pickerButton.frame = CGRectMake(self.pickerView.frame.origin.x,
                              self.pickerView.frame.origin.y + self.pickerView.frame.size.height + 10,
                              self.pickerView.frame.size.width,
                              30 );
    
    [self.pickerButton  setTitle:@"Select Order" forState:UIControlStateNormal];
    self.pickerButton.layer.borderWidth = 1;
    self.pickerButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.pickerButton.layer.cornerRadius = 10;
    self.pickerButton.layer.masksToBounds = YES;
    self.pickerButton.backgroundColor = [UIColor whiteColor];
    [self.pickerButton addTarget:self action:@selector(pressedSelectOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pickerButton];
}

// 픽커 뷰 선택 완료시
- (void)pressedSelectOrderButton:(id)sender
{
    NSLog();
    self.selectedOrder = [self.pickerView selectedRowInComponent:0];
    self.selectedDir = [self.pickerView selectedRowInComponent:1];
    
    // 버튼 타이틀 변경
    self.buttonOrder.title = [NSString stringWithFormat:@"Order by %@ %@",
                              stringOrder[0][self.selectedOrder],
                              stringOrder[1][self.selectedDir] ];
    
    // 픽커 제거
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    
    // 버튼 제거
    [self.pickerButton removeFromSuperview];
    self.pickerButton = nil;
    
    // 모든 뷰 활성화
    for(UIView *subView in self.view.subviews) {
        subView.userInteractionEnabled = YES;
        subView.alpha = 1.0;
    }
    
    // 갭쳐 데이터 다시 읽기
    [self.dataManager readCapturedDataOrderby:[stringOrder[0][self.selectedOrder] lowercaseString]
                                withAscending:[stringOrder[1][self.selectedDir] isEqualToString:stringOrder[1][0]]];
    [self.tableView reloadData];
}

- (IBAction)pressedDeleteButton:(id)sender {
    NSLog();
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

#pragma mark - PickerView datasource , delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //return [NSString stringWithFormat:@"string %li - %li", row, component];
    return stringOrder[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"row:%li componet:%li", row, component);
}
@end
