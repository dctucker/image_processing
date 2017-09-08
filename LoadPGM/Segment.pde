class ImgSegGThresh extends ImgOpHist {
  //int [][] imgHist;
  int dThresh = 5, T;
  public ImgSegGThresh(ImgData img){
    super(img);
    title = "Local Thresh";
    //imgHist = new int[imgMax+1][imgChannels];
    imgChannels = 1;
    imgData = new int[in.imgWidth][in.imgHeight][2];
    updateme = true;
  }
  public ImgData compute(){
    
    int ch = 0;
    /*
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        int v = in.imgData[x][y][ch];
        imgHist[v][ch]++;
        if(histMax[ch] < imgHist[v][ch]) histMax[ch] = imgHist[v][ch];
      }
    }
    */
    super.compute();
    
    int nT, dT = imgMax;
    int G1, G2, C1, C2, m1, m2;
    T = imgMax / 2;
   
    while(dT > dThresh){
      G1=0; C1=0;
      for(int v=0; v <= T; v++){
        G1 += imgHist[v][ch] * v;
        C1 += imgHist[v][ch];
      }
      if(C1 != 0) m1 = G1 / C1; else m1 = 0;

      G2=0; C2=0;
      for(int v=T+1; v < imgMax; v++){
        G2 += imgHist[v][ch] * v;
        C2 += imgHist[v][ch];
      }
      if(C2 != 0) m2 = G2 / C2; else m2 = 0;

      nT = (m1 + m2) / 2;
      dT = abs(nT - T);
      println("dT="+dT);
      T = nT;
    }
    // now segment
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        imgData[x][y][0] = (in.imgData[x][y][ch]  > T) ? imgMax : 0;
        imgData[x][y][1] = (in.imgData[x][y][ch] <= T) ? imgMax : 0;
      }
    }
    //histPImage = getHistPImage();

    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    //drawBox();
    textAlign(LEFT);
    fill(#cccccc);
    text("T=" + T + "\n0:G_1\n1:G_2" ,
         posLeft + 5, height - posTop + 20);
    stroke(#ff00ff);
    line(posLeft + 5 + T, height - posTop + 15, posLeft+5+T, height - posTop + 50);
  }
}

