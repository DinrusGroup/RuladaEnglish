//This example is in the public domain.

module pictureviewer;

import tango.util.log.Trace;//Thread safe console output.

import tango.io.FilePath;
import tango.util.container.LinkedList;
import Utf = tango.text.convert.Utf;
//import tango.math.Math;
//import tango.stdc.string;
//import tango.io.Stdout;
//import stringz = tango.stdc.stringz;
//import tango.core.Thread;

import rae.Rae;

//import rae.core.Timeout;
import rae.ui.Window;
import rae.ui.SubWindow;//for Sides.
import rae.ui.Menu;
//import rae.ui.Paned;
import rae.ui.Button;
import rae.ui.ProgressBar;
import rae.ui.Widget;
import rae.ui.Box;
import rae.ui.Entry;
import rae.canvas.Draw;
import rae.canvas.Rectangle;
import rae.canvas.Image;
import rae.ui.Animator;
import rae.ui.ImageView;

import rae.ui.FileChooser;

//import lodepng.Decode;
//import lodepng.Encode;

//import rae.canvas.Bezier;

//import rae.av.globals;
//import rae.av.VideoFileQT;
//import rae.av.AudioFileQT;
//import rae.av.IAudioReader;
//import rae.av.IVideoReader;
//import rae.av.IVideoWriter;

//import rae.av.aspecthelper;
////////////////import rae.av.enums;
//import rae.av.VideoFormat;
//import rae.av.IVideoFileWriter;
//import rae.av.VideoWriterQT;

//double g_tempclip = 0.0f;
//double g_tempclip2 = 0.0f;


class ImageViewerSides : Sides
{
	this()
	{
		super();
		
		side1 = new Rectangle();
		side2 = new Rectangle();
		
		Sides.append(side1);
		Sides.append(side2);
	}
	
	Rectangle side1;
	Rectangle side2;
	
	void setImageOne( Image set )
	{
		side1.texture = set;
	}
	
	void setImageTwo( Image set )
	{
		side2.texture = set;
	}

}

class ImageCanvas : protected Rectangle
{
	this()
	{
		//arrangeType = ArrangeType.FREE;
		colour = g_rae.getColourArrayFromTheme("Rae.SubWindow.background");
		
		currentImageLabel = new Entry("");
		
		filelist = new LinkedList!(char[]);
		//imagelist = new LinkedList!(ImageView);
		foreach( int set; imageListIndex )
		{
			set = -1;
		}
		
		/*filelist ~= "/home/joonaz/muiden/kuvat/90137-pihlaja.png";
		filelist ~= "/home/joonaz/muiden/kuvat/horse_and_watertower.png";
		filelist ~= "/home/joonaz/muiden/kuvat/rae_bw.png";
		filelist ~= "/home/joonaz/muiden/kuvat/rae_grey.png";
		
		foreach( char[] file; filelist )
		{
			ImageView im = new ImageView(file);
			imagelist ~= im;
			//add( im );
		}
		*/
	}
	
	void rotateRight()
	{
		if( currentImage !is null )
		{
			//This is a bit problematic, as the image will not stay
			//at 90 degrees if you click rapidly.
			//currentImage.zRotAnim( currentImage.zRot + 90.0f );
			
			currentDegrees = currentDegrees + 90.0f;
			currentImage.zRotAnim( currentDegrees );
			
			/*
			//That's why we have to do this:
			if( currentImage.zRot >= 360.0f )
			{
				currentImage.zRot( currentImage.zRot - 360.0f );//A trick to avoid silly animation from 360.0 to 90.0
				currentImage.zRotAnim( 90.0f );
			}
			else if( currentImage.zRot >= 270.0f )
				currentImage.zRotAnim( 360.0f );
			else if( currentImage.zRot >= 180.0f )
				currentImage.zRotAnim( 270.0f );
			else if( currentImage.zRot >= 90.0f )
				currentImage.zRotAnim( 180.0f );
			else //if( currentImage.zRot >= 0.0f )
				currentImage.zRotAnim( 90.0f );
			*/
		}
	}
	
	float currentDegrees = 0.0f;
	
