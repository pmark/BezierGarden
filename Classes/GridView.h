//
//  GridView.m
//
//

#import <UIKit/UIKit.h>
#import "SM3DAR.h"

// Works well for grid size 660km
//#define GRID_SCALE_HORIZONTAL 0.001
//#define GRID_SCALE_VERTICAL 0.12

// Works well for grid size 25km
#define GRID_SCALE_HORIZONTAL 1.0   // 0.1
#define GRID_SCALE_VERTICAL 2.0  // 0.45


@interface GridView : SM3DAR_MarkerView
{
}

@end
