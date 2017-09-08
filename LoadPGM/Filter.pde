public class ImgOpFilter extends ImageOp {
  int[] z;     // filter
  int zh;      // filter width, height
  int zc;      // filter center
  int zs;      // sum of filter components
  int th = 15;
  int tw = 15;
  
  public ImgOpFilter(ImgData img){
    super(img);
    title = "Filter";
    defaultFilter();
    posWidth = tw * (zh + 2);
  }
  public ImgOpFilter(ImgData img, int[] f){
    super(img);
    title = "Filter";
    setFilter(f);    
    posWidth = tw * (zh + 2);
    updateme = true;
  }
  public void defaultFilter(){
    int[] f = new int[9];
    for(int a=0; a < 9; a++) f[a] = 1;
    setFilter(f);
  }
  public void setFilter(int[] f){
    zs = 0;
    zh = int( sqrt( f.length ) );
    zc = zh / 2;
    z = new int[zh*zh];
    for(int a=0; a < z.length; a++){
      z[a] = f[a];
      zs += z[a];
    }
    posWidth = tw * (zh + 2);

  }
  public int calc(int x, int y, int ch){
    int v=0;
    int[] r = calcFilts(x, y, ch);
    int v1 = 0;
    for(int a=0; a < zh*zh; a++){
      if(v >= Integer.MAX_VALUE / 2) {
        v1 += v / ( (zs == 0) ? 1 : zs );
        v = 0;
      }
      v += r[a];
    }
    v1 += v / ( (zs == 0) ? 1 : zs );
    return v1 ;
  }
  public int[] calcFilts(int x, int y, int ch){
    int[] r = new int[zh*zh];
    int v = 0;
    for(int b=0; b < zh; b++){
      for(int a=0; a < zh; a++){
        int x2 = x - zc + a;
        int y2 = y - zc + b;
        int data;
        if( x2 < 0 || y2 < 0 || x2 >= imgWidth || y2 >= imgHeight ) data = 0;
        else data = in.imgData[x2][y2][ch];
        r[ a * zh + b ] = data * z[ a * zh + b ];
        //print("" + x2 + "," + y2 + " ");
      }
      //println("");
    }
    //println("");
    return r;
  }
  public void drawFilter(int[] z, int topY){
    fill(#dddddd);
    stroke(#dddddd);
    int sw = tw * zh;
    int sh = th * zh;
    int sx = posLeft + posWidth / 2 - sw / 2 + tw / 2;
    int sy = height - posTop + topY;
    //hThresh.display(color(32,32,32));
    textAlign(CENTER);
    for(int a=0; a < zh; a++){
      for(int b=0; b < zh; b++){
        text("" + z[ a * zh + b ], a * tw + sx, b * th + sy  );
      }
    }
    line( sx - tw , sy - th            , sx - tw     , sy + (th - 2) * zh  );
    line( sx - tw , sy - th            , sx - tw + 3 , sy - th             );
    line( sx - tw , sy + (th - 2) * zh , sx - tw + 3 , sy + (th - 2) * zh  );

    line( sx + (tw - 1) * zh + 3 , sy - th            , sx + (tw - 1) * zh + 3, sy + ( th - 2) * zh  );
    line( sx + (tw - 1) * zh     , sy - th            , sx + (tw - 1) * zh + 3, sy - th              );
    line( sx + (tw - 1) * zh     , sy + (th - 2) * zh , sx + (tw - 1) * zh + 3, sy + ( th - 2) * zh  );
    
  }
  public void display(){
    drawBox();
    drawFilter(z, 40);
  }
/*  public boolean update(){
    //compute();
    //updateme = false;
    return false;
  }*/

}

public class ImgOpZeroCrossing extends ImgOpFilter {
  public ImgOpZeroCrossing(ImgData img){
    super(img);
    title = "Zero Crossing";
    
  }
}

public class ImgOpGaussian extends ImgOpFilter{
  int[] gf = { 1 ,  4 ,  7 ,  4 , 1 ,
               4 , 16 , 26 , 16 , 4 ,
               7 , 26 , 41 , 26 , 7 ,
               4 , 16 , 26 , 16 , 4 ,
               1 ,  4 ,  7 ,  4 , 1 };
  float sigma;

  public ImgOpGaussian(ImgData img){
    super(img);
    title = "Gaussian";
    updateme = true;
    //setFilter(gf);
  }
  public ImgOpGaussian(ImgData img, int M, float sig){
    super(img);
    title = "Gaussian";
    sigma = sig;
    zh = M;
    if(Float.isNaN(sigma)) sigma = 0.8408964f; else println(sigma);
    if(zh == 0) zh = 3;
    calcGaussian();
    updateme = true;
  }
  public float G(int x, int y){
    //float sigma = 0.84089642f; // 1.0f; //zh / 3.0f;
    return exp( - (x*x + y*y) / ( 2.0f * sq(sigma) ) ) / (TWO_PI * sq(sigma)) ;
  }
  public void defaultFilter(){
    zh = 3;
    sigma = 0.84089642f;
    calcGaussian();
  }
  public void calcGaussian(){
    zc = zh / 2;
    gf = new int[zh*zh];
    //    sigma = 0.84089642f;

    
    float scval = G(-zc, -zc) ;

    for(int i=0; i < zh; i++){
      for(int j = 0; j < zh; j++){
        int x = i - zc, y = j - zc;
        float v = G(x, y); //( 1 / (TWO_PI * sq(sigma)) ) * exp( - (x*x + y*y) / ( 2 * sq(sigma) ) );
        gf[i * zh + j] = int(v / scval);
        print("" + nf(v, 1, 5) + "\t");
      }
      println("");
    }
    setFilter(gf);
  }
}

public class ImgOp5x5 extends ImgOpFilter {
  int[] avgf = { 1 , 1 , 1 , 1 , 1 ,
                 1 , 1 , 1 , 1 , 1 ,
                 1 , 1 , 1 , 1 , 1 ,
                 1 , 1 , 1 , 1 , 1 ,
                 1 , 1 , 1 , 1 , 1 };

  public ImgOp5x5(ImgData img){
    super(img);
    title = "5x5";
    setFilter(avgf);
  }
}

public class ImgOpFilter2 extends ImgOpFilter {
  public ImgOpFilter2(ImgData img){
    super(img);
    title = "Filter2";
    updateme = true;
    posWidth = tw * 5;
  }
}

public class ImgOpSobel extends ImgOpFilter2 {

  int[] gx = { -1 ,  0 ,  1 ,
               -2 ,  0 ,  2 ,
               -1 ,  0 ,  1 };

  int[] gy = { -1 , -2 , -1 , 
                0 ,  0 ,  0 ,
                1 ,  2 ,  1 };
  int[] zx;
  int[] zy;

  public ImgOpSobel(ImgData img){
    super(img);
    title = "Sobel";
    updateme = true;
    posWidth = tw * 5;
    defaultFilter();
  }

  public void defaultFilter(){
    zx = gx;
    zy = gy;
  }

  public int calc(int x, int y, int ch){
    int r1s = 0, r2s = 0;
    zh = 3; zs = 0; zc = 1;
    z = zx; int[] r1 = calcFilts(x,y,ch);
    z = zy; int[] r2 = calcFilts(x,y,ch);
    for(int i=0; i < r1.length; i++){
      r1s += r1[i];
      r2s += r2[i];
    }
    return /*imgData[x][y][ch] =*/ abs(r1s) + abs(r2s);
  }
  public void display(){
    drawBox();
    drawFilter(zx,  40);
    drawFilter(zy, 110);
    textAlign(CENTER);
    text("¶/¶x", posLeft + posWidth / 2, height - posHeight + 20);
    text("¶/¶y", posLeft + posWidth / 2, height - posHeight + 90);
  }  
}

public class ImgOpPrewitt extends ImgOpSobel {
  int[] gx1 ={ -1 , -1 , -1 , 
                0 ,  0 ,  0 ,
                1 ,  1 ,  1 };

  int[] gy1 ={ -1 ,  0 ,  1 ,
               -1 ,  0 ,  1 ,
               -1 ,  0 ,  1 };
  public ImgOpPrewitt(ImgData img){
    super(img);
    title = "Prewitt";
    defaultFilter();
  }
  public void defaultFilter(){
    zx = gx1;
    zy = gy1;
  }
}

//public ImgOpRoberts extends ImgOpFilter2 {
//}

public class ImgOpLoG extends ImgOpFilter {
  public ImgOpLoG(ImgData img){
    super(img);
    title = "LoG";
    
  }
//  public 
}

public class ImgOpMedian extends ImgOpFilter {
  public ImgOpMedian(ImgData img){
    super(img);
    title = "Median";
  }
  public int calc(int x, int y, int ch){
    int[] r = sort( calcFilts(x, y, ch) );
    return r[r.length/2];
  }
}

class ImgOpGMean extends ImgOp5x5 {
  public ImgOpGMean(ImgData img){
    super(img);
    title = "G.Mean";
  }
  public int calc(int x, int y, int ch){
    int[] r = calcFilts(x, y, ch);
    float mn = 1.0f / (float)(r.length);

    float prod = pow(r[0], mn);
    for(int i=1; i < r.length; i++){
      prod *= pow(r[i], mn);
    }
    //if(prod == 0.0f) return 0;
    //println(""+prod);
    return int(prod);
  }
  public void display(){
    drawBox();
    drawOperator("¸");
    textAlign(CENTER);
    textSize(11);

    textSize(10);
    text("g (s,t)", posLeft + 3 * posWidth / 4, height - posTop / 2);
    text("mn", posLeft + posWidth / 4, height - posTop / 2 - 12);
    
    textSize(32);
    text(""+((char)0x23B7) , posLeft + posWidth / 3, height - posTop / 2 + 2);

    
    textSize(8);
    text("r", posLeft + 3 * posWidth / 4 - 5, height - posTop / 2 + 2);
    text("s,t"+((char)0x2208)+"S", posLeft + posWidth / 2, height - posTop / 2 + 10);
    textSize(7);
    text("xy", 16 + posLeft + posWidth/2, height - posTop / 2 + 12);    

  }
}

class ImgOpAMean extends ImgOp5x5 {
  int d;
  ImgOpAMean(ImgData img){
    super(img);
    title = ""+ ((char) 0x03B1)+"trimMean";
    d = 5;
  }
  public int calc(int x, int y, int ch){
    int [] r = sort( calcFilts(x, y, ch) );
    int sum=0;
    for(int i= d / 2 - 1; i < r.length - d / 2; i++){
       sum += r[i];
    }
    return sum / (r.length - d);
  }
  public void display(){
    drawBox();
    drawOperator("·");
    textAlign(CENTER);
    textSize(11);
    text("d="+d, posLeft + posWidth / 2, height - 20);
    text("1",     posLeft + posWidth / 4, height - posTop / 2 - 10);
    line( posLeft + posWidth / 4 - 15, height - posTop / 2 - 8, posLeft + posWidth / 4 + 15, height - posTop / 2 - 8);
    text("mn-d",  posLeft + posWidth / 4, height - posTop / 2 + 2);
    textSize(10);
    text("g (s,t)", posLeft + 3 * posWidth / 4, height - posTop / 2);
    
    textSize(8);
    text("r", posLeft + 3 * posWidth / 4 - 5, height - posTop / 2 + 2);
    text("s,t"+((char)0x2208)+"S", posLeft + posWidth / 2, height - posTop / 2 + 10);
    textSize(7);
    text("xy", 16 + posLeft + posWidth/2, height - posTop / 2 + 12);
  }
    
}

public class ImgOpLaplacian extends ImgOpFilter {
  public ImgOpLaplacian(ImgData img){
    super(img);
    title = "Laplacian";
  }
  public ImgOpLaplacian(ImgData img, int filt){
    super(img);
    switch(filt) {
      case 1:
        defaultFilter();
        break;
      case 2:
        defaultFilter2();
        break;
      case 3:
        defaultFilter3();
        break;
      case 4:
        defaultFilter4();
        break;
    }

    title = "Laplacian";
  }
  public void display(){
    super.display();
    textAlign(CENTER);
    text("" + (char)(0x2207) + "" + (char)(0x00B2), posLeft + posWidth / 2, height - posTop + 20);
  }
  public void defaultFilter(){
    int[] r = new int[9];
    r[0] =  0; r[1] = -1; r[2] =  0;
    r[3] = -1; r[4] =  4; r[5] = -1;
    r[6] =  0; r[7] = -1; r[8] =  0;
    setFilter(r);
  }
  public void defaultFilter2(){
    int[] r = new int[9];
    r[0] = -1; r[1] = -1; r[2] = -1;
    r[3] = -1; r[4] =  8; r[5] = -1;
    r[6] = -1; r[7] = -1; r[8] = -1;
    setFilter(r);
  }
  public void defaultFilter3(){
    int[] r = new int[9];
    r[0] =  0; r[1] =  1; r[2] =  0;
    r[3] =  1; r[4] = -4; r[5] =  1;
    r[6] =  0; r[7] =  1; r[8] =  0;
    setFilter(r);
  }
  public void defaultFilter4(){
    int[] r = new int[9];
    r[0] =  1; r[1] =  1; r[2] =  1;
    r[3] =  1; r[4] = -8; r[5] =  1;
    r[6] =  1; r[7] =  1; r[8] =  1;
    setFilter(r);
  }
  public ImgData compute(){
    super.compute();
    //computeScale();
    updateme = false;
    return this;
  }
  public int calc(int x, int y, int ch){
    return /*in.imgData[x][y][ch] - z[1] * */ super.calc(x, y, ch);
  }
}

public class ImgOpSharp extends ImgOpFilter {
  HScrollbar hK;
  int k;
  public ImgOpSharp(ImgData img){
    super(img);
    title = "Sharpen";
    defaultFilter();
    hK = new HScrollbar(5 + posLeft, height - posTop + 35, "k", 1, 8);
    hK.setColor(color(32,32,128));
    k = 1;
    hK.setVal(k);
    updateme = true;
  }
  public void defaultFilter(){
    int[] f = new int[9];
    f[0]= 1; f[1]= 2; f[2]= 1;
    f[3]= 2; f[4]= 4; f[5]= 2;
    f[6]= 1; f[7]= 2; f[8]= 1;
    setFilter(f);
  }
  public boolean update(){
    hK.update();
    int hk = (int)(hK.getVal() );
    if(k != hk) {
      k = hk;
      updateme = true;
      return true;
    }
    return false;
  }
  public ImgData compute(){                    // this one can be overridden if necessary
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        for(int ch=0; ch < imgChannels; ch++){
          if(!chBypass[ch]){
            int f = in.imgData[x][y][ch];
            int fblur = calc(x,y,ch);
            int gmask = f - fblur;
            imgData[x][y][ch] = f + k * gmask;
          }
        }
      }
    }
    computeScale();
    updateme = true;
    return this;
  }
  public void display(){
    drawBox();
    hK.display();
  }
  public void setPos(int l){
    super.setPos(l);
    hK.setPos(l + 5);
  }
}