	void rotateLeft()
	{
		if( currentImage !is null )
		{
			currentDegrees = currentDegrees - 90.0f;
			currentImage.zRotAnim( currentDegrees );
			
			
			/*
			if( currentImage.zRot <= 0.0f )
			{
				currentImage.zRot( currentImage.zRot + 360.0f );//A trick to avoid silly animation from 0.0 to 270.0
				currentImage.zRotAnim( 270.0f );
			}
			else if( currentImage.zRot <= 90.0f )
				currentImage.zRotAnim( 0.0f );
			else if( currentImage.zRot <= 180.0f )
				currentImage.zRotAnim( 90.0f );
			else if( currentImage.zRot <= 270.0f )
				currentImage.zRotAnim( 180.0f );
			else //if( currentImage.zRot <= 360.0f )
				currentImage.zRotAnim( 270.0f );
			*/
		}
	}
	
	void resetZoomAndMoveScreen()
	{
		zoomAnim( 1.0f );
		moveScreenXAnim( 0.0f );
		moveScreenYAnim( 0.0f );
		//if( currentImage !is null )
		//{
			//currentImage.zRot(0.0f);
		//}
	}
	
	void openFile( char[] set )
	{
		debug(pictureviewer) Trace.formatln("ImageCanvas.openFile() START {}", set);
		debug(pictureviewer) scope(exit) Trace.formatln("ImageCanvas.openFile() END {}", set);
			
		clearFiles();
		
		auto setpath = new FilePath( set );
		if( setpath.exists == false )
		{
			Trace.formatln("The file or folder: {} doesn't exist.", set );
			return;
		}
		
		if( setpath.isFolder == true )
		{
			debug(pictureviewer) Trace.formatln("ImageCanvas.openFile() The path {} is a folder.", set);
			foreach( FilePath file; FileChooser.listFilesInFolderAlphabetically(setpath) )
			{
				addFile( file.toString() );
			}
			showFirst();
		}
		else
		{
			debug(pictureviewer) Trace.formatln("ImageCanvas.openFile() The path {} is a file.", set);
			auto folderpath = new FilePath( setpath.parent );
			foreach( FilePath file; FileChooser.listFilesInFolderAlphabetically(folderpath) )
			{
				addFile( file.toString() );
			}
			showFile( set );
		}
	}
	
	void addFile(char[] file)
	{
		debug(pictureviewer) Trace.formatln("ImageCanvas.addFile() {}", file);
		filelist.append(file);
		//filelist ~= file;
		//ImageView im = new ImageView(file);
		//imagelist ~= im;
	}
	
	void clearFiles()
	{
		filelist.clear();
		foreach( int set; imageListIndex )
		{
			set = -1;
		}
	}
	
	void showFirst()
	{
		debug(pictureviewer) Trace.formatln("ImageCanvas.showFirst()");
		m_filelistPosition = -1;
		next();
	}
	
	void showFile( char[] set )
	{
		debug(pictureviewer) Trace.formatln("ImageCanvas.showFile() {}", set);
	
		for( uint i = 0; i < filelist.size; i++ )
		{
			if( set == filelist.get(i) )
			{
				m_filelistPosition = i-1;
				next();
				return;
			}
		}
		
		Trace.formatln("filelist contents:");
		foreach(char[] file; filelist)
		{
			Trace.formatln(file);
		}
		
		Trace.formatln("For some reason the file was not found in the current filelist. This must be a bug in this software. Sorry.");
	}
	
	void next()
	{
		/*
		static bool side_is_front = true;
		if( imageViewerSides !is null && imageViewerSides.hasAnimators == false )
		{
			if( side_is_front == true )
			{
				imageViewerSides.addDefaultAnimator( DefaultAnimator.ROTATE_180 );
				side_is_front = false;
			}
			else
			{
				imageViewerSides.addDefaultAnimator( DefaultAnimator.ROTATE_180_TO_360 );
				side_is_front = true;
			}	
		}
		*/
		
		//ImageView im = new ImageView( filelist[filelistPositionNext] );
		//add( im );//calls arrange.
		
		transition(true);
	}
	
	void previous()
	{
		transition(false);
	}
	
	bool isNext = true;
	
