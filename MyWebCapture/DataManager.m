//
//  DataManager.m
//  MyWebCapture
//
//  Created by jschoi on 2015. 12. 21..
//  Copyright © 2015년 jschoi. All rights reserved.
//

#import "DataManager.h"
#import "SQLite3Class.h"
#import "IOSUtils.h"

static NSString * const DBFileName = @"Bookmarks";

/**
 * 현재 DB 스키마 버전
 */
static const int DB_SCHEMA_VERION = 2;

/**
 * 설정 내용 저장 이름
 */
static NSString * const DBSettingNameSchema = @"schema_version";

@implementation BookmarkData

- (id)copyWithZone:(NSZone *)zone
{
    BookmarkData *copyedData = [BookmarkData allocWithZone:zone];
    
    copyedData.no = self.no;
    copyedData.url = self.url;
    copyedData.title = self.title;
    copyedData.iconFileName = self.iconFileName;
    copyedData.iconImage = self.iconImage;
    copyedData.position = self.position;

    return copyedData;
}

@end

@interface DataManager ()

@property (strong, nonatomic) NSMutableArray<BookmarkData *> *listBookmark;
@property (strong, nonatomic) SQLite3Class *database;
@property (strong, nonatomic, readonly) NSString *documentsDirectory;

// 갭쳐 데이터
@property (strong, nonatomic) NSMutableArray<CapturedData *> *listCapturedDatas;

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
    return _listBookmark.count;
}

- (id)getCapturedDatas{
    return _listCapturedDatas;
}

#pragma mark - public method (captured data)

/**
 * 갭쳐 데이터를 주어진 항목을 기준으로 정렬하여 읽어온다.
 */
