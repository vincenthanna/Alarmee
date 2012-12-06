//
//  db_access.c
//  Alarmee
//
//  Created by 연희 김 on 12. 8. 1..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "db_access.h"
#include <stdio.h>

const char *db_create_str_template = "CREATE TABLE IF NOT EXISTS %s \
    (id INTEGER PRIMARY KEY NOT NULL \
    ,title VARCHAR \
    ,todo VARCHAR \
    ,adddate VARCHAR \
    ,duedate VARCHAR \
    ,scheduledDate VARCHAR \
    ,repeat INTEGER \
    ,scheduledCount INTEGER \
    ,status INTEGER \
    )";


@implementation DBAccessHelper

@synthesize stateId;

- (id)init
{
    self = [super init];
    if (self) {
        stateId = 0;
    }
    return self;
}

#pragma mark - SQLite DB파일 초기화
-(int)init_db:(int)recreate
{
    NSError *error;
    sqlite3 *database = NULL;
    int ret = 0;
    
    // get db file path
    NSString *filePath = [self getDBFilePath];
    if (recreate) { // delete database file first
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error] != YES) {
            NSLog(@"[%s]%d error = %@!", __FUNCTION__, __LINE__, [error description]);
            goto exit;
        }
    }
    
    // connect database(make if doesn't exist)
    if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"db open Error");
        goto exit;
    }
    
    // create table
    char buffer[256];
    memset(buffer, 0x0, sizeof(buffer));
    sprintf(buffer, db_create_str_template, DB_TABLENAME);
    
    NSLog(@"%s", buffer);
    //sqlite3_exec 쿼리문을 실행할 수 있다.
    if (sqlite3_exec(database, buffer, nil,nil,nil) != SQLITE_OK) {
        NSLog(@"[%s]%d error!", __FUNCTION__, __LINE__);
        goto exit;
    }
    else {
        NSLog(@"[%s]%d success!", __FUNCTION__, __LINE__);
    }
    
    ret = 1; // all succeeded
    
exit:
    if (database != NULL) {
        //db close
        sqlite3_close(database);
        database = NULL;
    }
    return ret;
}

#pragma mark - SQLite DB파일 경로를 얻고 뒤에 파일이름을 붙여서 돌려준다.
- (NSString*)getDBFilePath
{
    // get document directory location
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // make filepath
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@DB_FILENAME];
    //NSLog(@"filePath=%@", filePath);
    return filePath;
}

#pragma mark - DB에 추가할 때 사용할 id를 얻는다. (가장 큰값 + 1)
- (int)getNextId
{
    int nextId = 0;
    sqlite3 *database = NULL;
    int ret = 0;
    
    // get db file path
    NSString *filePath = [self getDBFilePath];
    //NSLog(@"filePath=%@", filePath);
    if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"[%s]%d db open fail!", __func__,__LINE__);
    }
    else {        
        char buffer[256];
        memset(buffer, 0x0, sizeof(buffer));
        sprintf(buffer, "SELECT max(id) FROM %s", DB_TABLENAME);
        
        //NSLog(@"sql_getid = %s", buffer);
        sqlite3_stmt *selectStatement;         
        ret = sqlite3_prepare_v2(database, buffer, -1, &selectStatement, NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(selectStatement)==SQLITE_ROW) {
                nextId = sqlite3_column_int(selectStatement, 0);
                ret = 1; // all succeeded
            }
        }
        else {
            NSLog(@"[%s]%d error=%d!", __func__, __LINE__, ret);
        }
    }

    if (database != NULL) {
        //db close
        //NSLog(@"[%s]%d release sqlite db file...", __func__, __LINE__);
        sqlite3_close(database);
        database = NULL;
    }
    if (ret) {
        return ++nextId;
    }
    else {
        return -1;
    }
}

