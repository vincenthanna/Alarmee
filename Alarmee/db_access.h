//
//  db_access.h
//  Alarmee
//
//  Created by 연희 김 on 12. 8. 1..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#ifndef Alarmee_db_access_h
#define Alarmee_db_access_h

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Item.h"

#define DB_TABLENAME "dbtable"
#define DB_FILENAME "db.sqlite"

extern const char *db_create_str_template;


@interface DBAccessHelper : NSObject
{
    int stateId;
}

@property (readonly, nonatomic) int stateId;

// functions :
- (NSString*)getDBFilePath;
- (int)init_db:(int)recreate;
- (int)getNextId;

-(BOOL)addNewItem:(Item*)item isExists:(int)isExists;
-(BOOL)deleteItem:(Item*)item;
-(Item*)getItemById:(int)identifier;
-(BOOL)changeItemStatus:(Item*)item status:(int)stat;
-(NSMutableArray*)getAllItems;

- (void)makeTestData;

@end

#endif
