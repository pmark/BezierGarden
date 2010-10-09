//
//  BezierGardenViewController.h
//  BezierGarden
//
//  Created by P. Mark Anderson on 10/6/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SM3DAR.h"

@interface BezierGardenViewController : UIViewController <SM3DAR_Delegate>
{
	SM3DAR_Controller *sm3dar;
}

@end