	void transition( bool is_next )
	{
		resetZoomAndMoveScreen();
	
		if( currentImage !is null )
		{
			currentDegrees = 0.0f;
			currentImage.zRotAnim(currentDegrees);
		}
	
		isNext = is_next;
		float startpos;
		float endpos;
		
		if( isNext == true )//direction forward
		{
			startpos = -(w*3.0f);
			endpos = w*3.0f;
		}
		else //direction backward
		{
			startpos = w*3.0f;
			endpos = -(w*3.0f);
		}
	
		//Move the currentImage out of the way.
			if( currentImage !is null )
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() Move the current image out of the way. {}", currentImage.filename );
				//transform so that we take zoom and moveScreen into account.
				startpos = tr_xc2i( startpos );
				endpos = tr_xc2i( endpos );
			
				//Move the currentImage away with an animation.
				//ImageView tim = currentImage;
				currentImage.xPosAnim( endpos, &transition2 );//, { remove( tim ); } );
			}
			else transition2();
	}
	
	void transition2()
	{
		int filepos;
		float startpos;
		float endpos;
		
		if( isNext == true )//direction forward
		{
			filepos = filelistPositionNext;
			startpos = -(w*3.0f);
			endpos = w*3.0f;
		}
		else //direction backward
		{
			filepos = filelistPositionPrevious;
			startpos = w*3.0f;
			endpos = -(w*3.0f);
		}
		
			debug(pictureviewer) Trace.formatln("ImageCanvas.transition() trying to load the image.");
			
			//Time to load a new image.
			if( currentImage is null )
			{
				currentImage = new ImageView();
				currentImage.isClipping = false;
				currentImage.isClipByParent = false;
				add(currentImage);
			}
			
			bool is_file_ok = false;
			
			if( currentImage.openFile( filelist.get(filepos) ) == false )
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() file not ok {}.", filelist.get(filepos) );
				int nextfilepos = -1;
				if( isNext == true ) nextfilepos = filelistPositionNext;
				else nextfilepos = filelistPositionPrevious;
				
				while( nextfilepos != filepos )
				{
					if( currentImage.openFile( filelist.get(nextfilepos) ) == true )
					{
						is_file_ok = true;
						break;
					}
					else
					{
						debug(pictureviewer) Trace.formatln("ImageCanvas.transition() file not ok {}.", filelist.get(nextfilepos) );
					}
					
					if( isNext == true ) nextfilepos = filelistPositionNext;
					else nextfilepos = filelistPositionPrevious;
					//If we get something loaded we'll stop. And if we go around the list
					//and nothing gets loaded then we stop too.
				}
			}
			else//The file is ok.
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() file loaded ok the first time.");
				is_file_ok = true;
			}
			
			//And get the new image in.
			if( currentImage !is null && is_file_ok == true )
			{
				if( currentImageLabel !is null )
				{
					currentImageLabel.text = Utf.toString32( currentImage.filename );
				}
			
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() Move the new image in. {}", currentImage.filename );
				//currentImage.show();
				currentImage.xPos = startpos;
				currentImage.xPosAnim(0.0f);//animate to center.
			}
			else
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() Error: Can't load any images from that folder.");
			}
			
	}
	
	/*
	void transition( bool is_next )
	{
		debug(pictureviewer) Trace.formatln("ImageCanvas.transition()");
	
		//if( imagelist is null )
		//	return;
	
		//TransitionType.SWIPE
		
		int filepos;
		float startpos;
		float endpos;
		
		if( is_next == true )//direction forward
		{
			filepos = filelistPositionNext;
			startpos = -(w*2.0f);
			endpos = w*2.0f;
		}
		else //direction backward
		{
			filepos = filelistPositionPrevious;
			startpos = w*2.0f;
			endpos = -(w*2.0f);
		}
		
		
		//Here's some file checking. It propably could be alot simpler,
		//but this is what my mind created this time:
		int list_index = -1;
		
		bool is_file_ok = false;
		
		//First we check if we already have the image loaded.
		//This is told by comparing the imageListIndex[] values,
		//with the filepos value.
		debug(pictureviewer) Trace.formatln("ImageCanvas.transition() trying to find the image in memory.");
		for( uint i = 0; i < imageListIndex.length; i++ )
		{
			if( imageListIndex[i] == filepos )
			{
				list_index = i;
				is_file_ok = true;
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() found it at {}", list_index );//, imagelist[list_index].filename );
			}
		}
		
		//If the file wasn't already loaded, then we try to load it.
		//If the loading fails we'll try the next one in our filelist,
		//until we either find a valid image or then not.
		if( list_index == -1 || imagelist[list_index] is null )
		{
			debug(pictureviewer) Trace.formatln("ImageCanvas.transition() trying to load the image.");
		
			//Time to load a new image.
			list_index = getNewImageListPosition();
			debug(pictureviewer) Trace.formatln("ImageCanvas.transition() got a new imagelistposition {}", list_index);
			if( imagelist[list_index] is null )
				imagelist[list_index] = new ImageView();
			
			if( imagelist[list_index].openFile( filelist.get(filepos) ) == false )
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() file not ok {}.", filelist.get(filepos) );
				int nextfilepos = -1;
				if( is_next == true ) nextfilepos = filelistPositionNext;
				else nextfilepos = filelistPositionPrevious;
				
				while( nextfilepos != filepos )
				{
					if( imagelist[list_index].openFile( filelist.get(nextfilepos) ) == true )
					{
						imageListIndex[list_index] = nextfilepos;
						is_file_ok = true;
						break;
					}
					else
					{
						debug(pictureviewer) Trace.formatln("ImageCanvas.transition() file not ok {}.", filelist.get(nextfilepos) );
					}
					
					if( is_next == true ) nextfilepos = filelistPositionNext;
					else nextfilepos = filelistPositionPrevious;
					//If we get something loaded we'll stop. And if we go around the list
					//and nothing gets loaded then we stop too.
				}
			}
			else//The file is ok.
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() file loaded ok the first time.");
				imageListIndex[list_index] = filepos;
				is_file_ok = true;
			}
		}
		
		if( is_file_ok == true )
		{
			//Move the currentImage out of the way.
			if( currentImage !is null )
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() Move the current image out of the way. {}", currentImage.filename );
				//transform so that we take zoom and moveScreen into account.
				startpos = tr_xc2i( startpos );
				endpos = tr_xc2i( endpos );
			
				//Move the currentImage away with an animation.
				//ImageView tim = currentImage;
				currentImage.xPosAnim( endpos, &currentImage.hide );//, { remove( tim ); } );
			}
			
			//And get the new image in.
			if( imagelist[list_index] !is null )
			{
				currentImage = imagelist[list_index];
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() Move the new image in. {}", currentImage.filename );
				if( currentImage.parent is null )
					add(currentImage);//calls arrange.
			
				currentImage.show();
				currentImage.xPos = startpos;
				currentImage.xPosAnim(0.0f);//animate to center.
			}
			else
			{
				debug(pictureviewer) Trace.formatln("ImageCanvas.transition() Error: Can't load any images from that folder.", list_index);
			}
		}
	}
	*/
	
	/*
	override void arrange()
	{
		foreach(Rectangle im; itemList )
		{
			//It would be nice to have this as some prebuilt
			//functionality that would keep the aspect ratios.
			//something like: im.hAspect = h;
			//which would also change w accordingly.
			float aspectrat = im.aspect;//store the current aspect.
			//Check which has a wider aspectratio,
			//this canvas or the picture:
			if( aspectrat <= aspect )
			{
				//the canvas is wider use it's height
				//for the image.
				im.h = h;
				im.w = aspectrat * im.h;
			}
			else
			{
				//the image is wider, use canvas width
				//for the image.
				im.w = w;
				im.h = im.w / aspectrat;
			}
		}
	}
	*/
	int filelistPosition() { return m_filelistPosition; }
	int filelistPositionNext()
	{
		m_filelistPosition++;
		//wrap from the end to the beginning:
		if( m_filelistPosition >= filelist.size )
			m_filelistPosition = 0;
		return m_filelistPosition;
	}
	int filelistPositionPrevious()
	{
		m_filelistPosition--;
		//wrap from the end to the beginning:
		if( m_filelistPosition < 0 )
			m_filelistPosition = filelist.size-1;
		return m_filelistPosition;
	}
	int m_filelistPosition = -1;
	
	int getNewImageListPosition()
	{
		static int nextpos = -1;
	
		int result = -1;
		for( uint i = 0; i < imageListIndex.length; i++ )
		{
			if( imageListIndex[i] == -1 )
				result = i;
		}
		
		//if none are free return nextpos.
		if( result == -1 )
		{
			nextpos++;
			if( nextpos >= imageListIndex.length )
			{
				nextpos = 0;
			}
			return nextpos;
		}
		return result;
	}
	
	ImageView currentImage;
	int[5] imageListIndex;
	
	ImageView[5] imagelist;
	//char[][] filelist;
	LinkedList!(char[]) filelist;
	
	Entry currentImageLabel;
	
}

