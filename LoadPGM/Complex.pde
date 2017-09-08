public class Complex {
  float re;
  float im;
  Complex(float r, float i){
    re=r;
    im=i;
  }
  Complex conj(){
    return new Complex(re, -im);
  }
  Complex add(Complex z){
    return new Complex(re + z.re, im + z.im);
  }
  Complex sub(Complex z){
    return new Complex(re - z.re, im - z.im);
  }
  Complex mul(Complex z){
    float a, b, c, d;
    a = re; b = im;
    c = z.re; d = z.im;
    return new Complex( a*c - b*d, b*c + a*d );
  }
  Complex div(Complex z){
    float a, b, c, d;
    a = re; b = im;
    c = z.re; d = z.im;
    
    return new Complex ( (a*c + b*d) / ( c*c + d*d ) , ( b*c - a*d) / ( c*c + d*d) );
  }
  Complex div(float z){
    return new Complex( re / z, im );
  }
  float mag(){
    return sqrt( (float)( re*re + im*im ) );
  }
  float theta(){
    return atan( (float)(im / re) );
  }
  Complex e(){
    float e1 = exp((float)re);
    return new Complex( e1 * cos((float)im), e1 * sin((float)im) );
  }
}

public class ImgOpDFT4 extends ImageOp {
  float[][] re;
  float[][] im;
  Complex[][] F;
  
  public ImgOpDFT4(ImgData img){
    super(img);
    title = "DFT";
    posWidth = 40;
    imgData = new int[imgWidth][imgHeight][2];
    imgChannels = 2;
    
    updateme = true;
  }
  public ImgData compute(){
    F = new Complex[imgWidth][imgHeight];
    //re = new float[imgWidth][imgHeight];
    //im = new float[imgWidth][imgHeight];
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        //re[x][y] = (float)in.imgData[x][y][0];
        //im[x][y] = 0.0f;
        F[x][y] = new Complex( in.imgData[x][y][0], 0 );
      }
    }
    Complex[] row = new Complex[imgWidth];  
    for(int v=0; v < imgHeight; v++){
      for(int i=0; i < imgWidth; i++){
        //row[i] = new Complex(re[i][v], im[i][v]);
        row[i] = new Complex(F[i][v].re, F[i][v].im);
      }
      Complex[] dft = DFT1(row ,false);
      for(int i=0; i < imgWidth; i++){
        //re[i][v] = dft[i].re;
        //im[i][v] = dft[i].im;
        F[i][v] = new Complex(dft[i].re, dft[i].im);
      }
    }
    
    Complex[] col = new Complex[imgHeight];
    for(int u=0; u < imgWidth; u++){
      for(int j=0; j < imgHeight; j++){
        //col[j] = new Complex(re[u][j], im[u][j]);
        col[j] = new Complex(F[u][j].re, F[u][j].im);
      }
      Complex[] dft = DFT1(col ,false);
      for(int j=0; j < imgHeight; j++){
        //re[u][j] = dft[j].re;
        //im[u][j] = dft[j].im;
        F[u][j] = new Complex(dft[j].re, dft[j].im);
      }
    }
    for(int y=0; y < imgHeight; y++){
      for(int x=0; x < imgWidth; x++){
        int u, v;
        u = x + imgWidth / 2;
        v = y + imgHeight / 2;
        u%=imgWidth; v%=imgHeight;
        imgData[x][y][0] = int(F[u][v].mag());  //int( sqrt( sq(re[x][y]) + sq(im[x][y]) ) );
        imgData[x][y][1] = int(degrees(F[u][v].theta())); //int( degrees( atan( im[x][y] / re[x][y] ) ) );
      }
    }
    //swapQuadrants();
    updateme = false;
    return this;
  }
  Complex[] DFT1(Complex[] g, boolean inv){
    int M = g.length;
    Complex[] R = new Complex[M];
    float s = 1.0f / sqrt(M);
    for(int u=0; u < M; u++){
      float sre = 0, sim = 0;
      for(int v=0; v < M; v++){
        float re = g[v].re, im = g[v].im;
        float k = (TWO_PI * u * v) / (float)M;
        float cosk = cos(k), sink = -sin(k);
        if(inv) sink = -sink;
        sre += re * cosk - im * sink;
        sim += re * sink + im * cosk;
      }
      R[u] = new Complex(s*sre, s*sim);
    }
    return R;
  }
  void swapPixels(int x1, int y1, int x2, int y2){
    int temp;
    temp = imgData[x1][y1][0];
    imgData[x1][y1][0] = imgData[x2][y2][0];
    imgData[x2][y2][0] = temp;

    temp = imgData[x1][y1][1];
    imgData[x1][y1][1] = imgData[x2][y2][1];
    imgData[x2][y2][1] = temp;
  }
  void swapQuadrants(){
    int[][] temp = new int[imgWidth][imgHeight];
    int ymid = imgHeight / 2;
    int xmid = imgWidth / 2;
    for(int x=0; x < xmid; x++){
      for(int y=0; y < ymid / 2; y++){
        swapPixels( x        , y, x + xmid , y + ymid );
      }
    }
    for(int x=0; x < xmid; x++){
      for(int y=0; y < ymid / 2; y++){
        swapPixels( x + xmid , y, x        , y + ymid );
      }
    }

  }
}

