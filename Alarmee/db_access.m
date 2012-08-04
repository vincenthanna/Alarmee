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
    ,repeat INTEGER \
    )";


@implementation DBAccessHelper

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


- (NSString*)getDBFilePath
{
    // get document directory location
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // make filepath
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@DB_FILENAME];
    NSLog(@"filePath=%@", filePath);
    return filePath;
}

- (int)getNextId
{
    int nextId = 0;
    sqlite3 *database = NULL;
    int ret = 0;
    
    // get db file path
    NSString *filePath = [self getDBFilePath];
    NSLog(@"filePath=%@", filePath);
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

-(BOOL)addNewItem:(Item*)item isExists:(int)isExists
{
    BOOL bRet = FALSE;
    sqlite3 *database = NULL;
    int nextId;
    if (!isExists) {
        nextId = [self getNextId];
    }
    else {
        nextId = item.id;
    }
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
                             @"INSERT OR REPLACE INTO %s (id, title, todo, adddate, duedate, repeat) VALUES(?,?,?,?,?,?)", DB_TABLENAME];
            }
            else {
                insertSql = [[NSMutableString alloc]initWithFormat:
                             @"INSERT INTO %s (id, title, todo, adddate, duedate, repeat) VALUES(?,?,?,?,?,?)", DB_TABLENAME];
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
                sqlite3_bind_int(insertStatement,   6, item.repeat); //repeat
                
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
    
    return bRet;
}

- (void)makeTestData
{
    Item *item = [[Item alloc]init];
    
    item.title = @"매일 할일";
    item.todo = @"아침 점심 저녁 꼬박 챙겨 먹기\n아침에 출근하기";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.repeat = REPEAT_DAY;    
    [self addNewItem:item isExists:0];
    
    item.title = @"이번주 할일";
    item.todo = @"공부하기\n주말에 빨래하기";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.repeat = REPEAT_WEEK;    
    [self addNewItem:item isExists:0];
    
    item.title = @"달마다 할일";
    item.todo = @"월세 내기\n우유값 내기\n월급받기";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.repeat = REPEAT_MONTH;    
    [self addNewItem:item isExists:0];
    
        
    item.title = @"친구하고저녁약속";
    item.todo = @"친구하고 저녁약속 - 홍대에서";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.repeat = REPEAT_NONE;    
    [self addNewItem:item isExists:0];
    
    item.title = @"8월8일 소개팅";
    item.todo = @"8월 8일에 강남역 4번출구에서 보기로 함";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.repeat = REPEAT_NONE;
    [self addNewItem:item isExists:0];
    
    item.title = @"이달말까지 프로젝트 완료해야함";
    item.todo = @"8월10일까지 중간결과 넘겨주고 21일에 시연\n1주일동안 인수인계";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.repeat = REPEAT_NONE;
    [self addNewItem:item isExists:0];
    
    item.title = @"꼭 빨래하자!!!";
    item.todo = @"입은 옷이너무 쌓였음";
    item.duedate = [NSDate date];
    item.adddate = [NSDate date];
    item.repeat = REPEAT_NONE;
    [self addNewItem:item isExists:0];
    
}

@end