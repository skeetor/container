// Pong2D.cpp : This file contains the 'main' function. Program execution begins and ends there.
// Original: https://noobtuts.com/cpp/2d-pong-game

#include <string>
#include <vector>

#include <windows.h>
#include <iostream>
#include <conio.h>
#include <sstream>
#include <math.h>
#include <gl\gl.h>
#include <gl\glu.h>
#include "GL/freeglut.h"
#pragma comment(lib, "OpenGL32.lib")
#pragma comment(lib, "freeglut.lib")

#include "Vertex3d.h"

using namespace std;

static int gWindowWidth = 640;
static int gWindowHeight = 256;
static int gInterval = 1000 / 60;

static float gEyeDistance = 500.0;			// Eye to screen distance
static float gProjDistance = 200.0;		// Screen to projection distance

static vector<Vertex3D> gVertices;

// Calculate the screencoordinates from a single 3D vertex
void projectToScreen(const Vertex3D &v, GLint &x, GLint &y)
{
	x = (GLint)((v.getX()*v.getX()*gEyeDistance) / (gProjDistance + v.getZ()));
	y = (GLint)((v.getY()*v.getX()*gEyeDistance) / (gProjDistance + v.getZ()));
}

void update(int value)
{
	// Call update() again in 'interval' milliseconds
	glutTimerFunc(gInterval, update, 0);

	// Redisplay frame
	glutPostRedisplay();
}

void enable2D(int width, int height)
{
	glViewport(0, 0, width, height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0.0f, width, 0.0f, height, 0.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

string int2str(int x)
{
	return to_string(x);
}

static void prepareVertices(void)
{
	gVertices.push_back(Vertex3D(10.0, 1.0, 10.0));
	gVertices.push_back(Vertex3D(10.0, 2.0, 10.0));
	gVertices.push_back(Vertex3D(20.0, 1.0, 10.0));
	gVertices.push_back(Vertex3D(20.0, 2.0, 10.0));

	/*gVertices.push_back(Vertex3D(10.0, 1.0, 200));
	gVertices.push_back(Vertex3D(10.0, 2.0, 2.0));
	gVertices.push_back(Vertex3D(20.0, 1.0, 2.0));
	gVertices.push_back(Vertex3D(20.0, 2.0, 2.0));*/
}

void drawText(float x, float y, string text)
{
	glRasterPos2f(x, y);
	glutBitmapString(GLUT_BITMAP_8_BY_13, (const unsigned char*)text.c_str());
}

void draw()
{
	// clear (has to be done at the beginning)
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	// draw score
	drawText(gWindowWidth / 2.0 - 10, gWindowHeight - 20.0, "Test:" + int2str(0));

	glBegin(GL_POINTS);
	{
		GLint x, y;

		glColor3f(1, 1, 1);

		for (const Vertex3D &v : gVertices)
		{
			projectToScreen(v, x, y);
			glVertex2i(x, y);
		}
	}
	glEnd();

	// swap buffers (has to be done at the end)
	glutSwapBuffers();
}

int main(int argc, char *argv[])
{
	prepareVertices();

	// initialize opengl (via glut)
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(gWindowWidth, gWindowHeight);
	glutCreateWindow("Pong 2D");

	// Register callback functions  
	glutDisplayFunc(draw);
	glutTimerFunc(gInterval, update, 0);

	// setup scene to 2d mode and set draw color to white
	enable2D(gWindowWidth, gWindowHeight);
	glColor3f(1.0f, 1.0f, 1.0f);

	// start the whole thing
	glutMainLoop();

	return 0;
}
