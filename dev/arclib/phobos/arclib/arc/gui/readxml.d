/******************************************************************************* 

    ReadXML used in the background by layout to read XML files 

    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
		ReadXML used in the background by layout to read XML files.
	User will not want to use this file by itself. 

	Examples:
	--------------------
		Not provided.
	--------------------

*******************************************************************************/

module arc.gui.readxml; 

// XML parsing into Node structure code 
import 
	arc.types, 
	arc.xml.xml;

// stream file and text->int conversion utilites 
import 	
	std.file,
	std.stream,
	std.io,
	std.string,
	std.conv; 

// read xml layout data public interface 
public
{
	// Read layout data 
	LayoutData readLayoutXMLData(char[] fileName)
	{
		// Load XML into XML data structure
		assert(std.file.exists(fileName), "File " ~ fileName ~ " does not exist!"); 
		XmlNode xml = new XmlNode();
		File file = new File(fileName, FileMode.In);
		xml = readDocument(file);
		file.close();

		LayoutData layout; 

		layout.name = xml.getAttribute("name");
		layout.position.x = toFloat(xml.getAttribute("x"));
		layout.position.y = toFloat(xml.getAttribute("y"));
		layout.size.w = toFloat(xml.getAttribute("width"));
		layout.size.h = toFloat(xml.getAttribute("height"));

		// Recurse through the entire tree and save data into skin
		recurseReadLayoutXML(layout, xml);

		return layout;
	}

	// Read GUI data 
	GUIData readGUIXMLData(char[] fileName)
	{
		// Load XML into XML data structure
		assert(std.file.exists(fileName), "File " ~ fileName ~ " does not exist!"); 
		XmlNode xml = new XmlNode();
		File file = new File(fileName, FileMode.In);
		xml = readDocument(file);
		file.close();

		GUIData gui; 

		// Recurse through the entire tree and save data into skin
		recurseReadGUIXML(gui, xml);

		return gui;
	}

	// GUI data /////////////////////////////////////////////
	struct GUIData
	{
		GUILayoutData[] layouts; 

		void addLayout(char[] name, char[] file, bool hide)
		{
			layouts.length = layouts.length + 1; 
			int curr = layouts.length-1; 
			
			layouts[curr].name = name;
			layouts[curr].file = file; 
			layouts[curr].hide = hide; 
		}
	}

	// each layout will contain this data 
	struct GUILayoutData
	{
		char[] name, file;
		bool hide; 
	}
	
	// Layout data //////////////////////////////////////////
	struct LayoutData
	{
		// name of the layout 
		char[] name;

		// x and y, width and height
		Point position;
		Size size;

		// layout widget data arrays
		ImageData[] images; 
		ButtonData[] buttons; 
		LabelData[] labels;
		TextBoxData[] textboxes; 

		// add image widget 
		void addImage(char[] name, Point pos, Size size, char[] color, char[] image)
		{
			images.length = images.length+1;
			int curr = images.length-1; 

			images[curr].name = name;
			images[curr].position = pos;
			images[curr].size = size;
			images[curr].color = color; 
			images[curr].image = image; 
		} 

		// add label widget 
		void addLabel(Point pos, Size size, uint fontheight, char[] name, char[] color, char[] fontcolor, char[] fontname)
		{
			labels.length = labels.length+1;
			int curr = labels.length-1; 

			labels[curr].position = pos;
			labels[curr].size = size;
			labels[curr].fontheight = fontheight;
			labels[curr].name = name;
			labels[curr].color = color;
			labels[curr].fontcolor = fontcolor; 
			labels[curr].fontname = fontname; 
		}

		void setCurrLabelText(char[] argT)
		{
			labels[labels.length-1].text = argT; 
		}

		void addTextBox(Point pos, Size size, uint fontheight, char[] name, char[] color, char[] fontcolor, char[] fontname)
		{
			textboxes.length = textboxes.length+1;
			int curr = textboxes.length-1; 

			textboxes[curr].position = pos;
			textboxes[curr].size = size;
			textboxes[curr].fontheight = fontheight; 
			textboxes[curr].name = name; 
			textboxes[curr].color = color; 
			textboxes[curr].fontcolor = fontcolor; 
			textboxes[curr].fontname = fontname; 
		}

		void setCurrTextBoxText(char[] argT)
		{
			textboxes[textboxes.length-1].text = argT; 
		}

		void addButton(Point pos, Size size, uint fontheight, char[] name, char[] color, char[] fontcolor, char[] fontname)
		{
			buttons.length = buttons.length+1;
			int curr = buttons.length-1; 

			buttons[curr].position = pos;
			buttons[curr].size = size;
			buttons[curr].fontheight = fontheight;
			buttons[curr].name = name;
			buttons[curr].color = color;
			buttons[curr].fontcolor = fontcolor; 
			buttons[curr].fontname = fontname; 

		}

		void setCurrButtonText(char[] argT)
		{
			buttons[buttons.length-1].text = argT; 
		}

		void print()
		{
			int curr = 1;
			foreach(ImageData img; images)
			{
				writefln("Image num ", curr++); 
				img.print(); 
			}
		}
	}
	

	struct ButtonData
	{
		Point position;
		Size size;
		uint fontheight; 
		char[] name, text, color, fontcolor, fontname; 
	}

	struct TextBoxData 
	{
		Point position; 
		Size size;
		uint fontheight; 
		uint maxwidth=0;
		uint maxlines=0; 
		char[] name, text, color, fontcolor, fontname;
	}

	struct LabelData 
	{
		Point position;
		Size size;
		uint fontheight; 
		char[] name, text, color, fontcolor, fontname; 
	}

	// single image can hold a list of frames 
	struct ImageData
	{
		Point position;
		Size size;
		char[] name; 
		char[] color;
		char[] image;

		void print()
		{
			writefln("Image x is ", position.x, " and y is ", position.y, " with name ", name); 
		}
	}

}

