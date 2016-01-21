/******************************************************************************* 

    Input module allows access to the keyboard and the mouse. 

    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
        The input module allows the user access to keyboard, mouse and joystick.
	Input must be processed once every frame. Use keyPressed methods to tell 
	if user only lightly pressed their key. Use keyDown methods to tell if 
	user is holding a key down. Use keyReleased to tell when user has released
	a key. 

    Examples:
    -------------------------------------------------------------------------------
    import arc.input;

int main() {
	
	// initializes input
	arc.input.open();
	arc.input.openJoysticks();
	
	// while the user hasn't closed the window
	while (!arc.input.keyDown(ARC_QUIT))
	{
		// get current input from user
		arc.input.process();

		// user lightly taps 't' key
		arc.input.keyPressed('t'); // a-z, SDLK_a-SDLK_z
		
		// user holds down 't' key
		arc.input.keyDown('t');

		// user lightly clicks right mouse button
		arc.input.mouseButtonPressed(RIGHT);

		// user holds down left mouse button
		arc.input.mouseButtonDown(LEFT) // RIGHT and MIDDLE work as well

		// returns true if user hits a character
		if (arc.input.charHit) {
			// returns the last characters the user hit
			char[] ch = arc.input.lastChars; 
		}

		// returns position of mouse
		arc.input.mouseX; // .mouseY  .mouseOldY  .mouseOldX 

		// returns true if mouse is in motion
		arc.input.mouseMotion; 

		// returns true if mouse is wheeling up
		// wheelDown - returns true on mouse Wheelup and Wheeldown
		arc.input.wheelUp; 

		foreach(stick; joysticksIter)
		{
			foreach(button; arc.input.joyButtonsDown(stick))
				writefln("button ", button, " pressed on joystick ", stick );
			foreach(button; arc.input.joyButtonsUp(stick))
				writefln("button ", button, " released on joystick ", stick );
			foreach(pos, axis; joyAxesMove(stick))
				writefln("axis ", axis, " moved to ", pos, " on joystick ", stick );
		}
	

		// close doesn't actually do anything now
        arc.input.close(); 
        
        return 0;
    }
    -------------------------------------------------------------------------------


*******************************************************************************/

module arc.input;

// import input key identifiers
import
	derelict.sdl.sdl,
	derelict.sdl.keysym;
	//derelict.sdl.events; 

// Input uses window when user resizes the window
import 
	arc.window,
	arc.log,
	arc.types,
	arc.math.point; 

// Let user have constants used in input
public import arc.internals.input.constants;

// Import mouse and keyboard structs internally
import 
	arc.internals.input.keyboard,
	arc.internals.input.mouse,
	arc.internals.input.joystick;