class ProjectWindow : Window
{
	/*rEMOVE
	void printFolders(FilePath set_path)
	{
		set_path.toList( &printFolder );
	}

	bool printFolder(FilePath set_path, bool isDir)
	{
		if( isDir == true )
			Trace.formatln( "folder: {}", set_path.name );
		return true;
	}

	void printFiles(FilePath set_path)
	{
		set_path.toList( &printFile );
	}

	bool printFile(FilePath set_path, bool isDir)
	{
		if( isDir == false )
			Trace.formatln( "file: {}", set_path.name );
		return true;
	}
	
	//
	
	REMOVE
	FilePath[] listFiles(FilePath set_path)
	{
		bool onlyFiles(FilePath set_path, bool isDir)
		{
			if( isDir == false )
				return true;
			//else
// 				return false;
		}
		
		return set_path.toList( &onlyFiles );
	}
*/
	

	this(char[][] openfiles)
	{
		debug(ProjectWindow) Trace.formatln("ProjectWindow.this() START.");
		debug(ProjectWindow) scope(exit) Trace.formatln("ProjectWindow.this() END.");
		
		super("Pictureviewer");
		
		//threadGroup = new ThreadGroup();
		
		
		FileChooserDialog fileChooserDialog = new FileChooserDialog;
		addFloating( fileChooserDialog );
		fileChooserDialog.hide();
		
		fileChooserDialog.fileChooser.signalFileChosen.attach( &openFile );
		
		//Menu stuff:
		
		Menu amenu = new Menu();
		MenuItem amenuitem1 = new MenuItem("<b>Pictureviewer</b>");
		amenu.addMenuItem( amenuitem1 );
				//MenuItem amenuitem1_1 = new MenuItem("Preferences...", &tempMenuHandler);
				//amenuitem1.addMenuItem( amenuitem1_1 );
				MenuItem amenuitem1_2 = new MenuItem("Quit", &g_rae.quit);
				amenuitem1.addMenuItem( amenuitem1_2 );
		MenuItem amenuitem2 = new MenuItem("File");
		amenu.addMenuItem( amenuitem2 );
			MenuItem amenuitem2_1 = new MenuItem("Open...", &fileChooserDialog.present );
			amenuitem2.addMenuItem( amenuitem2_1 );
		MenuItem amenuitem3 = new MenuItem("View");
		amenu.addMenuItem( amenuitem3 );
			MenuItem amenuitem3_1 = new MenuItem("Fullscreen", &toggleFullscreen );
			amenuitem3.addMenuItem( amenuitem3_1 );
		MenuItem amenuitem4 = new MenuItem("Help");
		amenu.addMenuItem( amenuitem4 );
		
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
		
		imageCanvas = new ImageCanvas();
		
		toolbar = new HBox();
		toolbar.layer = 4900;
		//HBox is normally rendered in BYPASS,
		//but we want it to have background.
		toolbar.renderMethod = RenderMethod.NORMAL;
		toolbar.colour = g_rae.getColourArrayFromTheme("Rae.SubWindow.background");
		
		add(toolbar);
		
		auto previousButton = new Button("Previous");
		previousButton.signalActivate.attach(&imageCanvas.previous);
		//previousButton.colour(1.0f, 0.0f, 0.0f, 1.0f);
		toolbar.add( previousButton );		
		auto nextButton = new Button("Next");
		nextButton.signalActivate.attach(&imageCanvas.next);
		//nextButton.colour(0.0f, 0.7f, 0.0f, 1.0f);
		toolbar.add( nextButton );
		
		auto rotateLeftButton = new Button("Rotate Left");
		rotateLeftButton.signalActivate.attach(&imageCanvas.rotateLeft);
		toolbar.add( rotateLeftButton );
		
		auto rotateRightButton = new Button("Rotate Right");
		rotateRightButton.signalActivate.attach(&imageCanvas.rotateRight);
		toolbar.add( rotateRightButton );
		
		auto zoomInButton = new Button("Zoom In");
		zoomInButton.signalActivate.attach(&imageCanvas.zoomIn);
		toolbar.add( zoomInButton );
		
		auto zoomOutButton = new Button("Zoom Out");
		zoomOutButton.signalActivate.attach(&imageCanvas.zoomOut);
		toolbar.add( zoomOutButton );
		
		auto zoomResetButton = new Button("Fit");
		zoomResetButton.signalActivate.attach(&imageCanvas.resetZoomAndMoveScreen);
		toolbar.add( zoomResetButton );
		
		toolbar.add( imageCanvas.currentImageLabel );
		imageCanvas.currentImageLabel.signalTextChanged.attach(&entryTextChangedHandler);
		
		//////insideButton4 = new Button("شیراز");
		//insideButton4.colour(0.0f, 0.2f, 0.9f, 1.0f);
		//////insideButton4.signalActivate.attach(&clickHandler3);
		/*
		insideButton4.signalMouseButtonPress.attach(&clickHandler3);
		insideButton4.signalMouseButtonRelease.attach(&clickHandler3);
		insideButton4.signalMouseMotion.attach(&clickHandler3);
		insideButton4.signalEnterNotify.attach(&clickHandler3);
		insideButton4.signalLeaveNotify.attach(&clickHandler3);
		*/
		/////add(insideButton4);
			auto hbox1 = new HBox();
			hbox1.xPackOptions = PackOptions.EXPAND;//To keep it maximized.
			hbox1.yPackOptions = PackOptions.EXPAND;
			hbox1.isClipping = false;//This gets rid of a funny bug with our clipping system and
			//zRot, which aren't compatible.
			add(hbox1);
			
			isClipping = false;//This gets rid of a funny bug with our clipping system and
			//zRot, which aren't compatible.
			container.isClipping = false;//This gets rid of a funny bug with our clipping system and
			//zRot, which aren't compatible.
			
			//playerRect.colour(0.0f, 0.0f, 0.0f, 1.0f);
			//playerRect.arrangeType = ArrangeType.FREE;
			
			imageCanvas.isClipping = false;
			imageCanvas.isClipByParent = false;
			imageCanvas.signalMouseButtonPress.attach(&playerRectMouseHandler);
			imageCanvas.signalMouseButtonRelease.attach(&playerRectMouseHandler);
			imageCanvas.signalMouseMotion.attach(&playerRectMouseHandler);
			imageCanvas.signalScrollUp.attach(&playerRectMouseHandler);
			imageCanvas.signalScrollDown.attach(&playerRectMouseHandler);
			
			hbox1.add( imageCanvas );
			//add( playerRect );
		/*
		imageViewerSides = new ImageViewerSides();
		add( imageViewerSides );
		
		imageViewerSides.setImageOne( new Image("/home/joonaz/muiden/kuvat/90137-pihlaja.png") );
		//imageViewerSides.setImageTwo( new Image("/home/joonaz/muiden/kuvat/90137-pihlaja.png") );
		imageViewerSides.setImageTwo( new Image("/home/joonaz/muiden/kuvat/horse_and_watertower.png") );
		
		//images[0] = new ImageView("/home/joonaz/muiden/kuvat/horse_and_watertower.png");
		//images[1] = new ImageView("/home/joonaz/muiden/kuvat/90137-pihlaja.png");

		//add( images[0] );
		//add( images[1] );
		
		*/
		
		if( openfiles !is null )
		{
			//If there's only one file, then
			//we also scan the same directory for other
			//pictures.
			if( openfiles.length == 1 )
			{
				openFile( openfiles[0] );
				/*auto ourfile = new FilePath( openfiles[0] );
				auto ourfolder = new FilePath( ourfile.parent );
				
				
				
				foreach( FilePath file; listFilesInFolderAlphabetically(ourfolder) )
				{
					//if( file.ext == "png" )
					imageCanvas.addFile( file.toString() );
				}*/
			}
			else //otherwise we just open only the files we were told to.
			{
				foreach( char[] file; openfiles )
				{
					imageCanvas.addFile(file);
				}
			}
			
			
		
			imageCanvas.next();//to Show the current.
		}
	}
	
