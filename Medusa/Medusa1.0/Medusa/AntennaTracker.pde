import gab.opencv.*;
import java.awt.Rectangle;
import org.opencv.core.Mat;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.CvType;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;
import org.opencv.core.Scalar;
import org.opencv.core.Core;


public class AntennaTracker{
  
  private PApplet app;
  private OpenCV opencv;
  private KinectHandler kh;
  private PImage src;
  //public ArrayList<Contour> contours;
  //public ArrayList<Rectangle> rectangles;
  //public ArrayList<Rectangle> neoPixels;
  //public Hashtable<Integer,PVector> neoHash; //a hash which contains the found center of the neoPixel

  // <1> Set the range of Hue values for our filter
  //ArrayList<Integer> colors;
  public int maxColors = 4;
  public int[] hues;
  public int[] colors;
  public int rangeWidth = 10;
  
  public final float ANTENNA_WIDTH = 83.0; //in mm to estimate space between neopixels
  public final float ANTENNA_HEIGHT = 53.0; //in mm to estimate space between neopixels in vertical direction (i.e. the ethernet socket face down)

  public PImage[] outputs;

  public int colorToChange = -1;
  
  public Date d;
  
  public AntennaTracker(){
    
  }

  public AntennaTracker(PApplet _app, OpenCV _opencv,KinectHandler _kinectHandler){
  //video = new Capture(this, 640, 480);
  //opencv = new OpenCV(this, video.width, video.height);
  this.app = _app;
  this.opencv = _opencv;
  this.kh = _kinectHandler;
  //contours = new ArrayList<Contour>();
  //rectangles = new ArrayList<Rectangle>();
  //neoPixels = new ArrayList<Rectangle>();
  //neoHash = new Hashtable<Integer,PVector>();
  
  //size(opencv.width + opencv.width/4 + 30, opencv.height, P2D);
  
  // Array for detection colors
  colors = new int[maxColors];
  hues = new int[maxColors];
  
  outputs = new PImage[maxColors];
  d = new Date();
  
  //video.start();
  }
  
  public void PImagetoM3(PImage img, Mat m){
    BufferedImage image = (BufferedImage)img.getNative();
    int[] matPixels = ((DataBufferInt)image.getRaster().getDataBuffer()).getData();
    neoColor temp = new neoColor(0); //default initializer
    byte[] colors = new byte[3];
    for (int i = 0; i < m.rows(); i++){
     for (int j = 0; j < m.cols(); j++){
       temp.setColor(matPixels[(i*640)+j]);
       colors[0] = (byte) temp.blue;
       colors[1] = (byte) temp.green;
       colors[2] = (byte) temp.red;
       m.put(i,j,colors);
     }
    }
}

 
 public void M3toPImage(Mat m, PImage img){
    int pixelCount = m.rows()*m.cols();
    byte[] colors = new byte[3];
    neoColor temp = new neoColor(0);
    for (int i = 0; i < m.rows(); i++){
     for (int j = 0; j < m.cols(); j++){
       m.get(i,j,colors);
       temp.setColor(colors[2],colors[1],colors[0]); //r,g,b
       img.pixels[(i*640)+j] = temp.getColorAsInt();
       //colors[0] = (byte) temp.blue;
       //colors[1] = (byte) temp.green;
       //colors[2] = (byte) temp.red;
      // m.put(i,j,colors);
     }
    }
 }
 


public void RGB2HSV(PImage rgb, PImage hsv){
  //Scalar Constructor Scalar(b,g,r,a)
  //create two 3-channel matrices to hold information and fill with black
      Mat rgbMat,hsvMat;
      Scalar modifier = new Scalar(0,0,0);
      rgbMat = new Mat(480,640,CvType.CV_8UC3,modifier);
      hsvMat = new Mat(480,640,CvType.CV_8UC3,modifier);
      
      PImagetoM3(rgb,rgbMat);
      
      Imgproc.cvtColor(rgbMat,hsvMat, Imgproc.COLOR_BGR2HSV);
      
      M3toPImage(hsvMat, hsv);
} 

public void update(PImage frame) {
  
  //background(150);
  
  //if (video.available()) {
    //video.read();
  //}

  // <2> Load the new frame of our movie in to OpenCV
  opencv.loadImage(frame);
  
  // Tell OpenCV to use color information
  opencv.useColor();
  src = opencv.getSnapshot();
  
  // <3> Tell OpenCV to work in HSV color space.
  opencv.useColor(HSB);
  
  detectColors();
  
  // Show images
  image(src, 0, 0);
  for (int i=0; i<outputs.length; i++) {
    if (outputs[i] != null) {
      image(outputs[i], 700, 0, src.width, src.height);
      
      noStroke();
      fill(colors[i]);
      rect(src.width, i*src.height/4, 30, src.height/4);
    }
  }
  
  // Print text if new color expected
  textSize(20);
  stroke(255);
  fill(255);
  
  if (colorToChange > -1) {
    text("click to change color " + colorToChange, 10, 25);
  } else {
    text("press key [1-4] to select color", 10, 25);
  }
  
  //displayContoursBoundingBoxes();
}

//////////////////////
// Detect Functions
//////////////////////

