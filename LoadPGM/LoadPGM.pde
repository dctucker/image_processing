import java.io.File;

class LoadImage extends ImgData {
  public LoadImage(String filename){
    super();
    pimg = loadImage(filename);
    pimg.loadPixels();
    imgHeight = pimg.height;
    imgWidth = pimg.width;
    imgChannels = 4;
    imgMax = 255;
    imgData = new int[imgWidth][imgHeight][imgChannels];
    imgPalette = new color[imgMax + 1][imgChannels];
    setPalette(0, 1.0, 0.0, 0.0);
    setPalette(1, 0.0, 1.0, 0.0);
    setPalette(2, 0.0, 0.0, 1.0);
    imgScale = 1.0f;

    for(int x=0; x < imgWidth; x++){
      for(int y=0; y < imgHeight; y++){
        color c = pimg.pixels[ x + y * imgWidth ];
        imgData[x][y][0] = c >> 16 & 0xFF;
        imgData[x][y][1] = c >> 8  & 0xFF;
        imgData[x][y][2] = c & 0xFF;
        //print(c);
      }
      //println("");
    }    
  }
}

class PGMImage extends ImgData {        // class for PGM file I/O
  String magicNumber;
  public PGMImage(String filename) {
    super();
    imgChannels = 1;
    loadPGM(filename);
    setPalette(1.0, 1.0, 1.0);
    imgPalette[0][0] = color(0,0,0);
    imgPalette[imgMax][0] = color(255,255,255);
    loadPImage(zoom);
    //System.out.println("Image: " + imgWidth + "x" + imgHeight + ":" + imgMax);
  }
  public boolean readHeader(int header, String sj){
    switch(header){
    case 0:                       // magic number
      magicNumber = sj;
      if(!(sj.equals("P2") || sj.equals("P5"))) return false;
      break;
    case 1:                       // width
      imgWidth = int(sj);
      break;
    case 2:                       // height
      imgHeight = int(sj);
      imgData = new int[imgWidth][imgHeight][imgChannels];
      if(imgHeight > 620) imgHeight = 620;
      break;
    case 3:                       // maximum pixel value
      imgMax = int(sj);
      imgPalette = new color[imgMax + 1][1];
      imgScale = 255.0f / ((float)imgMax);
      break;
    }
    return true;
  }

  // loads a PGM image from a file into memory
  public boolean loadPGM(String filename) {
    /*
    String fn = filename;
     File f = new File(filename);
     if(!f.exists()){
     filename = "data/proj/test/" + fn;
     f = new File(filename);
     if(!f.exists()){
     filename = "data/proj/training/" + fn;
     f = new File(filename);
     if(!f.exists()) {
     println("File not found");
     return false;
     }
     }
     }
     */

    //System.out.println("Loading " + filename);
    String[] lines = loadStrings(filename);
    int header = 0;
    int row=0, col=0;
    for(int i=0; i < lines.length; i++) {     // start out reading in ASCII mode
      if(header < 4){
        if(lines[i].charAt(0) != '#') {
          String[] s = splitTokens(lines[i], " \t\n");
          for(int j=0; j < s.length; j++) {
            if( ! readHeader(header, s[j]) ){
              System.err.println("Wrong magic number: " + magicNumber);
              return false;
            }
            header++;
          }
        }
      } 
      else if(magicNumber.equals("P2")) { // ASCII data
        if(row < imgHeight) { // to tolerate erroroneous files, don't overfill array
          String[] s = splitTokens(lines[i], " \t\n");
          for(int j=0; j < s.length; j++) {   
            imgData[col][row][0] = int(s[j]); 
            col++;
            if(col >= imgWidth) { // with this structure, newlines are whitespace
              row++;              // instead of row/column governing structural elements
              col = 0;
            }
          }//end for
        }//end if
      } 
      else if(magicNumber.equals("P5")) { // RAW data follows, switch to binary mode
        int begin=0, k=0;
        byte[] b = loadBytes(filename);
        String s ="";
        String[] heads = new String[4];
        heads[0] = ""+magicNumber;
        heads[1] = ""+imgWidth;
        heads[2] = ""+imgHeight;
        heads[3] = ""+imgMax;

        for(int j=0; j < b.length; j++){ // reread over the header until we've reached the end
          if(k >= 4) {
            begin=j+1;
            break;
          } 
          else {
            s += (char)(b[j] & 0xff);
            //System.out.println(s);
            if(s.equals(heads[k])){
              //System.out.println("Found " +k + ": "+ heads[k]);
              k++;
              s="";
            }
            if(b[j] == '\n' || b[j] == '\r' || b[j] ==' '){
              s="";
            }
          }
        }
        // now we're ready to load the raster
        if(imgMax < 256) { // one byte...
          for(int j=begin; j < b.length; j++){
            imgData[col][row][0] = b[j] & 0xff;
            col++;
            if(col >= imgWidth) {
              row++;
              col=0;
            }
          }
        } 
        else { // ...or two
          for(int j=begin; j < b.length; j+=2){
            imgData[col][row][0] = (int)(b[j] & 0xff) * 256 + (int)(b[j+1] & 0xff);
            col++;
            if(col >= imgWidth) {
              row++;
              col=0;
            }
          }
        }
        break;
      }
    }

    pimg = new PImage(imgWidth * zoom , zoom * imgHeight, RGB); // finally, set up the display structure
    return true;
  }//end load

  public boolean savePGM(String filename, int magic){ // to be written
    // convert from color to grayscale: 0.3 * red + 0.59 * green + 0.11 * blue
    PrintWriter output = createWriter(filename);
    output.print("P"+magic+"\n# created by DCT\n");
    output.print(""+ imgWidth +" "+ imgHeight +"\n"+ imgMax +"\n");

    if(magic == 2) {          // ASCII mode
      for(int y=0; y < imgHeight; y++) {
        output.print("" + imgData[0][y][0]);
        for(int x=1; x < imgWidth; x++) {
          output.print( " " + imgData[x][y][0] );
        }
        output.print("\n");
      }
    } 
    else if(magic == 5) {   // binary mode
      if(imgMax < 256) {                        // one byte per pixel
        for(int y=0; y < imgHeight; y++) {
          for(int x=0; x < imgWidth; x++) {
            char c = (char)(imgData[x][y][0] & 0xff);
            output.print( c );
          }
        }
      } 
      else {                                  // two bytes per pixel
        for(int y=0; y < imgHeight; y++) {
          for(int x=0; x < imgWidth; x++) {
            char c1 = (char)(imgData[x][y][0] & 0x00ff);
            char c2 = (char)(imgData[x][y][0] & 0xff00);
            output.print( c2 );
            output.print( c1 );
          }
        }
      }
    } 
    else {
      System.err.println("Magic number " + magic + " not supported.");
    }
    output.flush(); // Write the remaining data
    output.close(); // Finish the file

      return true;
  }
}//end class
