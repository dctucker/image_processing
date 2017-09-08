public class ImgOpBitPlane extends ImageOp {
  //HScrollbar hBit;
  int bit, maxBit;
  public ImgOpBitPlane(ImgData img){
    super(img);
    title = "Bit Planes";
    maxBit = int(log(in.imgMax + 1) / log(2) ) - 1;
    //hBit = new HScrollbar(posLeft + 5, height-posTop + 50, "Bit", maxBit, 0);
    bit = 7;
    updateme = true;
  }
  public ImgOpBitPlane(ImgData img, int b){
    super(img);
    title = "Bit " + b;
    posWidth = 50;
    maxBit = int(log(in.imgMax + 1) / log(2) ) - 1;
    //hBit = new HScrollbar(posLeft + 5, height-posTop + 50, "Bit", maxBit, 0);
    //hBit.setVal(b);
    bit = b;
    updateme = true;    
  }
  public int calc(int x, int y, int ch){
    return (in.imgData[x][y][ch] & (0x01 << bit)) > 0 ? imgMax : 0 ;
  }
  public void setPos(int l){
    super.setPos(l);
    //hBit.setPos(l + 5);
  }
  public void display(){
    super.display();
    textSize(18);
    drawOperator((char)0x2227);
    text("2"      , posLeft + posWidth / 2 - 5, height - posTop / 3);
    textSize(12);
    text("" + bit , posLeft + posWidth / 2 + 5, height - posTop / 3 - 10);
    //hBit.display();
  }
  /*
  public boolean update(){
    int hb = bit;
    hBit.update();
    bit = int( hBit.getVal() );
    if( bit != hb ){
      updateme = true;
    } 
    return updateme;
  }*/
}

public class ImgOpBitSubst extends ImageOp {
  ImgData in1, in2;
  int bit, logMax;
  ImgOpBitSubst(ImgData img, ImgData img2, int b){
    super(img);
    in1 = img;
    in2 = img2;
    bit = b;
    posWidth = 50;
    title = "Subst";
    updateme = true;
  }
  public ImgData compute(){
    logMax = int( pow(2, ceil(log(in.imgMax) / log(2))) - 1);
    println("LogMax: " + logMax);
    super.compute();
    return this;
  }
  public int calc(int x, int y, int ch){
    int v = in1.imgData[x][y][ch];
    int k = (in2.imgData[x][y][ch] == 0) ? 0 : 1;
    int k1 = k << bit;
    int k2 = (~(1 << bit)) & logMax;
    int v2 = (v & k2) | k1;
    //println("k1=" + k1 + ", k2=" + k2 + ", v=" + v + ", v2=" + v2);
    return v2;
  }
  public void display(){
    super.display();
    fill(#cccccc);
    textSize(12);
    text("Â"      , posLeft + posWidth / 2 - 20, height - posTop / 3 - 5);
    textSize(18);
    drawOperator((char)0x2228);
    text("2"      , posLeft + posWidth / 2 - 5, height - posTop / 3);
    textSize(12);
    text("" + bit , posLeft + posWidth / 2 + 5, height - posTop / 3 - 10);
    textSize(18);
    text("" + (char)0x2227, posLeft + posWidth / 2, height - posTop / 4 );
  }

}


public class ImgOpNegate extends ImageOp {
  public ImgOpNegate(ImgData img){
    super(img);
    title = "Neg";
    posWidth = 40;
    updateme = true;
  }
  public int calc(int x, int y, int ch){
    return in.imgMax - in.imgData[x][y][ch];
  }
  public void display(){
    super.display();
    drawOperator('Â');
  }
}
