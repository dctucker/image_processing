class ImgOpChannel extends ImageOp {
  int channel = 0;
  public ImgOpChannel( ImgData img ){
    super(img);
    title = "Ch";
    imgChannels = 1;
    updateme = true;
    posWidth = 40;
    setPalette(1.0, 1.0, 1.0);
  }
  public ImgOpChannel( ImgData img, int ch){
    super(img);
    posWidth = 40;
    channel = ch;
    title = "Ch";
    imgChannels = 1;
    updateme = true;
    setPalette(0, 1.0, 1.0, 1.0);

  }
  public ImgData compute(){
    for(int y = 0; y < imgHeight; y++){
      for(int x = 0; x < imgWidth; x++){
        imgData[x][y][0] = calc(x, y, channel);
      }
    }
    updateme = false;
    return this;
  }
  public int calc(int x, int y, int ch){
    //if(ch < in.imgChannels)
    if(ch < in.imgData[x][y].length) 
    return in.imgData[x][y][ch];
    else return -1;
  }
  public void display(){
    super.display();
    fill(#ffffff);
    textSize(24);
    text(""+channel, (posLeft + posWidth + posLeft) / 2, (height + height - posTop) / 2);
  }
    
}

class ImgOpColor extends ImageOp {
  public ImgOpColor (ImgData img) {
    super(img);
    //setupScrollbars();
    title = "Color";
    doPalette();
    updateme = true;
  }
  public ImgOpColor (ImgData img, String fn){
    super(img);
    //this.in = img;
    copyFrom(img);
    //setupScrollbars();
    title = fn;
    updateme=true;
    //doPalette();
    //compute();
  }
  /*
  void display(){
    super.display();
    
    // draw the palette scrollbars
    hsr1.display();
    hsg1.display();
    hsb1.display();
  }
  */
  /*
  void setPos(int l){
    super.setPos(l);
    hsr1.setPos(l+5);
    hsg1.setPos(l+5);
    hsb1.setPos(l+5);
  }
  */
  boolean update(){
    /*
    float r1 = r, g1 = g, b1 = b;
    hsr1.update();
    hsg1.update();
    hsb1.update();
    r = hsr1.getVal();
    g = hsg1.getVal();
    b = hsb1.getVal();
    */
    //if( r != r1 || g != g1 || b != b1){
    if(updateme){
      doPalette();
      return true;
    }
    //}
    return false;
  }
  void doPalette(){     // deal with the palette scrollbars and redraw if needed
    //setPalette( 1.0, 1.0, 1.0 );
    setPalette(0, 1.0, 0.0, 0.0);
    setPalette(1, 0.0, 1.0, 0.0);
    setPalette(2, 0.0, 0.0, 1.0);

    pimg = loadPImage(zoom); 
    //drawPalette((width - img.imgMax)/2, height -190);
  }

  /*
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
  */

}

class ImgOpSubst extends ImageOp {
  ImgData in1, in2;
  int subst;
  ImgOpSubst(ImgData img, ImgData img2){
    super(img);
    title = "Subst";
    posWidth = 40;
    in1 = img;
    in2 = img2;
    in = in1;
    subst = 0;
    updateme = true;
  }
  ImgOpSubst(ImgData img, ImgData img2, int s){
    super(img);
    title = "Subst";
    posWidth = 40;
    in1 = img;
    in2 = img2;
    in = in1;
    subst = s;
    updateme = true;
  }  
  public ImgData compute(){
    for(int ch=0; ch < imgChannels; ch++){
      for(int y=0; y < imgHeight; y++){
        for(int x=0; x < imgWidth; x++){
          if(ch != subst)
            imgData[x][y][ch] = in.imgData[x][y][ch];
          else 
            imgData[x][y][ch] = in2.imgData[x][y][0];
        }
      }
    }
    updateme = false;
    return this;
  }
}


class ImgOpHSItoRGB extends ImageOp {
  public ImgOpHSItoRGB(ImgData img){
    super(img);
    title = "RGB";
    posWidth = 40;
    imgMax = 255;
    imgChannels = 4;
    setPalette(0, 1.0, 0.0, 0.0);
    setPalette(1, 0.0, 1.0, 0.0);
    setPalette(2, 0.0, 0.0, 1.0);

    updateme = true;
  }
  public ImgData compute(){
    for(int y=0; y < imgHeight; y++){
      for(int x=0; x < imgWidth; x++){
        float k = in.imgMax;
        float r, g, b;
        float h, s, i;
        float t;
        int H;
        
        h = in.imgData[x][y][0] / k;
        s = in.imgData[x][y][1] / k;
        i = in.imgData[x][y][2] / k;
        
        H = int(h * 360) % 360;
        
        if( 0 <= H && H < 120 ){
          b = i * (1 - s);
          r = i * ( 1 + ( s * cos(radians(H)) / cos( radians(60 - H) ) ) );
          g = 3 * i - (r + b);
        } else if( 120 <= H && H < 240 ){
          H -= 120;
          r = i * (1 - s);
          g = i * ( 1 + ( s * cos(radians(H)) / cos( radians(60 - H) ) ) );
          b = 3 * i - (r + g);
          
        } else if( 240 <= H && H < 360) { // 240 to 360 deg
          H -= 240;
          g = i * (1 - s);
          b = i * ( 1 + ( s * cos(radians(H)) / cos( radians(60 - H) ) ) );
          r = 3 * i - (g + b);
        } else {
          r = -1000;
          g = -1000;
          b = -1000;
        }
        
        
        imgData[x][y][0] = int( r * imgMax );
        imgData[x][y][1] = int( g * imgMax );
        imgData[x][y][2] = int( b * imgMax );
        //imgData[x][y][3] = imgMax;
      }
    }
    updateme = false;
    loadPImage(zoom);
    return this;
  }
}

class ImgOpRGBtoHSI extends ImageOp {
  public ImgOpRGBtoHSI(ImgData img){
    super(img);
    title = "HSI";
    posWidth = 40;
    imgMax = 359;
    imgChannels = 3;
    
    imgPalette = new color[imgMax + 1][imgChannels];
    setPalette(0, -0.2,  0.0,  0.2);
    setPalette(1,  0.2,  0.0, -0.2);
    setPalette(2,  0.5,  0.5,  0.5);

    updateme = true;
  }
  public ImgData compute(){
    for(int y=0; y < imgHeight; y++){
      for(int x=0; x < imgWidth; x++){
        float k = in.imgMax;
        float r, g, b;
        float h, s, i;
        float t;
        
        r = in.imgData[x][y][0] / k;
        g = in.imgData[x][y][1] / k;
        b = in.imgData[x][y][2] / k;
        
        t = acos(     (  0.5f * ( (r - g) + (r - b) )  )
                   /  sqrt( sq(r - g) + (r - b)*(g - b) )
                );
        h = ( (b <= g) ? degrees(t) : 360 - degrees(t) ) / 360f;
        s = 1 - ( 3 * min(r, g, b) / (r + g + b) );
        i = (r + g + b) / 3;
        
        imgData[x][y][0] = int( h * imgMax );
        imgData[x][y][1] = int( s * imgMax );
        imgData[x][y][2] = int( i * imgMax );
      }
    }
    updateme = false;
    return this;
  }

}
