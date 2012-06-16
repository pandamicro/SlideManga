//
//  ModelController.m
//  SlideManga
//
//  Created by LING HUABIN on 22/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import "ModelController.h"
#import "DataViewController.h"

#import "MangaPage.h"
#import "SimpleDivider.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface ModelController()
@property (readonly, strong, nonatomic) NSArray *pages;
@end

@implementation ModelController

@synthesize pages = _pages;

- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSMutableArray *origins = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < 6; i++) {
            NSString *name = [NSString stringWithFormat:@"Unknown-%d.png", i];
            [origins addObject:[UIImage imageNamed:name]];
        }
        SimpleDivider* divider = [[SimpleDivider alloc] init];
        for (int i = 0; i < 6; i++) {
            [data addObject:[[MangaPage alloc] initWithUIImage:[origins objectAtIndex:i] andDivider:divider]];
        }
        
        _pages = [NSArray arrayWithArray:data];
    }
    return self;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    // Return the data view controller for the given index.
    if (([_pages count] == 0) || (index >= [_pages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.page = [_pages objectAtIndex:index];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController
{   
    /*
     Return the index of the given data view controller.
     For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
     */
    return [_pages indexOfObject:viewController.page];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [_pages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
