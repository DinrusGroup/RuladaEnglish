	/******************************************************************************* 

    Window module allows access to the game window. 

    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
		Window allows opening and closing of window with user given parameters. 
	Window also contains code to take a screenshot of itself, retrieve its 
	dimensions, resize itself and alter its coordinate system.

	Examples:
	--------------------
	import arc.window; 

	int main() 
	{
		// initialize SDL/OpenGL window 
		// read window parameters from a lua configuration file
		arc.window.open("Title", width, height, bFullScreen); 

		// take a screenshot of current window and save it as a bitmap
		arc.window.screenshot("screen1");
	   
		// toggle between full screen and window mode (linux only)
		arc.window.toggleFullScreen();

		// resize window with given width and height (currently texture information is lost on Windows)
		arc.window.resize(width, height)
	   
		// get window's height and width
		arc.window.getHeight/getWidth; 
	   
		while (gameloop)
		{
			// clear contents of window
			arc.window.clear();
			
			// draw stuff to the screen 
			
			// switch to next window frame
			arc.window.swap();
		}

		// closes the window
		arc.window.close(); 

	   return 0;
	}
	--------------------

*******************************************************************************/

module arc.window;

/*******************************************************************************

   Import all we need from the std library

*******************************************************************************/
import	std.string:cmp,toStringz;
import 	std.c: memcpy, exit;
import 	std.io; 

import
	arc.math.point,
	arc.math.rect,
	arc.types,
	arc.memory.routines; 

/*******************************************************************************

   Import all we need from derelict 

*******************************************************************************/
import 	
	derelict.opengl.gl,
	derelict.opengl.glu,
	derelict.sdl.sdl,
	derelict.sdl.image,
	derelict.util.exception;

/*******************************************************************************

	Opens a window with the given size and initializes OpenGL

*******************************************************************************/
void open(char[] argTitle, int argWidth, int argHeight, bool argFullscreen)
{
	// Initialize variables
	wTitle = argTitle;
	wWidth = argWidth;
	wHeight = argHeight;
	wFullscreen = argFullscreen;
		
	debug writefln("window: open(", wTitle, ", ", wWidth, ", ", wHeight, ", ", wFullscreen, ")");

	// Loads Derelict Libraries needed by Arc at runtime
	loadDerelict(); 

	// Create the SDL window
	initializeSDL();
	
	// reinitialize viewport, projection etc. to fit the window
	resizeGL();
	
	coordinates.setSize(Size(argWidth, argHeight));
	
	debug printVendor();
}

/*******************************************************************************

	Close SDL window and delete the screen

*******************************************************************************/
void close()
{
	SDL_Quit();

	unloadDerelict(); 
}

/// Returns window width
int getWidth() { return wWidth; }

/// Returns window height
int getHeight() { return wHeight; }

/// returns window size
Size getSize() { return Size(wWidth, wHeight); }

/// Returns true if window is fullscreen
bool isFullScreen() { return wFullscreen; }

/// get the window screen
SDL_Surface* getScreen() { return screen; }

/*******************************************************************************

	Resize window to desired width and height

*******************************************************************************/
void resize(int argWidth, int argHeight)
{
	wWidth = argWidth;
	wHeight = argHeight;
	
	if (wFullscreen)
		screen = SDL_SetVideoMode(argWidth, argHeight, bpp, SDL_OPENGL|SDL_HWPALETTE|SDL_FULLSCREEN|SDL_RESIZABLE);
	else
		screen = SDL_SetVideoMode(argWidth, argHeight, bpp, SDL_OPENGL|SDL_HWPALETTE|SDL_RESIZABLE);

	resizeGL();
}


/*******************************************************************************

	Toggle between fullscreen and windowed mode; linux only

*******************************************************************************/
void toggleFullScreen()
{
	if(SDL_WM_ToggleFullScreen(screen) == 0)
	{
			debug writefln("Window: Failed to toggle fullscreen");
			return;
	}

	wFullscreen = !wFullscreen;
}

/// clear the screen
void clear()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

/// swap the screen buffers
void swap()
{
	SDL_GL_SwapBuffers(); 
}

/// swap and clear the screen, equivalent to calling swap() and then clear()
void swapClear()
{
	SDL_GL_SwapBuffers(); 
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}


/*******************************************************************************

	Captures a screenshot and saves in BMP format to current directory

*******************************************************************************/
void screenshot(char[] argName)
{
	// a
	SDL_Surface *image = null;
	SDL_Surface *temp = null;

	// b
	image = SDL_CreateRGBSurface(SDL_SWSURFACE, wWidth, wHeight, 24, 0x0000FF, 0x00FF00, 0xFF0000, 0);

	if(!(image is null))
	{
			// c
			temp  = SDL_CreateRGBSurface(SDL_SWSURFACE, wWidth, wHeight, 24, 0x0000FF, 0x00FF00, 0xFF0000, 0);

			if(!(temp is null))
			{
				// d
				glReadPixels(0, 0, wWidth, wHeight, GL_RGB, GL_UNSIGNED_BYTE, image.pixels);

				// e
				for (int idx = 0; idx < wHeight; idx++)
				{
						char* dest = cast(char *)(temp.pixels+3*wWidth*idx);
						memcpy(dest, cast(char *)(image.pixels+3*wWidth*(wHeight-1-idx)), 3*wWidth);
						endianswap(dest, 3, wWidth);
				}

				// f
				SDL_SaveBMP(temp, toStringz(argName ~ ".bmp"));
				SDL_FreeSurface(temp);
				debug writefln("window: screenshot " ~ argName ~ ".bmp taken");
			}

			SDL_FreeSurface(image);
	}

} // screenshot()