	void entryTextChangedHandler( dchar[] set_text )
	{
		openFile( Utf.toString(set_text) );
	}
	
	/*
	void fileChosenHandler( char[] set )
	{
		Trace.formatln("File was chosen: {}", set );
		openFile( set );
	}*/
	
	void openFile(char[] set)
	{
		imageCanvas.openFile(set);
	}
	
	void tempMenuHandler()
	{
		Trace.formatln("Clicked menuitem.");
	}
	
	void playerRectMouseHandler( InputState input, Rectangle wid )
	{
		switch( input.eventType )
		{
			default:
			break;
			/*
			case SEventType.ENTER_NOTIFY:
				input.isHandled = true;
				wid.prelight();
			break;
			case SEventType.LEAVE_NOTIFY:
				input.isHandled = true;
				wid.unprelight();
			break;
			*/
			case SEventType.MOUSE_BUTTON_PRESS:
				//if( input.mouse.eventButton == MouseButton.MIDDLE )
				//{
					input.isHandled = true;
					wid.grabInput();
				//}
			break;
			case SEventType.MOUSE_BUTTON_RELEASE:
				//if( input.mouse.eventButton == MouseButton.MIDDLE )
				//{
					input.isHandled = true;
					wid.ungrabInput();
				//}
			break;
			case SEventType.MOUSE_MOTION:
				if( input.mouse.button[MouseButton.MIDDLE] == true || input.mouse.button[MouseButton.LEFT] == true )
				{
					//isHomeZoom = false;
					input.isHandled = true;
					wid.moveScreen( input.mouse.xRelLocal, input.mouse.yRelLocal );
				}
				else if( input.mouse.button[MouseButton.RIGHT] == true )
				{
					//isHomeZoom = false;
					input.isHandled = true;
					wid.zoomAnim = wid.zoomX + (wid.zoomAdder*input.mouse.yRelLocal);
				}
			break;
			case SEventType.SCROLL_UP:
				//isHomeZoom = false;
				input.isHandled = true;
				wid.zoomAnim = wid.zoomX + wid.zoomAdder;
			break;
			case SEventType.SCROLL_DOWN:
				//isHomeZoom = false;
				input.isHandled = true;
				wid.zoomAnim = wid.zoomX - wid.zoomAdder;
			break;
		}
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
		//debug(ProjectWindow) 
		Trace.formatln("Clicked a button.");
	
		if( myWindow3 !is null && myWindow3.hasAnimators == false )
		{
			myWindow3.addDefaultAnimator( DefaultAnimator.ROTATE_360 );
		}
		
		
		
	}
	
