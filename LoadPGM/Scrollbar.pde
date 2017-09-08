class Control {
  
}

class HScrollbar extends Control {
  int swidth, sheight;    // width and height of bar
  int xpos, ypos;         // x and y position of bar
  float spos, newspos;    // x position of slider
  int sposMin, sposMax;   // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;         // can we move?
  color bgcolor;          // background color for the bar
  float ratio;
  float loVal, hiVal;     // the minimum and maximum computed values
  int decimals;           // number of significant digits after the decimal point
  PFont font;             // font to be used
  float val;              // float value of scrollbar
  String title;           // scrollbar title to be drawn above
  int lastKey;            // keypress processing variable

  HScrollbar (int xp, int yp, int sw, int sh, int l) {
    loVal = -1.0f;
    hiVal = 1.0f;
    decimals = 3;
    //font = loadFont("CourierNew36.vlw");
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + (swidth - sheight)/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    title = "";
  }
  
  HScrollbar(int xp, int yp, String title, float lo, float hi){
    this(xp, yp, title);
    setScale(lo, hi);
  }
  HScrollbar(int xp, int yp, String title, int lo, int hi){
    this(xp, yp, title);
    setScale(lo, hi);
  }
  
  HScrollbar(int xp, int yp, String title){
    this(xp, yp, 90, 10, 1);
    setTitle(title);
  }
  void setColor(color bgc){
    bgcolor = bgc;
  }
  void setTitle(String ti){
    title = ti;
  }
  // move the scrollbar to a new position
  void setPos(int l){
    float v = val;
    xpos = l;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    newspos = (sposMin + sposMax) / 2;
    update();
    val = v;
    display();
  }
  // this is where the real work is done for computing its value
  float getReal(){
    float r = 2.0 * (spos - xpos + (sheight / 2.0f) - (swidth / 2.0f)) / (float)(swidth-sheight);
    return r;
  }
  void setVal(float r){
    if(loVal < hiVal) {
      val = constrain(r, loVal, hiVal);
    } else {
      val = constrain(r, hiVal, loVal);
    }
    r = 2.0 * (val - loVal) / ( hiVal - loVal ) - 1;
    newspos = (float)(swidth-sheight) * 0.5 * r + xpos - (sheight / 2.0f) + (swidth / 2.0f);
    //System.out.println(newspos);
    update();
  }

  float getVal() {
    //float r = getReal();
    //return ((1 + r) / 2.0) * (hiVal-loVal) + loVal;
    return val;
  }
  void setScale(float lo, float hi){
    loVal = lo;
    hiVal = hi;
    decimals = 3;
  }
  // integers don't have significant digits after the decimal point
  void setScale(int lo, int hi){
    loVal = lo;
    hiVal = hi;
    decimals = 0;
  }


  // let's update the scrollbar
  void update() {
    if(over()) {
      over = true;
    } else {
      over = false;
    }
    if(mousePressed && over) {
      locked = true;
    }
    if(!mousePressed) {
      locked = false;
    }
    if(locked) {
      newspos = constrain( (mouseX - sheight/2), sposMin, sposMax);
      float r = getReal();
      val = ((1 + r) / 2.0) * (hiVal-loVal) + loVal;
      //if(decimals == 0) val += (mouseY - ypos) * swidth / (float)(hiVal - loVal);
    }
    if(abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos) / loose;
    }
  }
  // limit val to a value between and including minv and maxv
  //int constrain(int val, int minv, int maxv) {
  //  return min(max(val, minv), maxv);
  //}

  // is the mouse currently over the scrollbar?
  boolean over() {
    if(mouseX > xpos && mouseX < xpos+swidth &&
    mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  // draw the scrollbar to the display
  void display(){
    float gv;
    fill(bgcolor);
    noStroke();
    rect(xpos, ypos, swidth, sheight);
    if(over || locked) {
      fill(153, 102, 0);
      if(!keyPressed){
        gv = getVal();
        float sv;
        if(decimals == 0) sv = 1; else sv = 0.1;
        switch(lastKey){
          case RIGHT: setVal(gv + sv); break;
          case LEFT:  setVal(gv - sv); break;
        }
        lastKey = 0;
      }
        //update();
      //} else {
      //  lastKey = keyCode;
      //}
      if(keyPressed) lastKey = keyCode;
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
    
    //textFont(font, 12);
    fill(#cccccc);
    textAlign(CENTER);
    text(title, (sposMax + sposMin) / 2, ypos - 1);

    int ofs;
    gv = getVal();
    if(getReal() < 0) {
      textAlign(LEFT);
      ofs = 10;
    } else {
      textAlign(RIGHT);
      ofs = 0;
    }
    
    fill(#ffffff);
    gv *= pow(10, decimals);
    int gvi = (int)gv;
    gv = gvi / (float)(pow(10,decimals));
    text("" + gv, spos + ofs, ypos + 10);
  }
  void display(color c) {
    bgcolor = c;
    display();
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}
