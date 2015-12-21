//
//  DataManager.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 21..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "DataManager.h"

@implementation BookmarkData
@end

@interface DataManager ()

@property (strong, nonatomic) NSMutableArray<BookmarkData *> *listBookmark;

@end

@implementation DataManager

#pragma mark - singleton

static DataManager *MyInstance = nil;
+ (DataManager *)GetSingleInstance;
{
    @synchronized(MyInstance) {
        if( MyInstance == nil )
            MyInstance = [[DataManager alloc] init];
    }
    return MyInstance;
}

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if( self ) {
        _listBookmark = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - pubic method


#pragma mark - private method

@end
