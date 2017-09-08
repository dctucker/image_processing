public class Pixel {
  public int x;
  public int y;
  public Pixel(int x, int y) { this.x=x; this.y=y; }
  public String toString(){
    return "(" + x + "," + y + ")";
  }
}

class ImgOpThreshold extends ImageOp {   // threshold operation
  HScrollbar hThresh;
  int threshold;
  public void setPos(int l){
    hThresh.setPos(5 + l);
    posLeft = l;
  }
  public ImgOpThreshold(ImgData img){
    super(img);
    updateme = true;
    title = "Threshold";
    threshold=128;
    hThresh = new HScrollbar(posLeft + 5, height-posTop + 50, "Threshold", 1, 255);
  }
  public ImgOpThreshold(ImgData img, int threshold){
    super(img);
    updateme = true;
    title = "Threshold";
    this.threshold = threshold;
    hThresh = new HScrollbar(posLeft + 5, height-posTop + 50, "Threshold", 1, 255);
    hThresh.setVal((float)threshold);  
  }
  public int calc(int x, int y, int ch){ // threshold operation
    int v = (int)(
                   (0.5 * imgMax) + in.imgData[x][y][ch] * (0.5 * imgMax) 
                                               / (2.0 * threshold)
                 );
    return ( in.imgData[x][y][ch] > threshold ) ? imgMax / 2 : 0;
  }
  public void display(){
    drawBox();
    hThresh.display(color(32,32,32));
  }
  public boolean update(){
    hThresh.update();
    int hv = (int)(hThresh.getVal() );
    if(threshold != hv) {
      threshold = hv;
      return true;
    }
    return false;
  }
}

public class ImgOpDistance extends ImgOpThreshold {
  Pixel p, q;            // pixels to find distance between
  float[] imgDistance;   // array of computed distances

  public ImgOpDistance(ImgData img) {
    super(img);
    title = "Distance";
    imgDistance = new float[3];
  }
  public ImgOpDistance(ImgData img, Pixel p, Pixel q, int thresh){
    super(img, thresh);
    imgPalette[imgMax][0] = color( 0, 255, 0 );
    title = "Distance";
    copyFrom(img);
    imgDistance = new float[3];
    this.p = p;
    this.q = q;
    p.x = constrain(p.x, 0, imgWidth  - 1);
    p.y = constrain(p.y, 0, imgHeight - 1);
    q.x = constrain(q.x, 0, imgWidth  - 1);
    q.y = constrain(q.y, 0, imgHeight - 1);
    
  }
  public void display(){
    super.display();
    String id0 = "De=" + imgDistance[0];
    String id1 = Float.isNaN(imgDistance[1]) ? "no D? path": ("D?="+imgDistance[1]);
    String id2 = Float.isNaN(imgDistance[2]) ? "no D? path": ("D?="+imgDistance[2]);
    textAlign(LEFT);
    text(p +" "+ q, posLeft + 5, height - posTop + 70);  
    text(id0, posLeft + 5, height - posTop + 90);
    textAlign(LEFT);
    text(id1, posLeft + 5, height - posTop + 104);
    text(id2, posLeft + 5, height - posTop + 118);
  }
  public ImgData compute(){         // computes all distance metrics
    imgData[p.x][p.y][0] = imgMax;
    imgData[q.x][q.y][0] = imgMax;
    
    String[] dmArr = { "euclidean", "cityblock", "chessboard" };

    for(int dm = 0; dm < 3; dm++){
      ImgData img = super.compute();

      String distMeasure = dmArr[dm];
      imgDistance[dm] = distance(p, q, distMeasure);

      if(Float.isNaN(imgDistance[dm])) {       // no path was found
        System.out.println("There is no " + distMeasure + " path between p"+ p +" and q"+ q +
        " under V={0.."+ threshold +"}");
      } else {
        System.out.println(distMeasure + " distance between p"+ p +" and q"+ q +
        " under V={0.."+ threshold +"} is " + imgDistance[dm]);
      }
    }
    return img;
  }
  public float De(Pixel p, Pixel q){         // euclidean distance
    int x=p.x, y=p.y, s=q.x, t=q.y;
    return sqrt( (x-s)*(x-s) + (y-t)*(y-t) );
  }
  public float D4(Pixel p, Pixel q){         // D? cityblock distance
    int d=0, i=0, x=p.x, y=p.y, s=q.x, t=q.y;
    while( i < imgHeight + imgWidth ){
      if     ( x > s && imgData[x-1][y][0] != 0 ){ x--; d++; }
      else if( x < s && imgData[x+1][y][0] != 0 ){ x++; d++; }
      imgData[x][y][0] = imgMax;
      
      if     ( y > t && imgData[x][y-1][0] != 0 ){ y--; d++; }
      else if( y < t && imgData[x][y+1][0] != 0 ){ y++; d++; }
      imgData[x][y][0] = imgMax;

      if(x == s && y == t) return d;
      i++;
    }
    return Float.NaN;
  }
  /*
  public int getD4Direction(int x, int y, int s, int t){
    int rR=0, rU=0, rL=0, rD=0, r=0;
    if( x > 0 && x < imgWidth );
    if( y > 0 && y < imgHeight );

    int R = (x+1 < imgWidth)  ? imgData[x+1][y][0] : 0;
    int L = (x-1 > 0)         ? imgData[x-1][y][0] : 0;
    int D = (y+1 < imgHeight) ? imgData[x][y+1][0] : 0;
    int U = (y-1 > 0)         ? imgData[x][y-1][0] : 0;

    if( R != imgMax ) rR++;    
    if( U != imgMax ) rU++;
    if( L != imgMax ) rL++;
    if( D != imgMax ) rD++;

    if( rR == rU && rU == rL && rL == rD){
      if ( x > s ) rL ++;
      if ( x < s ) rR ++;
      if ( y > t ) rU ++;
      if ( y < t ) rD ++;
    }

    if( R == 0 ) rR=0;
    if( U == 0 ) rU=0;
    if( L == 0 ) rL=0;
    if( D == 0 ) rD=0;
    
    if( rR > rL ) r = 0;
    if( rU > rD ) r = 1;
    if( rL > rU ) r = 2;
    if( rD > rL ) r = 3;
    
    return r;
    //return R+L+U+D;
  }
  public float D4(Pixel p, Pixel q){         // D? cityblock distance
    int d=0, i=0, x=p.x, y=p.y, s=q.x, t=q.y;
    while( i < (imgHeight * imgWidth) ){
      switch(getD4Direction(x, y, s, t)){
        case 0: x++; break;
        case 1: y--; break;
        case 2: x--; break;
        case 3: y++; break;
        default: d--;
      }
      d++;
      
      imgData[x][y][0] = imgMax;
      if(x == s && y == t) return d;
      i++;
    }
    return Float.NaN;
  }
  */
  /*
  public float D4(Pixel p, Pixel q){         // D? cityblock distance
    int d=0, i=0, x=p.x, y=p.y, s=q.x, t=q.y;
    Pixel traversed[] = new Pixel[imgWidth * imgHeight];
    int direction=3;
    //if     ( x < s ) direction = 0; // right
    //else if( y < t ) direction = 1; // up
    //else if( x > s ) direction = 2; // left
    //else if( y < t ) direction = 3; // down
    
    while( i < (imgHeight * imgWidth)*100 ){
      switch(direction){
        case 0: // right
          if( x+1 < imgWidth ) {
            if ( imgData[x+1][y][0] != 0 ) {
              x++;
              d++;
            } else if(imgData[x][y-1][0] != 0) {
              imgData[x][y][0] = 0;
              direction++;
            } else {
              imgData[x][y][0] = 0;

              direction+=3;
            }
          }
        break;
        case 1: // up
          if( y-1 > 0 ) {
            if( imgData[x][y-1][0] != 0 ) {
              y--;
              d++;
            } else if( imgData[x-1][y][0] !=0 ){
              imgData[x][y][0] = 0;
              direction++;
            } else {
              direction+=3;
              imgData[x][y][0] = 0;

            }
          }
        break;
        case 2: // left
          if( x-1 > 0 ) {
            if( imgData[x-1][y][0] != 0 ){
              x--;
              d++;
            } else if (imgData[x][y+1][0] != 0 ){
              imgData[x][y][0] = 0;
              direction++;
            } else {
              imgData[x][y][0] = 0;

              direction+=3;
            }
          }
        break;
        case 3: // down
          if( y+1 < imgHeight ) {
            if( imgData[x][y+1][0] != 0 ){
              y++;
              d++;
            } else if( imgData[x][y-1][0] !=0 ){
              imgData[x][y][0] = 0;
              direction++;
            } else {
              imgData[x][y][0] = 0;
              direction+=3;
            }
          }
        break;
      }
      direction %= 4;
      imgData[x][y][0] = imgMax;
      if(x == s && y == t) return d;
      i++;
    }
    return Float.NaN;
  }
  */

