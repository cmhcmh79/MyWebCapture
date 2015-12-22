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
    NSLog("segue cell : %li", cell.tag);
    
}


#pragma mark - collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataManager.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
 
    BookmarkData *bookmark = [self.dataManager bookmarkAtIndex:indexPath.row];
    NSLog(@"collection cell(%li) title:%@", indexPath.row, bookmark.title);
    
    // Configure the cell
    
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 1.0f;
    cell.tag = indexPath.row;
 
    return cell;
}

@end
