class ImageOp extends ImgData { // we'll put all image operations as a subclass of ImageOp
  String title = "";            // default title to be drawn above panel
  boolean updateme = true;      // do I really need to be redrawn?
  int posLeft = 0;              // default left position for the panel
  final int posTop = 150;       // how far from the bottom do we draw the panel's top?
  protected int posWidth = 100; // how wide should each panel be?
  protected ImgData in;         // reference to our input image
  protected boolean[] chBypass; // this keeps track of what channels should be affected by the op
  protected boolean visible;
  protected boolean selected;
  Control[] controls;

  public ImageOp(ImgData img){                 // constructor
    super(img);
    in = img;
    chBypass = new boolean[imgChannels];
    for(int ch=0; ch < imgChannels; ch++){  // process all channels by default
      chBypass[ch] = false;
    }
    updateme = true;
    visible = false;
    title = "Default Op";
  }
  
  public String toString(){
    return title;// +" "+ super.toString();
  }
  public void printOut(){
    loadPImage(zoom);
    for(int ch=0; ch < imgChannels; ch++){
      println("channel "+ch);
      for(int y=0; y < imgHeight; y++){
        for(int x=0; x < imgWidth; x++){
          print(imgData[x][y][ch] + "\t");
        }
        println("");
      }
      println("");
    }
  }
  public void printPal(){
    loadPImage(zoom);
    for(int ch=0; ch < imgChannels; ch++){
      for(int k=0; k <= imgMax; k++){
        print(hex(imgPalette[k][ch], 6) + "\t");
      }
      println("");
    }
  }
  
  public void setBypass(boolean[] b){          // set the bypass states for all channels
    chBypass = b;
  }
  
  public void setBypass(int ch, boolean b){    // set the bypass for a given channel
    chBypass[ch] = b;
  }
  
  public boolean toggleBypass(int ch){         // flip the bypass for a given channel
    chBypass[ch] = !(chBypass[ch]);
    return chBypass[ch];
  }
  
  public boolean getBypass(int ch){            // should we touch this channel?
    return chBypass[ch];
  }


  public void computeScale(){                // scale the image after operating
  for(int ch=0; ch < imgChannels; ch++){
    int imgLocalMin = this.imgMax, imgLocalMax = 0;
    for(int x=0; x < imgWidth; x++){         // find minimum and maximum values
      for(int y=0; y < imgHeight; y++){
        //for(int ch=0; ch < imgChannels; ch++){
          int v = imgData[x][y][ch];
          if(v < imgLocalMin) imgLocalMin = v;
          if(v > imgLocalMax) imgLocalMax = v;
        //}
      }
    }
    if(imgLocalMin < 0 || imgLocalMax > imgMax) { // only scale if we've exceeded bounds
      float imgLocalScale = imgMax / (float)(imgLocalMax - imgLocalMin);
      // now we want to apply the scale
      for(int x=0; x < imgWidth; x++){
        for(int y=0; y < imgHeight; y++){
          //for(int ch=0; ch < imgChannels; ch++){
            int v = imgData[x][y][ch];
            imgData[x][y][ch] = (int)((v - imgLocalMin) * imgLocalScale);
          //}
        }
      }
    }
  }
  }
  