// privates user should not access 
private 
{
	char[][] validWidgets; 
	
	void initializeValidParents()
	{
		validWidgets.length = 4; 
		validWidgets[0] = "button"; 
		validWidgets[1] = "image"; 
		validWidgets[2] = "label";
		validWidgets[3] = "textfield";
	}

	// Recursively print all Nodes in the xml tree
	void recurseReadLayoutXML(inout LayoutData layout, XmlNode node, char[] parentName="")
	{
		// For each xml node 
		foreach (XmlNode child; node.getChildren())
		{
			char[] name = child.getName(); 
			
			if (name == "image")
			{
				layout.addImage(child.getAttribute("name"), 
								Point(toFloat(child.getAttribute("x")),	toFloat(child.getAttribute("y"))), 
								Size(toFloat(child.getAttribute("width")), toFloat(child.getAttribute("height"))),
								child.getAttribute("color"), 
								child.getAttribute("image"));
			}
			else if (name == "label")
			{
				layout.addLabel(
								Point(toFloat(child.getAttribute("x")),	toFloat(child.getAttribute("y"))), 
								Size(toFloat(child.getAttribute("width")), toFloat(child.getAttribute("height"))),
								toUint(child.getAttribute("fontheight")),
								child.getAttribute("name"),
								child.getAttribute("color"),
								child.getAttribute("fontcolor"),
								child.getAttribute("fontname")); 
			}
			else if (name == "button")
			{
                
				layout.addButton(
								Point(toFloat(child.getAttribute("x")),	toFloat(child.getAttribute("y"))), 
								Size(toFloat(child.getAttribute("width")), toFloat(child.getAttribute("height"))),
								toUint(child.getAttribute("fontheight")),
								child.getAttribute("name"),
								child.getAttribute("color"),
								child.getAttribute("fontcolor"),
								child.getAttribute("fontname")); 
			}
			else if (name == "textbox")
			{
				layout.addTextBox(
									Point(toFloat(child.getAttribute("x")),	toFloat(child.getAttribute("y"))), 
									Size(toFloat(child.getAttribute("width")), toFloat(child.getAttribute("height"))),
									toUint(child.getAttribute("fontheight")), 
									child.getAttribute("name"), 
									child.getAttribute("color"), 
									child.getAttribute("fontcolor"),
									child.getAttribute("fontname"));

			}

			// child has Cdata text
			if (child.isCdata())
			{		
				if (parentName == "label")
				{
					// split by newlines
					char[][] lines = split(child.getCdata, r"\n");
					char[] newtext=""; 

					foreach(char[] line; lines)
					{
						newtext ~= line ~ '\n';
					}
					
					layout.setCurrLabelText(newtext); 
				}	
				else if (parentName == "button")
				{
					// split by newlines
					char[][] lines = split(child.getCdata, r"\n");
					char[] newtext=""; 

					foreach(char[] line; lines)
					{
						newtext ~= line ~ '\n';
					}
					
					layout.setCurrButtonText(newtext); 
				}
				else if (parentName == "textbox")
				{
					// split by newlines
					char[][] lines = split(child.getCdata, r"\n");
					char[] newtext=""; 

					foreach(char[] line; lines)
					{
						newtext ~= line ~ '\n';
					}
					
					layout.setCurrTextBoxText(newtext);
				}

			}

			// recurse until we have read entire structure 
			recurseReadLayoutXML(layout, child, child.getName());
		}

	}

	// Recursively print all Nodes in the xml tree
	void recurseReadGUIXML(inout GUIData gui, XmlNode node, char[] parentName="")
	{
		// For each xml node 
		foreach (XmlNode child; node.getChildren())
		{
			char[] name = child.getName(); 
			
			if (name == "layout")
			{
				bool b = false;

				if (child.getAttribute("hide")=="true")
					b = true; 
				
				gui.addLayout(	child.getAttribute("name"), 
								child.getAttribute("file"),
								b);
			}

			// recurse until we have read entire structure 
			recurseReadGUIXML(gui, child, child.getName());
		}

	}
}
