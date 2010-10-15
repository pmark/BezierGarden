//
//  GridView.m
//
//

#import <OpenGLES/ES1/gl.h>
#import "GridView.h"
#import "ElevationGrid.h"

@implementation GridView

- (void) printElevationData
{
    CGFloat len = ELEVATION_LINE_LENGTH / 1000.0;
    NSMutableString *str = [NSMutableString stringWithFormat:@"\n\n%i elevation samples in a %.1f sq km grid\n", ELEVATION_PATH_SAMPLES, len, len];
    NSMutableString *wpStr = [NSMutableString stringWithString:@"\n\nworld coordinates:\n"];
    
    for (int i=0; i < ELEVATION_PATH_SAMPLES; i++)
    {
        [str appendString:@"\n"];
        [wpStr appendString:@"\n"];
        
        for (int j=0; j < ELEVATION_PATH_SAMPLES; j++)
        {
            Coord3D c = worldCoordinateData[i][j];
            [wpStr appendFormat:@"%.0f,%.0f,%.0f  ", c.x, c.y, c.z];            
            
            CGFloat elevation = elevationData[i][j];            
            
            if (abs(elevation) < 10) [str appendString:@" "];
            if (abs(elevation) < 100) [str appendString:@" "];
            if (abs(elevation) < 1000) [str appendString:@" "];
            
            if (elevation < 0)
            {
                [str replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            
            [str appendFormat:@"%.0f ", elevation];                        
        }
        
    }
    
    [str appendString:@"\n\n"];
    [wpStr appendString:@"\n\n"];
    
    //NSLog(str, 0);
    NSLog(wpStr, 0);
}

- (void) buildView 
{
    NSLog(@"[GV] buildView");  
    [self printElevationData];
}

- (void) drawAxes
{
    static float verts[4][3] = {
        { 3,3,3 },
        { 9,3,3 },
        { 3,9,3 },
        { 3,3,9 }
    };
    
    static ushort line0 [] = {0,1};
    static ushort line1 [] = {0,2};
    static ushort line2 [] = {0,3};
    glDisable(GL_LIGHTING);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	glVertexPointer(3, GL_FLOAT, 0, verts);
    
    glLineWidth(3.0);
    
    glColor4f(1,0,0,1);
	glDrawElements(GL_LINES, 2, GL_UNSIGNED_SHORT, line0);
    
    glColor4f(0,1,0,1);
	glDrawElements(GL_LINES, 2, GL_UNSIGNED_SHORT, line1);
    
    glColor4f(0,0,1,1);
	glDrawElements(GL_LINES, 2, GL_UNSIGNED_SHORT, line2);    
}

- (void) drawGrid
{
    
}

- (void) drawInGLContext 
{
    const int stride = 3 * sizeof(float);
    
    float lines[][3] = 
    {
        { 0, 0, 0 }, 
        { 0, 2, 0 },
        { 2, 2, 0 },
        { 2, 0, 0 }
    };

    glEnableClientState(GL_VERTEX_ARRAY);
    
    glColor4f(1, 1, 1, 1);
    
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    
    glLineWidth(3.0);
    glVertexPointer(3, GL_FLOAT, stride, lines);
    glDrawArrays(GL_LINE_LOOP, 0, sizeof(lines) / stride);

    [self drawAxes];
}

@end
