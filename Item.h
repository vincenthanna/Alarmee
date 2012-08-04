//
//  Item.h
//  Alarmee
//
//  Created by 연희 김 on 12. 8. 2..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *repeatModeStr[];
extern NSString *dateTextSaveFormat;
extern NSString *dateTextFormal;
@interface Item : NSObject {
    enum {REPEAT_NONE = 0, REPEAT_DAY, REPEAT_WEEK, REPEAT_MONTH, REPEAT_MAX};
    unsigned int id;
    NSString* title;
    NSString* todo;
    NSDate* adddate;
    NSDate* duedate;
    unsigned int repeat;
}

@property (nonatomic) unsigned int id;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* todo;
@property (nonatomic, retain) NSDate* adddate;
@property (nonatomic, retain) NSDate* duedate;
@property (nonatomic) unsigned int repeat;

+(NSString*)date2Str:(NSDate*)date;
+(NSDate*)str2Date:(NSString*)string;

-(NSString*)dueDateString;
-(NSString*)repeatModeString;
+(NSString*)getRepeatModeString:(int)repeat;

@end
