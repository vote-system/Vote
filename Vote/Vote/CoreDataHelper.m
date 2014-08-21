//
//  CoreDataHelper.m
//  Vote
//
//  Created by 丁 一 on 14-3-8.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

+ (void) sharedDatabase:(completion_block_t)completionBlock
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // url is "<Documents Directory>/databaseName"
    url = [url URLByAppendingPathComponent:@"vote.db"];
    
    static UIManagedDocument *managedDocument = nil;
    static dispatch_once_t mngddoc;
    
    dispatch_once(&mngddoc, ^{
        if (!managedDocument) {
            managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
        }
    });
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[managedDocument.fileURL path]]) {
        [managedDocument saveToURL:managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                completionBlock(managedDocument);
            } else {
                NSLog(@"Creation of database failed");
            }
        }];
    } else if (managedDocument.documentState == UIDocumentStateClosed) {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                completionBlock(managedDocument);
            } else {
                NSLog(@"Opening of database failed!");
            }
        }];
    } else if (managedDocument.documentState == UIDocumentStateNormal) {
        completionBlock(managedDocument);
    }
}

#pragma mark - Retrieve objects

// Fetch objects with a predicate
+ (NSArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// If a sort key was passed then use it in the request
	if (sortKey != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
	}
    
	// Execute the fetch request
	NSError *error = nil;
	NSArray *fetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
	// If the returned array was nil then there was an error
	if (fetchResults == nil)
		NSLog(@"Couldn't get objects for entity %@", entityName);
    
	// Return the results
	return fetchResults;
}

// Fetch objects without a predicate
+ (NSArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self searchObjectsForEntity:entityName withPredicate:nil andSortKey:sortKey andSortAscending:sortAscending andContext:managedObjectContext];
}

#pragma mark - Count objects

// Get a count for an entity with a predicate
+ (NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setIncludesPropertyValues:NO];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// Execute the count request
	NSError *error = nil;
	NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    
	// If the count returned NSNotFound there was an error
	if (count == NSNotFound)
		NSLog(@"Couldn't get count for entity %@", entityName);
    
	// Return the results
	return count;
}

// Get a count for an entity without a predicate
+ (NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self countForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

#pragma mark - Delete Objects

// Delete all objects for a given entity
+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	// Ignore property values for maximum performance
	[request setIncludesPropertyValues:NO];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// Execute the count request
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
	// Delete the objects returned if the results weren't nil
	if (fetchResults != nil) {
		for (NSManagedObject *manObj in fetchResults) {
			[managedObjectContext deleteObject:manObj];
		}
	} else {
		NSLog(@"Couldn't delete objects for entity %@", entityName);
		return NO;
	}
    
	return YES;
}

+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self deleteAllObjectsForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

@end
