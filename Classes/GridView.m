//
//  GridView.m
//
//

#import <OpenGLES/ES1/gl.h>
#import "GridView.h"
#import "ElevationGrid.h"

#define GRID_SCALE_HORIZONTAL 0.1
#define GRID_SCALE_VERTICAL 0.4

@implementation GridView

- (void) buildView 
{
    NSLog(@"[GV] buildView");    
}

#define MAX_LINE_LENGTH 256

- (void) drawFog
{
    GLfloat fogColor[4] = {0.8f, 0.8f, 0.9f, 1.0f};
    glFogfv(GL_FOG_COLOR, fogColor);

    glFogf(GL_FOG_MODE, GL_LINEAR);
    glFogf(GL_FOG_DENSITY, 1.0);

    glFogf(GL_FOG_START, 0.0);
    
    CGFloat fogEnd = GRID_SCALE_HORIZONTAL * ELEVATION_LINE_LENGTH / 2.0;
    glFogf(GL_FOG_END, fogEnd);

    glHint(GL_FOG_HINT, GL_NICEST);

    glEnable(GL_FOG);
}

- (void) drawGrid
{
    ushort lineIndex [256];
    
    Coord3D *verts = &worldCoordinateData[0][0];
    int gridSize = ELEVATION_PATH_SAMPLES;
    
    glDisable(GL_LIGHTING);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	glVertexPointer(3, GL_FLOAT, 0, verts);
    
    glLineWidth(1.0);
    glColor4f(1,1,0,1);
    
    glScalef(GRID_SCALE_HORIZONTAL, GRID_SCALE_HORIZONTAL, GRID_SCALE_VERTICAL);
    
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

- (void) drawInGLContext 
{
    [self drawGrid];
    [self drawFog];
}

@end
