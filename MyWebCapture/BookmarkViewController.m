//
//  BookmarkViewController.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 22..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "BookmarkViewController.h"
#import "ViewController.h"
#import "DataManager.h"
#import "AddPageViewController.h"
#import "IOSUtils.h"

@interface BookmarkViewController ()  <UISearchResultsUpdating, UISearchBarDelegate,
                                       UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) DataManager *dataManager;
//@property (nonatomic) NSInteger indexOfSeleted;

// search controller
@property (strong, nonatomic) UITableViewController *searchResult;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet UIView *viewTop;

// 검색 결과 리스트
@property (strong, nonatomic) NSArray<NSString *> *titleOfSection;
@property (strong, nonatomic) NSArray<NSMutableArray *> *listOfSection;
@property (strong, nonatomic) NSMutableArray<BookmarkData *> *bookmarkSearch;
@property (strong, nonatomic) NSMutableArray<NSString *> *googleSearch;
@property (strong, nonatomic) NSMutableArray<NSString *> *websiteeSearch;

// 플리킹을 준비
@property (strong, nonatomic) UIView *iconView;
@property (nonatomic) CGPoint pointPrev;
@property (nonatomic) BOOL isMoved;
@property (nonatomic) BOOL isRelocationed;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
@property (strong, nonatomic) NSMutableArray<BookmarkData *> *listOfBookmark;
@property (strong, nonatomic) NSTimer *timerShakeIcons;
@property (nonatomic) BOOL isShakeIcons;

// 제스처
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic) CFTimeInterval defaultLongPressDuration;
@end

@implementation BookmarkViewController

/**
 * 콜렉션 셀의 테그 번호
 */
static const int TAG_CELL_LABEL = 1;
static const int TAG_CELL_IMAGE = 2;

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog();
    
    self.dataManager = [DataManager GetSingleInstance];
    
    self.searchResult = [[UITableViewController alloc] init];
    self.searchResult.tableView.delegate = self;
    self.searchResult.tableView.dataSource = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResult];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    
    // autoresizing
    self.searchController.searchBar.frame = self.viewTop.bounds;
    self.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.viewTop addSubview:self.searchController.searchBar];

    self.definesPresentationContext = YES;
    
    // 검색 결과 리스트 초기화
    self.titleOfSection = [[NSArray alloc] initWithObjects:@"Website", @"Google Search", @"Bookmarks", nil];
    self.bookmarkSearch = [[NSMutableArray alloc] init];
    self.googleSearch = [[NSMutableArray alloc] init];
    self.websiteeSearch = [[NSMutableArray alloc] init];
    self.listOfSection = [[NSArray alloc] initWithObjects: self.websiteeSearch, self.googleSearch, self.bookmarkSearch, nil];
    
    // 북마크 아이콘 위치 정보 설정
    self.listOfBookmark = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.dataManager.count; ++i) {
        [self.listOfBookmark addObject:[self.dataManager bookmarkAtIndex:i]];
    }
    
    // 제스처 초기화
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickCell:)];
    [self.view addGestureRecognizer:self.longPressGesture];
    self.defaultLongPressDuration = self.longPressGesture.minimumPressDuration;
    self.isShakeIcons = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return NO;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"segue");
    /*
    if([segue.identifier isEqualToString:@"EditBookmark"]) {
        AddPageViewController *dest = segue.destinationViewController;
        dest.stringViewTitle = @"Edit Bookmark";
        dest.bookmark = [self.dataManager bookmarkAtIndex:self.indexOfSeleted];
        dest.bookmarkIndex = self.indexOfSeleted;
        
        dest.complitCallback = ^() {
            [self.collectionView reloadData];
        };
        
        return;
    }
    */
    
    
    ViewController *dest = [segue destinationViewController];
    dest.completionCallback = ^() {
        self.searchController.searchBar.text = @"";
        [self.searchController dismissViewControllerAnimated:NO completion:nil];
        
        // 북마크 아이콘 위치 정보 설정
        self.listOfBookmark = [[NSMutableArray alloc] init];
        for(int i = 0; i < self.dataManager.count; ++i) {
            [self.listOfBookmark addObject:[self.dataManager bookmarkAtIndex:i]];
        }

        [self.collectionView reloadData];
    };
    
    dest.preCompletionCallback = ^(){
        NSLog(@"====");
        self.searchController.searchBar.text = @"";
    };
    
    
    if( [sender isKindOfClass:[NSString class]] ) {
        // 검색결과 웹사이트(url string)로 이동
        dest.stringURL = sender;
        NSLog(@"URL >%@", dest.stringURL);
    }
    else if( [sender isKindOfClass:[BookmarkData class]] ) {
        // 검색결과 북마크
        dest.bookmark = sender;
        dest.bookmarkIndex = [self.dataManager indexOfBookmark:sender];
        dest.stringURL = dest.bookmark.url;
    }
    else {
        // 콜렉션 뷰에서 이동
        UICollectionViewCell *cell = sender;
        NSInteger index = [self.collectionView indexPathForCell:cell].row;
        NSLog("segue cell : %li", index);

        dest.bookmark = [self.dataManager bookmarkAtIndex:index];
        dest.bookmarkIndex = index;
        dest.stringURL = dest.bookmark.url;
    }
    
}


