//
//  GridView.m
//
//

#import <OpenGLES/ES1/gl.h>
#import "GridView.h"
#import "ElevationGrid.h"

@implementation GridView

- (void) buildView 
{
    NSLog(@"[GV] buildView");    
}

#define MAX_LINE_LENGTH 256

- (void) drawAxes
{
    ushort lineIndex [256];
    
    Coord3D * verts = &worldCoordinateData[0][0];
    int gridSize = ELEVATION_PATH_SAMPLES;
    
    glDisable(GL_LIGHTING);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	glVertexPointer(3, GL_FLOAT, 0, verts);
    
    glLineWidth(1.0);
    glColor4f(1,1,0,1);
    
    glScalef(1, 1, 10);
    
    // draw horizontal lines.
    
    for (int y=0; y < gridSize; y++)
    {
    	int start = y * gridSize;
        
        // build index array.
        
        for (int x=0; x < gridSize; x++)
        	lineIndex[x] = start + x;
            
		glDrawElements(GL_LINE_STRIP, gridSize, GL_UNSIGNED_SHORT, lineIndex);
    }
    
    // draw horizontal lines.
    
    for (int x=0; x < gridSize; x++)
    {
    	int start = x;
        
        // build index array.
        
        for (int y=0; y < gridSize; y++)
        	lineIndex[y] = start + (y * gridSize);
            
		glDrawElements(GL_LINE_STRIP, gridSize, GL_UNSIGNED_SHORT, lineIndex);
    }
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
