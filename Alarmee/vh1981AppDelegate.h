//
//  vh1981AppDelegate.h
//  Alarmee
//
//  Created by 김 연희 on 12. 2. 26..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "itemsListViewController.h"
#import "db_access.h"
#import "Schedule.h"

@interface vh1981AppDelegate : UIResponder <UIApplicationDelegate> {
    DBAccessHelper* dbHelper;
    itemsListViewController* _viewController;
    UINavigationController* _navigationController;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, nonatomic, retain) DBAccessHelper *dbHelper;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