#pragma mark - DB에 아이템 추가 / 수정
/* DB에 아이템 추가/수정 */
-(BOOL)addNewItem:(Item*)item isExists:(int)isExists
{
    BOOL bRet = FALSE;
    sqlite3 *database = NULL;
    int nextId;
    if (!isExists) {
        nextId = [self getNextId];
    }
    else {
        nextId = item.identifier;
    }
    
    [item dropSeconds];
    if (nextId != -1) {
        NSLog(@"next id=%d",nextId);
        NSString *filePath = [self getDBFilePath];
        if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
            NSLog(@"[%s]%d db open fail!", __func__,__LINE__);
        }
        else {
            sqlite3_stmt *insertStatement;
            NSMutableString *insertSql;
            if (isExists) {
                insertSql = [[NSMutableString alloc]initWithFormat:
                             @"INSERT OR REPLACE INTO %s\
                             (id, title, todo, adddate, duedate, scheduledDate, repeat, scheduledCount, status)\
                             VALUES(?,?,?,?,?,?,?,?,?)", DB_TABLENAME];
            }
            else {
                insertSql = [[NSMutableString alloc]initWithFormat:
                             @"INSERT INTO %s\
                             (id, title, todo, adddate, duedate, scheduledDate, repeat, scheduledCount, status)\
                             VALUES(?,?,?,?,?,?,?,?,?)", DB_TABLENAME];
            }
            
            //NSLog(@"queryString = %s", [insertSql UTF8String]);
            
            //프리페어스테이트먼트를 사용
            unsigned int ret = sqlite3_prepare_v2(database, [insertSql UTF8String], -1, &insertStatement, NULL);
            if (ret == SQLITE_OK) {
                
                //NSLog(@"[%s]%d success!", __func__, __LINE__);
                
                //?에 데이터를 바인드
                sqlite3_bind_int(insertStatement,   1, nextId); //id
                sqlite3_bind_text(insertStatement,  2, [item.title UTF8String],  -1, SQLITE_TRANSIENT); //title
                sqlite3_bind_text(insertStatement,  3, [item.todo UTF8String],  -1, SQLITE_TRANSIENT); //todo
                sqlite3_bind_text(insertStatement,  4, [[Item date2Str:item.adddate] UTF8String], -1, SQLITE_TRANSIENT); //adddate
                sqlite3_bind_text(insertStatement,  5, [[Item date2Str:item.duedate] UTF8String], -1, SQLITE_TRANSIENT); //duedate
                sqlite3_bind_text(insertStatement,  6, [[Item date2Str:item.scheduledDate] UTF8String], -1, SQLITE_TRANSIENT); //scheduledDate
                sqlite3_bind_int(insertStatement,   7, item.repeat); //repeat
                sqlite3_bind_int(insertStatement,   8, item.scheduledCount); //repeat
                sqlite3_bind_int(insertStatement,   9, item.status); //repeat
                
                // sql문 실행
                ret = sqlite3_step(insertStatement);
                if (ret != SQLITE_DONE) {
                    NSLog(@"[%s]%d Error =%d",__func__, __LINE__, ret);
                }
                else {
                    bRet = TRUE;
                }
            }
            else {
                NSLog(@"[%s]%d error=%d!", __FUNCTION__, __LINE__, ret);
            }
        }
    }
    
    if (database != NULL) {
        //db close
        sqlite3_close(database);
        database = NULL;
    }
    
    stateId++;
    
    return bRet;
}

