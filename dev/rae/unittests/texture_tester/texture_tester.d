module texture_tester;

import tango.util.log.Trace;//Thread safe console output.
	
import tango.math.Math;
//import tango.stdc.math;//std.math;
//import tango.stdc.stdio;//std.stdio;
import tango.stdc.string;
import stringz = tango.stdc.stringz;
import tango.core.Thread;

//version(nogc)
//{
	import tango.core.Memory;
//}

//import rae.core.globals;
import rae.Rae;
import rae.core.Timeout;
import rae.ui.Window;
import rae.ui.Menu;
import rae.ui.SubWindow;
import rae.ui.Paned;
import rae.ui.Button;
import rae.ui.Label;
import rae.ui.ProgressBar;
import rae.ui.Widget;
import rae.ui.Box;
import rae.canvas.Draw;
import rae.canvas.Rectangle;
import rae.canvas.Image;
import rae.ui.Animator;

import rae.canvas.Bezier;

double g_tempclip = 0.0f;
double g_tempclip2 = 0.0f;

class ProjectWindow : Window
{
	this()
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.this() END.");
		
		super("DPX Tester");
		
		
		//threadGroup = new ThreadGroup();
		
		//Menu stuff:
		
		Menu amenu = new Menu();
		//amenu.defaultSize( 0.3f, 0.4f );
		//amenu.xPos( -0.2 );
		//amenu.yPos( 0.1 );
		MenuItem amenuitem1 = new MenuItem("<b>Texture Tester</b>");
		amenu.addMenuItem( amenuitem1 );
			MenuItem amenuitem1_2 = new MenuItem("Quit", &g_rae.quit);
				amenuitem1.addMenuItem( amenuitem1_2 );
		MenuItem amenuitem2 = new MenuItem("Project");
		amenu.addMenuItem( amenuitem2 );
		MenuItem amenuitem3 = new MenuItem("Edit");
		amenu.addMenuItem( amenuitem3 );
		MenuItem amenuitem4 = new MenuItem("Help");
		amenu.addMenuItem( amenuitem4 );
		
		//
		/*
		myWindow3 = new SubWindow("HelloWorld");
		//videoViewerWindow.isRotate = true;
		//myWindow3.moveTo( -0.3f, -0.3f );
		myWindow3.defaultSize( 0.4f, 0.6f );
		add(myWindow3);
		
		myWindow3.
		*/
		add( amenu );
		
		//myWindow3.isClipping = true;
		
		auto emptyButton1 = new Button("Change Src");
		emptyButton1.signalActivate.attach(&changeSrc);
		//myWindow3.
		add( emptyButton1 );
		auto emptyButton2 = new Button("Change Dst");
		emptyButton2.signalActivate.attach(&changeDst);
		//myWindow3.
		add( emptyButton2 );
		
		//insideButton4 = new Button("شیراز");
		//insideButton4.signalActivate.attach(&clickHandler3);
		/*
		insideButton4.signalMouseButtonPress.attach(&clickHandler3);
		insideButton4.signalMouseButtonRelease.attach(&clickHandler3);
		insideButton4.signalMouseMotion.attach(&clickHandler3);
		insideButton4.signalEnterNotify.attach(&clickHandler3);
		insideButton4.signalLeaveNotify.attach(&clickHandler3);
		*/
		//myWindow3.add(insideButton4);
		
		testLabel = new Label("Texture tester");
		testLabel.texture.blendSource = GL_ONE;
		testLabel.texture.blendDestination = GL_ZERO;
		//myWindow3.
		add(testLabel);
		
		colourLabel = new Label("Coloured Label");
		colourLabel.textColour(1.0f, 0.3f, 0.1f, 1.0f);
		colourLabel.texture.blendSource = GL_ONE;
		colourLabel.texture.blendDestination = GL_ZERO;
		//myWindow3.
		add(colourLabel);
		
