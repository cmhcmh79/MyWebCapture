//
//  DataManager.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 21..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "DataManager.h"
#import "SQLite3Class.h"

static NSString * const DBFileName = @"Bookmarks";

@implementation BookmarkData
@end

@interface DataManager ()

@property (strong, nonatomic) NSMutableArray<BookmarkData *> *listBookmark;
@property (strong, nonatomic) SQLite3Class *database;

/**
 * 북마크 정보를 DB에서 읽어오고 아이콘 이미지도 생성한다.
 */
- (int)loadAllFromFile:(NSString *)filepath;

/**
 * 데이터를 저장할 DB 테이블을 생성한다.
 */
- (int)createDBTable;

/**
 * DB에서 모든 북마크정보를 읽어온다.
 * 읽은 데이터의 개수를 반환한다. 실패시 0보다 작은 값을 리턴
 */
- (int)readAllData;

/**
 * DB에 새로운 데이터를 추가한다. 추가된 데이터의 no 값을 리턴한다.
 */
- (int)insertData:(BookmarkData *)data;

/**
 * DB에 데이터 업데이트, 실패시 0보다 작은 값을 리턴한다.
 */
- (int)updateData:(BookmarkData *)data;
@end

@implementation DataManager

#pragma mark - singleton

static DataManager *MyInstance = nil;
+ (DataManager *)GetSingleInstance;
{
    @synchronized(MyInstance) {
        if( MyInstance == nil ) {
            MyInstance = [[DataManager alloc] init];
            
            // 파일에서 데이터를 읽어온다.
            NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            NSString  *filename = [documentsDirectory stringByAppendingPathComponent:DBFileName];
            [MyInstance loadAllFromFile:filename];
        }
    }
    return MyInstance;
}

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if( self ) {
        //_listBookmark = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - getter
- (NSUInteger)getCount
{
    return self.listBookmark.count;
}

#pragma mark - pubic method
/**
 * 새로운 북마크를 마지막에 추가
 */
- (int)addBookmark:(BookmarkData *)bookmark
{
    int result = 0;
    
    // DB에 추가
    
    // 아이콘 이미지가 있으면 파일로 저장
    
    // 저장한 아이콘 파일 이름을 DB에 적용
    
    return result;
}

/**
 * 해당 위치(인덱스)에 있는 북마트 데이터 반환
 */
- (BookmarkData *)bookmarkAtIndex:(NSUInteger)index
{
    return [self.listBookmark objectAtIndex:index];
}


#pragma mark - private method

/**
 * 북마크 정보를 DB에서 읽어오고 아이콘 이미지도 생성한다.
 */
- (int)loadAllFromFile:(NSString *)filepath
{
    int result = 0;
    self.database = [[SQLite3Class alloc] initWithFilePath:filepath];
    
    NSLog(@"Load All (%@)", filepath);
    // 파일이 없으면 새로운 테이블과 기본 북마크 추가
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filepath]) {
        NSLog(@"== creat new DB ==");
        
        if([self createDBTable] < 0)
            return -1;
        
        NSArray *defaultTitle = [NSArray arrayWithObjects:@"Google", @"NAVER", @"Daum", nil];
        NSArray *defaultURL = [NSArray arrayWithObjects:@"http://www.google.co.kr",
                                                        @"http://m.naver.com",
                                                        @"http://m.daum.net", nil];
        for(int i = 0; i < 3; ++i) {
            BookmarkData *data = [[BookmarkData alloc] init];
            data.url = defaultURL[i];
            data.title = defaultTitle[i];
            if( [self insertData:data] < 0 ) {
                return -2;
            }
        }
    }
    
    // DB에서 데이터를 읽어온다
    result = [self readAllData];
    
    // 아이콘 이미지를 읽어온다.
    for( BookmarkData *bookmark in self.listBookmark ) {
        // 파일이 없으면 기본 이미지 로딩
        if( [fileManager fileExistsAtPath:bookmark.iconFileName] ) {
            bookmark.iconImage = [UIImage imageWithContentsOfFile:bookmark.iconFileName];
        }
        else {
            bookmark.iconImage = [UIImage imageNamed:@"icon-default.png"];
        }
    }
    
    return result;
}

/**
 * 데이터를 저장할 DB 테이블을 생성한다.
 */
- (int)createDBTable
{
    int result = 0;
    @try {
        [self.database openAndTransaction];
        
        [self.database executeWithSQL:@"create table BookmarkTable ( no INTEGER PRIMARY KEY, "
                                       " url TEXT, title TEXT, iconfile TEXT, time TEXT );" ];
        
        [self.database closeBeforCommit];
    }
    @catch (NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        result = -1;
    }
    return result;
}

/**
 * DB에서 모든 북마크정보를 읽어온다.
 * 읽은 데이터의 개수를 반환한다. 실패시 0보다 작은 값을 리턴
 */
- (int)readAllData
{
    int result = 0;
    // 북마크 리스트 초기화
    self.listBookmark = [[NSMutableArray alloc] init];
    
    @try {
        [self.database openAndTransaction];
        
        RecordSet *set = [self.database executeWithSQL:@"select no, url, title, iconfile "
                                                        " from BookmarkTable order by no; " ];
        while( set && !set.endOfRecord ) {
            BookmarkData *bookmark = [[BookmarkData alloc] init];
            RecordData *data = [set getCollectDataAtColumnName:@"no"];
            if( data && !data.null )
                bookmark.no = data.intValue;
            
            data = [set getCollectDataAtColumnName:@"url"];
            if( data && !data.null )
                bookmark.url = data.stringValue;

            data = [set getCollectDataAtColumnName:@"title"];
            if( data && !data.null )
                bookmark.title = data.stringValue;

            data = [set getCollectDataAtColumnName:@"iconfile"];
            if( data && !data.null )
                bookmark.iconFileName = data.stringValue;

            [self.listBookmark addObject:bookmark];
            [set next];
            ++result;
        }
        
        [self.database closeBeforCommit];
    }
    @catch (NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        result = -1;
    }
    
    return result;
}

/**
 * DB에 새로운 데이터를 추가한다. 추가된 데이터의 no 값을 리턴한다.
 */
- (int)insertData:(BookmarkData *)data
{
    int result = 0;
    @try {
        [self.database openAndTransaction];
        
        RecordSet *set = [self.database executeWithSQL:
            [NSString stringWithFormat:@"insert into BookmarkTable (url, title, iconfile, time) "
                " values('%@', '%@', '%@', datetime('now', 'localtime') ); "
                " select no from BookmarkTable where no = last_insert_rowid(); ",
                data.url, data.title, data.iconFileName]  ];
        if( set && !set.endOfRecord ) {
            RecordData *data = [set getCollectDataAtColumnName:@"no"];
            if( data && !data.null )
                result = data.intValue;
        }
        
        [self.database closeBeforCommit];
    }
    @catch (NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        result = -1;
    }

    return result;
}

/**
 * DB에 데이터 업데이트, 실패시 0보다 작은 값을 리턴한다.
 */
- (int)updateData:(BookmarkData *)data
{
    int result = 0;
    return result;
}

@end
