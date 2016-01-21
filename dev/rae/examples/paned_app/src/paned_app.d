//This example is in the public domain.

module paned_app;

version (Tango)
{
	import tango.util.log.Trace;//Thread safe console output.

	import tango.math.Math;
	//import tango.stdc.math;//std.math;
	//import tango.stdc.stdio;//std.stdio;
	import tango.stdc.string;
	import stringz = tango.stdc.stringz;
	import tango.core.Thread;

	//import Float = tango.text.convert.Float;
	import Integer = tango.text.convert.Integer;
	import Utf = tango.text.convert.Utf;


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

import rae.Rae;
import rae.core.Timeout;
import rae.ui.Window;
import rae.ui.SubWindow;
import rae.ui.Menu;
import rae.ui.ComboBox;
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
import rae.canvas.Image;
import rae.ui.Animator;

import rae.ui.FileChooser;

import rae.canvas.Bezier;


class ProjectWindow : Window
{

	void tempMenuHandler()
	{
		Trace.formatln("Clicked menuitem.");
	}

	this()
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.this() END.");

		super("Application");

		debug(ProjectWindow) Trace.formatln("ProjectWindow.this() After super().");


		//RELATIVE
		bezier = new BezierG1();
		bezier.addPoint( 0.0f, 0.0f );//p
		bezier.addPoint( 0.1f, 0.1f );
		bezier.addPoint( 0.2f, 0.0f );
		bezier.addPoint( 0.2f, -0.1f );//p
		bezier.addPoint( 0.0f, -0.2f );
		bezier.addPoint( -0.1f, -0.2f );
		bezier.addPoint( -0.2f, 0.0f );//p
		bezier.addPoint( -0.3f, 0.2f );
		bezier.addPoint( -0.2f, 0.2f );
		bezier.addPoint( 0.0f, 0.1f );//p
		bezier.addPoint( 0.1f, 0.1f );
		bezier.addPoint( 0.2f, -0.3f );
		bezier.addPoint( 0.1f, -0.1f );//Close the path...

		/*//ABSOLUTE
		bezier = new BezierG1();
		bezier.addPoint( 0.0f, 0.0f );//p
		bezier.addPoint( 0.1f, 0.1f );
		bezier.addPoint( 0.3f, 0.1f );
		bezier.addPoint( 0.4f, 0.0f );//p
		bezier.addPoint( 0.4f, -0.2f );
		bezier.addPoint( 0.3f, -0.4f );
		bezier.addPoint( 0.1f, -0.4f );//p
		bezier.addPoint( -0.2f, -0.2f );
		bezier.addPoint( -0.4f, 0.0f );
		bezier.addPoint( -0.4f, 0.3f );//p
		bezier.addPoint( -0.3f, 0.4f );
		bezier.addPoint( -0.1f, 0.1f );
		bezier.addPoint( 0.0f, 0.0f );//Close the path...
		*/

		videoViewerWindow = new SubWindow("Viewer", WindowButtonType.NONE, WindowHeaderType.NONE, WindowHeaderType.NONE, false );//use_fbo_clipping=false
		videoViewerWindow.shadowType = ShadowType.NONE;
		//videoViewerWindow.isClipByParent = false;

		videoViewerWindow.side1.container.signalMouseButtonPress.attach(&videoViewerWindow.side1.container.defaultMouseHandler);
		videoViewerWindow.side1.container.signalMouseButtonRelease.attach(&videoViewerWindow.side1.container.defaultMouseHandler);
		videoViewerWindow.side1.container.signalMouseMotion.attach(&videoViewerWindow.side1.container.defaultMouseHandler);
		videoViewerWindow.side1.container.signalScrollUp.attach(&videoViewerWindow.side1.container.defaultMouseHandler);
		videoViewerWindow.side1.container.signalScrollDown.attach(&videoViewerWindow.side1.container.defaultMouseHandler);

		videoViewerWindow.side1.container.verticalScrollbarSetting = ScrollbarSetting.NEVER;
		videoViewerWindow.side1.container.horizontalScrollbarSetting = ScrollbarSetting.NEVER;

		//videoViewerWindow.side1.container.isDoubleSided = true;//BUG WEIRD. Why do I have to do this too?
		videoViewerWindow.side1.isDoubleSided = true;

		//videoViewerWindow.isRotate = true;
		debug(ProjectWindow) Trace.formatln("{}", videoViewerWindow );
		//videoViewerWindow.defaultSize( 0.8, 0.4 );
		//videoViewerWindow.moveTo( 0.3f, -0.2f );
		debug(ProjectWindow) Trace.formatln("{}", videoViewerWindow );
		//videoViewerWindow.colour( 0.2, 0.5, 0.3, 0.5 );
		videoViewerWindow.signalMouseButtonPress.attach(&clickHandler);

		videoViewerWindow.side2.ba = 0.5f;//TEMP hack. Side2 container background alpha to 0.5.

		//interlace button
		auto isInterlacedButton = new Button("Interlaced");
		//isInterlacedButton.a = 0.8f;
		/////////isInterlacedButton.signalActivate.attach(&videoViewer.dummyToggleIsDeinterlace);
		videoViewerWindow.add2(isInterlacedButton);

		//aspect button
		auto sixteenByNineButton = new Button("16:9 aspectratio");
		//sixteenByNineButton.a = 0.8f;
		//////////sixteenByNineButton.signalActivate.attach(&videoViewer.dummyToggle16by9);
		videoViewerWindow.add2(sixteenByNineButton);

		Image playerImage = new Image(Image.NOISE_3);
		Rectangle playerRect = new Rectangle();//It sucks that we need this. We should make a class
		//called Image to be infact ImageRectangle, and a ImageBuffer to be what Image is now.
		playerRect.colour(1.0f, 1.0f, 1.0f, 1.0f);
		playerRect.texture = playerImage;
		videoViewerWindow.add( playerRect );

		//

		FileChooserDialog fileChooserDialog = new FileChooserDialog;
		addFloating( fileChooserDialog );
		fileChooserDialog.hide();

		AboutDialog aboutDialog = new AboutDialog("About Rae GUI Library"d, "Rae\nis a general purpose OpenGL GUI library.\n©Jonas Kivi 2003-2009\nX11/MIT licence"d );
		addFloating( aboutDialog );
		aboutDialog.hide();

		auto aboutSettingsButton = new Button("Settings button 1");
		aboutDialog.add2(aboutSettingsButton);

		auto aboutSettingsButton2 = new Button("Settings button 2");
		aboutDialog.add2(aboutSettingsButton2);

		auto aboutLabel2 = new Label("You really can have\nwidgets in the backside.");
		aboutLabel2.alignType = AlignType.CENTER;
		aboutDialog.add2(aboutLabel2);
		
		auto comboTest = new ComboBox();
		comboTest.addOption("ComboBox"d);
		comboTest.addOption("Option 1"d);
		comboTest.addOption("A serious option"d);
		comboTest.addOption("How does it feel"d);
		comboTest.addOption("To be run over by"d);
		comboTest.addOption("Pure moments"d);
		aboutDialog.add2(comboTest);
		
		HBox aspectControlsHBox = new HBox();
		aboutDialog.add2(aspectControlsHBox);
		
		auto isLoopButton = new ToggleButton("Toggle button" );
			//isLoopButton.signalActivate.attach(&player.toggleIsLoop);
			aspectControlsHBox.add(isLoopButton);
			
			auto asp1Button = new Button("Square\nButton", ButtonType.SQUARE );
			//asp1Button.signalActivate.attach(&player.setAspectSquarePixels);
			aspectControlsHBox.add(asp1Button);
			
			auto asp2Button = new Button("Thumb", ButtonType.SQUARE );
			//asp2Button.signalActivate.attach(&player.setAspect133);
			aspectControlsHBox.add(asp2Button);

		//Menu stuff:

		Menu amenu = new Menu();
			//amenu.defaultSize( 0.3f, 0.4f );
			//amenu.xPos( -0.2 );
			//amenu.yPos( 0.1 );

	/*
			MenuItem amenuitem0 = new MenuItem("");
			CircleButton pihcirc = new CircleButton("●");
			amenuitem0.add(pihcirc);
			amenu.addMenuItem( amenuitem0 );
*/
			/*	MenuItem amenuitem0_1 = new MenuItem("Temppi 1", &tempMenuHandler);
				amenuitem0.addMenuItem( amenuitem0_1 );
				MenuItem amenuitem0_2 = new MenuItem("Temppi 2", &tempMenuHandler);
				amenuitem0.addMenuItem( amenuitem0_2 );
			*/

			MenuItem amenuitem1 = new MenuItem("<b>Application</b>");
			amenu.addMenuItem( amenuitem1 );
				MenuItem amenuitem1_1 = new MenuItem("Preferences...", &tempMenuHandler, "⌘P");
				amenuitem1.addMenuItem( amenuitem1_1 );
				MenuItem amenuitem1_2 = new MenuItem("Quit", &g_rae.quit, "⌘Q");
				amenuitem1.addMenuItem( amenuitem1_2 );
			MenuItem amenuitem2 = new MenuItem("Project");
			amenu.addMenuItem( amenuitem2 );
				MenuItem amenuitem2_1B = new MenuItem("Open...", &fileChooserDialog.present, "⌘O" );
				amenuitem2.addMenuItem( amenuitem2_1B );
				MenuItem amenuitem2_1 = new MenuItem("Save Version", &tempMenuHandler, "⌘S");
				amenuitem2.addMenuItem( amenuitem2_1 );
				MenuItem amenuitem2_2 = new MenuItem("New Movie", &tempMenuHandler, "⌘N");
				amenuitem2.addMenuItem( amenuitem2_2 );
			MenuItem amenuitem3 = new MenuItem("Edit");
			amenu.addMenuItem( amenuitem3 );
				MenuItem amenuitem3_1 = new MenuItem("Menuitem 1", &tempMenuHandler, "ctrl A");
				amenuitem3.addMenuItem( amenuitem3_1 );
				MenuItem amenuitem3_2 = new MenuItem("Menuitem 2", &tempMenuHandler, "alt P");
				amenuitem3.addMenuItem( amenuitem3_2 );
				MenuItem amenuitem3_3 = new MenuItem("Menuitem 3", &tempMenuHandler, "shift P");
				amenuitem3.addMenuItem( amenuitem3_3 );
				MenuItem amenuitem3_4 = new MenuItem("Menuitem 4", &tempMenuHandler, "⌘P");
				amenuitem3.addMenuItem( amenuitem3_4 );
				MenuItem amenuitem3_5 = new MenuItem("Menuitem 5", &tempMenuHandler, "ctrl P");
				amenuitem3.addMenuItem( amenuitem3_5 );
				MenuItem amenuitem3_6 = new MenuItem("Menuitem 6", &tempMenuHandler, "ctrl P");
				amenuitem3.addMenuItem( amenuitem3_6 );
				MenuItem amenuitem3_7 = new MenuItem("Menuitem 7", &tempMenuHandler, "ctrl P");
				amenuitem3.addMenuItem( amenuitem3_7 );
				MenuItem amenuitem3_8 = new MenuItem("Menuitem 8", &tempMenuHandler, "ctrl P");
				amenuitem3.addMenuItem( amenuitem3_8 );
				MenuItem amenuitem3_9 = new MenuItem("Menuitem 9", &tempMenuHandler, "ctrl P");
				amenuitem3.addMenuItem( amenuitem3_9 );
			MenuItem amenuitem4 = new MenuItem("View");
			amenu.addMenuItem( amenuitem4 );
				MenuItem amenuitem4_1 = new MenuItem("Fullscreen", &toggleFullscreen, "⌘F");
				amenuitem4.addMenuItem( amenuitem4_1 );
			MenuItem amenuitem5 = new MenuItem("Help");
			amenu.addMenuItem( amenuitem5 );
				MenuItem amenuitem5_1 = new MenuItem("About Rae...", &aboutDialog.present );
				amenuitem5.addMenuItem( amenuitem5_1 );
				MenuItem amenuitem5_2 = new MenuItem("Create a Window", &createWindow);
				amenuitem5.addMenuItem( amenuitem5_2 );
				MenuItem amenuitem5_3 = new MenuItem("Menuitem 3", &tempMenuHandler);
				amenuitem5.addMenuItem( amenuitem5_3 );

		//add(amenu);
		menu(amenu);

		//

		//ProgressBar testProgressBar = new ProgressBar("Testing...");
		//testProgressBar.fraction = 0.7f;

		/*auto emptyButton41 = new Button("Paned Button");
		auto emptyButton42 = new Button("Paned Button");
		auto emptyButton43 = new Button("Paned Button");
		auto emptyButton44 = new Button("Paned Button");*/

		//

		materialsWindow = new SubWindow("Materials", WindowButtonType.NONE, WindowHeaderType.NONE, WindowHeaderType.NONE);
		materialsWindow.shadowType = ShadowType.NONE;
		//materialsWindow.isClipByParent = false;
		materialsWindow.moveTo( -0.3f, 0.4f );
		materialsWindow.defaultSize( 0.2f, 0.4f );
		//materialsWindow.colour( 0.8f, 0.3f, 0.2f, 1.0f );
		/*
		materialsWindow.signalMouseButtonPress.attach(&mouseHandler);
		materialsWindow.signalMouseButtonRelease.attach(&mouseHandler);
		materialsWindow.signalMouseMotion.attach(&mouseHandler);
		materialsWindow.signalEnterNotify.attach(&mouseHandler);
		materialsWindow.signalLeaveNotify.attach(&mouseHandler);
		*/
		//add(materialsWindow);

		Entry entryTest1 = new Entry("Entry");//Utf.toString32("Entry") );
		entryTest1.signalTextChanged.attach(&entryTextChangedHandler);;
		materialsWindow.add(entryTest1);

		Entry entryTest2 = new Entry("Rae");
		materialsWindow.add(entryTest2);

		exportButton = new Button("Button");
		exportButton.alignType = AlignType.BEGIN;
		exportButton.moveTo(-0.7f, 0.0f );
		//exportButton.defaultSize( 0.1f, 0.05f );
		//exportButton.colour( 0.5f, 0.3f, 0.3f, 0.7f );
		//exportButton.colour( 0.3f, 0.04f, 0.04f, 1.0f );
		exportButton.signalActivate.attach(&exportButtonHandler);
		materialsWindow.add(exportButton);

		insideButton4 = new Button("Export");
		insideButton4.signalActivate.attach(&funnyProgressLoopHandler);
		insideButton4.alignType = AlignType.BEGIN;
		//insideButton4.signalActivate.attach(&clickHandler3);
		/*
		insideButton4.signalMouseButtonPress.attach(&clickHandler3);
		insideButton4.signalMouseButtonRelease.attach(&clickHandler3);
		insideButton4.signalMouseMotion.attach(&clickHandler3);
		insideButton4.signalEnterNotify.attach(&clickHandler3);
		insideButton4.signalLeaveNotify.attach(&clickHandler3);
		*/
		materialsWindow.add(insideButton4);


		exportProgressBar = new ProgressBar("Exporting...");
		materialsWindow.add(exportProgressBar);
		//exportProgressBar.fraction = 0.7f;

		playButton = new Button("Play");
		playButton.alignType = AlignType.END;

		//Quick hack:
		//playButton.texture = new Image(Image.GRADIENT_3);
		//playButton.colour(0.9f, 0.9f, 0.9f, 1.0f);

		//


		//playButton.moveTo(-0.5f, 0.0f );
		playButton.defaultSize( 0.1f, 0.05f );
		//playButton.colour( 0.3f, 0.3f, 0.3f, 0.7f );
		//playButton.signalActivate.attach(&player.playPause);
		//playButton.signalMouseButtonPress.attach(&playHandler);
		materialsWindow.add(playButton);

		seekToStartButton = new Button("To Start");
		seekToStartButton.alignType = AlignType.END;
		///////seekToStartButton.signalActivate.attach(&videoViewer.seekToStart);
		//seekToStartButton.signalActivate.attach(&player.seekToStart);
		materialsWindow.add(seekToStartButton);

		seekToEndButton = new Button("To End");
		seekToEndButton.alignType = AlignType.BEGIN;
		///////seekToEndButton.signalActivate.attach(&videoViewer.seekToEnd);
		materialsWindow.add(seekToEndButton);

		seekFrameBackwardButton = new Button("-Frame");
		seekFrameBackwardButton.alignType = AlignType.BEGIN;
		///////seekFrameBackwardButton.signalActivate.attach(&videoViewer.seekFrameBackward);
		materialsWindow.add(seekFrameBackwardButton);

		seekFrameForwardButton = new Button("+Frame");
		seekFrameForwardButton.alignType = AlignType.BEGIN;
		///////seekFrameForwardButton.signalActivate.attach(&videoViewer.seekFrameForward);
		materialsWindow.add(seekFrameForwardButton);

		//



		VPaned vpaned = new VPaned();
		vpaned.add(materialsWindow);
		vpaned.add(videoViewerWindow);

		HPaned hpaned = new HPaned();

		add( hpaned );

		hpaned.add( vpaned );
		//vpaned.add(testProgressBar);
		//vpaned.add(videoViewer);
		//vpaned.add(emptyButton41);
		//vpaned.add(emptyButton42);
		//vpaned.add(emptyButton43);
		//vpaned.add(emptyButton44);

		//

		timelineWindow = new SubWindow("Timeline", WindowButtonType.NONE, WindowHeaderType.NONE, WindowHeaderType.NONE);
		timelineWindow.shadowType = ShadowType.NONE;
		//timelineWindow.isClipByParent = false;
		//timelineWindow.defaultSize( 0.4f, 0.4f );
		timelineWindow.side1.container.arrangeType = ArrangeType.FREE;
		timelineWindow.side1.container.verticalScrollbarSetting = ScrollbarSetting.ALWAYS;
		timelineWindow.side1.container.horizontalScrollbarSetting = ScrollbarSetting.ALWAYS;
		timelineWindow.side1.container.colour = g_rae.getColourArrayFromTheme("Rae.Canvas.background");
		timelineWindow.side1.isDoubleSided = true;
		timelineWindow.side2.ba = 0.5f;
		//timelineWindow.add(checkerBoard2);

		timelineWindow.side1.container.signalMouseButtonPress.attach(&timelineWindow.side1.container.defaultMouseHandler);
		timelineWindow.side1.container.signalMouseButtonRelease.attach(&timelineWindow.side1.container.defaultMouseHandler);
		timelineWindow.side1.container.signalMouseMotion.attach(&timelineWindow.side1.container.defaultMouseHandler);
		timelineWindow.side1.container.signalScrollUp.attach(&timelineWindow.side1.container.defaultMouseHandler);
		timelineWindow.side1.container.signalScrollDown.attach(&timelineWindow.side1.container.defaultMouseHandler);

		timelineWindow.side1.container.horizontalScrollbar.attach( &timelineWindow.side1.container.zoom, &timelineWindow.side1.container.zoomAnim, 0.1f, 1.0f );
		//timelineWindow.side1.container.horizontalScrollbar.attach( &timelineWindow.side1.container.moveScreenX, &timelineWindow.side1.container.moveScreenXAnim, -1.0f, 1.0f );
		//timelineWindow.side1.container.verticalScrollbar.attach( &timelineWindow.side1.container.moveScreenY, &timelineWindow.side1.container.moveScreenYAnim, -1.0f, 1.0f );

		//

		//

		auto timelineButtonBox = new HBox();
		timelineButtonBox.name = "timelineButtonBox";
		//timelineButtonBox.arrangeType = ArrangeType.HBOX;
		//timelineButtonBox.xPackOptions = PackOptions.EXPAND;
		//timelineButtonBox.yPackOptions = PackOptions.SHRINK;
		//timelineButtonBox.padding = 0.0f;

		auto playButton2 = new Button("Play");
		//playButton2.signalActivate.attach(&player.playPause);
		timelineButtonBox.add(playButton2);

		/*auto playButton3 = new Button("Stop");
		playButton3.signalActivate.attach(&player.playPause);
		timelineButtonBox.add(playButton3);*/

		auto playButton4 = new Button("Rew");
		//playButton4.signalActivate.attach(&player.seekToStart);
		timelineButtonBox.add(playButton4);

		auto playButton5 = new Button("Ffw");
		//playButton5.signalActivate.attach(&playHandler);
		timelineButtonBox.add(playButton5);

		auto playButton6 = new Button("M");
		//playButton6.signalActivate.attach(&playHandler);
		timelineButtonBox.add(playButton6);

		VBox timelineVBox = new VBox();

		///////videoViewerWindow.add(videoViewer);
		timelineVBox.add(timelineButtonBox);
		timelineVBox.add(timelineWindow);
		//videoViewerWindow.add(playButton2);

		hpaned.add( timelineVBox );

		//

		//Window in window test
		/*
		//The FBO window:

			SubWindow winwin2 = new SubWindow("Window in Window", WindowHeaderType.SMALL, WindowHeaderType.SMALL);
			//winwin2.shadowType = ShadowType.NONE;//Because shadow drawing while zooming is broken.
			winwin2.defaultSize( 0.4f, 0.2f );
			winwin2.move(0.15, 0.25f );

			auto emptyButton128 = new Button("Crazy Button 1");
			emptyButton128.signalActivate.attach(&clickHandler3);
			winwin2.add( emptyButton128 );
			auto emptyButton228 = new Button("Crazy Button 2");
			emptyButton228.signalActivate.attach(&clickHandler3);
			winwin2.add( emptyButton228 );

			timelineWindow.add( winwin2 );
		*/
		//

		//Window in window test

		float varimove = -2.5f * 0.4f;

		for( uint i = 0; i < 50; i++ )
		{
			//SubWindow winwin3 = new SubWindow("Scene " ~ Integer.toString32(i), WindowHeaderType.SMALL, WindowHeaderType.SMALL, false );

			/*SubWindow winwin3 = new SubWindow("Scene " ~ Integer.toString32(i), WindowHeaderType.NONE, WindowHeaderType.NONE, false );
			winwin3.shadowType = ShadowType.NONE;//Because shadow drawing while zooming is broken.
			winwin3.defaultSize( 0.4f, 0.2f );
			winwin3.move(varimove, 0.0f );//((i/50.0f)-0.5f)*0.2f);
			*/
			varimove += 0.4f;

			/*
			auto emptyButton129 = new Button("Crazy Button 1");
			emptyButton129.signalActivate.attach(&clickHandler3);
			winwin3.add( emptyButton129 );
			auto emptyButton229 = new Button("Crazy Button 2");
			emptyButton229.signalActivate.attach(&clickHandler3);
			winwin3.add( emptyButton229 );
			*/

			auto edit1 = new Rectangle();
			edit1.setXYWH( 0.0, 0.0, 0.4, varimove*0.3f );
			edit1.isOutline = true;
			edit1.colour(0.8f, 0.8f, 0.8f, 1.0f);
			edit1.move(varimove, 0.0f );
			edit1.signalMouseButtonPress.attach(&mouseHandler);
			edit1.signalMouseButtonRelease.attach(&mouseHandler);
			edit1.signalMouseMotion.attach(&mouseHandler);
			edit1.signalEnterNotify.attach(&mouseHandler);
			edit1.signalLeaveNotify.attach(&mouseHandler);
			timelineWindow.add( edit1 );

			auto edit2 = new Rectangle();
			edit2.setXYWH( 0.0, 0.0, edit1.w, varimove*0.3f );
			edit2.isOutline = true;
			edit2.colour(0.8f, 0.8f, 0.8f, 1.0f);
			edit2.move(varimove, edit1.h );
			edit2.signalMouseButtonPress.attach(&mouseHandler);
			edit2.signalMouseButtonRelease.attach(&mouseHandler);
			edit2.signalMouseMotion.attach(&mouseHandler);
			edit2.signalEnterNotify.attach(&mouseHandler);
			edit2.signalLeaveNotify.attach(&mouseHandler);
			timelineWindow.add( edit2 );

			auto edit3 = new Rectangle();
			edit3.setXYWH( 0.0, 0.0, edit1.w, varimove*0.3f );
			edit3.isOutline = true;
			edit3.colour(0.4f, 0.4f, 0.4f, 1.0f);
			edit3.move(varimove, edit1.h * 2.0f );
			edit3.signalMouseButtonPress.attach(&mouseHandler);
			edit3.signalMouseButtonRelease.attach(&mouseHandler);
			edit3.signalMouseMotion.attach(&mouseHandler);
			edit3.signalEnterNotify.attach(&mouseHandler);
			edit3.signalLeaveNotify.attach(&mouseHandler);
			timelineWindow.add( edit3 );

			auto edit4 = new Rectangle();
			edit4.setXYWH( 0.0, 0.0, edit1.w, varimove*0.3f );
			edit4.isOutline = true;
			edit4.colour(0.4f, 0.4f, 0.4f, 1.0f);
			edit4.move(varimove, edit1.h * 3.0f );
			edit4.signalMouseButtonPress.attach(&mouseHandler);
			edit4.signalMouseButtonRelease.attach(&mouseHandler);
			edit4.signalMouseMotion.attach(&mouseHandler);
			edit4.signalEnterNotify.attach(&mouseHandler);
			edit4.signalLeaveNotify.attach(&mouseHandler);
			timelineWindow.add( edit4 );


			//timelineWindow.add( winwin3 );
		}

		//Trace.formatln("before crazytest.");
		//assert(0);

		/*void crazyTest()
		{
			SubWindow awin = new SubWindow("Crazy");
			awin.defaultSize( 0.4f, 0.2f );

			auto emptyButton1 = new Button("Crazy Button 1");
			emptyButton1.signalActivate.attach(&clickHandler4);
			awin.add( emptyButton1 );
			auto emptyButton2 = new Button("Crazy Button 2");
			emptyButton2.signalActivate.attach(&clickHandler3);
			awin.add( emptyButton2 );
			auto emptyButton3 = new Button("Crazy Button 3");
			emptyButton3.signalActivate.attach(&clickHandler4);
			awin.add( emptyButton3 );
			auto emptyButton4 = new Button("Crazy Button 4");
			emptyButton4.signalActivate.attach(&clickHandler3);
			awin.add( emptyButton4 );

			add(awin);
		}*/

		//Currently fullscreen FBO's are used for windows,
		//so the GPU can't handle more than about 15 windows
		//on a i945GM. Better GPU's will propably handle more,
		//but the solution would be to either resize the FBO's
		//on demand, or limit the amount of windows that can
		//be on the screen at the same time. Possibly both.

		/*
		for(uint i = 0; i < 10; i++)
		{
			crazyTest();
		}
		*/
	/*
		Widget checkerBoard = new Widget();
		checkerBoard.defaultSize( g_rae.pixel * 64, g_rae.pixel * 64 );
		checkerBoard.texture = new Image(Image.CHECKERBOARD);
		//checkerBoard.texture = new Image(Image.ROUND_SALMIAC);
		//checkerBoard.texture = new Image(Image.NOISE_GLASS);
		add(checkerBoard);

		checkerBoard.signalMouseButtonPress.attach(&mouseHandler);
		checkerBoard.signalMouseButtonRelease.attach(&mouseHandler);
		checkerBoard.signalMouseMotion.attach(&mouseHandler);
		checkerBoard.signalEnterNotify.attach(&mouseHandler);
		checkerBoard.signalLeaveNotify.attach(&mouseHandler);

		Widget checkerBoard2 = new Widget();
		checkerBoard2.defaultSize( g_rae.pixel * 64, g_rae.pixel * 64 );
		checkerBoard2.texture = new Image(Image.CHECKERBOARD);
		//add(checkerBoard2);

		checkerBoard2.signalMouseButtonPress.attach(&mouseHandler);
		checkerBoard2.signalMouseButtonRelease.attach(&mouseHandler);
		checkerBoard2.signalMouseMotion.attach(&mouseHandler);
		checkerBoard2.signalEnterNotify.attach(&mouseHandler);
		checkerBoard2.signalLeaveNotify.attach(&mouseHandler);

		//PlainWindow awin2 = new PlainWindow("Aaaaarrrggh!");
		SubWindow awin2 = new SubWindow("Aaaaarrrggh!");
		awin2.defaultSize( 0.4f, 0.4f );
		awin2.side1.container.arrangeType = ArrangeType.FREE;
		awin2.side1.container.verticalScrollbarSetting = ScrollbarSetting.ALWAYS;
		awin2.side1.container.horizontalScrollbarSetting = ScrollbarSetting.ALWAYS;
		awin2.side1.isDoubleSided = true;
		awin2.side2.ba = 0.5f;
		awin2.add(checkerBoard2);

		//Window in window test
			SubWindow winwin = new SubWindow("Window in Window");
			winwin.defaultSize( 0.4f, 0.2f );

			auto emptyButton12 = new Button("Crazy Button 1");
			emptyButton12.signalActivate.attach(&clickHandler3);
			winwin.add( emptyButton12 );
			auto emptyButton22 = new Button("Crazy Button 2");
			emptyButton22.signalActivate.attach(&clickHandler3);
			winwin.add( emptyButton22 );

			awin2.add( winwin );
		//



		add(awin2);



		Widget circ = new Widget();
		circ.defaultSize( g_rae.pixel * 64, g_rae.pixel * 64 );
		circ.texture = g_rae.getTextureFromTheme("Rae.CircleButton");
		add(circ);

		circ.signalMouseButtonPress.attach(&mouseHandler);
		circ.signalMouseButtonRelease.attach(&mouseHandler);
		circ.signalMouseMotion.attach(&mouseHandler);
		circ.signalEnterNotify.attach(&mouseHandler);
		circ.signalLeaveNotify.attach(&mouseHandler);



		myWindow3 = new SubWindow("Some buttons");
		//videoViewerWindow.isRotate = true;
		debug(ProjectWindow) Trace.formatln("{}", myWindow3 );
		debug(ProjectWindow) Trace.formatln("cx: {}", cast(double)myWindow3.cx);
		debug(ProjectWindow) Trace.formatln("cy: {}", cast(double)myWindow3.cy);
		myWindow3.moveTo( -0.3f, -0.3f );
		debug(ProjectWindow) Trace.formatln("{}", myWindow3);
		debug(ProjectWindow) Trace.formatln("cx: {}", cast(double)myWindow3.cx);
		debug(ProjectWindow) Trace.formatln("cy: {}", cast(double)myWindow3.cy);

		myWindow3.defaultSize( 0.4f, 0.2f );
		debug(ProjectWindow) Trace.formatln("{}", myWindow3);
		debug(ProjectWindow) Trace.formatln("cx: {}", cast(double)myWindow3.cx);
		debug(ProjectWindow) Trace.formatln("cy: {}", cast(double)myWindow3.cy);
		//myWindow3.colour( 0.1f, 0.6f, 0.1f, 1.0f );
		//myWindow3.colour( 0.2, 0.2, 0.2, 0.5 );

		add(myWindow3);

		//myWindow3.isClipping = true;

		auto emptyButton1 = new Button("Empty Button");
		emptyButton1.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton1 );
		auto emptyButton2 = new Button("Empty Button");
		emptyButton2.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton2 );
		auto emptyButton3 = new Button("Empty Button");
		emptyButton3.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton3 );
		auto emptyButton4 = new Button("Empty Button");
		emptyButton4.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton4 );
		auto emptyButton5 = new Button("Empty Button");
		emptyButton5.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton5 );
		auto emptyButton6 = new Button("Empty Button");
		emptyButton6.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton6 );
		auto emptyButton7 = new Button("Empty Button");
		emptyButton7.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton7 );
		auto emptyButton8 = new Button("Empty Button");
		emptyButton8.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton8 );
		auto emptyButton9 = new Button("Empty Button");
		emptyButton9.signalActivate.attach(&clickHandler3);
		myWindow3.add( emptyButton9 );

		*/

		/*
		myWindow3.yRot(45.0f);
		myWindow3.zRot(45.0f);
		myWindow3.xRot(45.0f);
		*/




	}

	~this()
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.~this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.~this() END.");

		//delete videoViewer;
		//delete videoViewerWindow;
	}

	void createWindow()
	{
		static uint numof = 0;
		numof++;
		auto a_window = new SubWindow("Window " ~ Integer.toString32(numof));
		a_window.w(0.6f);
		a_window.h(0.3f);
		addFloating( a_window );

		auto aboutSettingsButton = new Button("Settings button 1");
		a_window.add2(aboutSettingsButton);

		auto aboutSettingsButton2 = new Button("Settings button 2");
		a_window.add2(aboutSettingsButton2);

		auto aboutLabel1 = new Label("Another window.");
		aboutLabel1.alignType = AlignType.CENTER;
		a_window.add(aboutLabel1);

		auto aboutLabel2 = new Label("You really can have\nwidgets in the backside.");
		aboutLabel2.alignType = AlignType.CENTER;
		a_window.add2(aboutLabel2);
	}

	void entryTextChangedHandler( dchar[] set_text )
	{
		Trace.formatln("The text changed to: {}", set_text );
		//imageSequenceString = Utf.toString(set_text);
		//immaterial = new ImageMaterial( Utf.toString(set_text) );
		//player.material = immaterial;
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
		}

		if( input.mouse.button[MouseButton.LEFT] == true )
		{
			//myWindow4.moveTo( input.mouse.x, input.mouse.y );
			//wid.move( input.mouse.xRelLocal, input.mouse.yRelLocal );
			
			if( wid.parent !is null )
				wid.move( wid.parent.tr_wc2i( input.mouse.xRel ), wid.parent.tr_hc2i( input.mouse.yRel ) );
			//Trace.formatln( "xrel: {} yrel: {}", input.mouse.xRel, input.mouse.yRel );
		}

		/*if( input.mouse.button[MouseButton.LEFT] == true )
		{
			//materialsWindow.moveTo( input.mouse.x, input.mouse.y );
			wid.move( input.mouse.xRel, input.mouse.yRel );
			//Trace.formatln( "xrel: {} yrel: {}", input.mouse.xRel, input.mouse.yRel );
		}*/
	}


	void rotateAnimatorHandler( InputState input, Rectangle wid )
	{
		//Trace.formatln("mouseHandler.");

		if( input.mouse.button[MouseButton.LEFT] == true )
		{
			//Trace.formatln("Mouse click.");

			wid.moveTo( input.mouse.x, input.mouse.y );

			//Trace.formatln( "myWindow3: {}", myWindow3 );

			//Trace.formatln( "insideButton: {}", insideButton );

			if( wid.hasAnimators == false )
			{
				wid.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
			}
		}
	}

	void funnyProgressLoopHandler()
	{
		if( exportProgressBar.fraction < 1.0f )
			exportProgressBar.fractionAnim(1.0f, &funnyProgressLoopHandler);
		else exportProgressBar.fractionAnim(0.0f, &funnyProgressLoopHandler);
	}

	void clickHandler3()// InputState input, Rectangle wid  )
	{
		debug(ProjectWindow) Trace.formatln("Clicked me.");

		if( materialsWindow !is null && materialsWindow.hasAnimators == false )
		{
			materialsWindow.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
		}

		if( myWindow3 !is null && myWindow3.hasAnimators == false )
		{
			myWindow3.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
		}

		/*if( videoViewerWindow !is null && videoViewerWindow.hasAnimators == false )
		{
			videoViewerWindow.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
		}*/

		//input.isHandled = true;

		/*

		switch( input.eventType )
		{
			default:
			break;
			case SEventType.ENTER_NOTIFY:
				wid.colour(0.9f, 0.9f, 0.9f, 0.7f);
			break;
			case SEventType.LEAVE_NOTIFY:
				wid.colour(0.7f, 0.7f, 0.7f, 1.0f);
			break;
			case SEventType.MOUSE_BUTTON_PRESS:
				//Trace.formatln("You pressed me {}.", wid.name);
				wid.grabInput();
				//wid.sendToTop();
			break;
			case SEventType.MOUSE_BUTTON_RELEASE:
				//Trace.formatln("You released me {}.", wid.name);
				wid.ungrabInput();
				if( wid.parent !is null && wid.parent.hasAnimators == false )
				{
					wid.parent.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
				}
			break;
		}

		if( input.mouse.button[MouseButton.LEFT] == true )
		{
			//wid.move( input.mouse.xRel, input.mouse.yRel );
		}

		*/

	}

	void clickHandler4()// InputState input, Rectangle wid  )
	{
		debug(ProjectWindow) Trace.formatln("Clicked me.");

		if( playButton !is null )
			playButton.removeFromParent();
	}

	void exportButtonHandler()// InputState input, Rectangle wid )
	{
		Trace.formatln("You clicked the exportButton.");


	}

	void doExport()
	{

	}

	void playHandler()// InputState input, Rectangle wid )
	{
	}

	void clickHandler( InputState input, Rectangle wid )
	{
		Trace.formatln("VideoViewer.clickHandler()");
	}


	BezierG1 bezier;

	Button exportButton;
	ProgressBar exportProgressBar;

	Button playButton;
	Button seekToStartButton;
	Button seekToEndButton;
	Button seekFrameForwardButton;
	Button seekFrameBackwardButton;
	SubWindow myWindow3;
	SubWindow materialsWindow;
	Button insideButton;
	Button insideButton4;
	SubWindow videoViewerWindow;
	SubWindow timelineWindow;
	Rectangle timelineWindowContainer;

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
			case KeySym.space:
				Trace.formatln("space.");
			break;
			case KeySym.d:
				break;
				case KeySym.f:
					//SHIFT+F:toggleFullscreen();
					if( isFullscreenItem() )
					{
						hideFullscreenItem();
						//reset zoom and moveScreenX.
						videoViewerWindow.side1.container.zoom( 1.0f );
						videoViewerWindow.side1.container.moveScreenX( 0.0f );
						videoViewerWindow.side1.container.moveScreenY( 0.0f );
						videoViewerWindow.side1.container.colourAnim(0.18f, 0.18f, 0.18f, 1.0f);
					}
					//else showFullscreenItem(player);
					else if(videoViewerWindow !is null)
					{
						showFullscreenItem(videoViewerWindow.side1.container);
						//reset zoom and moveScreenX.
						videoViewerWindow.side1.container.zoom( 1.0f );
						videoViewerWindow.side1.container.moveScreenX( 0.0f );
						videoViewerWindow.side1.container.moveScreenY( 0.0f );
						videoViewerWindow.side1.container.colourAnim(0.0f, 0.0f, 0.0f, 1.0f);
					}
				break;
				case KeySym._1:

				break;
				case KeySym._2:

				break;
				case KeySym._3:

				break;
				case KeySym._4:

				break;
				case KeySym._6:
					if( timelineWindow !is null )
					{
						//TEMP
						timelineWindowContainer = timelineWindow.side1.container;
						//timelineWindowContainer.zoomAnim = timelineWindowContainer.zoomX - timelineWindowContainer.zoomAdder;
						timelineWindowContainer.zoom = timelineWindowContainer.zoomX - timelineWindowContainer.zoomAdder;
					}
				break;
				case KeySym._7:
					if( timelineWindow !is null )
					{
						//TEMP
						timelineWindowContainer = timelineWindow.side1.container;
						//timelineWindowContainer.zoomAnim = timelineWindowContainer.zoomX + timelineWindowContainer.zoomAdder;
						timelineWindowContainer.zoom = timelineWindowContainer.zoomX + timelineWindowContainer.zoomAdder;
					}
				break;

				case KeySym._8:

				break;
				case KeySym._9:

				break;
		}
		return true;
	}

}


void main(char[][] args)
{
	//Trace.formatln("Rae Paned Application example.");

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

	//Trace.formatln("Going to initialize Rae.");

	Rae rae = new Rae(args);
	rae.applicationName = "Application";
	rae.allowFBO = false;//do not use FBOs (frame buffer objects).


	//Trace.formatln("Going to create a new ProjectWindow.");

	ProjectWindow projectWindow = new ProjectWindow();
	//hello.isRotate = true;
	//ProjectWindow projectWindow = new HelloWorld();
	//projectWindow.colour( 0.5, 0.5, 0.5, 1.0 );
	//projectWindow.defaultSize( 0.5, 0.5 );
	////////projectWindow.defaultSize( 800, 400 );

	//projectWindow.setIconFromFile( rae.applicationDir ~ "icons/your_icon_here.svg or .png" );//Handled by GTK+.

	projectWindow.show();

	rae.run();

	delete projectWindow;
	delete rae;
}

