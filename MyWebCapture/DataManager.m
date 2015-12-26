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

- (id)copyWithZone:(NSZone *)zone
{
    BookmarkData *copyedData = [BookmarkData allocWithZone:zone];
    
    copyedData.no = self.no;
    copyedData.url = self.url;
    copyedData.title = self.title;
    copyedData.iconFileName = self.iconFileName;
    copyedData.iconImage = self.iconImage;

    return copyedData;
}

@end

@interface DataManager ()

@property (strong, nonatomic) NSMutableArray<BookmarkData *> *listBookmark;
@property (strong, nonatomic) SQLite3Class *database;
@property (strong, nonatomic, readonly) NSString *documentsDirectory;

/**
 * 주어진 번호를 이용하여 아이콘 이름을 생성한다.
 */
- (NSString *) iconNameWithNumber:(int)no;

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

/**
 * DB에서 데이터를 삭제한다. 실패시 0보다 작은 값 리턴
 */
- (int)deleteData:(BookmarkData *)data;
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
            NSString  *filename = [MyInstance.documentsDirectory stringByAppendingPathComponent:DBFileName];
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
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsDirectory = [paths objectAtIndex:0];
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
    if( (result = [self insertData:bookmark]) < 0 )
        return -1;
    
    bookmark.no = result;
    
    // 아이콘 이미지가 있으면 파일로 저장
    if( bookmark.iconImage ) {
        NSData *icon = UIImagePNGRepresentation(bookmark.iconImage);
        if( icon && icon.length ) {
            // 아이콘 파일을 저장하고 DB에 업데이트
            bookmark.iconFileName = [self iconNameWithNumber:bookmark.no];
            NSString *iconPath = [self.documentsDirectory stringByAppendingPathComponent:bookmark.iconFileName];
            [icon writeToFile:iconPath atomically:YES];
            
            if( [self updateData:bookmark] < 0 )
                return -3;
        }
    }
    
    // 아이콘이 없으면 디폴트 이미지 로딩
    if( bookmark.iconFileName == nil || bookmark.iconFileName.length == 0 ) {
        bookmark.iconImage = [UIImage imageNamed:@"icon-default.png"];
    }
    
    // 리스트에 추가
    [self.listBookmark addObject:bookmark];
    
    NSLog(@"[%i] title:%@ url:%@ icon-file:%@", bookmark.no, bookmark.title, bookmark.url, bookmark.iconFileName);
    
    return result;
}

/**
 * 해당 위치(인덱스)에 있는 북마트 데이터 반환
 */
- (BookmarkData *)bookmarkAtIndex:(NSUInteger)index
{
    return [self.listBookmark objectAtIndex:index];
}

/**
 * 해당 위치의 북마크 데이터를 변경한다. 실패시 0보다 작은 값 리턴
 */
- (int)updateBookmark:(BookmarkData *)bookmark atIndex:(NSInteger)index
{
    NSLog();
    BOOL isChanged = NO;
    
    // 아이콘 이미지 변경확인
    NSData *iconData = UIImagePNGRepresentation(bookmark.iconImage);
    NSData *iconBeforeData = UIImagePNGRepresentation(self.listBookmark[index].iconImage);
    if( ![iconData isEqualToData:iconBeforeData] ) {
        // 바뀐 아이콘 파일로 저장
        bookmark.iconFileName = [self iconNameWithNumber:bookmark.no];
        NSString *iconPath = [self.documentsDirectory stringByAppendingPathComponent:bookmark.iconFileName];
        [iconData writeToFile:iconPath atomically:YES];
        
        isChanged = YES;
    }
    
    // url 비교
    if( ![bookmark.url isEqualToString:self.listBookmark[index].url] )
        isChanged = YES;
    
    // title 비교
    if( ![bookmark.title isEqualToString:self.listBookmark[index].title] )
        isChanged = YES;
    
    // DB에 업데이트
    if( isChanged ) {
        if( [self updateData:bookmark] < 0 )
            return -2;
    
        [self.listBookmark replaceObjectAtIndex:index withObject:bookmark];
    }

    return 0;
}

/**
 * 해당 위치의 북마크를 삭제한다. 실패시 0보다 작은 값 리턴
 */
- (int)deleteBookmarkAtIndex:(NSInteger)index
{
    BookmarkData *bookmark = self.listBookmark[index];
    // DB에 삭제
    if([self deleteData:bookmark] < 0)
        return -1;
    
    // 아이콘 파일 삭제
    NSString *iconPath = [self.documentsDirectory stringByAppendingPathComponent:bookmark.iconFileName];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    [fileManager removeItemAtPath:iconPath error:nil];
    
    // 리스트에서 삭제
    [self.listBookmark removeObjectAtIndex:index];
    
    return 0;
}

#pragma mark - private method


/**
 * 주어진 번호를 이용하여 아이콘 이름을 생성한다.
 */
- (NSString *) iconNameWithNumber:(int)no
{
    return [NSString stringWithFormat:@"icon-%i.png", no];
}

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
    if( result < 0 )
        return -3;
    
    // 아이콘 이미지를 읽어온다.
    for( BookmarkData *bookmark in self.listBookmark ) {
        // 파일이 없으면 기본 이미지 로딩
        NSString *iconPath = [self.documentsDirectory stringByAppendingPathComponent:bookmark.iconFileName];
        if( [fileManager fileExistsAtPath:iconPath] ) {
            NSLog(@"icon-file:%@", iconPath);
            bookmark.iconImage = [UIImage imageWithContentsOfFile:iconPath];
        }
        else {
            NSLog(@"icon-default:%@", bookmark.iconFileName);
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
    
    // SQLite '문자를 사용하기 위해 '' 로 변경
    NSString *titleReplaced = [data.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    @try {
        [self.database openAndTransaction];
        
        RecordSet *set = [self.database executeWithSQL:
            [NSString stringWithFormat:@"insert into BookmarkTable (url, title, iconfile, time) "
                " values('%@', '%@', '%@', datetime('now', 'localtime') ); "
                " select no from BookmarkTable where no = last_insert_rowid(); ",
                data.url, titleReplaced, data.iconFileName]  ];
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

    // SQLite '문자를 사용하기 위해 '' 로 변경
    NSString *titleReplaced = [data.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    @try {
        [self.database openAndTransaction];
        
        [self.database executeWithSQL:
            [NSString stringWithFormat:@" update BookmarkTable set "
                                        " url = '%@', title = '%@' , iconfile = '%@', "
                                        " time = datetime('now', 'localtime') "
                                        " where no = %i ;",
                                        data.url, titleReplaced, data.iconFileName, data.no]];
        
        [self.database closeBeforCommit];
    }
    @catch( NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        result = -1;
    }
    return result;
}

/**
 * DB에서 데이터를 삭제한다. 실패시 0보다 작은 값 리턴
 */
- (int)deleteData:(BookmarkData *)data
{
    @try {
        [self.database openAndTransaction];
        [self.database executeWithSQL:
           [NSString stringWithFormat:@"delete from BookmarkTable where no = %i", data.no]];
        [self.database closeBeforCommit];
    }
    @catch(NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        return -1;
    }
    return 0;
}

@end
