//
//  VoteHomeViewController.m
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "VoteHomeViewController.h"
#import "VoteLoginViewController.h"
#import "CoreDataHelper.h"
#import "VoteFirstTableViewController.h"
#import "VoteSecondTableViewController.h"

@interface VoteHomeViewController ()

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation VoteHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:@"authenticated"];
    [ud synchronize];
    //NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    authenticated = [ud boolForKey:@"authenticated"];
    
    if (authenticated) {
        
        
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VoteLoginViewController *lvc=[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [lvc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [lvc setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:lvc animated:YES completion:nil];
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