public class ImgOpDFT3 extends ImageOp {
  float [] tsin1, tcos1, tsin2, tcos2;
  Complex [][] F;
  public ImgOpDFT3(ImgData img){
    super(img);
    calcTables();
    imgData = new int[imgWidth][imgHeight][2];
    updateme = true;
  }
  public ImgData compute(){
    float MN = imgWidth * imgHeight;
    F = new Complex[imgWidth][imgHeight];
    float sumf = 0;
    for(int y=0; y < imgHeight; y++){
      for(int x=0; x < imgWidth; x++){
        sumf += in.imgData[x][y][0];
      }
    }
    sumf *= (1.0 / MN);
    for(int v=0; v < imgHeight; v++){
      println("line "+v);
      for(int u=0; u < imgWidth; u++){
        float re=0, im=0;
        for(int k=0; k < imgHeight; k++){
          for(int l=0; l < imgWidth; l++){
            float cosku, coslv, sinku, sinlv, ku, lv;
            ku = -k*u; // % imgHeight;
            lv = -l*v; // % imgWidth;
            cosku = cos(ku);
            coslv = cos(lv);
            sinku = sin(ku);
            sinlv = sin(lv);
            re += cosku * coslv - sinku * sinlv;
            im += sinku * coslv + cosku * sinlv;
          }
        }
        F[u][v] = new Complex(sumf * re, sumf * im);
        imgData[u][v][0] = int( F[u][v].re );
        imgData[u][v][1] = int( F[u][v].im );
      }
    }
    updateme = false;
    return this;
  }
  void calcTables(){
    tsin1 = new float[in.imgWidth];
    tcos1 = new float[in.imgWidth];
    for(int i=0; i < in.imgWidth; i++){
      tsin1[i] = sin((float)i/(float)imgWidth * TWO_PI);
      tcos1[i] = cos((float)i/(float)imgWidth * TWO_PI);
    }
    tsin2 = new float[in.imgHeight];
    tcos2 = new float[in.imgHeight];
    for(int i=0; i < in.imgHeight; i++){
      tsin2[i] = sin((float)i/(float)imgHeight * TWO_PI);
      tcos2[i] = cos((float)i/(float)imgHeight * TWO_PI);
    }
  }

}