#pragma mark - collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listOfBookmark.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
 
    //BookmarkData *bookmark = [self.dataManager bookmarkAtIndex:indexPath.row];
    //NSLog(@"collection cell(%li) title:%@", indexPath.row, bookmark.title);
    BookmarkData *bookmark = self.listOfBookmark[indexPath.row];
    
    // Configure the cell    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:TAG_CELL_LABEL];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL_IMAGE];
    
    label.text = bookmark.title;
    imageView.image = bookmark.iconImage;
    imageView.layer.cornerRadius = 13.0;
    imageView.layer.masksToBounds = YES;
    
    /*
    // 제스터가 없는 경우 추가
    BOOL isFind = NO;
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        if( [gesture isKindOfClass:[UILongPressGestureRecognizer class]] )
             isFind = YES;
    }
    if( !isFind ) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(longClickCell:)];
        [cell addGestureRecognizer:longPressGesture];
        NSLog(@"add long press gesture cel:%li", indexPath.row);
    }
     */

    /*
    cell.layer.borderColor = [UIColor redColor].CGColor;
    cell.layer.borderWidth = 0.0f;
    */
    
    return cell;
}

// 섹션 여백 설정
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets inset = { 20, 20, 0 , 20};
    return inset;
}


#pragma mark - timer action
// 모든 셀을 흔든다.
- (void)actionShakeIcons:(NSTimer *)timer
{
    static int step = 0;
    static CGFloat angle[2] = {3.0f / 180 * M_PI , -3.0f / 180 * M_PI };
    step = (step + 1) & 0x01;
    
    for(int i = 0; i < self.listOfBookmark.count; ++i) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [UIView
         animateWithDuration:0.1
         delay:0.0
         options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
         animations:^(){
             cell.transform = CGAffineTransformMakeRotation(angle[step]);
         }
         completion:nil];
    }
}

// 타이머를 정지하고 아이콘 위치를 정위치로 한다.
- (void)stopShakeIcons
{
    [self.timerShakeIcons invalidate];
    self.timerShakeIcons = nil;

    // 모든 아이콘 정위치
    for(int i = 0; i < self.listOfBookmark.count; ++i) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.transform = CGAffineTransformMakeRotation(0);
    }
    
}

#pragma mark - icon moving

// 아이콘 움직을 정지한다.
- (void)stopMovingIcon
{
    // 아이콘 움직임 상태가 아니면 아무런 동작 없음
    if( !self.isShakeIcons )
        return;
    
    // 아이콘에 재배치된 경우 데이터 저장
    if( self.isRelocationed ) {
        // 위치정보 업데이트
        int position = 1;
        for(BookmarkData *data in self.listOfBookmark)
            data.position = position++;
        [self.dataManager updateBookmarkPositions:self.listOfBookmark];
    }
    
    [self stopShakeIcons];
    self.isShakeIcons = NO;
    
    // 롱 키 제스쳐 시간 복귀
    self.longPressGesture.minimumPressDuration = self.defaultLongPressDuration;
}

