class ImgOpEdgeLocal extends ImgOpSobel {
  int threshM = 200;
  float threshA = 0.1;
  int threshK = 10;
  ImgOpEdgeLocal(ImgData img){
    super(img);
    title = "Edge Local";
    imgChannels = 2;
    imgData = new int[imgWidth][imgHeight][4];
  }
  public ImgData compute(){
    //1. compute gradient magnitude and angle M(x,y) and alpha(x,y) of input image f(x,y)
    for(int y=0; y < in.imgHeight; y++){
      for(int x=0; x < in.imgWidth; x++){
        int g;
        float [] c = getMagAlpha(x,y,0);
        int magn = int(c[0]); float alph = c[1];
        int magx = int(c[2]), magy = int(c[3]);
        imgData[x][y][0] = magn;                       // Mag(x,y)
        imgData[x][y][1] = int( degrees( alph ) );     // alpha(x,y)
        imgData[x][y][2] = int( magx );                // horizontal
        imgData[x][y][3] = int( magy );                // vertical
      }
    }
    updateme = false;
    return this;
  }
  public float [] getMagAlpha(int x, int y, int ch){
    int r1s = 0, r2s = 0;
    zh = 3; zs = 0; zc = 1;
    z = zx; int[] r1 = calcFilts(x,y,ch);
    z = zy; int[] r2 = calcFilts(x,y,ch);
    for(int i=0; i < r1.length; i++){
      r1s += r1[i];
      r2s += r2[i];
    }
    float [] R = new float[4];
    R[0] = (abs(r1s) + abs(r2s));
    R[1] = atan2(r1s, r2s);
    R[2] = abs(r1s);
    R[3] = abs(r2s);
    return R;
  }
  public void display(){
    drawBox();
    fill(#cccccc);
    textAlign(LEFT);
    text("0: M(x,y)\n1: \u03b1(x,y)\n2: \u2202x\n3: \u2202y", posLeft+5, height - posTop + 20);
  }

}

class ImgOpAThresh extends ImageOp {
  int threshM;
  int threshA;
  ImgOpAThresh(ImgData img, int m, int t){
    super(img);
    title = "AThresh";
    threshM = m;
    threshA = t;
    imgChannels = 3;
    imgData = new int[in.imgWidth][in.imgHeight][imgChannels];
    imgPalette = new color[imgMax+1][imgChannels];
    updateme = true;
  }
  public ImgData compute() {
    for(int x=0; x < in.imgWidth; x++){
      for(int y=0; y < in.imgHeight; y++){
        int thX=0, thY=0;
        if( in.imgData[x][y][0] > threshM && abs( 90 - in.imgData[x][y][1] ) <= threshA ){
          thX = imgMax;
        }
        if( in.imgData[x][y][0] > threshM && abs( 0 - in.imgData[x][y][1] ) <= threshA ){
          thY = imgMax;
        }
        imgData[x][y][0] = thX;
        imgData[x][y][1] = thY;
      }
    }
    updateme = false;
    return this;
  }
  public void display(){
    drawBox();
    textAlign(LEFT);
    text( "\u03b1 "+threshA+
          "\nM > "+threshM ,
          posLeft + 5, height - posTop + 20 );
  }
}

class ImgOpHGap extends ImageOp {
  int threshK = 10;
  ImgOpHGap(ImgData img){
    super(img);
    title = "HGap";
    posWidth = 40;
  }
  public ImgData compute(){
    for(int y=0; y < in.imgHeight; y++){
      for(int x=0; x < in.imgWidth; x++){
        if(in.imgData[x][y][0] != 0){
          imgData[x][y][0] = in.imgData[x][y][0];
          boolean gap = false;
          int z = x + threshK;
          z = min(z, in.imgWidth - 1);
          for(; z > x; z--){
            if(in.imgData[z][y][0] != 0) {
              gap = true;
            }
            if(gap){
              imgData[z][y][0] = imgMax;
            }
          }
        }
      }
    }        
    updateme = false;
    return this;
  }
}
class ImgOpVGap extends ImageOp {
  int threshK = 10;
  ImgOpVGap(ImgData img){
    super(img);
    title = "VGap";
    posWidth = 40;
  }
  public ImgData compute(){
    for(int x=0; x < in.imgWidth; x++){
      for(int y=0; y < in.imgHeight; y++){
        if(in.imgData[x][y][0] != 0){
          imgData[x][y][0] = in.imgData[x][y][0];
          boolean gap = false;
          int z = y + threshK;
          z = min(z, in.imgHeight - 1);
          for(; z > y; z--){
            if(in.imgData[x][z][0] != 0) {
              gap = true;
            }
            if(gap){
              imgData[x][z][0] = imgMax;
            }
          }
        }
      }
    }        
    updateme = false;
    return this;
  }
}