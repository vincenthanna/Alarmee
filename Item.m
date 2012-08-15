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
NSString *dateTextFormal = @"yyyy:MM:dd HH:mm:ss";
@synthesize identifier;
@synthesize title;
@synthesize todo;
@synthesize adddate;
@synthesize duedate;
@synthesize repeat;

-(id)init
{
    identifier = UINT_MAX;
    title = @"";
    todo = NSLocalizedString(@"ToDoTypeHere", nil);
    adddate = [NSDate date];
    duedate = [NSDate date];
    repeat = REPEAT_NONE;
    return [super init];
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

-(NSString*)dueDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateTextFormal];    
    return [dateFormatter stringFromDate:duedate];
}

-(NSString*)repeatModeString
{
    /*
    "No Repeat" = "반복없음";
    "Daily" = "날마다";
    "Weekly" = "주마다";
    "Monthly" = "달마다";
    */
    switch(repeat) {
        case REPEAT_NONE: return NSLocalizedString(@"No Repeat",nil);
        case REPEAT_DAY: return NSLocalizedString(@"Daily",nil);
        case REPEAT_WEEK: return NSLocalizedString(@"Weekly",nil);
        case REPEAT_MONTH: return NSLocalizedString(@"Monthly",nil);
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

@end