#pragma mark - DB내의 아이템을 id로 찾아서 없앤다.
-(BOOL)deleteItem:(Item*)item
{
    BOOL bRet = FALSE;
    sqlite3 *database = NULL;
    bool found = false;
    unsigned int ret;
    sqlite3_stmt *statement;
    NSMutableString *sqlString;

    NSString *filePath = [self getDBFilePath];
    if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"[%s]%d db open fail!", __func__,__LINE__);
    }
    
    else {
        
        // 일단 해당 id를 가진것이 존재하는지 확인한다.
        sqlString = [[NSMutableString alloc]initWithFormat:@"SELECT * FROM %s WHERE id=%d", DB_TABLENAME, item.identifier];
        if (sqlite3_prepare_v2(database, [sqlString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            // while문을 돌면서 각 레코드의 데이터를 받아서 출력한다.
            while (sqlite3_step(statement)==SQLITE_ROW) {
                found = true;
            }
        }
        
        if (found) {
            sqlString = [[NSMutableString alloc]initWithFormat:@"DELETE FROM %s WHERE id=%d", DB_TABLENAME, item.identifier];
            if (sqlite3_prepare_v2(database, [sqlString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                // sql문 실행
                ret = sqlite3_step(statement);
                if (ret != SQLITE_DONE) {
                    NSLog(@"[%s]%d Error =%d",__func__, __LINE__, ret);
                }
                else {
                    bRet = TRUE;
                }
            }
        }
        else {
            NSLog(@"[%s]%d Error!!!", __func__, __LINE__);
        }
    }
        
    if (database != NULL) {
        //db close
        sqlite3_close(database);
        database = NULL;
    }
    
    stateId++;
    
    return bRet;
}

#pragma mark - DB내의 아이템을 id로 찾아서 상태 값을 변경한다.
-(BOOL)changeItemStatus:(Item*)item status:(int)stat
{
    BOOL bRet = FALSE;
    sqlite3 *database = NULL;
    bool found = false;
    unsigned int ret;
    sqlite3_stmt *statement;
    NSMutableString *sqlString;
    
    NSString *filePath = [self getDBFilePath];
    if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"[%s]%d db open fail!", __func__,__LINE__);
    }
    else {
        
        // 일단 해당 id를 가진것이 존재하는지 확인한다.
        sqlString = [[NSMutableString alloc]initWithFormat:@"SELECT * FROM %s WHERE id=%d", DB_TABLENAME, item.identifier];
        if (sqlite3_prepare_v2(database, [sqlString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            // while문을 돌면서 각 레코드의 데이터를 받아서 출력한다.
            while (sqlite3_step(statement)==SQLITE_ROW) {
                found = true;
            }
        }
        
        if (found) {
            sqlString = [[NSMutableString alloc]initWithFormat:@"UPDATE status=%d FROM %s WHERE id=%d",
                         stat, DB_TABLENAME, item.identifier];
            if (sqlite3_prepare_v2(database, [sqlString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                // sql문 실행
                ret = sqlite3_step(statement);
                if (ret != SQLITE_DONE) {
                    NSLog(@"[%s]%d Error =%d",__func__, __LINE__, ret);
                }
                else {
                    bRet = TRUE;
                }
            }
        }
        else {
            NSLog(@"[%s]%d Error!!!", __func__, __LINE__);
        }
    }
    
    if (database != NULL) {
        //db close
        sqlite3_close(database);
        database = NULL;
    }
    
    stateId++;
    
    return bRet;
}

- (void)makeTestData
{
    Item *item = [[Item alloc]init];
    
    item.title = @"매일 할일";
    item.todo = @"아침 점심 저녁 꼬박 챙겨 먹기\n아침에 출근하기";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.scheduledDate = [NSDate date];
    item.repeat = REPEAT_DAY;
    item.scheduledCount = 0;
    item.status = STAT_ACTIVE;
    [self addNewItem:item isExists:0];
    
    item.title = @"이번주 할일";
    item.todo = @"공부하기\n주말에 빨래하기";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.scheduledDate = [NSDate date];
    item.repeat = REPEAT_WEEK;
    item.scheduledCount = 0;
    item.status = STAT_ACTIVE;
    [self addNewItem:item isExists:0];
    
    item.title = @"달마다 할일";
    item.todo = @"월세 내기\n우유값 내기\n월급받기";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.scheduledDate = [NSDate date];
    item.repeat = REPEAT_MONTH;
    item.scheduledCount = 0;
    item.status = STAT_ACTIVE;
    [self addNewItem:item isExists:0];
        
    item.title = @"친구하고저녁약속";
    item.todo = @"친구하고 저녁약속 - 홍대에서";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.scheduledDate = [NSDate date];
    item.repeat = REPEAT_NONE;
    item.scheduledCount = 0;
    item.status = STAT_ACTIVE;
    [self addNewItem:item isExists:0];
    
    item.title = @"8월8일 소개팅";
    item.todo = @"8월 8일에 강남역 4번출구에서 보기로 함";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.scheduledDate = [NSDate date];
    item.repeat = REPEAT_NONE;
    item.scheduledCount = 0;
    item.status = STAT_ACTIVE;
    [self addNewItem:item isExists:0];
    
    item.title = @"이달말까지 프로젝트 완료해야함";
    item.todo = @"8월10일까지 중간결과 넘겨주고 21일에 시연\n1주일동안 인수인계";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.scheduledDate = [NSDate date];
    item.repeat = REPEAT_NONE;
    item.scheduledCount = 0;
    item.status = STAT_ACTIVE;
    [self addNewItem:item isExists:0];
    
    item.title = @"꼭 빨래하자!!!";
    item.todo = @"입은 옷이너무 쌓였음";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.scheduledDate = [NSDate date];
    item.repeat = REPEAT_NONE;
    item.scheduledCount = 0;
    item.status = STAT_ACTIVE;
    [self addNewItem:item isExists:0];
}

#pragma mark - DB에서 id로 검색해서 아이템을 얻는다.
- (Item*)getItemById:(int)identifier
{
    sqlite3 *database = NULL;
    int ret = 0;
    Item* item = [[Item alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateTextSaveFormat]; // 시간이 이런 형식으로 저장되어 있다.
    NSString* timeString;
    NSDate* date;
    
    // get db file path
    NSString *filePath = [self getDBFilePath];
    //NSLog(@"filePath=%@", filePath);
    if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"[%s]%d db open fail!", __func__,__LINE__);
    }
    else {
        char buffer[256];
        memset(buffer, 0x0, sizeof(buffer));
        sprintf(buffer, "SELECT * FROM %s WHERE id=%d", DB_TABLENAME, identifier);
        
        sqlite3_stmt *selectStatement;
        ret = sqlite3_prepare_v2(database, buffer, -1, &selectStatement, NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(selectStatement)==SQLITE_ROW) {
                item.identifier = sqlite3_column_int(selectStatement, 0);
                item.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 1) ];
                item.todo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 2) ];
                
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 3) ];
                date = [Item str2Date:timeString];
                item.adddate = date;
                
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 4) ];
                date = [Item str2Date:timeString];
                item.duedate = date;
                
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 5) ];
                date = [Item str2Date:timeString];
                item.scheduledDate = date;
                
                item.repeat = sqlite3_column_int(selectStatement, 6);
                item.scheduledCount = sqlite3_column_int(selectStatement, 7);
                item.status = sqlite3_column_int(selectStatement, 8);
                ret = 1;
            }
        }
        else {
            NSLog(@"[%s]%d error=%d!", __func__, __LINE__, ret);
        }
    }
    
    if (database != NULL) {
        //db close
        sqlite3_close(database);
        database = NULL;
    }
    
    if (ret) {
        return item;
    }
    else {
        return nil;
    }
}

