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
    enum {SCHED_WAITING = 0, SCHED_DONE, SCHED_EXPIRED};
    enum {STAT_ACTIVE, STAT_DONE};
    unsigned int identifier;
    NSString* title;
    NSString* todo;
    NSDate* adddate; //생성된 시간
    NSDate* duedate; //예약시간
    NSDate* scheduledDate; //스케줄링된 다음시간
    unsigned int repeat;
    unsigned int scheduledCount;
    unsigned int status;
}

@property (nonatomic) unsigned int identifier;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* todo;
@property (nonatomic, retain) NSDate* adddate;
@property (nonatomic, retain) NSDate* duedate;
@property (nonatomic, retain) NSDate* scheduledDate;
@property (nonatomic) unsigned int repeat;
@property (nonatomic) unsigned int scheduledCount;
@property (nonatomic) unsigned int status;

+(NSString*)date2Str:(NSDate*)date;
+(NSDate*)str2Date:(NSString*)string;

-(NSString*)dueDateString:(BOOL)withWeek;
-(void)dropSeconds;
-(NSString*)repeatModeString;
+(NSString*)getRepeatModeString:(int)repeat;
-(NSDictionary*)toDictionary;
-(NSString*)dateCompsToStr:(NSDateComponents*)comps;

-(int)getScheduledStatus;

@end