 public void findLEDs(PImage rgbImage){
      PImage hsvImage = new PImage(640,480);
      RGB2HSV(rgbImage,hsvImage);
      opencv.loadImage(hsvImage);
      Scalar RHIGH = new Scalar(0,0,254);
      Scalar RLOW = new Scalar(0,0,245);
      Mat hsvMat = new Mat(480,640,CvType.CV_8UC3,new Scalar(0,0,0));
      PImagetoM3(hsvImage,hsvMat);
      Core.inRange(hsvMat,RLOW,RHIGH,hsvMat);
      M3toPImage(hsvMat,hsvImage);
      
      opencv.loadImage(hsvImage);
      opencv.dilate();
      image(opencv.getSnapshot(),0,0);
      //contours = opencv.findContours(true,true);
      //displayContoursBoundingBoxes();
 }
 
 public void findAntennaLocation(PImage img, trackingElement el, testCase TC, boolean showImage){
   //Start an attempt to find the antenna for this test case
   TC.attempts += 1;
   
   //Will be either RGB or HSV image depending on tracking Element settings
    PImage rgbImage = img;
    Mat rgbMat = new Mat(480,640,CvType.CV_8UC3,new Scalar(0,0,0));
    ArrayList<Rectangle> rectangles = new ArrayList<Rectangle>();
    ArrayList<Rectangle> neoPixels = new ArrayList<Rectangle>();
    PImagetoM3(img,rgbMat);
    opencv.useColor(RGB);
    Scalar LOWTHRESH = new Scalar(((int) 0x00FF & el.filterLow.blue),((int) 0x00FF & el.filterLow.green),((int) 0x00FF & el.filterLow.red));
    Scalar HIGHTHRESH = new Scalar(((int) 0x00FF & el.filterHigh.blue),((int) 0x00FF & el.filterHigh.green),((int) 0x00FF & el.filterHigh.red));
    Core.inRange(rgbMat, LOWTHRESH, HIGHTHRESH, rgbMat);
      M3toPImage(rgbMat, rgbImage);
      opencv.setGray(rgbMat); 
      opencv.dilate();
      opencv.erode();
      
      if(showImage)
        image(opencv.getSnapshot(),0,0);
      ArrayList<Contour> contours = opencv.findContours(true,true);
      displayContoursBoundingBoxes(contours,el,rectangles,showImage);
     int retVal = analyzeBoxes(rectangles,neoPixels);
     if(retVal == 1){
        analyzeAntennaDimensions(neoPixels,el,TC, showImage); 
     }
 }
 
public void detectColors() {
    
  for (int i=0; i<hues.length; i++) {
    
    if (hues[i] <= 0) continue;
    
    opencv.loadImage(src);
    opencv.useColor(HSB);
    opencv.setGray(opencv.getH().clone());
    
    int hueToDetect = hues[i];
    outputs[i] = opencv.getSnapshot();
  }
  
  // <7> Find contours in our range image.
  //     Passing 'true' sorts them by descending area.
  if (outputs[0] != null) {
    
    opencv.loadImage(outputs[0]);
    //contours = opencv.findContours(true,true);
  }
}

void displayContoursBoundingBoxes(ArrayList<Contour> contours, trackingElement trckEl,ArrayList<Rectangle> rectangles, boolean showImage) {
  int rects = 0;
  rectangles.clear();
  for (int i=0; i<contours.size(); i++) {
    
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    
    if (r.width < 4 || r.height < 4)
      continue;
    
    rectangles.add(r);
    
    if(showImage){
    stroke(255, 0, 0);
    fill(255, 0, 0, 150);
    strokeWeight(2);
    rect(r.x, r.y, r.width, r.height);
    }
    //if(rects >= 2)
    //estimateNeoLocation(r, rects);
    ++rects;
  }
  //analyzeBoxes();
}

public int analyzeBoxes(ArrayList<Rectangle> rectangles, ArrayList<Rectangle> neoPixels){
    int rectCount = rectangles.size();
    int big1Count = 0;
    int big2Count = 0;
    
    neoPixels.clear();
    if(rectCount >= 6){
      println("got 6 rectangles");
      Rectangle bigRect1 = rectangles.get(0);
      Rectangle bigRect2 = rectangles.get(1);
      neoPixels.clear();
      for(int i = 2; i < rectCount; ++i){
          if(withinBoundingBox(bigRect1,rectangles.get(i))){
              ++big1Count;
              neoPixels.add(rectangles.get(i));
          }
              
              if(withinBoundingBox(bigRect2,rectangles.get(i))){
                ++big2Count;
                neoPixels.add(rectangles.get(i));
              }
      }
      
      if( (big1Count == 2) && (big2Count == 2) )
          return 1;
      
    } if(rectCount >= 5){
       println("Got 5 rectangles");
       Rectangle bigRect1 = rectangles.get(0);
       neoPixels.clear();
       int littleCount = 0;
       
       for(int i = 1; i < rectCount; ++i){
          if(withinBoundingBox(bigRect1,rectangles.get(i))){
              ++littleCount;
              neoPixels.add(rectangles.get(i));
          }
      }
      
      if(littleCount == 4){
        return 1;
      }
       
    }else{
      println("ANTENNA_TRACKER: Only found "+ rectCount+" rectangles, need to find 5 or 6");
    }
  return 0;
}

private void analyzeAntennaDimensions(ArrayList<Rectangle> neoPixels, trackingElement trckEl, testCase TC, boolean showImage){
  
  if(neoPixels.size() > 4)
    return; //should never be greater than 4
  
  Hashtable<Double,PVector> neoHash = new Hashtable<Double,PVector>();
  double[] ys = new double[neoPixels.size()];
  neoHash.clear();
  for(int i = 0; i < neoPixels.size(); ++i){
      PVector coords = getNeoRealCoordinates(neoPixels.get(i));
      //println("Y"+i+" "+coords.y);
      //neoHash.put((double)coords.x,coords);
      double lookup = coords.x+coords.y;
      //neoHash.put(i,coords);
      neoHash.put(lookup,coords);
      ys[i] = lookup;
  }
  
  Arrays.sort(ys);
  
  if(ys.length == 4){
     PVector pix1 = neoHash.get(ys[1]);
     PVector pix2 = neoHash.get(ys[0]);
     PVector pix3 = neoHash.get(ys[3]);
     PVector pix4 = neoHash.get(ys[2]);
     PVector dummy = neoHash.get(ys[3]);
     
     //PVector pix1 = neoHash.get(0);
     //PVector pix2 = neoHash.get(1);
     //PVector pix3 = neoHash.get(2);
     //PVector pix4 = neoHash.get(3);
     //PVector dummy = neoHash.get(3);
     long currentTime = System.nanoTime();
     
     
     
     //sort which is above and below
     if(pix4.y > pix1.y){
        dummy = pix4;
        pix4 = pix1;
        pix1 = pix4; 
     }
     
     /*if(pix4.y > pix3.y){
       dummy = pix3;
       pix3 = pix4;
       pix4 = dummy;
     }*/
     
     //println("Pix1 "+pix1.x+","+pix1.y+","+pix1.z+","+currentTime);
   // println("Pix2 "+pix2.x+","+pix2.y+","+pix2.z+","+currentTime);
   // println("Pix3 "+pix3.x+","+pix3.y+","+pix3.z+","+currentTime);
   // println("Pix4 "+pix4.x+","+pix4.y+","+pix4.z+","+currentTime);
     
     ////////////////////
     ///////////////////
     //no matter the rotation, for now just realize that
     //  
     //    1      3
     //
     //    2      4
     //
     ///////////////////////////////
    
     PVector diff12 = PVector.sub(pix1,pix2);
     PVector diff34 = PVector.sub(pix3,pix4);
     PVector diff13 = PVector.sub(pix3,pix1);
     PVector diff24 = PVector.sub(pix4,pix2);
     PVector diff14 = PVector.sub(pix1,pix4);
     PVector diff23 = PVector.sub(pix3,pix2);
     PVector add14 = PVector.add(pix1,pix4);
     PVector add23 = PVector.add(pix2,pix3);
     
    double widthConfidence = ((diff13.x+diff24.x)/2.0)/ANTENNA_WIDTH;
    double heightConfidence = ((diff12.y+diff34.y)/2.0)/ANTENNA_HEIGHT;
    
    //println("13: "+diff13.x+" |24: "+diff24.x+" |12: "+diff12.y+" |34: +"+diff34.y);
     
     if( (widthConfidence > TC.CONFIDENCE_LIMIT) && (heightConfidence > TC.CONFIDENCE_LIMIT)){
      
        double antennaX = (add14.x / 2.0 + add23.x/2.0)/2.0;
        double antennaY = (add14.y / 2.0 + add23.y/2.0)/2.0;
        double antennaZ = (add14.z / 2.0 + add23.z/2.0)/2.0;
      
      PVector antenna = new PVector((float)antennaX,(float)antennaY,(float)antennaZ);
      TC.diff12.add(diff12);
      TC.diff34.add(diff34);
      TC.diff13.add(diff13);
      TC.diff24.add(diff24);
      TC.pix1.add(pix1);
      TC.pix2.add(pix2);
      TC.pix3.add(pix3);
      TC.pix4.add(pix4);
      TC.antennas.add(antenna);
      
      //For drawing
      if(showImage){
      PVector pixelVals = new PVector();
      kh.convertRealWorldToPixels(antenna,pixelVals);
      stroke(255, 255, 0);
      fill(255, 255, 0, 150);
      strokeWeight(2);
      rect(pixelVals.x-5, pixelVals.y + 480-5, 10, 10);
      }
    
    //println("ANTENNA_TRACKER: ANTENNA SUCCESS - ANTX: "+antennaX+" ANTY: "+antennaY+" ANTZ: "+antennaZ);
     println(antenna.x+","+antenna.y+","+antenna.z+","+currentTime);
    TC.successes += 1;
    
    
    if(TC.successes == TC.SUCCESS_LIMIT){
      ah.updateElementHash();
      AntennaElement el = ah.elementHash.get(trckEl.elementID);
      if(el != null){
         el.setPhysicalLocation(TC.getMean(TC.antennas));
         el.setPixelPhysicalLocation(1,TC.getMean(TC.pix1));
         el.setPixelPhysicalLocation(2,TC.getMean(TC.pix2));
         el.setPixelPhysicalLocation(3,TC.getMean(TC.pix3));
         el.setPixelPhysicalLocation(4,TC.getMean(TC.pix4));
         //println(TC.getMean(TC.diff13).x);
         //float confidence = 100*(((TC.getMean(TC.diff12).y + TC.getMean(TC.diff34).y)/2.0)/ANTENNA_HEIGHT + ((TC.getMean(TC.diff13).x + TC.getMean(TC.diff34).x)/2.0)/ANTENNA_WIDTH);
         float confidence = ((((TC.getMean(TC.diff12).y)/ANTENNA_HEIGHT + (TC.getMean(TC.diff34).y)/ANTENNA_HEIGHT)/2.0) + (((TC.getMean(TC.diff13).x)/ANTENNA_WIDTH + (TC.getMean(TC.diff24).x)/ANTENNA_WIDTH)/2.0))/2.0*100.0;
        el.setConfidence(confidence);
        ah.updatePhysicalLocation(el); 
      }
    }
    
     }
     
     
     
     
     //need to adjust y distance due to z component i.e. the antenna could be tilted so the measurement maybe off
     /*double adj12 = sqrt(diff12.y*diff12.y + diff12.z*diff12.z); //yval
     double adj34 = sqrt(diff34.y*diff34.y + diff34.z*diff34.z);
     
     double adj13 = sqrt(diff13.x*diff13.x + diff13.z*diff13.z);
     double adj24 = sqrt(diff24.x*diff24.x + diff24.z*diff24.z);
     
     double avY = (adj12 + adj34)/2.0;
     double avX = (adj13 + adj24)/2.0;
     double avZ = diff14.z / 2.0;*/
     
      //double antennaY = (double) pix1.y - (avY/2.0);
      //double antennaX = (double) pix1.x + (avX/2.0);
      //double antennaZ = (double) pix1.z + avZ;
    //println("Pix1 "+pix1.x+","+pix1.y+","+pix1.z+","+currentTime);
    //println("Pix2 "+pix2.x+","+pix2.y+","+pix2.z+","+currentTime);
    //println("Pix3 "+pix3.x+","+pix3.y+","+pix3.z+","+currentTime);
    //println("Pix4 "+pix4.x+","+pix4.y+","+pix4.z+","+currentTime);
    /*ah.elements.get(0).setPhysicalLocation(antenna);
    ah.elements.get(0).setPixelPhysicalLocation(1,pix1);
    ah.elements.get(0).setPixelPhysicalLocation(2,pix2);
    ah.elements.get(0).setPixelPhysicalLocation(3,pix3);
    ah.elements.get(0).setPixelPhysicalLocation(4,pix4);
    ah.elements.get(0).setConfidence(80.0);
    ah.updatePhysicalLocation(ah.elements.get(0));*/
    
  }
    
}

private PVector getNeoRealCoordinates(Rectangle r){
  PVector[] realDepthVals;
  if(kh.isConnected()){
    realDepthVals = kh.getDepthMapRealWorld();  
  
  int pos = (r.x + r.width/2) + ((r.y + r.height/2) * 640); //get half of the box
  return realDepthVals[pos];
  }
 
 return new PVector(0.0,0.0,0.0);
}

private boolean withinBoundingBox(Rectangle bigRect, Rectangle littleRect){
       if( (littleRect.x > bigRect.x) && (littleRect.y > bigRect.y)){
            if( ((littleRect.x+littleRect.width) < (bigRect.x + bigRect.width)) && ( (littleRect.y + littleRect.height) < (bigRect.y + bigRect.height) ) ) {
               return true; 
            }
       }
      
      return false; 
}

public void estimateNeoLocation(Rectangle r, int count){
  PVector[] realDepthVals;
  if(kh.isConnected()){
    realDepthVals = kh.getDepthMapRealWorld();
    int pos1 = r.x + (r.y * 640);
    int pos2 = (r.x + r.width/2) + ((r.y + r.height/2) * 640);
    PVector upLeft = realDepthVals[pos1];
    PVector lowRight = realDepthVals[pos2];
    PVector diffVec = PVector.sub(lowRight,upLeft);
    double a = diffVec.x*diffVec.y;
    println("RECT"+count+" - x: "+lowRight.x+" y: "+lowRight.y+" z: "+lowRight.z);
    
  }else{
   println("ANTENNA_TRACKER: Kinect not connected"); 
  }
    
    
  
}


//////////////////////
// Keyboard / Mouse
//////////////////////

/*void mousePressed() {
    
  if (colorToChange > -1) {
    
    color c = get(mouseX, mouseY);
    println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
   
    int hue = int(map(hue(c), 0, 255, 0, 180));
    
    colors[colorToChange-1] = c;
    hues[colorToChange-1] = hue;
    
    println("color index " + (colorToChange-1) + ", value: " + hue);
  }
}*/

void keyPressed() {
  
  if (key == '1') {
    colorToChange = 1;
    
  } else if (key == '2') {
    colorToChange = 2;
    
  } else if (key == '3') {
    colorToChange = 3;
    
  } else if (key == '4') {
    colorToChange = 4;
  }
}

