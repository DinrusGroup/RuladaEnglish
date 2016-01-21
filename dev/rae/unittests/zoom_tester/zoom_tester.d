module zoom_tester;

//import helpers.gdkkeysyms;

version (Tango)
{
	debug(logging) import tango.util.log.Trace;//Thread safe console output.
	
	import tango.math.Math;
	//import tango.stdc.math;//std.math;
	//import tango.stdc.stdio;//std.stdio;
	import tango.stdc.string;
	import stringz = tango.stdc.stringz;
	import tango.core.Thread;
	
	import Float = tango.text.convert.Float;
	
	//version(nogc)
	//{
		import tango.core.Memory;
	//}
}
else
{
	import std.c.stdio;
	import std.math;
}

//import lqt.lqt;
//import lqt.colormodels;

//import rae.av.IPlaybackCore;
//import rae.av.PortAudioPlaybackCore;


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
		
		super("HelloWorld");
		
		container.arrangeType = ArrangeType.FREE;
		
		//threadGroup = new ThreadGroup();
		
		//Menu stuff:
		/*
		Menu amenu = new Menu();
		//amenu.defaultSize( 0.3f, 0.4f );
		//amenu.xPos( -0.2 );
		//amenu.yPos( 0.1 );
		MenuItem amenuitem1 = new MenuItem("HelloWorld");
		amenu.add( amenuitem1 );
		MenuItem amenuitem2 = new MenuItem("Project");
		amenu.add( amenuitem2 );
		MenuItem amenuitem3 = new MenuItem("Edit");
		amenu.add( amenuitem3 );
		MenuItem amenuitem4 = new MenuItem("Help");
		amenu.add( amenuitem4 );
		*/
		//
		/*
		myWindow3 = new SubWindow("HelloWorld");
		//videoViewerWindow.isRotate = true;
		//myWindow3.moveTo( -0.3f, -0.3f );
		myWindow3.defaultSize( 0.4f, 0.2f );
		add(myWindow3);*/
		
		//myWindow3.add( amenu );
		//add( amenu );
		
		//myWindow3.isClipping = true;
		
		/*auto emptyButton1 = new Button("Empty Button");
		emptyButton1.signalActivate.attach(&clickHandler3);
		//myWindow3.
		add( emptyButton1 );		
		auto emptyButton2 = new Button("Empty Button");
		emptyButton2.signalActivate.attach(&clickHandler3);
		//myWindow3.
		add( emptyButton2 );
		
		insideButton4 = new Button("شیراز");
		insideButton4.signalActivate.attach(&clickHandler3);
		*/
		
		/*
		insideButton4.signalMouseButtonPress.attach(&clickHandler3);
		insideButton4.signalMouseButtonRelease.attach(&clickHandler3);
		insideButton4.signalMouseMotion.attach(&clickHandler3);
		insideButton4.signalEnterNotify.attach(&clickHandler3);
		insideButton4.signalLeaveNotify.attach(&clickHandler3);
		*/
		//myWindow3.
		//add(insideButton4);
		
		Rectangle rect1 = new Rectangle();
		rect1.name = "Red";
		rect1.arrangeType = ArrangeType.FREE;
		rect1.defaultSize( 0.2f, 0.2f );
		rect1.moveTo( 0.1f, 0.1f );
		rect1.colour(0.7f, 0.0f, 0.0f, 1.0f);
		///////////rect1.zoom = 2.0f;
		//rect1.moveScreen( 0.05f, 0.05f );
		rect1.isOutline = true;
		rect1.signalMouseButtonPress.attach(&mouseHandler);
		rect1.signalMouseButtonRelease.attach(&mouseHandler);
		rect1.signalMouseMotion.attach(&mouseHandler);
		rect1.signalEnterNotify.attach(&mouseHandler);
		rect1.signalLeaveNotify.attach(&mouseHandler);
		rect1.signalScrollUp.attach(&mouseHandler);
		rect1.signalScrollDown.attach(&mouseHandler);
		add(rect1);
		
			Rectangle rect2 = new Rectangle();
			rect2.name = "Green";
			rect2.arrangeType = ArrangeType.FREE;
			rect2.defaultSize( 0.05f, 0.05f );
			rect2.moveTo( -0.025f, -0.025f );
			rect2.colour(0.0f, 0.7f, 0.2f, 1.0f);
			////////////rect2.zoom = 0.5f;
			rect2.isOutline = true;
			rect2.signalMouseButtonPress.attach(&mouseHandler);
			rect2.signalMouseButtonRelease.attach(&mouseHandler);
			rect2.signalMouseMotion.attach(&mouseHandler);
			rect2.signalEnterNotify.attach(&mouseHandler);
			rect2.signalLeaveNotify.attach(&mouseHandler);
			rect2.signalScrollUp.attach(&mouseHandler);
			rect2.signalScrollDown.attach(&mouseHandler);
			rect1.add(rect2);
			
				Rectangle rect4 = new Rectangle();
				rect4.name = "Blue";
				rect4.arrangeType = ArrangeType.FREE;
				rect4.defaultSize( 0.05f, 0.05f );
				rect4.moveTo( -0.025f, -0.025f );
				rect4.colour(0.0f, 0.2f, 0.7f, 1.0f);
				rect4.isOutline = true;
				rect4.signalMouseButtonPress.attach(&mouseHandler);
				rect4.signalMouseButtonRelease.attach(&mouseHandler);
				rect4.signalMouseMotion.attach(&mouseHandler);
				rect4.signalEnterNotify.attach(&mouseHandler);
				rect4.signalLeaveNotify.attach(&mouseHandler);
				rect4.signalScrollUp.attach(&mouseHandler);
				rect4.signalScrollDown.attach(&mouseHandler);
				rect2.add(rect4);
			/*
			Rectangle rect3 = new Rectangle();
			rect3.name = "Yellow";
			rect3.texture = null;
			rect3.arrangeType = ArrangeType.FREE;
			rect3.defaultSize( 0.05f, 0.05f );
			rect3.moveTo( -0.05f, -0.05f );
			rect3.colour(0.7f, 0.7f, 0.2f, 1.0f);
			rect3.isOutline = true;
			rect3.signalMouseButtonPress.attach(&mouseHandler);
			rect3.signalMouseButtonRelease.attach(&mouseHandler);
			rect3.signalMouseMotion.attach(&mouseHandler);
			rect3.signalEnterNotify.attach(&mouseHandler);
			rect3.signalLeaveNotify.attach(&mouseHandler);
			rect1.add(rect3);*/
		
		infoLabel1 = new Label("info");
		infoLabel1.move( -0.2f, 0.0f );
		infoLabel1.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel1.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel1.signalMouseMotion.attach(&mouseHandler);
		infoLabel1.signalEnterNotify.attach(&mouseHandler);
		infoLabel1.signalLeaveNotify.attach(&mouseHandler);
		add(infoLabel1);
		
		infoLabel2 = new Label("info");
		infoLabel2.move( -0.2f, 0.05f );
		infoLabel2.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel2.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel2.signalMouseMotion.attach(&mouseHandler);
		infoLabel2.signalEnterNotify.attach(&mouseHandler);
		infoLabel2.signalLeaveNotify.attach(&mouseHandler);
		add(infoLabel2);
		
		infoLabel3 = new Label("info");
		infoLabel3.move( -0.2f, 0.1f );
		infoLabel3.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel3.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel3.signalMouseMotion.attach(&mouseHandler);
		infoLabel3.signalEnterNotify.attach(&mouseHandler);
		infoLabel3.signalLeaveNotify.attach(&mouseHandler);
		add(infoLabel3);
		
		infoLabel4 = new Label("info");
		infoLabel4.move( -0.2f, 0.15f );
		infoLabel4.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel4.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel4.signalMouseMotion.attach(&mouseHandler);
		infoLabel4.signalEnterNotify.attach(&mouseHandler);
		infoLabel4.signalLeaveNotify.attach(&mouseHandler);
		add(infoLabel4);
		
	}
	
	Label infoLabel1;
	Label infoLabel2;
	Label infoLabel3;
	Label infoLabel4;
	
	~this()
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.~this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.~this() END.");
	}
	
	void mouseHandler( InputState input, Rectangle wid )
	{
		input.isHandled = true;
		
		currentWidget = wid;
		
		switch( input.eventType )
		{
			default:
			break;
			case SEventType.ENTER_NOTIFY:
				//wid.colour( 0.9f, 0.6f, 0.4f, 0.7f );
				wid.prelight();
				//wid.sendToTop();
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
				//wid.sendToTop();
			break;
			case SEventType.MOUSE_BUTTON_RELEASE:
				//Trace.formatln("release.");
				wid.ungrabInput();
			break;
			case SEventType.SCROLL_UP:
				wid.zoomAnim = wid.zoomX + wid.zoomAdder;
			break;
			case SEventType.SCROLL_DOWN:
				wid.zoomAnim = wid.zoomX - wid.zoomAdder;
			break;
		}
	
		if( input.mouse.button[MouseButton.LEFT] == true )
		{
			//myWindow4.moveTo( input.mouse.x, input.mouse.y );
			//wid.move( input.mouse.xRelLocal, input.mouse.yRelLocal );
			
			if( wid.parent !is null )
				wid.move( wid.parent.tr_wc2i( input.mouse.xRel ), wid.parent.tr_hc2i( input.mouse.yRel ) );
			//Trace.formatln( "xrel: {} yrel: {}", input.mouse.xRel, input.mouse.yRel );
		}
		
		if( input.mouse.button[MouseButton.MIDDLE] == true )
		{
			//myWindow4.moveTo( input.mouse.x, input.mouse.y );
				wid.moveScreen( input.mouse.xRelLocal, input.mouse.yRelLocal );
			//Trace.formatln( "xrel: {} yrel: {}", input.mouse.xRel, input.mouse.yRel );
		}
		
		if( currentWidget !is null )
		{
			infoLabel1.name = currentWidget.name;
			infoLabel2.name = "zoom:"d ~ Float.toString32( currentWidget.zoom );
			infoLabel3.name = "xPos:"d ~ Float.toString32( currentWidget.xPos );
			infoLabel4.name = "yPos:"d ~ Float.toString32( currentWidget.yPos );
		}
	}
		
	void clickHandler3()// InputState input, Rectangle wid  )
	{
		debug(ProjectWindow) Trace.formatln("Clicked me.");
	
		if( myWindow3 !is null && myWindow3.hasAnimators == false )
		{
			myWindow3.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
		}
		
		
		
	}
	
	/*
	void onKeyPress(int keyjuu)
	{
		switch( keyjuu )
		{
			default:
			break;
			case GDK_Escape:
				g_rae.quit();
			break;
			case GDK_1:
				if( currentWidget !is null )
					currentWidget.zoomAnim = currentWidget.zoomX - currentWidget.zoomAdder;
			break;
			case GDK_2:
				if( currentWidget !is null )
					currentWidget.zoomAnim = currentWidget.zoomX + currentWidget.zoomAdder;
			break;
		}
		return true;
	}
	*/
	
	Rectangle currentWidget;
	SubWindow myWindow3;
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

