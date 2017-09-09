// D. Casey Tucker
// Programming assignment 1, 2, 3
// Dr. Karl Ricanek 520

ImgData   img, img2;             // our source PGM image
ImageOp   add, sub, mul, div;    // for assignment 3
ImageOp[] chain;                 // structure to link image operations together
int       chainLeft=0;           // left pixel location of our first image op panel
int       chainPalette=0;        // draw this ImageOp's palette on screen
PImage    dispimg;               // the main displayed image
int       dispWidth, dispHeight; // width/height of the image display area
int       cmdHeight = 30;
int       posHeight;
PFont     font;
int       zoom = 8;
int       extraWidth = 0;
int       selChain;

int assignment = 5;

int getChainID(ImgData ch){
  for(int i=0; i < chain.length; i++){
    if(chain[i] == ch){
      return i;
    }
  }
  return -1;
}

void printChain(){
  for(int i=0; i < chain.length; i++){
    int pid = getChainID(chain[i].in);
    String parent = "";
    if(pid != -1) parent = " " + pid + ": " + chain[i].in;
    println("" + i +": "+ chain[i] + parent);
  }
}

void drawConnectors(int i, int pid){
  int kw = 6, kh = 3;

  if(pid != -1) {
      int x1 = chain[i].posLeft + kw;
      int x2 = chain[pid].posLeft + chain[pid].posWidth - (kh * (i - pid)) - kw;
      int x3 = x1;
      int y = height - chain[0].posTop - (kh * (i - pid));
      int y1 = height - chain[0].posTop - kh;
      
      while(get(x2, y) == #ffff00){
        y -= kh;
      }

      while(get(x1, y1) == #ffff00){
        x1 += kw;
      }
      
      //x1 = x3;
      
      stroke(#000000);
      
      line(x1-1, y, x1-1, height - chain[0].posTop);
      line(x1+1, y, x1+1, height - chain[0].posTop);
      line(x2-1, y, x2-1, height - chain[0].posTop);
      line(x2+1, y, x2+1, height - chain[0].posTop);
      line(x1, y-1, x2, y-1);
      line(x1, y+1, x2, y+1);

      stroke(#ffff00);
      line(x1, y, x2, y);
      line(x1, y, x1, height - chain[0].posTop);
      line(x2, y, x2, height - chain[0].posTop);
      
      /*
      stroke(#ff00ff);
      fill(#ff00ff);
      point(x1,y1);//, 2, 2);
      */

  }    
}

void drawChain(){
  String[] form = new String[chain.length];
  
  int kw = 6, kh = 3;
  noStroke();
  fill(#000000);
  rect(0, height - chain[0].posTop - cmdHeight, width, cmdHeight);
  String formula = "";

  stroke(#000000);
  fill(#000000);
  rect(width - 200, 0, 200, height - chain[0].posTop);
  textSize(10);
  
  for(int i=0; i < chain.length; i++){
    String curF0 = chain[i].toString();
    String curF1;  //chain[i].in.toString();
    String curF2;
    
    formula += (char)('a' + i) + " = ";
    if(i == 0) {
      formula += curF0;
    } else if(chain[i] instanceof ImgOpArith){
      int pid1 = getChainID(((ImgOpArith) chain[i]).in1);
      int pid2 = getChainID(((ImgOpArith) chain[i]).in2);
      /*
      if(pid2 < pid1){
        int pid3 = pid1;
        pid1 = pid2;
        pid2 = pid3;
      }
      */
      drawConnectors(i, pid1);
      drawConnectors(i, pid2);

      char curOp = ((ImgOpArith)chain[i]).operation;
      curF1 = form[pid1];
      curF2 = form[pid2];
      curF1 = "" + (char)('a' + pid1); //((ImgOpArith)chain[i]).in1.toString();
      curF2 = "" + (char)('a' + pid2); //((ImgOpArith)chain[i]).in2.toString();

      formula += "( " + curF1 + " " +curOp + " "+ curF2 + " )";
    
    } else {
      int pid = getChainID(chain[i].in);
      drawConnectors(i, pid);

      curF1 = form[pid];
      curF1 = "" + (char)('a' + pid);
      formula += curF0 + "( " + curF1 + " )";

    }
    //formula += ";";

    stroke(#ffffff);
    fill(#ffffff);
    textAlign(LEFT);
    text(formula, width - 200, 20 + i * 12);
    //println(formula);
    form[i] = formula;
    formula = "";
  }
}

void appendChain(ImageOp iop){ 
  //System.out.println("Appended to chain: " + iop);
  //chainLeft += chain[chain.length-1].posWidth;
  chainLeft = chain[chain.length - 1].posWidth + chain[chain.length - 1].posLeft;
  iop.setPos(chainLeft);
  iop.update();

  chain = (ImageOp[]) expand(chain,chain.length+1); // increase array size
  chain[chain.length-1] = iop;
}

void removeChain(int ch){
  //chain = (ImageOp[]) subset(chain, ch, 1);
  chainLeft -= chain[ch].posWidth;
  for(int i=ch; i < chain.length - 1; i++){
    chain[i+1].posLeft -= chain[i].posWidth;
    chain[i] = chain[i+1];
  }

  chain = (ImageOp[]) shorten(chain);
  fill(#000000);
  stroke(#000000);
  rect(0, chain[0].imgHeight, width, height);
}

void setupChain(String filename){
  //size(extraWidth + constrain(zoom * img.getWidth(), 400, 1024)  , 
  //     zoom * img.getHeight() + 220 );
  background(0);
  stroke(255);
  chain = new ImageOp[1]; // a nop to begin with


  if(img == null) {
    if(filename.endsWith(".pgm")){
      img = new PGMImage(filename);
      chain[0] = new ImgOpPalette(img, filename);
    } else {
      img = new LoadImage(filename);
      chain[0] = new ImgOpColor(img, filename);
    } 
    
  }

  zoom = 1;
  while( chain[0].imgHeight * zoom < (height / zoom) ) {
    //println(""+ (chain[0].imgHeight * zoom) +" < "+ (height / zoom));
    zoom++;
  }
  zoom--;
  //println("Zoom set to " + zoom ) ;
}

boolean updateChain(){
  boolean ret = false;
  for(int op=0; op < chain.length; op++) {
    if( chain[op].update() ) {              // if our panels have been tweaked, recompute.
      chain[op].compute();
      //println("updating " + op);
      if(chain[op].visible) chain[op].loadPImage(zoom);
      ret = true;
    }
  }
  return ret;
}

void settings(){
  size(1100, 700);
}

void setup() {
  

  font = createFont("Lucida Sans Unicode", 11);
  textFont(font, 12);
  

  switch(assignment) {
    case 1: setupAssignment1(); break;
    case 2: setupAssignment2(); break;
    case 3: setupAssignment3(); break;
    case 4: setupAssignment4(); break;
    default: setupChain("truck_rear.pgm");
  }

  posHeight = chain[0].posTop;
  dispWidth = width;
  dispHeight = height - posHeight - cmdHeight;

  println(""+dispWidth+"x"+dispHeight);
  for(int op=1; op < chain.length; op++){  // compute each op
    chain[op].compute();
    chain[op].loadPImage(zoom);
  }

  dispimg = chain[0].loadPImage(zoom);         // let's see...

  printChain();
  draw();
  noLoop();
}

void draw() {
  boolean updChain = updateChain();

  switch(assignment){
    case 2: drawAssignment2(); break;
    case 3: drawAssignment3(); break;
    case 4: drawAssignment4(); break;
    default:
      image(dispimg,0,0);                  // display the final image
  }
  //if(updChain) {
  //  chain[chainPalette] . drawPalette( 20, img.imgHeight + 4);
  //}
  drawChain();
  for(int op=0; op < chain.length; op++){  // draw each op's control panel
    chain[op].display();
  }
  drawCmd();
}

void drawCmd(){
  fill(#000000);
  stroke(#000000);
  //rect(0, dispimg.height, width, cmdHeight);
  fill(#cccccc);
  textAlign(LEFT);
  textSize(12);
  text("> " + cmd, 5, height - posHeight - 15);
}

void dispChain(int i){
  fill(#000000);
  noStroke();
  rect(0,0, dispWidth, dispHeight);

  if(i < chain.length){
    for(int ch=0; ch < chain.length; ch++){
      chain[ch].selected = false;
    }
    dispimg = chain[i].pimg;
    chain[i].selected = true;
    image(dispimg,0,0);
  }
}

void mousePressed(){
  loop();
}
void mouseReleased(){
  draw();
  noLoop();
}
String cmd="";

String[] smd;
boolean hasElem(int k, String sk){
  if(smd.length > k){
    if(smd[k].equals(sk)){
      return true;
    }
  }
  return false;
}
String hasElem(int k){
  if(smd.length > k){
    return smd[k];
  }
  return "";
}


void connectChain(ImageOp iop){
  appendChain(iop);
  chain[chain.length-1].updateme = true;
  chain[chain.length-1].visible = true;
  //chain[chain.length-1].imgPalette = chain[chain.length - 2].imgPalette;
  if(chain[chain.length-1].imgChannels == chain[chain.length-1].in.imgChannels)
    //chain[chain.length -1].copyPalette(chain[chain.length - 2]);
    chain[chain.length-1].copyPalette(chain[chain.length-1].in);
}

String CWD = "/Users/casey/Development/image_processing/LoadPGM/data/";

void ls(String path){
  //if(path.equals(""));
  File f = new File(path);
  File[] d = f.listFiles();
  if(d != null){
    for(int i=0; i < d.length; i++){
      String dn = d[i].getName();
      if(d[i].isDirectory()) {
        println(dn + "/");
      } else {
        println(dn);
      }
    }
  }
}




String LF(){
  File f = new File(CWD+"proj/test");
  File [] d = f.listFiles();
  if( d != null){
    int i;
    String dn = "";
    do {
      i = int( random(0, d.length - 1) );
      dn = CWD + "proj/test/" + d[i].getName() ;
      println("" + i + ":" +dn);
    } while ( d[i].isDirectory() && d[i].getName().startsWith("."));
    return dn;
  }
  return "";
}

class EyeDef {
  int lx, ly, rx, ry;
  String filename;
  EyeDef(String s){
    String[] k = s.split(" ");
    filename = k[0];
    lx = int( k[1] );
    ly = int( k[2] );
    rx = int( k[3] );
    ly = int( k[4] );
  }
}
EyeDef [] edef;
int eyei;

int LE(){
    img = null;
    if(edef == null){
      //String[] s = loadStrings(CWD+"proj/training/training.txt");
      String[] s = loadStrings(CWD+"proj/test/test.txt");
      edef = new EyeDef[s.length];
      for(int i=0; i < s.length; i++){
        edef[i] = new EyeDef(s[i]);
      }
      eyei=-1;
    }
    eyei++;
    eyei %= edef.length;
    //setupChain( "proj/training/" + edef[eyei].filename );
    setupChain( "proj/test/" + edef[eyei].filename );
    connectChain( new ImgOpGamma      ( chain[ 0 ], 1.4, 0.0 ) );
    connectChain( new ImgOpScale      ( chain[ 1 ] )  );
    
    connectChain( new ImgOpSobel      ( chain[ 0+2 ] )  );
    connectChain( new ImgOp5x5        ( chain[ 1+2 ] )  );
    connectChain( new ImgOpGamma      ( chain[ 2+2 ], 1.4, 0.0 ) );
    connectChain( new ImgOpScale      ( chain[ 3+2 ] )  );
    connectChain( new ImgEyeCrop      ( chain[ 4+2 ] )  );
    connectChain( new ImgOpRowSum     ( chain[ 5+2 ] )  );
    connectChain( new ImgOpHistEq     ( chain[ 6+2 ] )  );
    connectChain( new ImgEyeCrop2     ( chain[ 7+2 ], chain[ 7 ] ) );
    connectChain( new ImgOpSumXY      ( chain[ 8+2 ] )  );
    connectChain( new ImgEyeFinder2   ( chain[ 9+2 ] )  );

    return eyei;
}


  /*
    //connectChain( new ImgOpBitPlane   ( chain[ 0 ], 7 )  );
    //connectChain( new ImgOpBitPlane   ( chain[ 0 ], 6 )  );

    //connectChain( new ImgOpRowSum     ( chain[ 5+2 ] )  );
    //connectChain( new ImgOpHalfRowSum ( chain[ 5+2 ] )  );
    //connectChain( new ImgOpColSum     ( chain[ 5+2 ] )  );
    
    //connectChain(new ImgOpScale(chain[2] ));
    //connectChain(new ImgOpHistEq(chain[3] ));
    
    //connectChain(new ImgEyeMask( chain[2], edef[eyei].lx, edef[eyei].ly ) );
    //connectChain(new ImgOpScale( chain[2] ) );
    //setupChain( LF() );
  */

void execCmd(){
  smd = cmd.split(" ");

  if( cmd.equals("q") ){
    exit();
  } else if( hasElem(0, "l") ){
    //img = null;
    //setupChain(hasElem(1));
    String fn = hasElem(1);
    PGMImage loadimg = new PGMImage(fn); 
    appendChain( new ImgOpPalette(loadimg, fn) );
  } else if( hasElem(0, "L") ){
    img = null;
    setupChain(hasElem(1));
  } else if( hasElem(0, "LF") ){
    img = null;
    setupChain( LF() );
    nextChain();
  } else if( hasElem(0, "LE") ){
    LE();    
  } else if( hasElem(0, "LEA") ){
    int r;
    do {
      r = LE();
      ImgEyeFinder2 ef = (ImgEyeFinder2) chain[chain.length-1];
      String filename = chain[0].title;
      updateChain();
      println( filename + "\t" + ef.eyelx + "\t" + ef.eyely + "\t" + ef.eyerx + "\t" + ef.eyery );

    } while( r != edef.length -1 );
  } else if( hasElem(0, "d") ){
    int i = int(hasElem(1));
    dispChain(i);
  } else if( hasElem(0, "a") ){
    int p1 = int(hasElem(3)); 
    int ch = int(hasElem(1));
    String op = hasElem(2);
    if( ch == 0 ) {
      op = hasElem(1);
      ch = selChain;
      p1 = int(hasElem(2));
    }
    
    if(op.equals("hist")){
      appendChain(new ImgOpHist(chain[ch]));
      chain[chain.length - 1].updateme=true;
    } else if(op.equals("nhist")){
      appendChain(new ImgNoiseHist(chain[ch]));
      chain[chain.length - 1].updateme=true;
    } else if( op.equals("+") || op.equals("-") || op.equals("*") || op.equals("/") ){
      int ch1 = ch;
      int ch2 = int(hasElem(3));
      if(ch2 == 0) ch2 = int(hasElem(2));
      connectChain(new ImgOpArith(chain[ch1], chain[ch2], op.charAt(0) ));
    } else if(op.equals("neg")){
      connectChain(new ImgOpNegate(chain[ch]));
    } else if(op.equals("gamma")){
      float pf1 = float(hasElem(2));
      float pf2 = float(hasElem(3));
      connectChain(new ImgOpGamma(chain[ch], pf1, pf2));
    } else if(op.equals("thresh")){
      connectChain(new ImgOpThreshold ( chain[ch], p1 ) );
    } else if(op.equals("equal")) {
      connectChain(new ImgOpHistEq(chain[ch]));
    } else if(op.equals("filter")){
      connectChain(new ImgOpFilter(chain[ch]));
    } else if(op.equals("sharp")){
      connectChain(new ImgOpSharp(chain[ch]));
    } else if(op.equals("median")){
      connectChain(new ImgOpMedian(chain[ch]));
    } else if(op.equals("laplace")){
      int filt = int(hasElem(2));
      connectChain(new ImgOpLaplacian(chain[ch], filt));
    } else if(op.equals("sobel")){
      connectChain(new ImgOpSobel(chain[ch]));
    } else if(op.equals("prewitt")){
      connectChain(new ImgOpPrewitt(chain[ch]));
    } else if(op.equals("5x5")){
      connectChain(new ImgOp5x5(chain[ch]));
    } else if(op.equals("gauss")){
      float pf2 = float(hasElem(3));
      if(p1 == 0){
        connectChain(new ImgOpGaussian(chain[ch]));
      } else {
        connectChain(new ImgOpGaussian(chain[ch], p1, pf2));
      }
    } else if(op.equals("scale")){
      connectChain(new ImgOpScale(chain[ch]));
    } else if(op.equals("clip")){
      connectChain(new ImgOpClip(chain[ch]));
    } else if(op.equals("ch")){
      connectChain(new ImgOpChannel(chain[ch], p1));
    } else if(op.equals("hsi")){
      connectChain(new ImgOpRGBtoHSI(chain[ch]));
    } else if(op.equals("rgb")){
      connectChain(new ImgOpHSItoRGB(chain[ch]));
    } else if(op.equals("dft")){
      connectChain(new ImgOpDFT4(chain[ch]));
    } else if(op.equals("edgelocal")){
      connectChain(new ImgOpEdgeLocal(chain[ch]));
    } else if(op.equals("hgap")){
      connectChain(new ImgOpHGap(chain[ch]));
    } else if(op.equals("vgap")){
      connectChain(new ImgOpVGap(chain[ch]));
    } else if(op.equals("athresh")){
      int p2 = int(hasElem(3));
      connectChain(new ImgOpAThresh(chain[ch], p1, p2));
    } else if(op.equals("gthresh")){
      connectChain(new ImgSegGThresh(chain[ch]));
    } else if(op.equals("gmean")){
      connectChain(new ImgOpGMean(chain[ch]));
    } else if(op.equals("amean")){
      connectChain(new ImgOpAMean(chain[ch]));
    } else if(op.equals("eye")){
      connectChain(new ImgEyeFinder2(chain[ch]));
    } else if(op.equals("rowsum")){
      connectChain(new ImgOpRowSum(chain[ch]));
    } else if(op.equals("colsum")){
      connectChain(new ImgOpColSum(chain[ch]));
    } else if(op.equals("eyecrop")){
      connectChain(new ImgEyeCrop(chain[ch]));
    } else if(op.equals("sumxy")){
      connectChain(new ImgOpSumXY(chain[ch]));
    }      
  } else if( hasElem(0, "r") ){
    int i = int(hasElem(1));
    if(i == 0) i = selChain;
    removeChain(i);
    selChain--;
    dispChain(selChain);
  } else if( hasElem(0, "E") ){
    connectChain(new ImgOpSubst( chain[int(hasElem(2))], chain[selChain], int(hasElem(1)) ));
  } else if( hasElem(0, "e") ){
    connectChain(new ImgOpChannel(chain[selChain], int(hasElem(1)) ) );
  } else if( hasElem(0, "b") ){
    if(hasElem(1, "x")){
      int im = chain[selChain].imgMax;
      int np = int( log(im) / log(2) );
      for(int plane=np; plane >= 0; plane--){
        connectChain(new ImgOpBitPlane( chain[selChain], plane ) );
      }
    } else {
      connectChain(new ImgOpBitPlane( chain[selChain], int(hasElem(1)) ) );
    }
  } else if( hasElem(0, "B") ){
    connectChain(new ImgOpBitSubst( chain[int(hasElem(2))], chain[selChain], int(hasElem(1)) ) );
  } else if( hasElem(0, "c") ){
    chain[selChain].compute();
    chain[selChain].loadPImage(zoom);
  } else if( hasElem(0, "z" ) ){
    zoom = constrain( int(hasElem(1)), 1, 8 );
  } else if( hasElem(0, "ls") ){
    ls(CWD + hasElem(1));
  } else if( hasElem(0, "p" ) ){
    chain[selChain].printOut();
  } else if( hasElem(0, "pp" ) ){
    chain[selChain].printPal();
  } else if( hasElem(0, "macro") || hasElem(0, "M") ){
    String macro = "";
    switch( int( hasElem(1) ) ){
      case 1:
        macro = "a laplace 2;];a + 0;[;a sobel;]]];a 5x5;];a * 2;];a + 0;];a scale;];a gamma 0.4 -0.1";
        break;
      case 2:
        macro = "a bitplane 7;];a gamma 0.4 0.0;];a + 0;];a sobel;];a * 3;];a / 0;];a scale;];a gamma 0.4 0.0";
        break;
      case 3:
        macro = "a bitplane 7;a bitplane 6;a bitplane 5;a bitplane 4;a bitplane 3;a bitplane 2;a bitplane 1;a bitplane 0";
        break;
      case 4:
        macro = "a bitplane 7;a bitplane 6;]];a gamma 1.0 -0.5;];a + 1;];[[[[;a - 4;]]]]];a clip;[[[[[;a - 6;a * 7;]]]]]]]];a scale;]";
        break;
      case 5:
        macro = "a hist;a gamma 0.4 0.0;]];a hist;[[;a equal;]]]];a hist";
        break;
      case 23:
        macro = "L truck_rear.pgm;];a edgelocal;];a athresh 70 30;];e 0;e 1;];a hgap;];a vgap;]];a + 5";
        break;
      case 24:
        macro = "L fingerprint.pgm;];a hist;a gthresh";
        break;
      case 25:
        macro = "L noise.pgm;];a nhist";
        break;
      case 26:
        macro = "L noisy.pgm;];a gmean;a amean";
        break;
      default:
        macro = "";
    }
    execMacro(macro);
  }
  
  else if( cmd.startsWith("assignment ") ){
    assignment = Integer.parseInt(smd[1]);
    img = null;
    noLoop();
    setup();
  }
  
  else if( cmd.startsWith("[") ){
    for(int i = cmd.length(); i > 0; i--){
      prevChain();
    }
  } else if( cmd.startsWith("]") ){
    for(int i = cmd.length(); i > 0; i--){
      nextChain();
    }
  }
  
  cmd = "";
}

void execMacro(String macro){
  String[] cmds = split(macro, ";");
  for(int i=0; i < cmds.length; i++){
    cmd = cmds[i];
    execCmd();
  }
}

void nextChain(){
  if(selChain < chain.length - 1) selChain++; dispChain(selChain);
}
void prevChain(){
  if(selChain > 0) selChain--; dispChain(selChain);
}

void keyPressed(){
  if(key != CODED)
  switch(keyCode) {
    case BACKSPACE:
      if(cmd.length() > 0) cmd = cmd.substring(0, cmd.length() - 1);
      break;
    case RETURN:
    case ENTER:
      execCmd();
      break;
    case SHIFT:
      break;
    case '[':
      prevChain();
      break;
    case ']':
      nextChain();
      break;
    default:
      cmd += key;
      drawCmd();
  }
  loop();
}
void keyReleased(){
  draw();
  noLoop();
}