/**
	Offers functionality for dealing with the coordinate system.
	
	By default the origin (0,0) is in the top-left corner, x faces right, y down.
	By default, the bottom-right corner has the coordinates (800,600).
	
	This is mainly intended to allow the customization of the coordinate
	system at startup and on window resizes. 

	It is not recommended to use this for scrolling: since these
	functions alter the global coordinate system, you will have no
	control over what scrolls and what doesn't. Use the scenegraph
	with a Transform node for selective scrolling.
**/
struct coordinates
{
	/// sets the virtual size of the screen
	static void setSize(Size argsize)
	{
		size = argsize;
		setupGLMatrices();
	}
	
	/// sets the coordinates for the top-left corner of the screen
	static void setOrigin(Point argorigin)
	{
		origin = argorigin;
		setupGLMatrices();
	}
	
	/// gets the virtual screen size
	static Size getSize() { return size; }
	static arcfl getWidth() { return size.w; } /// ditto
	static arcfl getHeight() { return size.h; } /// ditto
	/// gets the coordinates of the top-left corner of the screen
	static Point getOrigin() { return origin; }				
	
private:
	static Size size;
	static Point origin;
	
	/// setup the projection and modelview matrices
	static void setupGLMatrices()
	{
		// projection matrix
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();		
		glOrtho(origin.x, origin.x + size.w, origin.y + size.h, origin.y, -1.0f, 1.0f);

		// modelview matrix
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();		
	}
}


private
{
	/*******************************************************************************

		Initialize SDL

	*******************************************************************************/
	void initializeSDL()
	{
		// for some mysterious reason this info is lost if we don't do this
		char* windowTitle = toStringz(wTitle);

		if(SDL_Init is null)
				throw new Exception("Window: SDL_Init is null");

		// initialize video
		if(SDL_Init(SDL_INIT_VIDEO) < 0)
				throw new Exception("Window: Failed to initialize SDL Video");

		// set pixel depth and format
		setupPixelDepth();
		setupPixelFormat();

		// set fullscreen flags properly
		if (wFullscreen)
				screen = SDL_SetVideoMode(wWidth, wHeight, bpp,  SDL_OPENGL|SDL_HWPALETTE|SDL_FULLSCREEN);
		else
				screen = SDL_SetVideoMode(wWidth, wHeight, bpp,  SDL_OPENGL|SDL_HWPALETTE|SDL_RESIZABLE);

		if (screen is null)
				throw new Exception("Window: screen is null after SDL_SetVideoMode called");

		// set window caption
		SDL_WM_SetCaption(windowTitle, null);
	}

	/*******************************************************************************

		Query's SDL for the current video info (desktop), extracts bpp and sets
				bpp to what it found it was, this way the color depth is the color depth
				the user uses from the desktop, and it should not crash

	*******************************************************************************/
	void setupPixelDepth()
	{
		SDL_VideoInfo *info = SDL_GetVideoInfo();

		if(info is null)
				throw new Exception("Window: SDL_GetVideoInfo() is null");

		bpp = info.vfmt.BitsPerPixel;
	}

	/*******************************************************************************

		Prints a slew of graphics driver and extension debug info

	*******************************************************************************/
	debug
	{
		void printVendor()
		{
			debug writefln("Render Type: OpenGL (Hardware)");
			printf( "Vendor     : %s\n", glGetString( GL_VENDOR ) );
			printf( "Renderer   : %s\n", glGetString( GL_RENDERER ) );
			printf( "Version    : %s\n", glGetString( GL_VERSION ) );
			printf( "Extensions : %s\n", glGetString( GL_EXTENSIONS ) );
		}
	}

	/*******************************************************************************

		Derelict is a library that allows me to load all my library functions at
				run time, and displaying a proper message if any single library fails 
				to load, a message like "Can't find library %s, go get it at %s"

	*******************************************************************************/
	void loadDerelict()
	{
		try {
			Derelict_SetMissingProcCallback(&handleMissingOpenGL);
			DerelictGL.load();
			DerelictGLU.load();
			DerelictSDL.load();
			DerelictSDLImage.load();
		} // try
	
		catch (Exception e) {
			e.print();
			exit(0);
		} // catch	
	} // loadDerelict
	
	// unload derelict 
	void unloadDerelict()
	{
		DerelictGL.unload();
		DerelictGLU.unload();
		DerelictSDL.unload();
		DerelictSDLImage.unload();
	}
    
	/*******************************************************************************

		Sets up the pixel format the way we like it

	*******************************************************************************/
	void setupPixelFormat()
	{
		SDL_GL_SetAttribute( SDL_GL_RED_SIZE, 5 );
		SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE, 5 );
		SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE, 5 );
		SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 16 );
		SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
	}


	/*******************************************************************************

		Resizes the openGL viewport and reinitializes its matrices. 
		Also resets GL states.

	*******************************************************************************/
	void resizeGL()
	{
		// viewport
		glViewport(0,0, wWidth, wHeight);

		// reset the matrices
		coordinates.setupGLMatrices();
		
		// states
		setGLStates();
	}
	
	/// initialize OpenGL parameters required to draw 
	void setGLStates()
	{
		glEnable(GL_TEXTURE_2D); 
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_DEPTH_TEST);
	}

	
	// skips trying to load glXGetProcAddress if it could not find it
	bool handleMissingOpenGL(char[] libName, char[] procName)
	{
			/// Not used by ArcLib 
			if(procName.cmp("glXGetProcAddress") == 0)    
				return true;                       

			return false;                           
	}
	
	/*******************************************************************************
	
		Private vars we hide inside the module
	
	*******************************************************************************/
	
	// window info
	char[] wTitle;
	int wWidth, wHeight;
	bool wFullscreen = false;

	// SDL info
	SDL_Surface *screen = null;
	int bpp = 0;
}