// 해당 뷰를 갭쳐하여 이미지 뷰로 리턴
- (UIImageView *)snapshotImageView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc] initWithImage:image];
}

// 주어진 인덱스의 아이콘을 선택한다.
- (void)selectIcon:(NSIndexPath *)indexPath
{
    // 선택한 아이콘의 움직임 초기화
    self.isMoved = NO;
    
    // 선택된 셀을 갭쳐하여 아이콘 뷰 생성
    self.selectedIndex = indexPath;
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [self snapshotImageView:cell];

    CGRect viewRect = [self.view convertRect:cell.frame fromView:self.collectionView];
    self.iconView = [[UIView alloc] initWithFrame:viewRect];
    [self.iconView addSubview:imageView];
    [self.view addSubview:self.iconView];

    // 확대 애니메이션 시작
    cell.hidden = YES;
    
    [UIView
     animateWithDuration:0.3
     delay:0.0
     options:UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.iconView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
         self.iconView.alpha = 0.7f;
     }
     completion:nil];
    
    // 아이콘 흔들기 시작
    if( !self.isShakeIcons ) {
        self.isShakeIcons = YES;
        self.timerShakeIcons = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                target:self
                                                              selector:@selector(actionShakeIcons:)
                                                              userInfo:nil
                                                               repeats:YES];
    }
}

// 현재의 아이콘을 주어진 위치로 이동한다.
- (void)movingIcon:(CGPoint) nowPoint
{
    // 움직임 설정
    self.isMoved = YES;
    
    // 아이콘 뷰 이동
    CGPoint iconCenter = self.iconView.center;
    iconCenter.x += nowPoint.x - self.pointPrev.x;
    iconCenter.y += nowPoint.y - self.pointPrev.y;
    self.iconView.center = iconCenter;
    self.pointPrev = nowPoint;
    
    // 움직인 아이콘의 중심 좌표가 새로운 셀의 위치인가 확인
    CGPoint center = [self.collectionView convertPoint:iconCenter fromView:self.view];
    NSIndexPath *destIndex = [self.collectionView indexPathForItemAtPoint:center];
    
    if( destIndex && self.selectedIndex.row != destIndex.row ) {
        // 다른 셀 영역이면 그 영역에 자신의 아이콘을 이동
        NSLog(@"change index %li -> %li", self.selectedIndex.row, destIndex.row);
        
        // 북마크 데이터 이동
        BookmarkData *data = self.listOfBookmark[self.selectedIndex.row];
        [self.listOfBookmark removeObjectAtIndex:self.selectedIndex.row];
        [self.listOfBookmark insertObject:data atIndex:destIndex.row];
        
        // 셀 이동
        [self.collectionView moveItemAtIndexPath:self.selectedIndex toIndexPath:destIndex];
        self.selectedIndex = destIndex;
        
        self.isRelocationed = YES;
    }
}

// 선택한 아이콘의 움직을 마무리 한다.
- (void)finishedMovingIcon
{
    // 아이콘을 셀 위치로 이동
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.selectedIndex];
    
    // 셀 복귀 애니메이션
    [UIView
     animateWithDuration:0.3
     delay:0.0
     options:UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.iconView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
         self.iconView.center = [self.view convertPoint:cell.center fromView:self.collectionView];
         self.iconView.alpha = 1.0f;
     }
     completion:^(BOOL finished){
         // 아이콘 뷰 해제
         cell.hidden= NO;
         [self.iconView removeFromSuperview];
         self.iconView = nil;

         // 아이콘이 움직이지 않은 경우만 메뉴 팝업
         if( !self.isMoved ) {
             NSLog(@"popup menu (index:%li)", self.selectedIndex.row);
             [self becomeFirstResponder];
             
             UIMenuItem *button1 = [[UIMenuItem alloc] initWithTitle:@"delete"
                                                              action:@selector(actionDelete:)];
             UIMenuItem *button2 = [[UIMenuItem alloc] initWithTitle:@"edit"
                                                              action:@selector(actionEdit:)];
             
             UIMenuController *menu = [UIMenuController sharedMenuController];
             menu.menuItems = [NSArray arrayWithObjects:button1, button2, nil];
             [menu setTargetRect:cell.frame inView:self.collectionView];
             [menu setMenuVisible:YES animated:YES];
         }
     } ];
}

