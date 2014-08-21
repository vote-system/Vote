//
//  CoreDataHelper.h
//  Vote
//
//  Created by 丁 一 on 14-3-8.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^completion_block_t)(UIManagedDocument *database);

@interface CoreDataHelper : NSObject

//get UIManagedDocument singleton
+ (void)sharedDatabase:(completion_block_t)completionBlock;

// For retrieval of objects
+ (NSArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext;

// For deletion of objects
+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate andContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext;

// For counting objects
+ (NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext;

@end
