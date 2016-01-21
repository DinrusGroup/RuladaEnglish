module amigos.dk.label;

import amigos.dk.widget;
import amigos.dk.options;

class Label: public Widget
{
  this(Widget master,string text)
    {
      Options o;o["text"]=text;
      super(master,"label",o);
    }
}
