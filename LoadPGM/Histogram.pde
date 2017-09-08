class ImgOpHist extends ImageOp {
  int[][] imgHist;
  int imgArea;
  int histMax[];
  float histZoom;
  PImage histPImage;
  public ImgOpHist(ImgData img){
    super(img);
    histZoom = 1.0f; //0.750f;
    title = "Histogram";
    imgHist = new int[imgMax+1][in.imgChannels];
    posWidth = (int)( 10 + imgMax * histZoom );
    imgData = in.imgData;
    imgArea = imgWidth * imgHeight;
    //imgPalette = in.imgPalette;
    copyPalette(in);
    histMax = new int[imgChannels];
    updateme = true;
  }
  public ImgData compute(){
    for(int ch=0; ch < imgChannels; ch++){
      histMax[ch] = 0;
      for(int k=0; k <= imgMax; k++){
        imgHist[k][ch] = 0;
      }
    }
    super.compute();
    updateme = false;
    histPImage = getHistPImage();
    return this;
  }
  public void printOut(){
    for(int ch=0; ch < imgChannels; ch++){
      for(int k=0; k <= imgMax; k++){
        int h = imgHist[k][ch];
        if(h == 0); //println("" + k);
        else println(""+ k +"\t = " + h );
      }
    }
    println("");
  }
  public int calc(int x, int y, int ch){
    int v = in.imgData[x][y][ch];
    if(v > imgMax) v = imgMax;
    imgHist[v][ch]++;
    if(histMax[ch] < imgHist[v][ch]) histMax[ch] = imgHist[v][ch];
    return in.imgData[x][y][ch];
  }
  public PImage getHistPImage(){
    //int dk = zoomOut;
    PImage p;
    int h = posTop - 20;
    p = createImage( imgMax + 1, h+1, RGB );
    p.loadPixels();
    for(int ch=0; ch < imgChannels; ch++){
      color c1 = #333333;
      color c2 = imgPalette[imgMax][ch];
      int v;
      float sc = (h - 1) / (float)(histMax[ch]+1);
      for(int x=0; x < p.width; x++){
        //v = 0;
        //for(int dx=0; dx < zoomOut; dx++){
        v = imgHist[x][ch];
        //}
        v *= sc;
        for(int y = p.height - 1; y > (p.height - v - 1); y--){
          p.pixels[ constrain(y,0,p.height-1) * p.width + x ] += c2;
        }
      }//horizontal

    }//channels

    p.updatePixels();
    return p;
  }
  public void display(){
    if(histPImage == null) histPImage = getHistPImage();
    drawBox();
    int h = posTop - 20;
    int y = height - 5;
    
    float sc = histZoom;
    scale(sc, 1.0);
    image(histPImage, (posLeft + 4) * (1.0 / sc), (height - posTop + 15) );
    scale(1.0 / sc, 1.0);
    //scale(1.0, 1.0);
  }
  public boolean update(){
    boolean r = updateme;
    updateme = false;
    return r;
  }
}

public class ImgOpHistEq extends ImageOp {
  int[][] imgProb;
  float[][] imgTransform;
  float imgInc, imgArea;
  PImage pimgGraph;

  public ImgOpHistEq(ImgData img){
    super(img);
    title = "Equalize";
    posWidth = 84;
    imgProb = new int[imgMax+1][imgChannels];
    imgTransform = new float[imgMax+1][imgChannels];
  }
  public ImgData compute(){
    imgArea = imgWidth * imgHeight;
    imgInc = 1.0f / (float) imgArea;
    for(int ch=0; ch < imgChannels; ch++){
      for(int k=0; k <= imgMax; k++){
        imgProb[k][ch] = 0;
        imgTransform[k][ch] = 0;
      }
    }
    
    // get probability
    for(int ch=0; ch < imgChannels; ch++){
      for(int y=0; y < imgHeight; y++){
        for(int x=0; x < imgWidth; x++){
          int v = in.imgData[x][y][ch];
          imgProb[v][ch]++;
        }
      }
    }
    
    for(int ch=0; ch < imgChannels; ch++){
      for(int k=0; k <= imgMax; k++){
        for(int j=0; j <= k; j++){
          imgTransform[k][ch] += imgProb[j][ch];
        }
        imgTransform[k][ch] /= (float)imgArea;
        //println("" + ( imgTransform[k][ch] / (float)imgArea ) );
      }
    }
    for(int ch=0; ch < imgChannels; ch++){
      for(int y=0; y < imgHeight; y++){
        for(int x=0; x < imgWidth; x++){
          int v = in.imgData[x][y][ch];
          imgData[x][y][ch] = (int)( imgTransform[v][ch] * imgMax );
        }
      }
    }
    //exit();

    updateme = false;
    pimgGraph = getGraphPImage();
    return this;
  }

  public PImage getGraphPImage(){   // draws the gamma curve
    int px, py;
    float inc = 1.0f / (float) imgMax;
    PImage p = createImage(64, 64, RGB);
    p.loadPixels();
    for(int ch=0; ch < imgChannels; ch++){
      for(float i=0.0f; i < 1.0f; i += inc){
        int c = (int)constrain(imgMax * i, 0, imgMax);
        float v = imgTransform[ c ][ch];
        px = (int)( p.width * i );
        py = (int)( constrain(p.height - p.height*v , 0,64) );
        p.pixels[ p.width - px + p.width * px] = #333333;
        p.pixels[ constrain(px + p.width * py, 0, p.pixels.length - 1)] += imgPalette[imgMax][ch];
      }
    }
    p.updatePixels();
    return p;
  }

  public void display(){
    drawBox();
    //if(pimgGraph == null) pimgGraph = getGraphPImage();
    //drawGraph();
    image(pimgGraph, posLeft - 32 + (posWidth) / 2 , height - posTop + 20);
  }
}