		blackLabel = new Label("Black Label");
		blackLabel.textColour(0.0f, 0.0f, 0.0f, 1.0f);
		blackLabel.texture.blendSource = GL_ONE;
		blackLabel.texture.blendDestination = GL_ZERO;
		//myWindow3.
		add(blackLabel);
		
		testRect = new Rectangle();
		testRect.texture = g_rae.getTextureFromTheme("Rae.WindowHeader.Top");
		testRect.texture.blendSource = GL_ONE;
		testRect.texture.blendDestination = GL_ZERO;
		//myWindow3.
		add(testRect);
		
		testCircle = new Rectangle();
		testCircle.texture = g_rae.getTextureFromTheme("Rae.CircleButton");
		testCircle.texture.blendSource = GL_ONE;
		testCircle.texture.blendDestination = GL_ZERO;
		//myWindow3.
		add(testCircle);
		
		srcLabel = new Label("Src: GL_ONE");
		//myWindow3.
		add(srcLabel);
		
		dstLabel = new Label("Dst: GL_ZERO");
		//myWindow3.
		add(dstLabel);
		
		subWindow = new SubWindow("SubWindow",WindowHeaderType.SMALL, WindowHeaderType.SMALL, true);
		subWindow.defaultSize(0.5f, 0.4f);
		subWindow.side1.container.arrangeType = ArrangeType.FREE;
		
		windowInWindow = new SubWindow("windowInWindow",WindowHeaderType.SMALL, WindowHeaderType.SMALL, false);
		windowInWindow2 = new SubWindow("windowInWindow2",WindowHeaderType.SMALL, WindowHeaderType.SMALL, false);
		windowInWindow.defaultSize(0.4f, 0.2f);
		subWindow.add(windowInWindow);
		windowInWindow2.defaultSize(0.4f, 0.2f);
		windowInWindow2.move(0.2f, 0.0f);
		subWindow.add(windowInWindow2);
		
