//This example is in the public domain.

//arrange tester

module main;

//import helpers.gdkkeysyms;

version (Tango)
{
	import tango.util.log.Trace;//Thread safe console output.
	
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
import rae.ui.ToggleButton;
import rae.ui.Label;
import rae.ui.Entry;
import rae.ui.ProgressBar;
import rae.ui.Widget;
import rae.ui.Box;
import rae.canvas.Draw;
import rae.canvas.Rectangle;
import rae.canvas.RoundedRectangle;
import rae.canvas.Image;
import rae.ui.Animator;

import rae.ui.FileChooser;

import rae.canvas.Bezier;

/*
import rae.av.globals;
import rae.av.VideoFileQT;
import rae.av.AudioFileQT;
import rae.av.IAudioReader;
import rae.av.IVideoReader;
import rae.av.IVideoWriter;

import rae.av.aspecthelper;
//import rae.av.enums;
import rae.av.VideoFormat;
import rae.av.IVideoFileWriter;
import rae.av.VideoWriterQT;
*/


double g_tempclip = 0.0f;
double g_tempclip2 = 0.0f;
/*
class RoundedRectangle : Rectangle
{
public:
	this(dchar[] set_label)
	{
		super();
		
		arrangeType = ArrangeType.HBOX;
		
		//isOutline = true;
		
		isClipping = false;
		renderMethod = RenderMethod.BYPASS;
		
		//xPackOptions = PackOptions.EXPAND;
		xPackOptions = PackOptions.SHRINK;
		yPackOptions = PackOptions.SHRINK;
		
		defaultHeight = g_rae.getValueFromTheme("Rae.Button.defaultHeight");
		minHeight = g_rae.getValueFromTheme("Rae.Button.defaultHeight");
		
		leftRect = new Rectangle();
		leftRect.name = "left"d;
		leftRect.arrangeType = ArrangeType.LAYER;
		leftRect.xPackOptions = PackOptions.SHRINK;
		leftRect.yPackOptions = PackOptions.EXPAND;
		//leftRect.defaultWidth = 0.5f * g_rae.getValueFromTheme("Rae.Button.defaultHeight");
		
		//hardcoded pixel sizes.
		leftRect.defaultWidth = 1.0f * (0.25*64.0f*g_rae.pixel);
		leftRect.minWidth = 1.0f * (0.25*64.0f*g_rae.pixel);
		
		//leftRect.colour(0.7f, 0.7f, 0.7f, 0.3f);
		//////leftRect.isOutline = true;
		leftRect.renderMethod = RenderMethod.PIXELS;
		leftRect.shape.themeTexture = "Rae.Button";
		leftRect.shape.texCoordOneRight = 0.25f;//0.3125f;
		add(leftRect);
		
		centerRect = new Rectangle();
		centerRect.name = "center"d;
		centerRect.arrangeType = ArrangeType.LAYER;
		centerRect.xPackOptions = PackOptions.SHRINK;
		//centerRect.xPackOptions = PackOptions.EXPAND;
		centerRect.yPackOptions = PackOptions.EXPAND;
		//centerRect.colour(0.7f, 0.7f, 0.7f, 0.3f);
		//centerRect.isOutline = true;
		centerRect.renderMethod = RenderMethod.PIXELS_VERTICAL;
		centerRect.shape.themeTexture = "Rae.Button";
		centerRect.shape.texCoordOneLeft = 0.25f;
		centerRect.shape.texCoordOneRight = 0.75f;
		add(centerRect);
		
		rightRect = new Rectangle();
		rightRect.name = "right"d;
		rightRect.arrangeType = ArrangeType.LAYER;
		rightRect.xPackOptions = PackOptions.SHRINK;
		rightRect.yPackOptions = PackOptions.EXPAND;
		//rightRect.colour(0.7f, 0.7f, 0.7f, 0.3f);
		//rightRect.defaultWidth = 0.5f * g_rae.getValueFromTheme("Rae.Button.defaultHeight");
		
		//hardcoded pixel sizes.
		rightRect.defaultWidth = 1.0f * (0.25*64.0f*g_rae.pixel);
		rightRect.minWidth = 1.0f * (0.25*64.0f*g_rae.pixel);
		
		//////rightRect.isOutline = true;
		rightRect.renderMethod = RenderMethod.PIXELS;
		rightRect.shape.themeTexture = "Rae.Button";
		rightRect.shape.texCoordOneLeft = 0.75f;//0.6875f;
		add(rightRect);
		
		label = new Label(set_label);
		label.textColour = g_rae.getColourFromTheme("Rae.Button.text");
		label.outPaddingX = 0.0f;
		label.outPaddingY = 0.0f;
		centerRect.add( label );
		
	}
	
// 	bool onMouseButtonPress( InputState input )
// 	{
// 		Trace.formatln("leftRect.w: {} in pix: {}", cast(double) leftRect.w, leftRect.w/g_rae.pixel);
// 		Trace.formatln("centerRect.w: {} in pix: {}", cast(double) centerRect.w, centerRect.w/g_rae.pixel);
// 		Trace.formatln("rightRect.w: {} in pix: {}", cast(double) rightRect.w, rightRect.w/g_rae.pixel);
// 		
// 		return super.onMouseButtonPress(input);
// 	}
	
protected:

	Rectangle leftRect;
	Rectangle centerRect;
	Rectangle rightRect;

	Label label;

}
*/


class ProjectWindow : Window
{
	this()
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.this() END.");
		
		super("Arrange tester");
		
		bool is_free = false;
		
		if( is_free == true )
		{
			container.arrangeType = ArrangeType.FREE;
			
			Button arrangeButton = new Button("Arrange all");
			arrangeButton.signalActivate.attach(&arrange);
			arrangeButton.moveTo( -0.4f, -0.4f );
			//DAS////////add( arrangeButton );
		}
		else
		{	
		
			//Menu stuff:
			
			Menu amenu = new Menu();
			//amenu.defaultSize( 0.3f, 0.4f );
			//amenu.xPos( -0.2 );
			//amenu.yPos( 0.1 );
			MenuItem amenuitem1 = new MenuItem("<b>Arrange tester</b>");
			amenu.addMenuItem( amenuitem1 );
				MenuItem amenuitem1_2 = new MenuItem("Quit", &g_rae.quit);
				amenuitem1.addMenuItem( amenuitem1_2 );
			MenuItem amenuitem2 = new MenuItem("Arrange");
			amenu.addMenuItem( amenuitem2 );
				MenuItem amenuitem2_1 = new MenuItem("Arrange all", &arrange);
				amenuitem2.addMenuItem( amenuitem2_1 );
			add(amenu);
		}
		
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
		
		
		/*
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
		
		
		
		
		
		
		
		
		
		
/*	
	
	//The arrange tester stuff:
	
	
	
		Rectangle rect1 = new Rectangle();
		rect1.name = "HBox";
		rect1.arrangeType = ArrangeType.HBOX;
		//rect1.defaultSize( 0.5f, 0.7f );
		rect1.moveTo( -0.2f, 0.1f );
		rect1.colour(0.7f, 0.0f, 0.0f, 0.7f);
		//rect1.zoom = 2.0f;
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
		
		for( uint i = 0; i < 8; i++ )
		{
			Rectangle rect2 = new Rectangle();
			rect2.name = "VBOX" ~ Integer.toString32(i);
			rect2.arrangeType = ArrangeType.VBOX;
			//rect2.defaultSize( 0.05f, 0.05f );
			//rect2.moveTo( -0.025f, -0.025f );
			rect2.colour(0.0f, (i/8.0f), 0.0f, 0.7f);
			//rect2.zoom = 0.5f;
			rect2.isOutline = true;
			rect2.signalMouseButtonPress.attach(&mouseHandler);
			rect2.signalMouseButtonRelease.attach(&mouseHandler);
			rect2.signalMouseMotion.attach(&mouseHandler);
			rect2.signalEnterNotify.attach(&mouseHandler);
			rect2.signalLeaveNotify.attach(&mouseHandler);
			rect2.signalScrollUp.attach(&mouseHandler);
			rect2.signalScrollDown.attach(&mouseHandler);
			rect1.add(rect2);
		
			for( uint j = 0; j < 4; j++ )
			{
				Rectangle rect4 = new Rectangle();
				rect4.name = "Blue" ~ Integer.toString32(j);
				rect4.arrangeType = ArrangeType.HBOX;
				//rect4.defaultSize( 0.05f, 0.05f );
				//rect4.moveTo( -0.025f, -0.025f );
				rect4.colour( (i/8.0f), 0.0f, (j/4.0f), 0.8f);
				rect4.isOutline = true;
				rect4.signalMouseButtonPress.attach(&mouseHandler);
				rect4.signalMouseButtonRelease.attach(&mouseHandler);
				rect4.signalMouseMotion.attach(&mouseHandler);
				rect4.signalEnterNotify.attach(&mouseHandler);
				rect4.signalLeaveNotify.attach(&mouseHandler);
				rect4.signalScrollUp.attach(&mouseHandler);
				rect4.signalScrollDown.attach(&mouseHandler);
				rect2.add(rect4);
				
				for( uint k = 0; k < 10; k++ )
				{
					Rectangle rect5 = new Rectangle();
					rect5.name = "Argh" ~ Integer.toString32(k);
					rect5.arrangeType = ArrangeType.FREE;
					//rect5.defaultSize( 0.05f, 0.05f );
					//rect5.moveTo( -0.025f, -0.025f );
					rect5.colour( (j/4.0f), (k/10.0f), (i/8.0f), 0.8f);
					rect5.isOutline = true;
					rect5.signalMouseButtonPress.attach(&mouseHandler);
					rect5.signalMouseButtonRelease.attach(&mouseHandler);
					rect5.signalMouseMotion.attach(&mouseHandler);
					rect5.signalEnterNotify.attach(&mouseHandler);
					rect5.signalLeaveNotify.attach(&mouseHandler);
					rect5.signalScrollUp.attach(&mouseHandler);
					rect5.signalScrollDown.attach(&mouseHandler);
					rect4.add(rect5);
				}
			}
		}
	*/		
			
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
		
		/*
		testEntry1 = new Entry("Too much stuff in one entry.");
		testEntry1.move( -0.2f, -0.05f );
		add(testEntry1);
		*/
		
		
		//EXPAND etc.
		VBox vbox1 = new VBox();
		if( is_free )
		{
			vbox1.defaultSize( 0.6f, 0.5f );
			vbox1.move(0.4f, 0.0f);
		}
		add(vbox1);
			HBox hbox1 = new HBox();
			vbox1.add(hbox1);
				Button but1 = new Button("One");
				hbox1.add(but1);
				Button but2 = new Button("Two");
				hbox1.add(but2);
				Button roundARect = new Button("Three");
				hbox1.add(roundARect);
				Button but3 = new Button("Three");
				hbox1.add(but3);
				ProgressBar prog1 = new ProgressBar("Progress");
				hbox1.add(prog1);
				Button but4 = new Button("Three4");
				ToggleButton togb1 = new ToggleButton("Toggle1");
				hbox1.add(togb1);
				hbox1.add(but4);
				Button but5 = new Button("Three5");
				hbox1.add(but5);
				Button but6 = new Button("Three6");
				hbox1.add(but6);
				Button but7 = new Button("Three7");
				hbox1.add(but7);
				Button but8 = new Button("Three8");
				hbox1.add(but8);
				Button but9 = new Button("Three9");
				hbox1.add(but9);
				Button but10 = new Button("Three10");
				hbox1.add(but10);
				
		HBox horibox1 = new HBox();
		if( is_free )
		{
			horibox1.defaultSize( 0.6f, 0.2f );
			horibox1.move(-0.4f, 0.0f);
		}
		add(horibox1);
			VBox vertibox1 = new VBox();
			horibox1.add(vertibox1);
				Button buta1 = new Button("One");
				vertibox1.add(buta1);
				Button buta2 = new Button("Two");
				vertibox1.add(buta2);
				Button roundBRect = new Button("Three");
				vertibox1.add(roundBRect);
				Button buta3 = new Button("Three");
				vertibox1.add(buta3);
				ProgressBar prog2 = new ProgressBar("Progress");
				vertibox1.add(prog2);
				Button buta4= new Button("Three4");
				vertibox1.add(buta4);
				Button buta5 = new Button("Three5");
				vertibox1.add(buta5);
				ToggleButton togb2 = new ToggleButton("Toggle2");
				vertibox1.add(togb2);
				Button buta6 = new Button("Three6");
				vertibox1.add(buta6);
				Button buta7 = new Button("Three7");
				vertibox1.add(buta7);
				Button buta8 = new Button("Three8");
				vertibox1.add(buta8);
				Button buta9 = new Button("Three9 is a very long entry");
				vertibox1.add(buta9);
				Button buta10 = new Button("Three10");
				vertibox1.add(buta10);
		
		
		
		
		
		/*
		FileChooser fileChooser = new FileChooser();
		fileChooser.defaultSize( 0.6f, 0.5f );
		//fileChooser.moveTo( 0.0f, 0.0f );
		add(fileChooser);
		fileChooser.sendToTop();
		*/
		
		
		
		
		Rectangle infoLabelBox = new Rectangle();
		infoLabelBox.name = "infoLabelBox";
		infoLabelBox.arrangeType = ArrangeType.FREE;////HBOX;
		if( is_free )
		{
			infoLabelBox.defaultSize( 0.4f, 0.15f );
			//infoLabelBox.moveTo( -0.5f, 0.3f );
		}
		infoLabelBox.colour(0.5f, 0.2f, 0.1f, 0.5f);
		//infoLabelBox.zoom = 2.0f;
		//infoLabelBox.moveScreen( 0.05f, 0.05f );
		
		infoLabelBox.isOutline = true;
		infoLabelBox.signalMouseButtonPress.attach(&mouseHandler);
		infoLabelBox.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabelBox.signalMouseMotion.attach(&mouseHandler);
		infoLabelBox.signalEnterNotify.attach(&mouseHandler);
		infoLabelBox.signalLeaveNotify.attach(&mouseHandler);
		infoLabelBox.signalScrollUp.attach(&mouseHandler);
		infoLabelBox.signalScrollDown.attach(&mouseHandler);
		add(infoLabelBox);
		
		Image checkerTexture = new Image( Image.CHECKERBOARD );
		
		//Rectangle 
		Rectangle checkerRect = new Rectangle();
		checkerRect.name = "checkerRect";
		checkerRect.arrangeType = ArrangeType.FREE;
		checkerRect.wh( 64.0f * g_rae.pixel, 64.0f * g_rae.pixel );
		//checkerRect.moveTo( 0.1234523f, 0.13450583452f );
		//checkerRect.colour(0.7f, 0.0f, 0.0f, 1.0f);
		//checkerRect.zoom = 1.0f;
		//checkerRect.shape.themeTexture = "Rae.Button";
		checkerRect.texture = checkerTexture;
		checkerRect.renderMethod = RenderMethod.PIXELS;
		checkerRect.shape.texCoordOneLeft = 0.25f;
		checkerRect.shape.texCoordOneRight = 0.75f;
		//checkerRect.moveScreen( 0.05f, 0.05f );
		checkerRect.isOutline = true;
		checkerRect.signalMouseButtonPress.attach(&mouseHandler);
		checkerRect.signalMouseButtonRelease.attach(&mouseHandler);
		checkerRect.signalMouseMotion.attach(&mouseHandler);
		checkerRect.signalEnterNotify.attach(&mouseHandler);
		checkerRect.signalLeaveNotify.attach(&mouseHandler);
		checkerRect.signalScrollUp.attach(&mouseHandler);
		checkerRect.signalScrollDown.attach(&mouseHandler);
		infoLabelBox.add(checkerRect);
		
		Button roundCRect = new Button("Rounded");
		roundCRect.wh( 128.0f * g_rae.pixel, 25.0f * g_rae.pixel );
		roundCRect.signalMouseButtonPress.attach(&mouseHandler);
		roundCRect.signalMouseButtonRelease.attach(&mouseHandler);
		roundCRect.signalMouseMotion.attach(&mouseHandler);
		roundCRect.signalEnterNotify.attach(&mouseHandler);
		roundCRect.signalLeaveNotify.attach(&mouseHandler);
		infoLabelBox.add(roundCRect);
		
		Button roundDRect = new Button("R");
		roundDRect.wh( 64.0f * g_rae.pixel, 25.0f * g_rae.pixel );
		roundDRect.signalMouseButtonPress.attach(&mouseHandler);
		roundDRect.signalMouseButtonRelease.attach(&mouseHandler);
		roundDRect.signalMouseMotion.attach(&mouseHandler);
		roundDRect.signalEnterNotify.attach(&mouseHandler);
		roundDRect.signalLeaveNotify.attach(&mouseHandler);
		infoLabelBox.add(roundDRect);
		
		RoundedRectangle roundRectE = new RoundedRectangle("Rae.Button", OrientationType.VERTICAL);
		roundRectE.wh( 25.0f * g_rae.pixel, 64.0f * g_rae.pixel );
		roundRectE.signalMouseButtonPress.attach(&mouseHandler);
		roundRectE.signalMouseButtonRelease.attach(&mouseHandler);
		roundRectE.signalMouseMotion.attach(&mouseHandler);
		roundRectE.signalEnterNotify.attach(&mouseHandler);
		roundRectE.signalLeaveNotify.attach(&mouseHandler);
		infoLabelBox.add(roundRectE);
		
		infoLabel1 = new Label("info");
		infoLabel1.move( -0.2f, 0.0f );
		infoLabel1.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel1.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel1.signalMouseMotion.attach(&mouseHandler);
		infoLabel1.signalEnterNotify.attach(&mouseHandler);
		infoLabel1.signalLeaveNotify.attach(&mouseHandler);
		//DAS////////infoLabelBox.add(infoLabel1);
		
		infoLabel2 = new Label("info");
		infoLabel2.move( -0.2f, 0.05f );
		infoLabel2.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel2.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel2.signalMouseMotion.attach(&mouseHandler);
		infoLabel2.signalEnterNotify.attach(&mouseHandler);
		infoLabel2.signalLeaveNotify.attach(&mouseHandler);
		//DAS////////infoLabelBox.add(infoLabel2);
		
		infoLabel3 = new Label("info");
		infoLabel3.move( -0.2f, 0.1f );
		infoLabel3.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel3.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel3.signalMouseMotion.attach(&mouseHandler);
		infoLabel3.signalEnterNotify.attach(&mouseHandler);
		infoLabel3.signalLeaveNotify.attach(&mouseHandler);
		//DAS////////infoLabelBox.add(infoLabel3);
		
		infoLabel4 = new Label("info");
		infoLabel4.move( -0.2f, 0.15f );
		infoLabel4.signalMouseButtonPress.attach(&mouseHandler);
		infoLabel4.signalMouseButtonRelease.attach(&mouseHandler);
		infoLabel4.signalMouseMotion.attach(&mouseHandler);
		infoLabel4.signalEnterNotify.attach(&mouseHandler);
		infoLabel4.signalLeaveNotify.attach(&mouseHandler);
		//DAS////////infoLabelBox.add(infoLabel4);
		
	}
	
	Entry testEntry1;
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
				wid.sendToTop();
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
	
	bool keyEvent( InputState input )
	{
		if( input.eventType != SEventType.KEY_PRESS )
			return false;
	
		switch( input.key.value )
		{
			default:
			break;
			case KeySym.Escape:
				g_rae.quit();
			break;
			case KeySym._1:
				if( currentWidget !is null )
					currentWidget.zoomAnim = currentWidget.zoomX - currentWidget.zoomAdder;
			break;
			case KeySym._2:
				if( currentWidget !is null )
					currentWidget.zoomAnim = currentWidget.zoomX + currentWidget.zoomAdder;
			break;
			case KeySym.Up:
				plainWindow.container.zoomIn();
				Trace.formatln("Zoom in. x:{} y:{}", plainWindow.container.zoomX, plainWindow.container.zoomY);
			break;
			case KeySym.Down:
				plainWindow.container.zoomOut();
				Trace.formatln("Zoom out. x:{} y:{}", plainWindow.container.zoomX, plainWindow.container.zoomY);
			break;
			case KeySym.f:
				toggleFullscreen();
			break;
		}
		return true;
	}
	
	Rectangle currentWidget;
	SubWindow myWindow3;
	Button insideButton;
	Button insideButton4;
	

}


void main(char[][] args)
{
	//Trace.formatln("Rae helloworld");
	
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
	//projectWindow.defaultSize( 800, 400 );
	
	projectWindow.show();
	
	rae.run();
	
	delete projectWindow;
	delete rae;
}

