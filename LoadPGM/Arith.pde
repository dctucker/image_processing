class ImgOpArith extends ImageOp { // Image arithmetic operations
  ImageOp in1, in2;                // two operands for any of these operations
  char operation;                  // what operation are we applying here?
  float mulScale;                  // factor to scale image after multiplication
  float addScale;                  // factor to scale image after addition

  public ImgOpArith(ImageOp in1, ImageOp in2, char operation){
    super(in1);
    this.in = in1;
    this.in1  = in1;
    this.in2 = in2;
    this.operation = operation;
    System.out.println("" + in1 + " " + operation + " " + in2 );
    title = "" + operation;
    posWidth = 40; //constrain( (int)(imgWidth) + 10, 30, 100);
    updateme = true;
  }
  public void display(){
    //mergePalettes();
    drawBox();
    drawOperator(operation);
  }
  public boolean update(){
    if(in1.updateme || in2.updateme) {
      //mergePalettes();
      updateme = true;
      //return true;
    }
    return updateme;
  }
  public ImgData compute(){                  // we'll implement our own compute for efficiency
    //updateme = true;
    switch(operation) {
      case '+':  computeAdd();  break;
      case '-':  computeSub();  break;
      case '*':  computeMul();  break;
      case '/':  computeDiv();  break;
    }
    //computeScale();
    //mergePalettes();
    updateme = false;
    
    return this;
  }
  public void mergePalettes(){               // merge palettes from source images
    for(int k=0; k < imgChannels; k++){
      for(int i=0; i <=imgMax; i++){
        color c1 = in1.imgPalette[i][k];
        color c2 = in2.imgPalette[i][k];
        imgPalette[i][k] = blendColor(c1, c2, OVERLAY);
      }
    }
  }
  
  //compute methods follow
  public void computeAdd() {
    for(int x=0; x < imgWidth; x++){
     for(int y=0; y < imgHeight; y++){
       for(int ch=0; ch < imgChannels; ch++){
         if(!chBypass[ch]){
            imgData[x][y][ch] = in1.imgData[x][y][ch] + in2.imgData[x][y][ch];
          }
        }
      }
    }
  }
  public void computeSub(){
   for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        for(int ch=0; ch < imgChannels; ch++){
          if(!chBypass[ch]){
            imgData[x][y][ch] = in1.imgData[x][y][ch] - in2.imgData[x][y][ch];
          }
        }
      }
    }
  }
  public void computeMul(){
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        for(int ch=0; ch < imgChannels; ch++){
          if(!chBypass[ch]){
            imgData[x][y][ch] = (int)(in1.imgData[x][y][ch] * in2.imgData[x][y][ch]);
          }
        }
      }
    }
  }
  public void computeDiv(){
    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        for(int ch=0; ch < imgChannels; ch++){
          if(!chBypass[ch]){
            if(in2.imgData[x][y][ch] == 0) {      // deal with division by zero
              imgData[x][y][ch] = 0;
            } else {
              imgData[x][y][ch] = in1.imgData[x][y][ch] / in2.imgData[x][y][ch];
            }
          }
        }
      }
    }
  }
}//end class

public class ImgOpScale extends ImageOp {
  public ImgOpScale(ImgData img){
    super(img);
    title = "Scale";
    posWidth = 40;
  }
  public ImgData compute(){
    copyFrom(in);
    computeScale();
    updateme = false;
    return this;
  }
  void display(){
    super.display();
    drawOperator((char)0x2243);
    //textSize(12);
    //fill(#dddddd);
    //text("(r-m)", posLeft + posWidth / 2, height - posTop + 40 );
  }
}

public class ImgOpClip extends ImageOp {
  public ImgOpClip(ImgData img){
    super(img);
    title = "Clip";
    posWidth = 40;
  }
  public int calc(int x, int y, int ch){
    return constrain(in.imgData[x][y][ch], 0, imgMax);
  }
  void display(){
    super.display();
    drawOperator((char)0x2440);
  }
}