#pragma mark - 모든 아이템을 얻는다.
-(NSMutableArray*)getAllItems
{
    NSMutableArray *itemsArray = nil;
    sqlite3 *database = NULL;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateTextSaveFormat]; // 시간이 이런 형식으로 저장되어 있다.

    // get db file path
    NSString *filePath = [self getDBFilePath];
    int ret = sqlite3_open([filePath UTF8String], &database);
    if (ret != SQLITE_OK) {
        NSLog(@"[%s]%d db open fail err=%d!", __func__,__LINE__, ret);
    }
    else {
        sqlite3_stmt *selectStatement;
        NSMutableString *selectSql = [[NSMutableString alloc]initWithFormat:@"SELECT * FROM %s", DB_TABLENAME];
        if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            
            itemsArray = [[NSMutableArray alloc]init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:dateTextSaveFormat]; // 시간이 이런 형식으로 저장되어 있다.
            NSString* timeString;
            NSDate* date;
            
            // while문을 돌면서 각 레코드의 데이터를 받아서 출력한다.
            while (sqlite3_step(selectStatement)==SQLITE_ROW) {
                
                Item* item = [[Item alloc]init];
                
                item.identifier = sqlite3_column_int(selectStatement, 0); //id
                item.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 1) ]; //title
                item.todo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 2) ]; //todo
                
                // adddate
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 3) ];
                date = [Item str2Date:timeString];
                item.adddate = date;
                
                // duedate
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 4) ];
                date = [Item str2Date:timeString];
                item.duedate = date;
                
                // scheduledDate
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 5) ];
                date = [Item str2Date:timeString];
                item.scheduledDate = date;
                
                item.repeat = sqlite3_column_int(selectStatement, 6); // repeat
                item.scheduledCount = sqlite3_column_int(selectStatement, 7); // scheduledCount
                item.status = sqlite3_column_int(selectStatement, 8); // status
                
                /*
                [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                
                NSLog(@"Loaded Items : id=%d adddate=%@ duedate=%@ repeat=%d scheduledCount=%d",
                      item.identifier,
                      [dateFormatter stringFromDate:item.adddate],
                      [dateFormatter stringFromDate:item.duedate],
                      item.repeat,
                      item.scheduledCount);
                 */
                
                [itemsArray addObject:item];
            }
        }
        else {
            NSLog(@"[%s]%d error!", __FUNCTION__, __LINE__);
        }
    }
    
    if (database != NULL) {
        //db close
        sqlite3_close(database);
        database = NULL;
    }
    return itemsArray;    
}

@end