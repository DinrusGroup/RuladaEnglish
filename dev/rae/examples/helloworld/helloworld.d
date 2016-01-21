//This example is in the public domain
//

module helloworld;

import tango.util.log.Trace;//Thread safe console output.
	
import tango.math.Math;
import tango.stdc.string;
import stringz = tango.stdc.stringz;
//import tango.core.Thread;

import rae.Rae;
import rae.core.Timeout;
import rae.ui.Window;
import rae.ui.SubWindow;
import rae.ui.Menu;
import rae.ui.Button;
//import rae.ui.Widget;
//import rae.ui.Box;
//import rae.canvas.Draw;
//import rae.canvas.Rectangle;
//import rae.canvas.Image;
//import rae.ui.Animator;

class ProjectWindow : Window
{
	this()
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.this() END.");
		
		super("HelloWorld");
		
		//Menu stuff:
		
		Menu amenu = new Menu();
		//amenu.defaultSize( 0.3f, 0.4f );
		//amenu.xPos( -0.2 );
		//amenu.yPos( 0.1 );
		Trace.formatln("menu created.");
		MenuItem amenuitem1 = new MenuItem("<b>HelloWorld</b>");
		amenu.addMenuItem( amenuitem1 );
		Trace.formatln("added to menu creating sub.");
				MenuItem amenuitem1_1 = new MenuItem("Preferences...", &tempMenuHandler);
				amenuitem1.addMenuItem( amenuitem1_1 );
				Trace.formatln("added 1 sub.");
				MenuItem amenuitem1_2 = new MenuItem("Quit", &g_rae.quit);
				amenuitem1.addMenuItem( amenuitem1_2 );
				Trace.formatln("added 2 sub.");
		MenuItem amenuitem2 = new MenuItem("Project");
		amenu.addMenuItem( amenuitem2 );
			version(gtk)
			{
				MenuItem amenuitem2_0 = new MenuItem("Fullscreen", &toggleFullscreen);
				amenuitem2.addMenuItem( amenuitem2_0 );
			}
				MenuItem amenuitem2_1 = new MenuItem("Menuitem 2.1", &tempMenuHandler);
				amenuitem2.addMenuItem( amenuitem2_1 );
				MenuItem amenuitem2_2 = new MenuItem("Menuitem 2.2", &tempMenuHandler);
				amenuitem2.addMenuItem( amenuitem2_2 );
				MenuItem amenuitem2_3 = new MenuItem("Menuitem 2.3", &tempMenuHandler);
				amenuitem2.addMenuItem( amenuitem2_3 );
				MenuItem amenuitem2_4 = new MenuItem("Menuitem 2.4", &tempMenuHandler);
				amenuitem2.addMenuItem( amenuitem2_4 );
		MenuItem amenuitem3 = new MenuItem("Empty");
		amenu.addMenuItem( amenuitem3 );
		MenuItem amenuitem4 = new MenuItem("Help");
		amenu.addMenuItem( amenuitem4 );
				MenuItem amenuitem4_1 = new MenuItem("This project needs your help!", &tempMenuHandler);
				amenuitem4.addMenuItem( amenuitem4_1 );
				MenuItem amenuitem4_2 = new MenuItem("So go to", &tempMenuHandler);
				amenuitem4.addMenuItem( amenuitem4_2 );
				MenuItem amenuitem4_3 = new MenuItem("www.dsource.org/projects/rae", &createMyWindow);
				amenuitem4.addMenuItem( amenuitem4_3 );
				MenuItem amenuitem4_4 = new MenuItem("and try to figure out", &tempMenuHandler);
				amenuitem4.addMenuItem( amenuitem4_4 );
				MenuItem amenuitem4_5 = new MenuItem("your way of helping", &tempMenuHandler);
				amenuitem4.addMenuItem( amenuitem4_5 );
				MenuItem amenuitem4_6 = new MenuItem("a quite ambitious GUI library.", &clickHandlerWorld);
				amenuitem4.addMenuItem( amenuitem4_6 );
		
		
		//
		
		//myWindow3 = new SubWindow("HelloWorld");
		//videoViewerWindow.isRotate = true;
		//myWindow3.moveTo( -0.3f, -0.3f );
		//myWindow3.defaultSize( 0.4f, 0.2f );
		//add(myWindow3);
		Trace.formatln("add menu.");
		//myWindow3.add( amenu );
		menu(amenu);
		
		//myWindow3.isClipping = true;
		
		Trace.formatln("add buttons.");
		
		auto emptyButton1 = new Button("Hello");
		emptyButton1.signalActivate.attach(&clickHandlerHello);
		add( emptyButton1 );
		auto emptyButton2 = new Button("World");
		emptyButton2.signalActivate.attach(&clickHandlerWorld);
		add( emptyButton2 );
	}
	
	void tempMenuHandler()
	{
		Trace.formatln("Clicked menuitem.");
	}
	
	void createMyWindow()
	{
		if( myWindow is null )
		{
			myWindow = new SubWindow("HelloWorld", WindowButtonType.DEFAULTS2, WindowHeaderType.SMALL, WindowHeaderType.SMALL, false);
			myWindow.defaultSize( 0.4f, 0.2f );
			
			auto emptyButton1 = new Button("Hello");	
			emptyButton1.signalActivate.attach(&clickHandlerHello);
			myWindow.add( emptyButton1 );
			auto emptyButton2 = new Button("World");
			emptyButton2.signalActivate.attach(&clickHandlerHello);
			myWindow.add2( emptyButton2 );
			
			addFloating(myWindow);
		}
		else myWindow.present();
	}
		
	void clickHandlerHello()
	{
		Trace.formatln("Hello.");
		createMyWindow();
	}
	
	void clickHandlerWorld()
	{
		Trace.formatln("World.");
	
		if( myWindow !is null && myWindow.hasAnimators == false )
		{
			myWindow.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
		}
	}
	
	bool keyEvent( InputState input )
	{
		if( input.eventType != SEventType.KEY_PRESS )
			return false;
	
		//TODO make keyfocus!
		switch(input.key.value)
		{
			default:
			break;
			case KeySym.Escape:
				g_rae.quit();
			break;
		}
		return true;
	}
	
	
	SubWindow myWindow;
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
	rae.applicationName = "HelloWorld";
	ProjectWindow projectWindow = new ProjectWindow();
	projectWindow.defaultSize( 800, 400 );
	
	projectWindow.show();
	
	rae.run();
	
	delete projectWindow;
	delete rae;
}

