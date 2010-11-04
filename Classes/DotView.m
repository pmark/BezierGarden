//
//  DotView.m
//
//

#import <OpenGLES/ES1/gl.h>
#import "DotView.h"

@implementation DotView

- (void) buildView 
{
    NSLog(@"[DV] buildView");    
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
    
    glLineWidth(2.0);
    glVertexPointer(3, GL_FLOAT, stride, lines);
    glDrawArrays(GL_LINE_LOOP, 0, sizeof(lines) / stride);

    //[self drawAxes];
}

@end