		addFloating(subWindow);
	}
	
	
	Rectangle testRect;
	Rectangle testCircle;
	Label testLabel;
	Label colourLabel;
	Label blackLabel;
	Label srcLabel;
	Label dstLabel;
	
	SubWindow subWindow;
	SubWindow windowInWindow;
	SubWindow windowInWindow2;
	
	uint srcFactorIndex = 0;
	uint[] srcFactor = [GL_ONE, GL_ZERO,
						GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR,
						GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,
						GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA,
						GL_SRC_ALPHA_SATURATE];
						
	uint dstFactorIndex = 0;
	uint[] dstFactor = [GL_ZERO, GL_ONE,
						GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR,
						GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,
						GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA];
	
	dchar[] factorToString(uint fact )
	{
		switch(fact)
		{
			case GL_ZERO:
				return "GL_ZERO"d;
			case GL_ONE:
				return "GL_ONE"d;
			case GL_DST_COLOR:
				return "GL_DST_COLOR"d;
			case GL_ONE_MINUS_DST_COLOR:
				return "GL_ONE_MINUS_DST_COLOR"d;
			case GL_SRC_ALPHA:
				return "GL_SRC_ALPHA"d;
			case GL_ONE_MINUS_SRC_ALPHA:
				return "GL_ONE_MINUS_SRC_ALPHA"d;
			case GL_DST_ALPHA:
				return "GL_DST_ALPHA"d;
			case GL_ONE_MINUS_DST_ALPHA:
				return "GL_ONE_MINUS_DST_ALPHA"d;
			case GL_SRC_ALPHA_SATURATE:
				return "GL_SRC_ALPHA_SATURATE"d;
			
			case GL_SRC_COLOR:
				return "GL_SRC_COLOR"d;
			case GL_ONE_MINUS_SRC_COLOR:
				return "GL_ONE_MINUS_SRC_COLOR"d;
			
		}
	}
	
	void changeSrc()
	{
		debug(ProjectWindow) Trace.formatln("Clicked me.");
		
		srcFactorIndex++;
		if( srcFactorIndex == srcFactor.length )
			srcFactorIndex = 0;
		testLabel.texture.blendSource = srcFactor[srcFactorIndex];
		colourLabel.texture.blendSource = srcFactor[srcFactorIndex];
		blackLabel.texture.blendSource = srcFactor[srcFactorIndex];
		testRect.texture.blendSource = srcFactor[srcFactorIndex];
		testCircle.texture.blendSource = srcFactor[srcFactorIndex];
		
		srcLabel.name( factorToString( srcFactor[srcFactorIndex] ) );
	}
	
	void changeDst()
	{
		debug(ProjectWindow) Trace.formatln("Clicked me.");
		
		dstFactorIndex++;
		if( dstFactorIndex == dstFactor.length )
			dstFactorIndex = 0;
		testLabel.texture.blendDestination = dstFactor[dstFactorIndex];
		colourLabel.texture.blendDestination = dstFactor[dstFactorIndex];
		blackLabel.texture.blendDestination = dstFactor[dstFactorIndex];
		testRect.texture.blendDestination = dstFactor[dstFactorIndex];
		testCircle.texture.blendDestination = dstFactor[dstFactorIndex];
		
		dstLabel.name( factorToString( dstFactor[dstFactorIndex] ) );
	}
	
	~this()
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.~this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.~this() END.");
	}
	
	void mouseHandler( InputState input, Rectangle wid )
	{
		input.isHandled = true;
	
		switch( input.eventType )
		{
			default:
			break;
			case SEventType.ENTER_NOTIFY:
				//wid.colour( 0.9f, 0.6f, 0.4f, 0.7f );
				wid.prelight();
				wid.sendToTop();
				/*if( wid.hasAnimators == false )
				{
					wid.addDefaultAnimator( DefaultAnimator.RAISE );
				}*/
			break;
			case SEventType.LEAVE_NOTIFY:
				wid.unprelight();
				//wid.colour( 0.8f, 0.3f, 0.2f, 1.0f );
				//if( wid.hasAnimators == false )
				//{
					//wid.addDefaultAnimator( DefaultAnimator.LOWER );
				//}
			break;
			case SEventType.MOUSE_BUTTON_PRESS:
				//Trace.formatln("press.");
				wid.grabInput();
				wid.sendToTop();
			break;
			case SEventType.MOUSE_BUTTON_RELEASE:
				//Trace.formatln("release.");
				wid.ungrabInput();
			break;
		}
	
		if( input.mouse.button[MouseButton.LEFT] == true )
		{
			//myWindow4.moveTo( input.mouse.x, input.mouse.y );
			wid.move( input.mouse.xRel, input.mouse.yRel );
			//Trace.formatln( "xrel: {} yrel: {}", input.mouse.xRel, input.mouse.yRel );
		}
	}
		
	void clickHandler3()// InputState input, Rectangle wid  )
	{
		debug(ProjectWindow) Trace.formatln("Clicked me.");
	
		/*if( myWindow3 !is null && myWindow3.hasAnimators == false )
		{
			myWindow3.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
		}
		*/
		
	}
	
	//SubWindow myWindow3;
	Button insideButton;
	Button insideButton4;
	

}


void main(char[][] args)
{
	Trace.formatln("Rae helloworld");
	
	if (args.length > 1)
	{
		//foreach(char[] ar; args)
		for( uint i = 0; i < args.length; i++ )
		{
			char[] ar = args[i];
			
			if( ar == "--help" )
			{
				Trace.formatln("Some help here. TODO.");
				//return;
			}
		}//endfor
	}//endif

	Rae rae = new Rae(args);
	ProjectWindow projectWindow = new ProjectWindow();
	projectWindow.defaultSize( 800, 400 );
	
	projectWindow.show();
	
	rae.run();
	
	delete projectWindow;
	delete rae;
}

