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
@property (nonatomic) NSInteger indexOfSeleted;

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
@property (strong, nonatomic) UIView *currentView;
@property (nonatomic) CGPoint pointPrev;
@property (nonatomic) BOOL isMoved;
@property (strong, nonatomic) NSIndexPath *selectedIndex;

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
    return self.dataManager.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
 
    BookmarkData *bookmark = [self.dataManager bookmarkAtIndex:indexPath.row];
    //NSLog(@"collection cell(%li) title:%@", indexPath.row, bookmark.title);
    
    // Configure the cell    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:TAG_CELL_LABEL];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL_IMAGE];
    
    label.text = bookmark.title;
    imageView.image = bookmark.iconImage;
    
    UILongPressGestureRecognizer* longClickEvent = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickCell:)];
    
    // 제스터가 없는 경우 추가
    BOOL isFind = NO;
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        if( [gesture isKindOfClass:[UILongPressGestureRecognizer class]] )
             isFind = YES;
    }
    if( !isFind ) {
        [cell addGestureRecognizer:longClickEvent];
        NSLog(@"add long press gesture cel:%li", indexPath.row);
    }
    
    cell.layer.borderColor = [UIColor redColor].CGColor;
    cell.layer.borderWidth = 0.0f;
    
    return cell;
}

#pragma mark - gesture callback

- (UIImageView *)snapshotImageView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc] initWithImage:image];
}

- (void)longClickCell:(UILongPressGestureRecognizer *)sender
{
    NSLog();
     
    if (sender.state == UIGestureRecognizerStateBegan){
        // 플리킹 시작
        self.pointPrev = [sender locationInView:self.view];
        self.isMoved = NO;
        
        // 해당 뷰의 선택된 영역의 CGPoint를 가져온다.
        CGPoint currentTouchPosition = [sender locationInView:self.collectionView];
        //NSLog(@"position %f,%f", currentTouchPosition.x, currentTouchPosition.y);
        // 테이블 뷰의 위치의 Cell의 indexPath를 가져온다
        //NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender.view];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
        NSLog(@"cell index %li  (%f,%f)",indexPath.row, self.pointPrev.x, self.pointPrev.y);
        self.indexOfSeleted = indexPath.row;
        self.selectedIndex = indexPath;
        
        /*
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        view.backgroundColor = [UIColor redColor];
        UIButton *button = [[ UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        button.backgroundColor = [ UIColor yellowColor];
        [button setTitle:@"copy" forState:UIControlStateNormal];
        [view addSubview:button];
        [self.view addSubview:view];
         */
        // 선택된 셀과 같은 뷰 생성
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        //NSLog("%f, %f", point.x, point.y);
        CGRect viewRect = cell.frame;
        viewRect.origin.x += self.collectionView.frame.origin.x;
        viewRect.origin.y += self.collectionView.frame.origin.y;
        self.currentView = [[UIView alloc] initWithFrame:viewRect];
        UIImageView *imageView = [self snapshotImageView:cell];
        [self.currentView addSubview:imageView];
        [self.view addSubview:self.currentView];
        
        // 셀 확대 애니메시션
        cell.alpha = 0.0f;

        [UIView
         animateWithDuration:0.3
         delay:0.0
         options:UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             self.currentView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
             self.currentView.alpha = 0.7f;
         }
         completion:nil];
    }
    else if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint currentTouchPosition = [sender locationInView:self.collectionView];
        //NSLog(@"position %f,%f", currentTouchPosition.x, currentTouchPosition.y);
        // 테이블 뷰의 위치의 Cell의 indexPath를 가져온다
        //NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender.view];
        //NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
        NSIndexPath *indexPath = self.selectedIndex;
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        NSLog(@"cell index %li", indexPath.row);
        // 셀 복귀 애니메이션
        [UIView
         animateWithDuration:0.3
         delay:0.0
         options:UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             self.currentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
             CGRect frame = cell.frame;
             frame.origin.x += self.collectionView.frame.origin.x;
             frame.origin.y += self.collectionView.frame.origin.y;
             self.currentView.frame = frame;
             self.currentView.alpha = 1.0f;
             
         }
         completion:^(BOOL finished){
             NSLog(@"long press finish");
             cell.alpha = 1.0f;
             [self.currentView removeFromSuperview];
             self.currentView = nil;
             
             // 움직이지 않은 경우만 메뉴 표시
             if( !self.isMoved ) {
                 [self becomeFirstResponder];
                 UIMenuItem *button1 = [[UIMenuItem alloc] initWithTitle:@"delete"
                                                                  action:@selector(actionDelete:)];
                 UIMenuItem *button2 = [[UIMenuItem alloc] initWithTitle:@"edit"
                                                                  action:@selector(actionEdit:)];
                 UIMenuController *menu = [UIMenuController sharedMenuController];
                 
                 CGRect cellRect = sender.view.frame;
                 
                 menu.menuItems = [NSArray arrayWithObjects:button1, button2, nil];
                 [menu setTargetRect:cellRect inView:self.collectionView];
                 [menu setMenuVisible:YES animated:YES];
             }
         }];
    }
    else if( sender.state == UIGestureRecognizerStateChanged ) {
        self.isMoved = YES;
        CGPoint pointNow = [sender locationInView:self.view];
        CGRect frame = self.currentView.frame;
        frame.origin.x += pointNow.x - self.pointPrev.x;
        frame.origin.y += pointNow.y - self.pointPrev.y;
        self.currentView.frame = frame;
        self.pointPrev = pointNow;
        NSLog(@"changed... (%f,%f)", pointNow.x, pointNow.y);
    }
}

// becomeFirstResponder에서 호출되어 YES 리턴시 화면에 표시
-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)actionDelete:(id)sender {
    NSLog(@"delete Clicked");
    [IOSUtils messageBoxTitle:@"Delete bookmark?" withMessage:nil onViewController:self
           withOkButtonAction:^(UIAlertAction *action) {
               [self.dataManager deleteBookmarkAtIndex:self.indexOfSeleted];
               [self.collectionView reloadData];
           }
       withCancelButtonAction:nil];
}

- (void)actionEdit:(id)sender {
    NSLog(@"edit Clicked");
    //[self performSegueWithIdentifier:@"EditBookmark" sender:nil];
    //return;
    AddPageViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPageView"];
    dest.stringViewTitle = @"Edit Bookmark";
    dest.bookmark = [self.dataManager bookmarkAtIndex:self.indexOfSeleted];
    dest.bookmarkIndex = self.indexOfSeleted;
    
    dest.complitCallback = ^() {
        NSLog("dismiss completion");
        [self.collectionView reloadData];
    };
    
    
    //[self.navigationController pushViewController:dest animated:YES];
    //[self showViewController:dest sender:self];
    
    [self presentViewController:dest animated:YES completion:^ {
        NSLog("present completion");
    }];
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