public class ImgOpDFT2 extends ImageOp {
  float [] tsin, tcos;
  public ImgOpDFT2(ImgData img){
    super(img);
    imgData = new int[imgWidth][imgHeight][2];
    calcDFT2();
    updateme = true;
  }
  public ImgData compute(){
    calcDFT2();
    updateme = false;
    return this;
  }
  public void calcDFT2(){
    Complex [][] c = new Complex[imgWidth][imgHeight];
    float[] real = new float[imgWidth];
    float[] imag = new float[imgWidth];
    calcTables(imgWidth);
    
    for(int y=0; y < imgHeight; y++){
      for(int x=0; x < imgWidth; x++){
        real[x] = in.imgData[x][y][0];
        imag[x] = 0; // in.imgData[x][y][0];
      }
      Complex [] c1 = calcDFT1(real, imag);
      for(int x=0; x < imgWidth; x++){
        c[x][y] = c1[x];
        imgData[x][y][0] = int( c[x][y].mag() );
        imgData[x][y][1] = int( degrees( c[x][y].theta() ) );
      }
    }

    real = new float[imgHeight];
    imag = new float[imgHeight];
    calcTables(imgHeight);
    
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        real[y] = in.imgData[x][y][0];
        imag[y] = 0; // in.imgData[x][y][0];
      }
      Complex [] c1 = calcDFT1(real, imag);
      for(int y=0; y < imgHeight; y++){
        c[x][y] = c1[y];
        imgData[x][y][0] = int( c[x][y].mag() );
        imgData[x][y][1] = int( degrees( c[x][y].theta() ) );
      }
    }
  }
  void calcTables(int len){
    tsin = new float[len];
    tcos = new float[len];
    for(int i=0; i < len; i++){
      tsin[i] = sin((float)i/(float)len * TWO_PI);
      tcos[i] = cos((float)i/(float)len * TWO_PI);
    }
  }
  
  Complex[] calcDFT1(float[] real, float[] imag){
    float m = real.length;
    float arg, cosarg, sinarg;
    Complex [] ret = new Complex[real.length];
    
    
    for(int i=0; i < real.length; i++){
      ret[i] = new Complex(0, 0);
      arg = TWO_PI * ((float)i) / m;
      for(int k=0; k < real.length; k++){
        cosarg = tcos[k]; //cos(k * arg);
        sinarg = tsin[k]; //sin(k * arg);
        ret[i].re += ( real[k] * cosarg - imag[k] * sinarg );
        ret[i].im += ( real[k] * sinarg + imag[k] * cosarg );
      }
    }
    return ret;
  }
}

public class ImgOpDFT extends ImageOp {
  Complex[][][] imgFFT;
  public ImgOpDFT(ImgData img){
    super(img);
    imgFFT = calcDFT();
    updateme = true;
    
  }
  public Complex[][][] calcDFT(){
    println("calc'dft");
    float M = in.imgWidth;
    float N = in.imgHeight;
    imgData = new int[imgWidth][imgHeight][2];
    Complex[][][] fft = new Complex[in.imgWidth][in.imgHeight][in.imgChannels];
    
    for(int ch=0; ch < in.imgChannels; ch++){
      for(int y=0; y < in.imgHeight; y++){
        for(int x=0; x < in.imgWidth; x++){
          float f = in.imgData[x][y][ch];

          Complex c = new Complex(0, 0);
          
          for(int n=0; n < in.imgHeight; n++){
            for(int m=0; m < in.imgWidth; m++){
              float magn = in.imgData[m][n][ch];
              float thet = TWO_PI * ( m*x/M + n*y/N );
              c = c.add( new Complex( magn * cos(thet) , magn * sin(thet) ) );
              
            }
          }
          fft[x][y][ch] = c.div(M*N);
          imgData[x][y][0] = int( sqrt(sq(fft[x][y][ch].im) + sq(fft[x][y][ch].re)) );
          imgData[x][y][1] = int( degrees( atan( fft[x][y][ch].im / fft[x][y][ch].re ) ) );
        }
      }
    }
    updateme = false;
    return fft;
  }
}