  public ImgData compute(){                    // this one can be overridden if necessary
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        for(int ch=0; ch < imgChannels; ch++){
          if(!chBypass[ch]){
            imgData[x][y][ch] = calc(x,y,ch);
          }
        }
      }
    }
    updateme = false;
    return this;
  }
  public void drawBox(){ // draw the box for the panel
  textFont(font);
    if(selected) {
      fill(#445566);
    } else {
      fill(#333333);
    }
    stroke(#CCCC00);
    rect(posLeft, height-posTop, posWidth - 2, posTop );
    textAlign(CENTER);
    fill(#cccc00);
    rect(posLeft, height-posTop, posWidth - 2, 9);
    fill(#000000);
    text(title, (posLeft + posLeft + posWidth) / 2, height - posTop + 9);
  }
  public PImage loadPImage(){                 // loads the image for onscreen display
    pimg = super.loadPImage(zoom);
    updateme = false;
    return pimg;
  }

  public void drawOperator(char operation){
    textSize(24);
    fill(#666633);
    for(int i=0; i < 3; i ++){
      for(int j=0; j < 3; j ++){
        text( operation, i + posLeft + posWidth / 2,
                         j + height - posTop + posTop / 2);
      }
    }
    fill(#dddddd);
    text( operation, 1 + posLeft + posWidth / 2,
                     1 + height - posTop + posTop / 2);
  }
  public void drawOperator(String op){
    drawOperator(op.charAt(0));
  }


  // METHODS TO BE OVERRIDDEN BY CHILD CLASS:    
  public int calc(int x, int y, int ch){      // main calculation for each pixel
    return in.imgData[x][y][ch];
  }
  public void display(){ drawBox(); }         // draw the control panel
  public boolean update(){ return updateme; } // update self
  public void setPos(int l) { posLeft = l; }  // reposition panel controls

}


class ImgOpPalette extends ImageOp {
  HScrollbar hsr1, hsg1, hsb1; // scroll bars for determining display palette
  float r=0.0f, g=0.0f, b=0.0f;

  public ImgOpPalette (ImgData img) {
    super(img);
    setupScrollbars();
    updateme = true;
    title = "Palette";
  }
  public ImgOpPalette (ImgData img, String fn){
    super(img);
    //this.in = img;
    copyFrom(img);
    setupScrollbars();
    title = fn;
    updateme=true;
    //compute();
  }
  void display(){
    super.display();
    
    // draw the palette scrollbars
    hsr1.display();
    hsg1.display();
    hsb1.display();
  }
  void setPos(int l){
    super.setPos(l);
    hsr1.setPos(l+5);
    hsg1.setPos(l+5);
    hsb1.setPos(l+5);
  }
  boolean update(){
    float r1 = r, g1 = g, b1 = b;
    hsr1.update();
    hsg1.update();
    hsb1.update();
    r = hsr1.getVal();
    g = hsg1.getVal();
    b = hsb1.getVal();
    
    if( r != r1 || g != g1 || b != b1){
      doPalette();
      return true;
    }
    return false;
  }
  void doPalette(){     // deal with the palette scrollbars and redraw if needed
    setPalette(r,g,b);
    pimg = loadPImage(zoom); 
    //drawPalette((width - img.imgMax)/2, height -190);
  }

  void setupScrollbars(){
    hsr1 = new HScrollbar(5 + posLeft, height - posTop + 35, "Red");
    hsg1 = new HScrollbar(5 + posLeft, height - posTop + 60, "Green");
    hsb1 = new HScrollbar(5 + posLeft, height - posTop + 85, "Blue");
    hsr1.setColor(color(128,32,32));
    hsg1.setColor(color(32,96,32));
    hsb1.setColor(color(32,32,128));
    hsr1.setVal(1.0);
    hsg1.setVal(1.0);
    hsb1.setVal(1.0);
  }

}

// gamma operation
class ImgOpGamma extends ImageOp {
  HScrollbar hGamma, hOffset;   // scrollbars for gamma and epsilon
  float      gamma, offset;     // parameters from scrollbars
  //boolean    drawn = false;     // have we been drawn recently?
  public ImgOpGamma(ImgData img){
    super(img);
    title = "Gamma";
    hGamma =  new HScrollbar(posLeft + 5, height - posTop + 100, "Gamma",   0.1f, 4.0f);
    hOffset = new HScrollbar(posLeft + 5, height - posTop + 120, "Offset", -0.5f, 0.5f);
    
    hGamma.setVal(1.0f);
    hOffset.setVal(0.0f);

    hGamma.setColor(color(32,32,32));
    hOffset.setColor(color(64,64,64));
    updateme = true;
  }
  public ImgOpGamma(ImgData img, float h, float o){
    super(img);
    title = "Gamma";
    //gamma = h;
    //offset = o;
    hGamma =  new HScrollbar(posLeft + 5, height - posTop + 100, "Gamma",   0.1f, 5.0f);
    hOffset = new HScrollbar(posLeft + 5, height - posTop + 120, "Offset", -0.5f, 0.5f);
    
    hGamma.setVal(h);
    hOffset.setVal(o);

    hGamma.setColor(color(32,32,32));
    hOffset.setColor(color(64,64,64));
    
    updateme = true;
  }

  public void setPos(int l){
    super.setPos(l);
    hGamma.setPos(l + 5);
    hOffset.setPos(l + 5);
  }
  public int calc(int x, int y, int ch){
    return (int)( pow(offset + in.imgData[x][y][ch], gamma) );
  }

  public void display(){
    super.display(); //drawBox();
    //if(updateme) {
    drawGraph();
    hGamma.display();
    hOffset.display();
    //}
  }
  public void drawGraph(){   // draws the gamma curve
    stroke(#888888);
    fill(#000000);
    rect(15 + posLeft, height - posTop + 10, 64, 64);
    stroke(#222266);
    line(15 + posLeft, height - posTop + 10 + 64, 15 + posLeft+64, height-posTop + 10);
    stroke(#cccccc);
    int px, py;
    for(float i=0.0f; i < 1.0f; i += 0.01f){
      float v = pow(offset + i, gamma);
      px = (int)(posLeft + 15 + 64*i);
      py = (int)(height - posTop + 10 + 64 - constrain(64*v, 0,64));
      point(px, py);      
    }
  }
  public boolean update(){
    hGamma.update();
    hOffset.update();
    float g = hGamma.getVal();
    float o = hOffset.getVal();
    //updateme = false;

    if(gamma != g){
      gamma = g;
      updateme = true;
    }
    if(offset != o){
      offset = o;
      updateme = true;
    }
    return updateme;
  }
}

class ImgOpInvLog extends ImgOpGamma {
  HScrollbar hFactor; //, hOffset;   // scrollbars for gamma and epsilon
  float      factor; /// , offset;     // parameters from scrollbars
  public ImgOpInvLog(ImgData img){
    super(img);
    title = "log??";
    gamma = 1.0;
    offset = 0.0f;
    hFactor =  new HScrollbar(posLeft + 5, height - posTop + 100, "Factor", 0.1f, 5.0f);
    //hOffset = new HScrollbar(posLeft + 5, height - posTop + 120, "Offset");
    
    hFactor.setVal(1.0);

    hFactor.setColor(color(32,32,32));
    //hOffset.setColor(color(64,64,64));
  }
  public void setPos(int l){
    hGamma.setPos(l + 5);
    hOffset.setPos(l + 5);
    posLeft = l;
  }
  public int calc(int x, int y, int ch){
    float v = in.imgData[x][y][ch] / (float)imgMax;
    return (int)(constrain( imgMax * pow(offset + v, gamma), 0, 255) );
  }
  public void display(){
    super.display(); //drawBox();
    //if(updateme) {
      drawGraph();
      hGamma.display();
      hOffset.display();
    //}
  }
  public void drawGraph(){   // draws the gamma curve
    stroke(#888888);
    fill(#000000);
    rect(15 + posLeft, height - posTop + 10, 64, 64);
    stroke(#222266);
    line(15 + posLeft, height - posTop + 10 + 64, 15 + posLeft+64, height-posTop + 10);
    stroke(#cccccc);
    int px, py;
    for(float i=0.0f; i < 1.0f; i += 0.01f){
      float v = factor * exp(i);
      px = (int)(posLeft + 15 + 64*i);
      py = (int)(height - posTop + 10 + 64 - constrain(64*v, 0,64));
      point(px, py);      
    }
  }
  public boolean update(){
    hFactor.update();
    float f = hFactor.getVal();
    updateme = false;

    if(factor != f){
      factor = f;
      updateme = true;
    }
    return updateme;
  }
}