class ImgNoiseHist extends ImgOpHist {
  //int T, sigma, zbar;
  float zbar, sigma;
  int maxK, maxL;
  ImgNoiseHist(ImgData img){
    super(img);
    title = "Noise Hist";
    zbar = imgMax / 2;
    updateme = true;
  }
  public ImgData compute(){
    super.compute();
    maxK = 0; maxL = 0;
    for(int l=0; l <= imgMax; l++){
      int k = imgHist[l][0];
      if( k > maxK ){
        maxK = k;
        maxL = l;
      }
    }
    /// new code begin
    int zbarsum=0;
    for(int l=0; l <= imgMax; l++){
      zbarsum += l * imgHist[l][0];
    }
    float zbf = zbarsum / (float)(in.imgWidth * in.imgHeight);
    
    println("calculated zbar = " + zbf);
    
    int sigma2sum = 0;
    for(int l=0; l <= imgMax; l++){
      sigma2sum += sq( l - zbf ) * imgHist[l][0];
    }
    float s2f = sigma2sum / (float)(in.imgWidth * in.imgHeight);
    //sigma2sum /= in.imgWidth * in.imgHeight;
    println("calculated sigma = " + sqrt(s2f) );
    
    
    
    /*
    /// old code begin
    maxK = min( imgHist[maxL][0], imgHist[maxL - 1] [0], imgHist[maxL + 1][0] );
    
    T = maxL;
    for(int l=0; l <= imgMax; l++){
      int k = imgHist[l][0];
      if( k >= 0.607 * maxK ){
        zbar = k;
      }
    }
    for(int l=T; l <= imgMax; l++){
      int k = imgHist[l][0];
      if( k < zbar ){
        sigma = l - T - 2;
        break;
      }
    }
    */
    
    zbar = zbf ;
    sigma = sqrt( s2f );
    
    
    //printGauss();
    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    textAlign(LEFT);
    fill(#cccccc);
    text("z"+(char)(0x0305)+"="+ zbar +"\n"+ ((char)0x03C3) + "=" + sigma,
          posLeft+5, height - posTop + 20 );
    stroke(#ff00ff);
    line(zbar + 5 + posLeft, height - posTop + 10, zbar+5+posLeft, height);
    line(zbar - sigma + 5 + posLeft, height - 5, zbar + sigma+5+posLeft, height - 5);
    drawGauss();
  }
  float p(float z){
    return exp( - sq( z - zbar ) / ( 2 * sq(sigma) ) ) / (float)( sqrt(TWO_PI) * sigma );
  }
  public void printGauss(){
    for(int l = 0; l <= imgMax; l++){
      float y1 = maxK * p( (float)l ) * (sqrt(TWO_PI) * sigma);
      println( "" + l + ":" + y1 );
    }
  }
  public void drawGauss(){
    stroke(#FF0022);
    int x0 = 5 + posLeft;
    int y0 = height - 5;
    int y1 = 0, y2 = 0;
    for(int l = 0; l <= imgMax; l++){
      y1 = int (  
                   (posTop - 20) * p( (float)l ) * (sqrt(TWO_PI) * sigma) 
               );
      //println( "" + l + ":" + y1 );
      line( x0 + l , y0 - y1 , x0 + l, y0 - y2 );
      y2 = y1;
    }
  }
}

class ImgEyeFinder2 extends ImageOp {
  int eyeDiam, eyelx, eyely, eyerx, eyery, imgH;
  ImgEyeFinder2(ImgData img){
    super(img);
    posWidth = 60;
    title = "Eye Finder";
    eyeDiam = 20;
    imgChannels = 1;
    //copyPalette( in );
    setPalette(1.0, 1.0, 1.0);
    updateme = true;
  }
  public ImgData compute(){
    int target0 = imgMax;
    int target1 = 90;
    int dmin = imgMax * imgMax;
    int dx, dy;
    
    for(int x = in.imgWidth / 5; x < 4 * in.imgWidth / 5; x++){
      for(int y=0; y < in.imgHeight; y++){
        int d0 = 1 + abs( target0 - in.imgData[x][y][0] ) ;
        int d1 = 1 + abs( target1 - in.imgData[x][y][1] ) / 2;
        int d = d0 * d1;
        if(d < dmin){
          dmin = d;
          eyelx = x;
          eyely = y;
          //imgData[x][y][0] = imgMax;//in.imgData[x][y][0];
        }
        /*
        if(in.imgData[x][y][0] == 0 && in.imgData[x][y][1] == 0) {
          imgData[x][y][0] = imgMax;
        } else {
        */
        imgData[x][y][0] = d;
        //}
      }
    }
    //computeScale();
    //println("Eye1: " + eyelx + ", " + eyely);
    
    
    
    // this uses a mask of the found eye to compute a subtraction
    int [][][] imgEye = new int[32][32][2];
    int eyeSize = 10;
    int eyeDist = eyeSize * 4;
    for(int x = 0; x < eyeSize; x++){
      for(int y = 0; y < eyeSize; y++){
        imgEye[x][y][0] = in.imgData[x + eyelx - eyeSize/2][y + eyely - eyeSize/2][0];
        imgEye[x][y][1] = in.imgData[x + eyelx - eyeSize/2][y + eyely - eyeSize/2][1];
      }
    }
        
    int minV = 999999999;
    for(int x = in.imgWidth / 5; x < 4 * in.imgWidth / 5; x++){
      for(int y=32; y < in.imgHeight - eyeSize; y++){
        //imgData[x][y][0] = 0;

        int v = 0;

        for(int x1=0; x1 < eyeSize; x1++){
          for(int y1=0; y1 < eyeSize; y1++){
            v += sq(in.imgData[x+x1 - eyeSize/2][y+y1 - eyeSize/2][0] - imgEye[x1][y1][0]);
            v += sq(in.imgData[x+x1 - eyeSize/2][y+y1 - eyeSize/2][1] - imgEye[x1][y1][1]);
          }
        }

        if( abs(x - eyelx) < eyeDist ){
          v = eyeSize * eyeSize * imgMax * imgMax;
        }

        //imgData[x][y][0] += eyeSize * constrain( eyeDist - abs(x - eyelx), 1, eyeDist );
        //imgData[x][y][0] /= constrain( abs(y - eyely) / (eyeDist/2), 1, eyeDist );

        imgData[x][y][0] = v / (eyeSize * 2);


        if(v < minV) {
          minV = v;
          eyerx = x;
          eyery = y;
          //println("v="+v);
        }
        
      }

    }    
    if(eyelx > eyerx){
      int tmpx, tmpy;
      tmpx = eyelx;
      tmpy = eyely;
      eyelx = eyerx;
      eyely = eyery;
      eyerx = tmpx;
      eyery = tmpy;
    }
    
    //println("\tL:\t"+eyelx+"\t"+eyely+"\t; R:\t"+eyerx+"\t"+eyery);
    
    //search for a second eye, assuming it will be at least imgHeight / 8 pixels away        

    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    drawOperator((char)0x25c9);
    int eyeRadius = eyeDiam / 2;
    //fill(#ff00ff);
    noFill();
    stroke(#ff00ff);
    ellipse(eyelx, eyely, eyeDiam, eyeDiam);
    ellipse(eyerx, eyery, eyeDiam, eyeDiam);
    //line(100,100,200,200);
  }
}


class ImgEyeFinder extends ImgOpFilter {
  int eyeDiam, eyelx, eyely, eyerx, eyery, imgH;
  ImageOp op1;
  ImgEyeFinder(ImgData img){
    super(img);
    title = "Eye Finder";
    copyPalette( in );
    updateme = true;
  }
  public void defaultFilter(){
    imgH = min(in.imgWidth, in.imgHeight);
    eyeDiam = imgH / 20;
    zh = eyeDiam;

    int [] f = new int[eyeDiam*eyeDiam];
    for(int i = 0; i < f.length; i++){  // fill background
      f[i] = imgMax / 2;
    }

    int center = eyeDiam / 2;

    int r = eyeDiam / 2 - 1;
    for(int deg=0; deg < 360; deg++){
      int x = int( r * cos(radians(deg)) );
      int y = int( r * sin(radians(deg)) );
      x += center;
      y += center;
      f[ y * eyeDiam + x ] = 0;
      for(int k = r - 1; k > 0; k--){
        x = int( k * cos(radians(deg)) );
        y = int( k * sin(radians(deg)) );
        x += center;
        y += center;
        f[ y * eyeDiam + x ] = imgMax / 8;
      }
    }
    f[center * eyeDiam + center] = imgMax;
    for(int j=-1; j < 1; j++){
      for(int k = -1; k < 1; k++){
        f[ (center + j) * eyeDiam + k] = 0;
      }
    }
    setFilter(f);
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
        r[ a * zh + b ] = abs( data - z[ a * zh + b ] );
      }
    }
    return r;
  }

  public int calc(int x, int y, int ch){
    int [] r = calcFilts(x, y, ch);
    int sum = 0;
    for(int i=0; i < r.length; i++){
      sum += r[i];
    }
    return sum;
  }
  public ImgData compute(){
    //copyFrom(in);
    
    op1 = new ImgOpNegate(in);
    op1.copyPalette(in);
    op1.compute();
    copyFrom(op1);
    
    int vmin = imgMax * imgMax;
    int ch = 0;
    int dt = 1;

    eyelx = imgH / 2;
    eyely = imgH / 2;

    int clx = imgWidth / 3, cly = imgHeight / 2, crx = 2 * imgWidth / 3, cry = imgHeight / 2;
    int elmin = imgMax * imgMax, ermin = imgMax * imgMax;
    int eldist = imgWidth, erdist = imgWidth;
    int del, der;
    for(int y = imgHeight / 4; y < 3 * imgHeight / 4; y++){
      for(int x = imgWidth / 10; x < 9 * imgWidth / 10; x++){
        del = abs(clx - x);
        if(imgData[x][y][0] < elmin)
        if( del < eldist){
          eldist = del;
          elmin = imgData[x][y][0];
          eyelx = x;
          eyely = y;
        }
        der = abs(crx - x);
        if(imgData[x][y][0] < ermin)
        if( der < erdist){
          erdist = der;
          ermin = imgData[x][y][0];
          eyerx = x;
          eyery = y;
        }
      }
    }
    
    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    int eyeRadius = eyeDiam / 2;
    //fill(#ff00ff);
    noFill();
    stroke(#ff00ff);
    ellipse(eyelx - eyeRadius, eyely - eyeRadius, eyeDiam, eyeDiam);
    ellipse(eyerx - eyeRadius, eyery - eyeRadius, eyeDiam, eyeDiam);
    //line(100,100,200,200);
  }
}

public class ImgEyeMask extends ImgOpFilter {
  int eyelx, eyely;
  ImgEyeMask(ImgData img){
    super(img);
    title = "Eye mask";
    copyPalette(in);
    updateme = true;
  }
  ImgEyeMask(ImgData img, int lx, int ly){
    super(img);
    title = "Eye mask";
    eyelx = lx; eyely = ly;
    copyPalette(in);
    updateme = true;
  }
  public ImgData compute(){
    int d = min(imgWidth, imgHeight) / 16;
    zh = d * 2;
    int [] f = new int[zh * zh];
    for(int x = eyelx - d; x < eyelx+d; x++){
      for(int y = eyely - d; y < eyely+d; y++){
        imgData[x][y][0] = in.imgData[x][y][0];
        f[(y - eyely+d) * zh + (x - eyelx+d)] = -in.imgData[x][y][0];
      }
    }
    
    setFilter(f);
    //for(int x=0; x < imgWidth; x++){
    //  for(int y=0; y < imgHeight; y++){

    //  }
    //}
    super.compute();
    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    stroke(#ff00ff);
    line( eyelx - 5, eyely, eyelx + 5, eyely);
    line( eyelx, eyely - 5, eyelx, eyely + 5);
  }
  public int calc(int x, int y, int ch){
    int [] r = calcFilts(x, y, ch);
    int sum = 0;
    for(int i=0; i < r.length; i++){
      sum += r[i];
    }
    return sum;
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
        r[ a * zh + b ] = abs( data - z[ a * zh + b ] );
      }
    }
    return r;
  }

}

class ImgOpRowSum extends ImageOp {
  ImgOpRowSum(ImgData img){
    super(img);
    title = "RowSum";
    updateme = true;
    posWidth = 50;
  }
  public ImgData compute(){
    int ch = 0;
    for(int y=0; y < imgHeight; y++){
      int sum = 0;
      for(int x=0; x < imgWidth; x++){
        sum += in.imgData[x][y][ch];
      }
      for(int x=0; x < imgWidth; x++){
        imgData[x][y][ch] = sum / in.imgWidth;
      }
    }
    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    drawOperator("·");
  }
}

class ImgEyeCrop extends ImageOp {
  ImgEyeCrop(ImgData img){
    super(img);
    title = "EyeCrop";
    posWidth = 60;
    updateme = true;
  }
  public ImgData compute(){
    int ch = 0;
    int fh = 5;
    int fw = 6;
    for(int y = imgHeight / fh; y < (fh-1) * imgHeight / fh; y++){
      for(int x = imgWidth / fw; x < (fw-1) * imgWidth / fw; x++){
        imgData[x][y][ch] = in.imgData[x][y][ch];
      }
    }
    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    drawOperator("#");
  }
}

class ImgEyeCrop2 extends ImageOp {
  int thresh = 230;
  ImgData in2;
  ImgEyeCrop2(ImgData img){
    super(img);
    title = "EyeCrop2";
    posWidth = 60;
    updateme = true;
  }
  ImgEyeCrop2(ImgData img, ImgData img2){
    super(img);
    in2 = img2;
    title = "EyeCrop2";
    posWidth = 60;
    updateme = true;
  }
  public ImgData compute(){
    int ch = 0;
    int x1, x2, y1, y2;
    x1 = 0;
    x2 = imgWidth;
    y1 = 0;
    y2 = 0;
    for(int y=0; y < imgHeight; y++){
      if(y1 == 0 && in.imgData[0][y][0] > thresh){
        y1 = y;
      }
      if(in.imgData[0][y][0] > thresh){
        y2 = y;
      }
    }

    int iter = 0;
    do { iter++;
    
      int ldens = imgMax;
      int hdens = 0;
      int hdy = 0, ldy = 0;
      for(int y = y1; y < y2; y++){
        int v = in.imgData[imgWidth/2][y][0];
        if(v < ldens) {
          ldens = v;
          ldy = y;
        }
        if(v > hdens) {
          hdens = v;
          hdy = y;
        }
      }

      int hdh = 32;    
      if(ldy < hdy){
        // cut from above
        y1 = ldy - hdh;
        y2 = hdy + hdh;
      } else {
        // cut from below
        y1 = hdy - hdh;
        y2 = ldy + hdh;
      }
    
    } while(iter < 3);
    
    for(int y = y1; y < y2; y++){
      for(int x = x1; x < x2; x++){
        imgData[x][y][ch] = in2.imgData[x][y][ch];
      }
    }

    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    drawOperator("#");
  }

}


class ImgOpHalfRowSum extends ImageOp {
  ImgOpHalfRowSum(ImgData img){
    super(img);
    posWidth = 50;
    title = "HalfRowSum";
    updateme = true;
  }
  public ImgData compute(){
    int ch = 0;
    int max1=0, max2=0;
    for(int y=0; y < imgHeight; y++){
      int sum = 0;
      for(int x=0; x < imgWidth/2; x++){
        sum += in.imgData[x][y][ch];
      }
      for(int x=0; x < imgWidth/2; x++){
        imgData[x][y][ch] = sum; // / (in.imgWidth/2);
        max1 = max(sum, max1);
      }

      sum = 0;
      for(int x=imgWidth/2; x < imgWidth; x++){
        sum += in.imgData[x][y][ch];
      }
      for(int x=imgWidth/2; x < imgWidth; x++){
        imgData[x][y][ch] = sum; // / (in.imgWidth/2);
        max2 = max(sum, max2);
      }
    }
    int max3 = max(max1, max2);
    float f1 = max3 / (float)max1;
    float f2 = max3 / (float)max2;
    for(int y=0; y < imgHeight; y++){
      for(int x=0; x < imgWidth/2; x++){
        imgData[x][y][ch] *= f1;
      }
      for(int x=imgWidth/2; x < imgWidth; x++){
        imgData[x][y][ch] *= f2;  
      }
    }
    computeScale();
    
    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    drawOperator("·");
  }

}

class ImgOpColSum extends ImageOp {
  ImgOpColSum(ImgData img){
    super(img);
    title = "ColSum";
    posWidth = 40;
    updateme = true;
  }
  public ImgData compute(){
    int ch = 0;
    for(int x=0; x < imgWidth; x++){
      int sum = 0;
      for(int y=0; y < imgHeight; y++){
        sum += in.imgData[x][y][ch];
      }
      for(int y=0; y < imgHeight; y++){
        imgData[x][y][ch] = sum / in.imgHeight;
      }
    }
    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    drawOperator("·");
  }

}

class ImgOpSumXY extends ImageOp { // row/column transform
  ImgOpSumXY(ImgData img){
    super(img);
    title = "SumXY";
    posWidth = 50;
    imgChannels = 2;
    imgData = new int[imgWidth][imgHeight][imgChannels];
    imgPalette = new color[imgMax + 1][imgChannels];
    updateme = true;
  }
  public ImgData compute(){
    int ch = 0;
    for(int x=0; x < imgWidth; x++){ 
      int sum = 0;
      for(int y=0; y < imgHeight; y++){ // sum on every pixel in this column
        sum += in.imgData[x][y][ch];
      }
      for(int y=0; y < imgHeight; y++){ // assign this column sum across the entire column
        imgData[x][y][ch] = sum;
      }
    }

    int maxval = 0;
    for(int y=0; y < imgHeight; y++){
      int sum = 0;
      for(int x=0; x < imgWidth; x++){ // sum on every pixel in this row
        sum += in.imgData[x][y][ch];
      }
      for(int x=0; x < imgWidth; x++){ // assign this row sum across the entire row and compute the channels
        int v1 = imgData[x][y][ch];    // previously computed column sum
        int v2 = sum;                  // recently computed row sum
        imgData[x][y][0] *= v2;        // magnitude
        imgData[x][y][1] = int( 2 * degrees( atan(v2 / ((v1==0) ? 1 : v1) ) ) ); // phase angle
        maxval = max(maxval, imgData[x][y][ch]); // retain maximum for scale
      }
    }
    for(int y=0; y < imgHeight; y++){
      for(int x = 0; x < imgWidth; x++){
        imgData[x][y][ch] /= maxval / 255;
      }
    }

    updateme = false;
    return this;
  }
  public void display(){
    super.display();
    drawOperator("·");
  }
}
