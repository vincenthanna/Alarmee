//
//  vh1981AppDelegate.m
//  Alarmee
//
//  Created by 김 연희 on 12. 2. 26..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "vh1981AppDelegate.h"
#import "db_access.h"
#import "Schedule.h"

@implementation vh1981AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // 가장 최상위에 깔아놓는 Window를 생성한다.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // root로 사용될 ViewController를 생성한다.
    _viewController = [[itemsListViewController alloc]init];
    _navigationController = [[UINavigationController alloc]initWithRootViewController:_viewController];

    // viewController를 가장 최상에 넣는다.
    [self.window addSubview:_navigationController.view];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // sqlite database 초기화
    DBAccessHelper *dbHelper = [[DBAccessHelper alloc] init];
    int ret = 0;
    ret = [dbHelper init_db:0];
    if (ret) {
        NSLog(@"db init succeeded");
    }
    else {
        NSLog(@"db init failed!");
    }
//    [dbHelper makeTestData];
    
    {
        //통지시간 정하기 
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
        NSDateComponents *dateComps = [calendar components:unitFlags fromDate:[NSDate date]];
        

        /*
        [dateComps setYear:2012];
        [dateComps setMonth:8];
        [dateComps setDay:11];
        [dateComps setHour:16];
        [dateComps setMinute:15];
        [dateComps setSecond:0];
         */

//        
        
        NSDate* now = [dateComps date];

        NSLog(@"%d:%02d:%02d (%d,%d,%d) %d %d", dateComps.year, dateComps.month, dateComps.day, dateComps.week, dateComps.weekday, dateComps.weekdayOrdinal, dateComps.month, dateComps.day);
        
        NSLog(@"%d:%02d:%02d (%d,%d,%d)", dateComps.year, dateComps.month, dateComps.day, dateComps.week, dateComps.weekday, dateComps.weekdayOrdinal);
        NSDate *date;
        date = [calendar dateFromComponents:dateComps];
        NSLog(@"sec=%f", [date timeIntervalSince1970]);
        [dateComps setYear:2013];
        date = [calendar dateFromComponents:dateComps];
        NSLog(@"sec=%f", [date timeIntervalSince1970]);
        
        NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:now];
        
        NSLog(@"range length=%d location=%d", range.length, range.location);
        
  
/*
//        NSDate *now = [[NSDate alloc]init];
        if ([now compare:date] == NSOrderedDescending) {
            NSLog(@"A %@ ===> %@",date, now);
        }
        else {
            NSLog(@"B %@ ===> %@",now, date);
        }
        
        UILocalNotification *localNotif = [[UILocalNotification alloc]init];
        if (localNotif != nil) 
        {
            //통지시간 
            localNotif.fireDate = date;
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            
            //Payload
            localNotif.alertBody = [NSString stringWithFormat:@"내부통지 %@",date];
            localNotif.alertAction = @"상세보기";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.applicationIconBadgeNumber = 1;
            
            //Custom Data
            NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"mypage" forKey:@"page"];
            localNotif.userInfo = infoDict;
            
            //Local Notification 등록
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            
        }
 */


    }

    return YES;
}

-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	application.applicationIconBadgeNumber = 0;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" 
													message:[NSString stringWithFormat:@"didReceiveLocalNotification %@",notification.alertBody] 
												   delegate:nil 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"확인",nil];
	[alert show];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Alarmee" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Alarmee.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