#pragma mark - UIMenuController handler
// becomeFirstResponder에서 호출되어 YES 리턴시 화면에 표시
-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)actionDelete:(id)sender {
    NSLog(@"delete Clicked");
    return;
    [IOSUtils messageBoxTitle:@"Delete bookmark?" withMessage:nil onViewController:self
           withOkButtonAction:^(UIAlertAction *action) {
               [self.dataManager deleteBookmarkAtIndex:self.selectedIndex.row];
               
               // 북마크 아이콘 위치 정보 설정
               self.listOfBookmark = [[NSMutableArray alloc] init];
               for(int i = 0; i < self.dataManager.count; ++i) {
                   [self.listOfBookmark addObject:[self.dataManager bookmarkAtIndex:i]];
               }
               
               [self.collectionView reloadData];
           }
       withCancelButtonAction:nil];
}

- (void)actionEdit:(id)sender {
    NSLog(@"edit Clicked");
    return;
    //[self performSegueWithIdentifier:@"EditBookmark" sender:nil];
    //return;
    AddPageViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPageView"];
    dest.stringViewTitle = @"Edit Bookmark";
    dest.bookmark = [self.dataManager bookmarkAtIndex:self.selectedIndex.row];
    dest.bookmarkIndex = self.selectedIndex.row;
    
    dest.complitCallback = ^() {
        NSLog("dismiss completion");
        // 북마크 아이콘 위치 정보 설정
        self.listOfBookmark = [[NSMutableArray alloc] init];
        for(int i = 0; i < self.dataManager.count; ++i) {
            [self.listOfBookmark addObject:[self.dataManager bookmarkAtIndex:i]];
        }
        
        [self.collectionView reloadData];
    };
    
    
    //[self.navigationController pushViewController:dest animated:YES];
    //[self showViewController:dest sender:self];
    
    [self presentViewController:dest animated:YES completion:^ {
        NSLog("present completion");
    }];
}


#pragma mark - gesture callback
- (void)longClickCell:(UILongPressGestureRecognizer *)sender
{
    NSLog();
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"long press began");
        // 셀을 선택하였는지 확인
        NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:[sender locationInView:self.collectionView]];
        if( index == nil ) {
            // 셀 이외의 영역을 선택한 경우
            [self stopMovingIcon];
            return;
        }
        
        // 셀을 클랙한 경우
        
        // 처음으로 아이콘 이동모드로 진입한 경우
        if( !self.isShakeIcons ) {
            // 아이콘 위치 이동 상태 초기화
            self.isRelocationed = NO;
            
            // 다음 클릭은 바로 이벤트 발생
            self.longPressGesture.minimumPressDuration = 0.0;
        }
        
        // 아이콘 선택 작업
        [self selectIcon:index];
        
        // 아이콘 이동 추적을 위한 좌표 저장
        self.pointPrev = [sender locationInView:self.view];
    }
    else if( self.isShakeIcons && sender.state == UIGestureRecognizerStateChanged ) {
        //NSLog(@"long press changed");
        [self movingIcon:[sender locationInView:self.view]];
    }
    else if (self.isShakeIcons && sender.state == UIGestureRecognizerStateEnded){
        NSLog(@"long press ended");
        [self finishedMovingIcon];
    }
}