- (int)readCapturedData
{
    return [self readCapturedDataOrderby:nil withAscending:YES];
}
- (int)readCapturedDataOrderby:(NSString *)order withAscending :(BOOL)isAscending
{
    int result = 0;
    self.listCapturedDatas = [[NSMutableArray alloc] init];
    
    @try {
        [self.database openAndTransaction];
        NSString *dir = (isAscending) ? @"ASC" : @"DESC";
        NSString *column;
        if( [order isEqualToString:@"time"] ) {
            // 날짜 기준으로 정렬
            column = @"time";
        }
        else {
            // 그밖의 경우 제목 기준으로 정렬
            column = @"title, url";
        }
        
        RecordSet *set = [self.database
                          executeWithSQL:[NSString
                                          stringWithFormat:@"select no, title, url, filename, isfull, time "
                                          " from CapturedDataTable order by %@ %@ ", column, dir]];
        while( set && !set.endOfRecord ) {
            CapturedData *captured = [[CapturedData alloc] init];
            RecordData *data = [set getCollectDataAtColumnName:@"no"];
            if( data && !data.null )
                captured.no = data.intValue;

            data = [set getCollectDataAtColumnName:@"title"];
            if( data && !data.null )
                captured.title = data.stringValue;

            data = [set getCollectDataAtColumnName:@"url"];
            if( data && !data.null )
                captured.url = data.stringValue;
            
            data = [set getCollectDataAtColumnName:@"filename"];
            if( data && !data.null )
                captured.filename = data.stringValue;
            
            data = [set getCollectDataAtColumnName:@"isfull"];
            if( data && !data.null )
                captured.fullScreen = data.intValue;
            
            data = [set getCollectDataAtColumnName:@"time"];
            if( data && !data.null )
                captured.datetime = data.stringValue;
            
            [self.listCapturedDatas addObject:captured];
            
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
 * 새로운 갭처 데이터를 추가한다.
 */
- (int)addCapturedData:(CapturedData *)data withImage:(UIImage *)image
{
    // DB에 추가
    if( [self insertCapturedData:data] < 0 )
        return -1;
    
    // 갭쳐 이미지 파일 저장
    NSString *pathImage = [IOSUtils pathDocumentsWithFilename:data.filename];
    NSData *dataImage = UIImagePNGRepresentation(image);
    BOOL isSaved = [dataImage writeToFile:pathImage atomically:YES];
    NSLog(@"%@ saved(%i)", data.filename, isSaved);
    if( !isSaved )
        return -2;
    
    // 리스트에 추가
    [self.listCapturedDatas addObject:data];

    return 0;
}

/**
 * 주어진 갭처 데이터를 삭제한다.
 */
- (int)deleteCapturedData:(CapturedData *)data
{
    // DB에서 삭제
    
    // 이미지 파일 삭제
    
    // 리스트에서 삭제
    
    return 0;
}

#pragma mark - pubic method (bookmark)
/**
 * 새로운 북마크를 마지막에 추가
 */
- (int)addBookmark:(BookmarkData *)bookmark
{
    int result = 0;
    
    // 포지션 정보는 마지막 값 기준
    bookmark.position =  self.listBookmark.lastObject.position + 1;
    
    // DB에 추가
    if( (result = [self insertData:bookmark andClose:NO]) < 0 )
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
            
            if( [self updateData:bookmark andClose:YES] < 0 )
                return -3;
        }
    }
    
    // 아이콘이 없으면 디폴트 이미지 로딩
    if( bookmark.iconFileName == nil || bookmark.iconFileName.length == 0 ) {
        bookmark.iconImage = [UIImage imageNamed:@"icon-default.png"];
    }
    
    // 리스트에 추가
    [self.listBookmark addObject:bookmark];
    
    NSLog(@"[%i] title:%@ url:%@ icon-file:%@ pos:%i",
          bookmark.no, bookmark.title, bookmark.url, bookmark.iconFileName, bookmark.position);
    
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
 * 해당 북마트 데이터가 있는 인덱스 값을 반환
 */
- (NSInteger)indexOfBookmark:(BookmarkData *)bookmark
{
    return [self.listBookmark indexOfObject:bookmark];
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

/**
 * 북마크 위지청보를 수정한다.
 * 위치정보 기준으로 정렬된 리스트를 입력받아 저장하고 배열을 재정리 한다.
 */
- (int)updateBookmarkPositions:(NSArray<BookmarkData *> *)positions
{
    int count = 0;
    
    [self.listBookmark removeAllObjects];
    
    for(BookmarkData *data in positions) {
        if( [self updateData:data andClose:NO] < 0 )
            return -1;
        
        [self.listBookmark addObject:data];
        ++count;
    }
    [self.database closeBeforCommit];
    
    return count;
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
        
        // 기본 설정값 추가
        
        // DB 버전 입력
        if([self insertSettingNames:@[DBSettingNameSchema]
                         withValues:@[[NSString stringWithFormat:@"%i", DB_SCHEMA_VERION]] ] < 0 )
            return -3;
        
        // 기본 북마크 정보 추가
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
    else {
        // DB 테이블 생성(존재하지 않는 테이블만)
        if([self createDBTable] < 0)
            return -11;
        
        // 파일이 존재하면 DB스키마 버전 확인 -> 업데이트
        int schemaVersion = [self readSettingValueAtName:DBSettingNameSchema].intValue;
        NSLog("DB Schema version :%i", schemaVersion);
        if( schemaVersion < DB_SCHEMA_VERION ) {
            if([self updateDBSchema_ver_1] < 0 )
                return -12;
        }
        
        // DB 버전 2는 갭체 테이블 생성(다른 동작 없음)
        
        // DB 버번 정보를 업데이트 한다.
        if([self updateSettingValues:@[[NSString stringWithFormat:@"%i", DB_SCHEMA_VERION]]
                             atNames:@[DBSettingNameSchema]]  < 0)
            return -99;
        
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
 * 데이터를 저장할 DB 테이블을 생성한다. (디비 버전-1)
 */
- (int)createDBTable
{
    int result = 0;
    @try {
        [self.database openAndTransaction];
        
        // 설정값 테이블
        [self.database executeWithSQL:@"create table if not exists "
         " SettingTable ( no INTEGER PRIMARY KEY, "
         " name TEXT, value TEXT, descript TEXT, time TEXT );" ];
        
        // 북마크 테이블
        [self.database executeWithSQL:@"create table if not exists "
                                       " BookmarkTable ( no INTEGER PRIMARY KEY, "
                                       " url TEXT, title TEXT, iconfile TEXT, position INTEGER,time TEXT );" ];
        
        // 갭쳐 데이터 테이블
        [self.database executeWithSQL:@" create table if not exists "
                                       " CapturedDataTable ( no INTEGER PRIMARY KEY, "
                                        " title TEXT, url TEXT, filename TEXT, isfull BOOL, time TEXT );" ];
        
        
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
        
        // 북마크 리스트 읽기
        RecordSet *set = [self.database executeWithSQL:@"select no, url, title, iconfile, position "
                                                        " from BookmarkTable order by position; " ];
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
            
            data = [set getCollectDataAtColumnName:@"position"];
            if( data && !data.null )
                bookmark.position = data.intValue;
            
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
    return [self insertData:data andClose:YES];
}
- (int)insertData:(BookmarkData *)data andClose:(BOOL)isClose
{
    int result = 0;
    
    // SQLite '문자를 사용하기 위해 '' 로 변경
    NSString *titleReplaced = [data.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    @try {
        [self.database openAndTransaction];
        
        RecordSet *set = [self.database executeWithSQL:
            [NSString stringWithFormat:@"insert into BookmarkTable (url, title, iconfile, position, time) "
                " values('%@', '%@', '%@', %i, datetime('now', 'localtime') ); "
                " select no from BookmarkTable where no = last_insert_rowid(); ",
                data.url, titleReplaced, data.iconFileName, data.position] ];
        if( set && !set.endOfRecord ) {
            RecordData *data = [set getCollectDataAtColumnName:@"no"];
            if( data && !data.null )
                result = data.intValue;
        }
        
        if( isClose )
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
    return [self updateData:data andClose:YES];
}
- (int)updateData:(BookmarkData *)data andClose:(BOOL)isClose
{
    int result = 0;

    // SQLite '문자를 사용하기 위해 '' 로 변경
    NSString *titleReplaced = [data.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    @try {
        [self.database openAndTransaction];
        
        [self.database executeWithSQL:
            [NSString stringWithFormat:@" update BookmarkTable set "
                                        " url = '%@', title = '%@' , iconfile = '%@', position = %i, "
                                        " time = datetime('now', 'localtime') "
                                        " where no = %i ;",
                                        data.url, titleReplaced, data.iconFileName, data.position, data.no]];
        if( isClose )
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

/**
 * 설정값을 추가한다.
 */
- (int)insertSettingNames:(NSArray<NSString*> *)names withValues:(NSArray<NSString*> *)values
{
    @try {
        [self.database openAndTransaction];
        for(int i = 0; i < names.count; ++i) {
            NSString *sql = [NSString stringWithFormat:
                             @" insert into SettingTable(name, value, time) "
                             " values('%@', '%@', datetime('now', 'localtime')); ",
                             names[i], values[i]];
            [self.database executeWithSQL:sql];
        }
        [self.database closeBeforCommit];
    }
    @catch(NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        return -1;
    }
    return 0;
}

/**
 * 설정값들을 변경한다.
 */
- (int)updateSettingValues:(NSArray<NSArray *> *)values atNames:(NSArray<NSString *> *)names
{
    @try {
        [self.database openAndTransaction];
        for(int i = 0; i < names.count; ++i) {
            NSString *sql = [NSString stringWithFormat:
                             @" update SettingTable set "
                             " value = '%@', time = datetime('now', 'localtime') "
                             " where name = '%@'; ",
                             values[i], names[i]];
            [self.database executeWithSQL:sql];
        }
        [self.database closeBeforCommit];
    }
    @catch(NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        return -1;
    }
    return 0;
}

/**
 * 설정값을 읽어온다.
 */
- (NSString *)readSettingValueAtName:(NSString *)name
{
    NSString *value;

    @try {
        [self.database openAndTransaction];
        NSString *sql = [NSString stringWithFormat:
                         @" select value from SettingTable "
                         " where name = '%@'; ", name];
        RecordSet *set = [self.database executeWithSQL:sql];
        
        if( set && !set.endOfRecord ) {
            RecordData *data = [set getCollectDataAtColumnName:@"value"];
            if( data && !data.null )
                value = data.stringValue;
        }
        
        [self.database closeBeforCommit];
    }
    @catch(NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        return nil;
    }
    
    return value;
}

#pragma mark - private method (captured data)
- (NSString *)capturedImageNameWithNumber:(int)no
{
    return [NSString stringWithFormat:@"captured-%i.png", no];
}

- (int)insertCapturedData:(CapturedData *)captured
{
    @try {
        [self.database openAndTransaction];
        
        // 갭쳐 데이터 삽입
        RecordSet *set =
        [self.database executeWithSQL:[NSString stringWithFormat:
                                       @" insert into CapturedDataTable (title, url, isfull, time) "
                                       " values('%@', '%@', %i, datetime('now', 'localtime') ); "
                                       " select no from CapturedDataTable where no = last_insert_rowid(); ",
                                       captured.title, captured.url, captured.fullScreen ] ];
        // 파일 이름 업데이트
        if( set && !set.endOfRecord ) {
            RecordData *data = [set getCollectDataAtColumnName:@"no"];
            if( data && !data.null ) {
                captured.no = data.intValue;
                captured.filename = [self capturedImageNameWithNumber:captured.no];
                [self.database executeWithSQL:[NSString stringWithFormat:
                                               @" update CapturedDataTable set "
                                               " filename = '%@' where no = %i ;" , captured.filename, captured.no]];
            }
        }
        
        [self.database closeBeforCommit];
    }
    @catch(NSException *exception) {
        [self.database closeBeforRollback];
        NSLog(@"[exception] %@ > %@", exception.name, exception.reason);
        return -1;
    }
    
    return 0;
}

#pragma mark - DB schema update
/**
 * DB 스키마를 0->1로 업데이트한다.
 */
- (int)updateDBSchema_ver_1
{
    NSLog(@"DB Schema update to v.1");
    @try {
        [self.database openAndTransaction];
        
        // 설정값 DB스키마 버전정보를 기록한다.
        NSString *sql = [NSString stringWithFormat:
                         @" insert into SettingTable(name, value, time) "
                         " values('%@', '1', datetime('now', 'localtime')); ", DBSettingNameSchema];
        [self.database executeWithSQL:sql];

        // 북마크 백업 테이블 생성
        [self.database executeWithSQL:@"create table "
         " BookmarkTable_backup ( no INTEGER PRIMARY KEY, "
         " url TEXT, title TEXT, iconfile TEXT, time TEXT );" ];
        [self.database executeWithSQL:@" INSERT INTO BookmarkTable_backup SELECT * FROM BookmarkTable; "];
        
        // 북마크 테이블에 position 컬럼 추가
        [self.database executeWithSQL:@"drop table if exists BookmarkTable; "
         " create table BookmarkTable ( no INTEGER PRIMARY KEY, "
         " url TEXT, title TEXT, iconfile TEXT, position INTEGER, time TEXT );" ];
        
        // 백업 테이블로부터 데이터 복구
        [self.database executeWithSQL:@"insert into BookmarkTable "
         " (no, url, title, iconfile, time) select * from BookmarkTable_backup; "];
        [self.database executeWithSQL:@"drop table BookmarkTable_backup"];
        
        // 포지션 값 적용
        [self.database executeWithSQL:@"update bookmarktable set position = no;"];
        
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