	bool keyEvent( InputState input )
	{
	
		if( input.eventType != SEventType.KEY_PRESS )
			return false;
		
		//TODO make keyfocus!
		switch( input.key.value )
		{
			default:
			break;
			case KeySym.Escape:
				g_rae.quit();
			break;
			case KeySym.Left:
				imageCanvas.previous();
			break;
			case KeySym.Right:
				imageCanvas.next();
			break;
			case KeySym.Up:
				imageCanvas.zoomIn();
			break;
			case KeySym.Down:
				imageCanvas.zoomOut();
			break;
			case KeySym.f:
				toggleFullscreen();
			break;
			case KeySym.z:
				imageCanvas.resetZoomAndMoveScreen();
			break;
		}
		return true;
	}
	
	SubWindow myWindow3;
	HBox toolbar;
	Button insideButton;
	Button insideButton4;
	
	ImageCanvas imageCanvas;
	
	ImageViewerSides imageViewerSides;
	
	//ImageView[10] images;
	
	
	
}


void main(char[][] args)
{
	Trace.formatln("Pictureviewer");
	
	char[][] openfiles;
	
	if (args.length > 1)
	{
		//foreach(char[] ar; args)
		//We dont' process 0 because that's our executable file.
		//and it exists.
		for( uint i = 1; i < args.length; i++ )
		{
			char[] ar = args[i];
			
			if( ar == "--help" )
			{
				Trace.formatln("Some help here. TODO.");
				//return;
			}
			else
			{
				scope FilePath a_path = new FilePath(ar);
				if( a_path.exists )
				{
					Trace.formatln("File exists: {}", ar);
					openfiles ~= ar;
				}
			}
		}//endfor
	}//endif

	Rae rae = new Rae(args);
	rae.applicationName = "Pictureviewer";
	ProjectWindow projectWindow = new ProjectWindow(openfiles);
	//projectWindow.defaultSize( 800, 400 );
	if( rae.isFullScreen == false )//our fullscreen default might be overridden by the -w switch.
	{
		projectWindow.defaultSize( rae.screenWidthP-20, rae.screenHeightP-100 );
	}
	
	projectWindow.show();
	
	rae.run();
	
	delete projectWindow;
	delete rae;
}