  public float D8(Pixel p, Pixel q){         // D? chessboard distance
    int d=0, i=0, x=p.x, y=p.y, s=q.x, t=q.y;
    Pixel [] traversed = new Pixel[imgWidth + imgHeight];
    while( i < imgWidth + imgHeight){
      int x1=x, y1=y, d1 = d;

      // try moving vertically / horizontally first
      if     ( x > s && imgData[x-1][y][0] != 0 ){ x--; }
      else if( x < s && imgData[x+1][y][0] != 0 ){ x++; }
      if     ( y > t && imgData[x][y-1][0] != 0 ){ y--; }
      else if( y < t && imgData[x][y+1][0] != 0 ){ y++; }
      
      if( x1 != x || y1 != y ){ // we moved one unit in either direction
        d++; 
      } else {                  // try moving exclusively diagonal
        if       ( x > s ){   
          if     ( y > t && imgData[x-1][y-1][0] != 0 ){ x--; y--; d++; }
          else if( y < t && imgData[x-1][y+1][0] != 0 ){ x--; y++; d++; }
        } else if( x < s ){
          if     ( y < t && imgData[x+1][y+1][0] != 0 ){ x++; y++; d++; }
          else if( y > t && imgData[x+1][y-1][0] != 0 ){ x++; y--; d++; }
        }
      }
      
      imgData[x][y][0] = imgMax;
      if( x  == s && y  == t ){ return d; }
      
      if( d1 == d ) {            // we didn't go anywhere, go back!
        imgData[x][y][0] = 0;
        d--;
        if( d < 0 ) return Float.NaN;
        x = traversed[d].x;
        y = traversed[d].y;
      } else {
        traversed[d-1] = new Pixel(x,y);
      }
      i++;
    }
    return Float.NaN;
  }
  public float distance(Pixel p, Pixel q, String dist_measure){ // interface
    int x = p.x, y = p.y, s = q.x, t = q.y;
    if     ( dist_measure.equals("euclidean" ) ) { return De(p,q); }
    else if( dist_measure.equals("cityblock" ) ) { return D4(p,q); }
    else if( dist_measure.equals("chessboard") ) { return D8(p,q); }
    return Float.NaN;
  }

}
