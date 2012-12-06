//
//  Item.m
//  Alarmee
//
//  Created by 연희 김 on 12. 8. 2..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "Item.h"

@implementation Item

NSString *repeatModeStr[] = {@"a",@"b",@"c",@"d",@"e"};
NSString *dateTextSaveFormat = @"yyyyMMddHHmmss";
NSString *dateTextFormal = @"yyyy.MM.dd HH:mm  EEEE";
@synthesize identifier;
@synthesize title;
@synthesize todo;
@synthesize adddate;
@synthesize duedate;
@synthesize scheduledDate;
@synthesize repeat;
@synthesize scheduledCount;
@synthesize status;

-(id)init
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags =
        NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekCalendarUnit |
        NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSSecondCalendarUnit;

    NSDate *now = [NSDate date];
    NSDateComponents *addDateComp = [calendar components:unitFlags fromDate:now];
    addDateComp.second = 0;
    now = [calendar dateFromComponents:addDateComp];
    
    identifier = UINT_MAX;
    title = @"";
    todo = NSLocalizedString(@"ToDoTypeHere", nil);
    adddate = now;
    duedate = now;
    scheduledDate = now;
    repeat = REPEAT_NONE;
    scheduledCount = 0;
    return [super init];
}

-(void)dropSeconds
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags =
    NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekCalendarUnit |
    NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *addDateComp = [calendar components:unitFlags fromDate:adddate];
    addDateComp.second = 0;
    adddate = [calendar dateFromComponents:addDateComp];
    
    NSDateComponents *dueDateComp = [calendar components:unitFlags fromDate:duedate];
    dueDateComp.second = 0;
    duedate = [calendar dateFromComponents:dueDateComp];
    
    NSDateComponents *scheduledDateComp = [calendar components:unitFlags fromDate:scheduledDate];
    scheduledDateComp.second = 0;
    scheduledDate = [calendar dateFromComponents:scheduledDateComp];
}

+(NSString*)date2Str:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateTextSaveFormat];
    
    NSLog(@"[%s]%d %@", __func__,__LINE__, [dateFormatter stringFromDate:date]);
    return [dateFormatter stringFromDate:date];
}

+(NSDate*)str2Date:(NSString*)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateTextSaveFormat];
    return [dateFormatter dateFromString:string];
}

-(NSString*)dueDateString:(BOOL)withWeek
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateTextFormal];
    return [dateFormatter stringFromDate:duedate];
}

-(NSString*)repeatModeString
{
    switch(repeat) {
        case REPEAT_NONE: return [NSLocalizedString(@"No Repeat",nil) copy];
        case REPEAT_DAY: return [NSLocalizedString(@"Daily",nil) copy];
        case REPEAT_WEEK: return [NSLocalizedString(@"Weekly",nil) copy];
        case REPEAT_MONTH: return [NSLocalizedString(@"Monthly",nil) copy];
        default: assert(false);
    }
}

+(NSString*)getRepeatModeString:(int)repeat
{
    switch(repeat) {
        case REPEAT_NONE: return NSLocalizedString(@"No Repeat",nil);
        case REPEAT_DAY: return NSLocalizedString(@"Daily",nil);
        case REPEAT_WEEK: return NSLocalizedString(@"Weekly",nil);
        case REPEAT_MONTH: return NSLocalizedString(@"Monthly",nil);
        default: assert(false);
    }
}

-(NSDictionary*)toDictionary
{
    // key들을 먼저 setting
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [[NSNumber alloc] initWithInt:identifier], @"id",
                         nil];
    return dic;
}

/**
 * Item의 스케줄링된 상태를 리턴해 준다.
 * SCHED_WAITING : 아직 시간이 안되었음.
 * SCHED_DONE : 스케줄링됨
 * SCHED_EXPIRED : REPEAT_NONE일때만 리턴됨. 예정시간이 지났고 이미 사용자가 해당 아이템을 확인했다는 것을 의미한다.
 */ 
-(int)getScheduledStatus {
    /*
     now < scheduledDate : 아직 스케줄되지 않음
     now > scheduledDate : 스케줄되었음
     스케줄된 상태에서 내용을 확인하면 updateSchedule
     내용을 변경해서 저장하면 updateSchedule
     */
    
    unsigned int ret;
    NSDate *now = [NSDate date];
    NSTimeInterval timeIntervalNow = [now timeIntervalSince1970];
    NSTimeInterval timeIntervalScheduledDate = [scheduledDate timeIntervalSince1970];
    NSTimeInterval timeIntervalDueDate = [duedate timeIntervalSince1970];
    
    // for debug :
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags =
    NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSWeekCalendarUnit |
    NSWeekdayCalendarUnit |
    NSWeekdayOrdinalCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *dateCompsNow = [calendar components:unitFlags fromDate:now];
    NSDateComponents *dateCompsScheduled = [calendar components:unitFlags fromDate:scheduledDate];
    NSDateComponents *dateCompsDue = [calendar components:unitFlags fromDate:duedate];

    if (repeat == REPEAT_NONE) {
        if (timeIntervalNow < timeIntervalDueDate) {
            ret = SCHED_WAITING;
        }
        else {
            ret = SCHED_DONE;
        }
    }
    else {
        if (timeIntervalNow < timeIntervalScheduledDate) {
            ret = SCHED_WAITING;
        }
        else {
            ret = SCHED_DONE;
        }
    }
    
    NSLog(@"now=%@ scheduled=%@ duedate=%@ item=%@ scheduleStatus=%s",
          [self dateCompsToStr:dateCompsNow],
          [self dateCompsToStr:dateCompsScheduled],
          [self dateCompsToStr:dateCompsDue],
          title,
          ret==SCHED_WAITING ? "SCHED_WAITING" : "SCHED_DONE");
    
    return ret;
}

-(NSString*)dateCompsToStr:(NSDateComponents*)comps
{
    return [[NSString alloc]initWithFormat:@"%d:%02d:%02d (%d,%d,%d)",
            comps.year, comps.month, comps.day, comps.hour, comps.minute, comps.second];
}

@end