#pragma mark - SearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSLog(@"search string:%@", searchController.searchBar.text);
    NSString *searhString = searchController.searchBar.text;
    
    // website
    [self searchWebsite:searhString];
    
    // goole search
    [self searchGoogle:searhString];
    
    // bookmarks
    [self searchBookmark:searhString];
    
    [self.searchResult.tableView reloadData];
}

/**
 * 유효한 웹사이트 주소를 매핑
 */
- (void)searchWebsite:(NSString *)searchString;
{
    [self.websiteeSearch removeAllObjects];
    
    // 모두 소문자로 변경
    NSString *url = [searchString lowercaseString];
    
    // http:// or https:// 로 시작하지 않는 경우 http:// 붙임
    if( ![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] ) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    // 유효한 형식의 url 확인
    if( [IOSUtils isValidateURL:url] )
        [self.websiteeSearch addObject:url];
}

/**
 * 구글 검색어 제안
 */
- (void)searchGoogle:(NSString *)searchString
{
    [self.googleSearch removeAllObjects];
}

/**
 * 저장된 북마크 리스트에서 검색
 */
- (void)searchBookmark:(NSString *)searchString
{
    [self.bookmarkSearch removeAllObjects];
    for(int i = 0; i < self.dataManager.count; ++i) {
        BookmarkData *bookmark = [self.dataManager bookmarkAtIndex:i];
        if( [bookmark.title rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0 ) {
            // 제목에서 문자열을 찾은 경우
            [self.bookmarkSearch addObject:bookmark];
            continue;
        }

        if( [bookmark.url rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0 ) {
            // URL에서 문자열을 찾은 경우
            [self.bookmarkSearch addObject:bookmark];
        }
    }
}
/*
// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSLog();
    [self updateSearchResultsForSearchController:self.searchController];
}
*/

#pragma mark - SearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    NSLog(@"string:%@", self.searchController.searchBar.text);
    
    NSString *url = [self.searchController.searchBar.text lowercaseString];
    if( ![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] ) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    // 유효한 형식의 url 확인
    if( [IOSUtils isValidateURL:url] ) {
        [self performSegueWithIdentifier:@"ViewWeb" sender:url];;
    }
    else {
        // 구글 검색 https://www.google.com/search?q=%@
        [self performSegueWithIdentifier:@"ViewWeb"
                                  sender:[NSString stringWithFormat:@"https://www.google.com/search?q=%@",
                                          self.searchController.searchBar.text]];;
    }
}


#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //NSLog();
    
    return self.listOfSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //NSLog();
    //return [NSString stringWithFormat:@"section-%li", section];
    // 검색결과기 있는 경우만 해더 표시
    if( self.listOfSection[section].count )
        return self.titleOfSection[section];
    else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"section:%li", section);
    return self.listOfSection[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"index-row:%li section:%li", indexPath.row, indexPath.section);
    UITableViewCell *cell;
    if( self.searchResult.tableView == tableView ) {
        //NSLog(@"search result table view");
        static NSString *cellID = @"SearchCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        // 북마크 표시
        if( self.listOfSection[indexPath.section] == self.bookmarkSearch ) {
            BookmarkData *bookmark = self.bookmarkSearch[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", bookmark.title, bookmark.url];
        }
        else if( self.listOfSection[indexPath.section] == self.websiteeSearch ) {
            // 웹사이트 제안
            cell.textLabel.text = self.websiteeSearch[indexPath.row];
        }
    }

    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"select section:%li row:%li", indexPath.section, indexPath.row);
    if( self.searchResult.tableView == tableView ) {
        [self.searchController.searchBar resignFirstResponder];
        
        if( self.listOfSection[indexPath.section] == self.bookmarkSearch ) {
            // 북마크 검색 결과
            [self performSegueWithIdentifier:@"ViewWeb" sender:self.bookmarkSearch[indexPath.row]];
        }
        else if( self.listOfSection[indexPath.section] == self.websiteeSearch ) {
            // 웹사이트 제안
            [self performSegueWithIdentifier:@"ViewWeb" sender:self.websiteeSearch[indexPath.row]];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 2;
}

@end