  void keyReleased() {
    colorToChange = -1; 
  }
}

public class testCase{
  public int attempts;
  public int successes;
  public final int SUCCESS_LIMIT = 1;
  public final int ATTEMPTS_LIMIT = 1;
  public final float CONFIDENCE_LIMIT = 0.85;
  public ArrayList<PVector> antennas;
  public ArrayList<PVector> diff13;
  public ArrayList<PVector> diff24;
  public ArrayList<PVector> diff12;
  public ArrayList<PVector> diff34;
  public ArrayList<PVector> pix1;
  public ArrayList<PVector> pix2;
  public ArrayList<PVector> pix3;
  public ArrayList<PVector> pix4;
  
  public testCase(){
   attempts = 0;
   successes = 0;
   antennas = new ArrayList<PVector>();
   diff13 = new ArrayList<PVector>();
   diff24 = new ArrayList<PVector>();
   diff34 = new ArrayList<PVector>(); 
   diff12 = new ArrayList<PVector>();
   pix1 = new ArrayList<PVector>();
   pix2 = new ArrayList<PVector>();
   pix3 = new ArrayList<PVector>(); 
   pix4 = new ArrayList<PVector>();
  }
  
  public PVector getMean(ArrayList<PVector> newVec){
     PVector retVec = new PVector(0,0,0);
     int size = newVec.size();
     for(int i = 0; i < size; ++i){
        retVec =  PVector.add(newVec.get(i),retVec);
     }
     retVec.div(size);
     return retVec; 
  }
  
  public PVector getVariance(ArrayList<PVector> newVec){
      PVector tempVec = new PVector(0,0,0);
      PVector retVec = new PVector(0,0,0);
      PVector meanVec = getMean(newVec);
      int size = newVec.size();
      for(int i = 0; i < size; ++i){
        tempVec =  PVector.sub(meanVec,newVec.get(i));
        tempVec.x *= tempVec.x;
        tempVec.y *= tempVec.y;
        tempVec.z *= tempVec.z;
        PVector.add(retVec,tempVec);
     }
     retVec.div(size);
     return retVec;
  }
  
  public PVector getStdDev(ArrayList<PVector> newVec){
      PVector retVec = getVariance(newVec);
      retVec.x = sqrt(retVec.x);
      retVec.y = sqrt(retVec.y);
      retVec.z = sqrt(retVec.z);
      return retVec; 
  }
  
}
