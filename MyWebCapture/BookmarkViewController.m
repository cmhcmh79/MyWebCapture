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
@interface BookmarkViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation BookmarkViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataManager = [DataManager GetSingleInstance];
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
    ViewController *dest = [segue destinationViewController];
    dest.completionCallback = ^() {
        [self.collectionView reloadData];
    };
    
    UICollectionViewCell *cell = sender;
    NSInteger index = [self.collectionView indexPathForCell:cell].row;
    NSLog("segue cell : %li", index);
    
    dest.bookmark = [[self.dataManager bookmarkAtIndex:index] copy];
    dest.bookmarkIndex = index;
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
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:2];
    
    label.text = bookmark.title;
    imageView.image = bookmark.iconImage;
    
    UILongPressGestureRecognizer* longClickEvent = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickCell:)];
    [cell addGestureRecognizer:longClickEvent];
    
    /*
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 1.0f;
     */
    
    return cell;
}

#pragma mark - gesture callback

- (void)longClickCell:(UILongPressGestureRecognizer *)sender
{
    NSLog();
    
    if (sender.state == UIGestureRecognizerStateBegan){
        
        // 해당 뷰의 선택된 영역의 CGPoint를 가져온다.
        //CGPoint currentTouchPosition = [sender locationInView:[sender view]];
        
        // 테이블 뷰의 위치의 Cell의 indexPath를 가져온다
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender.view];
        //NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
        
        NSLog(@"cell index %li",indexPath.row);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        view.backgroundColor = [UIColor redColor];
        
        [self.view addSubview:view];
        
        
    }
}


@end
