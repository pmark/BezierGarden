//
//  BezierGardenAppDelegate.h
//  BezierGarden
//
//  Created by P. Mark Anderson on 10/6/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BezierGardenViewController;

@interface BezierGardenAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BezierGardenViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BezierGardenViewController *viewController;

@end

