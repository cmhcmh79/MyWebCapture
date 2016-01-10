//
//  CZPickerMultiView.m
//  MyWebCapture
//
//  Created by jschoi on 2016. 1. 8..
//  Copyright © 2016년 jschoi. All rights reserved.
//

#import "CZPickerMultiView.h"

#define CZP_FOOTER_HEIGHT 44.0
#define CZP_HEADER_HEIGHT 44.0
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
#define CZP_BACKGROUND_ALPHA 0.9
#else
#define CZP_BACKGROUND_ALPHA 0.3
#endif

@interface CZPickerMultiView ()

// 테이블 뷰 리스트
@property (strong, nonatomic) NSMutableArray<UITableView *> *tableviews;

// 테이블 뷰에서 표시할 문자열과 선택된 것 저장
@property (strong, nonatomic) NSMutableArray<NSArray<NSString *> *> *tableStrings;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *selectedRows;

// confirm 버튼 동작
@property (strong, nonatomic) void (^confirmAction)(NSArray *selectedStrings, NSArray<NSNumber *> *selectedRows);
@end

@implementation CZPickerMultiView

#pragma mark - override
- (id)initWithHeaderTitle:(NSString *)headerTitle
        cancelButtonTitle:(NSString *)cancelButtonTitle
       confirmButtonTitle:(NSString *)confirmButtonTitle
{
    NSLog();
    
    self = [super initWithHeaderTitle:headerTitle
                    cancelButtonTitle:cancelButtonTitle
                   confirmButtonTitle:confirmButtonTitle];
    self.needFooterView = YES;
    
    self.tableviews = [[NSMutableArray alloc] init];
    self.tableStrings = [[NSMutableArray alloc] init];
    self.selectedRows = [[NSMutableArray alloc] init];
    
    return self;
}

- (UITableView *)buildTableView
{
    NSLog();
    
    // 테이블 뷰를 추가할 뷰 생성
    CGAffineTransform transform = CGAffineTransformMake(0.8, 0, 0, 0.8, 0, 0);
    CGRect newRect = CGRectApplyAffineTransform(self.frame, transform);
    CGRect viewRect;
    float heightOffset = CZP_HEADER_HEIGHT + CZP_FOOTER_HEIGHT;
    NSInteger maxRow = [self.dataSource numberOfRowsInPickerView:self];

    // 최대 높이 계산
    for(NSArray *strings in self.tableStrings) {
        maxRow = MAX(maxRow, strings.count);
    }
    if(maxRow > 0){
        float height = maxRow * 44.0;
        height = height > newRect.size.height - heightOffset ? newRect.size.height -heightOffset : height;
        viewRect = CGRectMake(0, 44.0, newRect.size.width, height);
    }
    else {
        viewRect = CGRectMake(0, 44.0, newRect.size.width, newRect.size.height - heightOffset);
    }
    UIView *view = [[UIView alloc] initWithFrame:viewRect];
    view.backgroundColor = [UIColor whiteColor];
    
    // 테이블 뷰 생성
    NSUInteger countOfTable = self.tableStrings.count;
    CGFloat widthOfTable = viewRect.size.width / self.tableStrings.count;
    for(int i = 0; i < countOfTable; ++i) {
        CGRect rectTable;
        // 크기
        if(self.tableStrings[i].count > 0) {
            float height = self.tableStrings[i].count * 44.0;
            height = height > newRect.size.height - heightOffset ? newRect.size.height -heightOffset : height;
            rectTable = CGRectMake(widthOfTable * i, 0, widthOfTable, height);
        }
        else {
            rectTable = CGRectMake(widthOfTable * i, 0, widthOfTable, newRect.size.height - heightOffset);
        }
        
        // 테이블 뷰 생성
        UITableView *tableView = [[UITableView alloc] initWithFrame:rectTable style:UITableViewStylePlain];
        [self.tableviews addObject:tableView];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // 가운데 위치로 이동
        tableView.center = CGPointMake(tableView.center.x, viewRect.size.height / 2);
        [view addSubview:tableView];
    }
        
    return (UITableView *)view;
}

- (IBAction)confirmButtonPressed:(id)sender
{
    NSLog();
    if( self.confirmAction ) {
        NSMutableArray *selectedString = [[NSMutableArray alloc] init];
        for( int i  = 0; i < self.tableStrings.count; ++i ) {
            [selectedString addObject:self.tableStrings[i][self.selectedRows[i].longValue]];
        }
        
        self.confirmAction(selectedString, self.selectedRows);
    }
    [super confirmButtonPressed:sender];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableStrings objectAtIndex:[self.tableviews indexOfObject:tableView]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"czpicker_view_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }
    
    // 테이블 뷰 위치
    NSUInteger indexOfTable = [self.tableviews indexOfObject:tableView];
    
    //  선택 표시
    if( self.selectedRows[indexOfTable].longValue  == indexPath.row )
        cell.accessoryType  = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType  = UITableViewCellAccessoryNone;
    
    // 문자열 표시
    cell.textLabel.text = self.tableStrings[indexOfTable][indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 셀 선택 표시 해제
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 체크 표시 설정
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // 변경된 경우만 적용
    NSUInteger indexOfTable = [self.tableviews indexOfObject:tableView];
    if( indexPath.row != self.selectedRows[indexOfTable].longValue ) {
        // 이전 체크 삭제
        [tableView cellForRowAtIndexPath:
         [NSIndexPath indexPathForRow:self.selectedRows[indexOfTable].longValue
                            inSection:indexPath.section]].accessoryType = UITableViewCellAccessoryNone;
        
        // 선택 변경
        NSNumber *number = [NSNumber numberWithLong:indexPath.row];
        [self.selectedRows replaceObjectAtIndex:indexOfTable withObject:number];
    }
}

#pragma mark - public method

/**
 * 입력한 문자열들로 픽커 항목 구성
 */
- (void)addStrings:(NSArray<NSString *> *)strings withDefaultSelect:(NSInteger)seleted
{
    [self.tableStrings addObject:strings];
    
    NSNumber *number = [NSNumber numberWithLong:seleted];
    [self.selectedRows addObject:number];
}

/**
 * confirm 버튼 클릭시 동작을 등록한다.
 */
- (void)setConfirmButtonAction:(void (^)(NSArray *selectedStrings, NSArray<NSNumber *> *selectedRows))action
{
    self.confirmAction = action;
}


@end
