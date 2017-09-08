class ImgData {
  protected int       imgWidth, imgHeight,  // width / height
                      imgChannels, imgMax; // channels / maximum pixel value
  protected int[][][] imgData;            // image data is stored here
  protected color[][] imgPalette;        // image palette is stored here - for display purposes
  protected float     imgScale;         // factor to convert to float for palette
  protected PImage    pimg;            // native image object for display on screen

  public String toString(){
    return ""; //"[" + imgWidth + "x" + imgHeight + "/" + imgChannels + "]";
  }
  public ImgData(){}
  public void ImgDataInit(ImgData in){
    imgChannels = in.imgChannels;
    imgWidth = in.imgWidth;
    imgHeight = in.imgHeight;
    imgMax = in.imgMax;
    imgScale = in.imgScale;

    //System.out.println("Instantiated "+imgWidth+"x"+imgHeight+"."+imgChannels);
  }
  public ImgData(ImgData in){
    ImgDataInit(in);
    
    imgData = new int[imgWidth][imgHeight][imgChannels];
    pimg = new PImage(imgWidth * zoom, imgHeight * zoom);
    imgPalette = new color[imgMax+1][imgChannels];
  }
  // copy pixel and palette data from an existing image
  public void copyFrom(ImgData in){
    copyPalette(in);
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        for(int ch=0; ch < imgChannels; ch++){
          imgData[x][y][ch] = in.imgData[x][y][ch];
        }
      }
    }
  }
  public void copyPalette(ImgData in){
    imgPalette = new color[imgMax + 1][in.imgChannels];
    for(int ch = 0; ch < in.imgChannels; ch++){
      for(int i=0; i <= imgMax; i++){
        imgPalette[i][ch] = in.imgPalette[i][ch];
      }
    }    
  }
  // draws the image to the display
  public void draw(){
    image(pimg, 0,0);
  }
  
  // prepares the PImage for display
  public PImage loadPImage(){
    int x,y;
    if( pimg == null ) {
      pimg = new PImage(imgWidth, imgHeight);
    }
    pimg.loadPixels();
    if( imgChannels == 1 ){
      for(int i=0; i< pimg.pixels.length; i++){
        x = i % imgWidth;
        y = i / imgWidth;
        pimg.pixels[i] = imgPalette[ imgData[x][y][0] ][ 0 ];
      }
    } else if( imgChannels >= 3 ){
      color c;
      for(int i=0; i< pimg.pixels.length; i++){
        x = i % imgWidth;
        y = i / imgWidth;
        c = getBlend(x,y);
        pimg.pixels[i] = c;
        print(c);
      }     
    }
    pimg.updatePixels();
    return pimg;
  }
  public color getBlend(int x, int y){
    color c0, c1, c2, c3, c4;
    int ch0, ch1, ch2;
    ch0 = constrain(imgData[x][y][0], 0, 255);
    ch1 = constrain(imgData[x][y][1], 0, 255);
    ch2 = constrain(imgData[x][y][2], 0, 255);
    c0 = imgPalette[ ch0 ][ 0 ];
    c1 = imgPalette[ ch1 ][ 1 ];
    c2 = imgPalette[ ch2 ][ 2 ];
    c3 = blendColor(c0, c1, ADD);
    c4 = blendColor(c2, c3, ADD);
    return c4;
  }
  public PImage loadPImage(int zoom){
    pimg = new PImage(imgWidth * zoom, imgHeight * zoom);
    //println("PIMG " + (imgWidth) * zoom + "x" + (imgHeight * zoom));
    pimg.loadPixels();
    if(imgChannels == 1){
      for(int y=0; y < imgHeight; y++){
        for(int x=0; x < imgWidth; x++){
         int col = imgData[x][y][0];
         col = constrain(col, 0, imgMax);

          for(int z2=0; z2 < zoom; z2++){
            for(int z1=0; z1 < zoom; z1++){
              int loc = (imgWidth*zoom) * (y*zoom+z2) + (x*zoom) + z1;
              pimg.pixels[ loc ] = imgPalette [ col ][0];
            }
          }
        }
      }
    } else if(imgChannels == 2){ // complex data
      for(int y=0; y < imgHeight; y++){
        for(int x=0; x < imgWidth; x++){
          int c1 = imgData[x][y][0];
          int c2 = imgData[x][y][1];
          colorMode(HSB, 360);
          color c = color( c2 + 180, constrain( 60 + c1, 0, 360 ), constrain( c1, 0, 360 ) );

          for(int z2=0; z2 < zoom; z2++){
            for(int z1=0; z1 < zoom; z1++){
              int loc = (imgWidth*zoom) * (y*zoom+z2) + (x*zoom) + z1;
              pimg.pixels[ loc ] = c;
              //print(c);
            }
          }
          
        }
      }
      colorMode(RGB, 255);

    } else if(imgChannels >= 3){
      for(int y=0; y < imgHeight; y++){
        for(int x=0; x < imgWidth; x++){
         int col = imgData[x][y][0];
         col = constrain(col, 0, imgMax);

          for(int z2=0; z2 < zoom; z2++){
            for(int z1=0; z1 < zoom; z1++){
              int loc = (imgWidth*zoom) * (y*zoom+z2) + (x*zoom) + z1;
              color c = getBlend(x,y);
              pimg.pixels[ loc ] = c;
              //print(c);
            }
          }
        }
      }
      
    }
    pimg.updatePixels();
    return pimg;    
  }
  // set the display palette for an image based on rgb ? [ -1.0 , 1.0 ]
  public void setPalette(float r, float g, float b) {
    for(int ch=0; ch < imgChannels; ch++){
      setPalette(ch, r, g, b);
    }
  }
  // set the palette for one channel
  public void setPalette(int ch, float r, float g, float b) {
    for(int i=0; i <= imgMax; i++){
      int vr = getPalValue(i,r);
      int vg = getPalValue(i,g);
      int vb = getPalValue(i,b);
      imgPalette[i][ch] = color(vr,vg,vb);
    }
  }
  // calculates the correct value for a given index in the palette
  public int getPalValue(int index, float val){
    float fr;
    if(val<0) fr = -val * imgScale * (float)(imgMax - index);
    else      fr =  val * imgScale * (float)index;
    return (int)fr;
  }
  // draws the palette to the screen for the first channel
  public void drawPalette(int x, int y){
    fill(0);
    noStroke();
    //rect(x, y, x+imgMax, y+20);
    for(int i=0; i <= imgMax; i++){
      color c = imgPalette[imgMax - i][0];
      stroke(c);
      line(x+i, y, x+i, y+20);
    }
    for(int i=0; i <= imgMax; i++){
      color c = imgPalette[i][0];
      stroke(c);
      line(x+i, y+5, x+i, y+15);
    }
  }
  // prints the palette out to stdout
  public void printPalette(){
    for(int i=0; i<= imgMax; i++){
      color c = imgPalette[i][0];
      System.out.print(hex(c));
    }
    System.out.print("\n\n");
  }
  // getter methods
  public int getHeight(){ return imgHeight; }
  public int getWidth() { return imgWidth; }
  public PImage getPImage(){ return pimg; }

}
