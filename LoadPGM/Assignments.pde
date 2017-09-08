
// assignment 1
public void setupAssignment1(){
//  setupChain("starP5.pgm");

//  if( img.savePGM("output.pgm", 5) ) {
//      System.out.println("output.pgm written");
//  } else {
//    System.err.println("file couldn't be written");
//  }
}

// assignment 2
public void setupAssignment2(){
  setupChain("starP5.pgm");
  Pixel p, q;
  p = new Pixel( 0, 13 );
  q = new Pixel( 8, 18 );
  //p = new Pixel(  0, 13 );
  //q = new Pixel( 20, 14);
  ImgOpDistance V20 = new ImgOpDistance(chain[0], p, q, 20);
  ImgOpDistance V5  = new ImgOpDistance(chain[0], p, q, 5);
  appendChain( V20 );
  appendChain( V5  );
  chain[0].visible = true;
  chain[1].visible = true;
  chain[2].visible = true;
  chain[1].imgPalette = chain[0].imgPalette;
  chain[2].imgPalette = chain[0].imgPalette;
  chain[0].updateme = true;
}

void drawAssignment2(){
  boolean u = chain[0].update();
  for(int i=0; i < chain.length; i++){
    if(chain[i].visible) {
      if(u) {
        chain[i].loadPImage(zoom);
      }
      image(chain[i].pimg, chain[i].posLeft, 0);
    }
  }
}

// assignment 3
public void setupAssignment3(){
  setupChain("starP5.pgm");
  String filename = "invStarP2.pgm";
  img2 = new PGMImage(filename);
  ImageOp iop2 = new ImgOpPalette(img2);
  iop2.title = filename;
  iop2.copyFrom(img2);
  iop2.compute();
  appendChain(iop2);
  add = new ImgOpArith(chain[0], chain[1], '+');
  sub = new ImgOpArith(chain[0], chain[1], '-');
  mul = new ImgOpArith(chain[0], chain[1], '*');
  div = new ImgOpArith(chain[0], chain[1], '/');
  chain[0].visible = true;
  chain[1].visible = true;
  add.visible = true;
  sub.visible = true;
  mul.visible = true;
  div.visible = true;
  appendChain(add);
  appendChain(sub);
  appendChain(mul);
  appendChain(div);
  chainPalette = chain.length - 1;
}

public void drawAssignment3(){
  if( chain[0].update() || chain[1].update() ) {
    add.loadPImage();
    sub.loadPImage();
    mul.loadPImage();
    div.loadPImage();
    div.drawPalette( 20, img.imgHeight + 4);
  }
  image(chain[0].pimg,  0, 0);
  image(chain[1].pimg, 40, 0);
  image(add.pimg, add.posLeft, 0);
  image(sub.pimg, sub.posLeft, 0);
  image(mul.pimg, mul.posLeft, 0);
  image(div.pimg, div.posLeft, 0);
}

public void setupAssignment4(){
  extraWidth = 500;
  setupChain("homework4.pgm");
  //appendChain( new ImgOpHist(chain[0]) );
  chain[0].visible = true;
  chain[0].updateme = true;
  
  execMacro("a hist;a gamma 0.4 0.0;]];a hist;[[;a equal;]]]];a hist");

  //appendChain( new ImgOpHistEq(chain[0]) );
  chain[2].imgPalette = chain[0].imgPalette;
  chain[2].visible = true;
  chain[2].updateme=true;
  
  //appendChain( new ImgOpHist(chain[2]) );
  chain[3].visible = true;
  chain[3].updateme = true;

}
public void drawAssignment4(){
  boolean u = chain[0].update();
  for(int i=0; i < chain.length; i++){
    if(chain[i].update()) {
      chain[i].compute();
    }
    chain[i].loadPImage(zoom);

  }
  image(chain[0].pimg, 0, 0);
  if(chain.length > 2) image(chain[2].pimg, 400, 0);
  if(chain.length > 4) image(chain[4].pimg, 720, 0);
}