import std.math : abs;
import std.string : toString;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                      PUBLIC INTERFACE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
public {

/// clear's input, gets current modifiers, enables unicode and disables key repeat
void open(bool keyRepeat=true)
{
	// focus is true unless otherwise set
	focus = true;

	// clear keyboard and mouse
	keyboard.clear();
	mouse.clear();
	
	// Enable UNICODE translation for keyboard input
	SDL_EnableUNICODE(1);

	// set keyboard repeat state
	setKeyboardRepeat(keyRepeat);
}

/// implementation just for symmetry, does not do anything
void close()
{
}

//
// keyboard configuration methods
//

/// sets keyboard repeat on or off
void setKeyboardRepeat(bool onoff)
{
	if(onoff == true)
	{
		// Enable auto repeat for keyboard input
		SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
	}
	else
	{
		// Disable auto repeat for keyboard input
		SDL_EnableKeyRepeat(0, 0);		
	}
}


//
// keyboard query methods
//

/// returns the full KeyStatus information for the key
KeyStatus keyStatus(int keyNum) { return keyboard.status[keyNum]; }
/// test if is set
private bool isSet(T)(T state, T flag) { return 0 != (state & flag); }
/// returns true when key has gone from up to down between calls to process
bool keyPressed(int keyNum) { return isSet(keyboard.status[keyNum], KeyStatus.PRESSED);   }
/// returns true when key has gone from down to up between calls to process
bool keyReleased(int keyNum) { return isSet(keyboard.status[keyNum], KeyStatus.RELEASED);  }
/// returns true when key is physically down
bool keyDown(int keyNum) { return isSet(keyboard.status[keyNum], KeyStatus.DOWN);  }
/// returns true when key is physically up
bool keyUp(int keyNum) { return !isSet(keyboard.status[keyNum], KeyStatus.DOWN);  }

/// returns true if user has hit a character on the keyboard between two calls to process
bool charHit()           { return keyboard.charHit;       }
/// returns characters hit by the user between two process calls
char[] lastChars()         { return keyboard.lastChars;      }


//
// mouse query methods
//

/// returns full KeyStatus information for the button
KeyStatus mouseButtonStatus(int keyNum) { return mouse.buttonStatus[keyNum]; }

/// returns true if mouse button has gone from up to down between calls to process
bool mouseButtonPressed(int keyNum) { return isSet(mouse.buttonStatus[keyNum], KeyStatus.PRESSED); }
/// returns true if mouse button has gone from down to up between calls to process
bool mouseButtonReleased(int keyNum) { return isSet(mouse.buttonStatus[keyNum], KeyStatus.RELEASED); }
/// returns true if user holds mouse button down
bool mouseButtonDown(int keyNum)  { return isSet(mouse.buttonStatus[keyNum], KeyStatus.DOWN); }
/// returns true if user doesn't hold mouse button down
bool mouseButtonUp(int keyNum)  { return !isSet(mouse.buttonStatus[keyNum], KeyStatus.DOWN); }

// NOTE: for the arc 2D game engine, mouse.x and mouse.y are only used 
//       to help determine the virtual coordinates.
//       for 3D games, you may want to use mouse.x and mouse.y
//       but for 2D games, there is never a need to, so mouseX and mouseX2D
//       will return the same values

/// mouseX position 
arcfl mouseX()               { return mouse.x2D;      }
/// mouseY position 
arcfl mouseY()               { return mouse.y2D;      }
/// mouse position
Point mousePos() { return Point(mouse.x2D, mouse.y2D); }
/// old mouse X position 
arcfl mouseOldX()            { return mouse.oldX2D;   }
/// old mouse Y position 
arcfl mouseOldY()            { return mouse.oldY2D;   }
/// old mouse position
Point mouseOldPos() { return Point(mouse.oldX2D, mouse.oldY2D); }

/// returns true when mouse is moving
bool mouseMotion()          { return mouse.moving; }

/// set mouse cursor visibility
void defaultCursorVisible(bool argV) { mouse.setDefaultCursorVisible(argV); }

/// returns true when mouse is wheeling up
bool wheelUp()     { return isSet(mouse.buttonStatus[WHEELUP], KeyStatus.DOWN);   }
/// returns true when mouse is wheeling down
bool wheelDown()   { return isSet(mouse.buttonStatus[WHEELDOWN], KeyStatus.DOWN); }


//
// joystick configuration
//

/// JoyStick Exception Class 
class JoystickException : Exception
{
	this(char[] msg)
	{
		super(msg);
	}
}

/// returns the number of joysticks that are plugged in
ubyte numJoysticks() 
{
	if (!joysticks.initialized)
		joysticks.init();
	return SDL_NumJoysticks(); 
}

/*******************************************************************************

	Joysticks have to be opened with this function before they can be used.
	Use numJoysticks() to query the number of sticks (or gamepads) that are
	plugged in. Joysticks are identified by a number, starting from 0. Either
	specify a joystick by index to be opened, or call this function without
	any arguments to open all available joysticks.
	The number of joysticks that are actually opened is returned.
	
	Use numJoysticks to query the number of sticks or pads that are plugged in.

*******************************************************************************/
int openJoysticks(int index = -1)
in
{
	assert(index >= -1 && index <= ubyte.max, "invalid range for joystick index");
}
body
{
	if (!joysticks.initialized)
	joysticks.init();
	SDL_JoystickEventState(SDL_ENABLE);
	if (index < 0)
	{
		index = numJoysticks();
		joysticks.joystickInfo.length = index;
		while (index--)
			joysticks.joystickInfo[index] = Joysticks.Joystick(index);
	}
	else
	{
		if (index > cast(int)(joysticks.joystickInfo.length) - 1)
			joysticks.joystickInfo.length = index;
		joysticks.joystickInfo[index] = Joysticks.Joystick(index);
	}
	int result = joysticks.numSticksOpen();
	joysticks.isJoyStickEnabled = cast(bool)result;
	joysticks.numJoysticks = SDL_NumJoysticks();

	return result;
}

/// The counterpart to openJoysticks.
void closeJoysticks(int index = -1)
in
{
    assert(index >= -1 && index <= ubyte.max, "invalid range for joystick index");
}
body
{
	joysticks.isJoyStickEnabled = false;

	if (index < 0)
	{
		foreach(stick; joysticks.joystickInfo)
			if (stick.isOpen)
				stick.close();
		joysticks.joystickInfo.length = 0;
	}
	else
	{
		if (index > cast(int)(joysticks.joystickInfo.length) - 1)
			return;
		if (joysticks.joystickInfo[index].isOpen)
			joysticks.joystickInfo[index].close();
		joysticks.isJoyStickEnabled = cast(bool)joysticks.numSticksOpen();
	}
}


//
// joystick query methods
//

/// returns whether button is currently down on joystick index (button numbers start from 0)
/// button must be smaller than numJoystickButtons(index) or a runtime error will result.
bool joyButtonDown(ubyte index, ubyte button)
in
{
	assert(isJoystickOpen(index) && numJoystickButtons(index) < button);
}
body
{
	return isJoystickOpen(index) && isSet(joysticks.joystickInfo[index].buttonStatus[button], KeyStatus.DOWN);
}

/// returns whether button is up, see joyButtonDown for details
bool joyButtonUp(ubyte index, ubyte button)
in
{
	assert(isJoystickOpen(index) && numJoystickButtons(index) < button);
}
body
{
	return isJoystickOpen(index) && !isSet(joysticks.joystickInfo[index].buttonStatus[button], KeyStatus.DOWN);
}

/// returns whether button has been pressed since last call to process
bool joyButtonPressed(ubyte index, ubyte button)
in
{
	assert(isJoystickOpen(index) && numJoystickButtons(index) < button);
}
body
{
	return isJoystickOpen(index) && isSet(joysticks.joystickInfo[index].buttonStatus[button], KeyStatus.PRESSED);
}

/// returns whether button has been released since last call to process
bool joyButtonReleased(ubyte index, ubyte button)
in
{
	assert(isJoystickOpen(index) && numJoystickButtons(index) < button);
}
body
{
	return isJoystickOpen(index) && isSet(joysticks.joystickInfo[index].buttonStatus[button], KeyStatus.RELEASED);
}

/** returns position of axis on joystick index (axes numbers start from 0)
  axis must be smaller than numJoystickAxes(index) or a runtime error will result.
 
 The value returned is the current position of the axis, which is in the range of -1.0f to 1.0f epsilon (give or take)
 An exact value of 0.0f has a special meaning: in this case there was no axis movement at all
 */
arcfl joyAxisMoved(ubyte index, ubyte axis)
in
{
	assert(isJoystickOpen(index) && numJoystickAxes(index) < axis);
}
body
{
	if (!isJoystickOpen(index))
		return 0.0f;
	return joysticks.joystickInfo[index].axisMoved[axis];
}

/// iterate over all open joysticks
int delegate(int delegate(inout ubyte)) joysticksIter;

/// iterate over currently down on joystick index
/// throws: JoystickException if index is not valid
Joysticks.Joystick.ButtonIterator joyButtonsDown(ubyte index)
in
{   assert(index < joysticks.joystickInfo.length, "out of bounds: invalid joystick index"); }
body
{
	if(!(index < joysticks.joystickInfo.length))
		throw new JoystickException("out of bounds: invalid joystick index");
	return joysticks.joystickInfo[index].makeButtonIterator(KeyStatus.DOWN);
}

/// iterate over buttons currently up on joystick index
/// throws: JoystickException if index is not valid
Joysticks.Joystick.ButtonIterator joyButtonsUp(ubyte index)
in
{   assert(index < joysticks.joystickInfo.length, "out of bounds: invalid joystick index"); }
body
{
	if(!(index < joysticks.joystickInfo.length))
		throw new JoystickException("out of bounds: invalid joystick index");
	return joysticks.joystickInfo[index].makeButtonIterator(KeyStatus.UP);
}

/// iterate over buttons on joystick index that were pressed since last call to process
/// throws: JoystickException if index is not valid
Joysticks.Joystick.ButtonIterator joyButtonsPressed(ubyte index)
in
{   assert(index < joysticks.joystickInfo.length, "out of bounds: invalid joystick index"); }
body
{
	if(!(index < joysticks.joystickInfo.length))
		throw new JoystickException("out of bounds: invalid joystick index");
	return joysticks.joystickInfo[index].makeButtonIterator(KeyStatus.PRESSED);
}

/// iterate over buttons on joystick index that were released since last call to process
/// throws: JoystickException if index is not valid
Joysticks.Joystick.ButtonIterator joyButtonsReleased(ubyte index)
in
{   assert(index < joysticks.joystickInfo.length, "out of bounds: invalid joystick index"); }
body
{
	if(!(index < joysticks.joystickInfo.length))
		throw new JoystickException("out of bounds: invalid joystick index");
	return joysticks.joystickInfo[index].makeButtonIterator(KeyStatus.RELEASED);
}

/// iterate over axes moved on joystick index since last call to process
int delegate(int delegate(inout ubyte axis, inout arcfl)) joyAxesMoved(ubyte index)
in
{   assert(index < joysticks.joystickInfo.length, "out of bounds: invalid joystick index"); }
body
{
	if(!(index < joysticks.joystickInfo.length))
		throw new JoystickException("out of bounds: invalid joystick index");
    return &joysticks.joystickInfo[index].foreachAxisMoved;
}

/// number of buttons on joystick index or 0 if joystick is not opened
ubyte numJoystickButtons(ubyte index)
{
    return index < joysticks.joystickInfo.length ? joysticks.joystickInfo[index].numButtons : 0;
}

/// number of axes on joystick index or 0 if joystick is not opened
ubyte numJoystickAxes(ubyte index)
{
    return index < joysticks.joystickInfo.length ? joysticks.joystickInfo[index].numAxes : 0;
}

/// vendor specific string describing this device or empty string if joystick is not opened
char[] joystickName(ubyte index)
{
    return index < joysticks.joystickInfo.length ? joysticks.joystickInfo[index].name : "";
}

/// true if this joystick has been opened, false otherwise
bool isJoystickOpen(ubyte index)
{
    return index < joysticks.joystickInfo.length ? joysticks.joystickInfo[index].isOpen : false;
}

/// 
void setAxisThreshold(arcfl threshold)
in 
{	assert(threshold > 0.0f && threshold < 1.0f, "invalid threshold value, should be larger than 0.0.f and smaller than 1.0f"); }
body
{
	if (threshold > 0.0f && threshold < 1.0f)
	{
		joysticks.axisThreshold = cast(short)(cast(real)(short.max) * threshold);
	}
}

//
// other methods
//

/// return whether SDL window has lost focus 
bool lostFocus() { return !focus; }

/// force quit of application
void quit() { keyboard.status[ARC_QUIT] = KeyStatus.DOWN | KeyStatus.PRESSED; }

/// returns true if quitting 
bool isQuit() { return (keyboard.status[ARC_QUIT] & KeyStatus.DOWN) != 0; }

import std.io;

/// Capture input from user
public void process()
{
	SDL_Event event;
	
	mouse.moving = false;
	mouse.clearHit();
	//say("mouse.clearHit();").nl;
	keyboard.clearHit();
	//say("keyboard.clearHit();").nl;
	if (joysticks.isJoyStickEnabled)
		joysticks.clear();

	// Keep on looping through our event until all events are accounted for
	while (SDL_PollEvent(&event))
	{
		// get the type of event
		///say("while (SDL_PollEvent(&event))").nl;
		switch (event.type)
		{
			case SDL_ACTIVEEVENT:
				if ( event.active.gain == 0 )
					focus = false;
				else
					focus = true;
			break; 

			case SDL_MOUSEBUTTONUP:
				// clear mouse keys when button up
				mouse.handleButtonUp(event.button);
			break;

			case SDL_MOUSEBUTTONDOWN:
				// handle mouse keys when button is down
				mouse.handleButtonDown(event.button);
			break;

			case SDL_MOUSEMOTION:
				// handle mouse motion
				mouse.handleMotion(event);
			break;

			case SDL_KEYDOWN:
				// handle key down
				keyboard.handleKeyDown(event.key);
			break;

			case SDL_KEYUP:
				// handle key up, release keys
				keyboard.handleKeyUp(event.key);
			break;

			case SDL_QUIT:
				// set our SDL quit key to true
				keyboard.status[SDL_QUIT] = KeyStatus.DOWN | KeyStatus.PRESSED;
			break;

			case SDL_VIDEORESIZE:
				// have the window be resized based upon user input
				arc.window.resize(event.resize.w, event.resize.h);

				// reload windows textures because Windows is special
				// and re-initialize OpenGL
				version(Windows)
				{
					//arc.gfx.texture.reload();
				}
			break;
			
			if (joysticks.isJoyStickEnabled)
			{
				case SDL_JOYBUTTONDOWN:
					joysticks.handleButtonDown(event);
				break;

				case SDL_JOYBUTTONUP:
					joysticks.handleButtonUp(event);
				break;

				case SDL_JOYAXISMOTION:
					if (abs(cast(int)event.jaxis.value) > joysticks.axisThreshold)
						joysticks.handleAxisMove(event);
				break;

			}

			default:
			break;
		} // switch(event)
	} // while(SDL_Poll(&event))

} // process()

} // public

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                      PRIVATE INTERNALS
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

private {
	// whether or not input has focus
	bool focus;
	Joysticks joysticks;
	KeyBoard keyboard;
	Mouse mouse;
} // private

static this()
{
	joysticksIter = &joysticks.opApply;
}
