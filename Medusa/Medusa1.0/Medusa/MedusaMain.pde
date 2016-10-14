//Main Window to handle main program
//Written by Jeff Jensen 2015


import java.awt.Rectangle;
import java.util.ArrayList;
import g4p_controls.*;
import gab.opencv.*;
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
import java.util.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

//OpenCVgr
OpenCV opencv;

//Scanning
GButton scanButton;

//3D View
Antenna3D at3d;
GButton start3d;

//Kinect Thread
public Thread tuningThread;
public Thread showHSVThread;
public Thread colorChooser;
public Thread elPanelUpdateThread;
public Thread trackingThread;

//Main Images 
PImage filteredRGB;
PImage HSVIMAGE;

//Tuning Panel
GSlider redSlider;
GSlider blueSlider;
GSlider greenSlider;
GSlider redSliderLow;
GSlider blueSliderLow;
GSlider greenSliderLow;
GLabel tuningLabel1;
GLabel tuningLabel2;
GLabel tuningLabel3;
GLabel tuningLabel4;
GLabel tuningLabel5;
GLabel tuningLabel6;
GCheckbox rgbView;
GCheckbox hsvView;
GButton setFilter;
boolean tuningChecked = false;

//Tracking Panel
GCheckbox trackRed;
GCheckbox trackGreen;
GCheckbox trackBlue;
GCheckbox trackRGB;
boolean trackImage = false;

//Cube Control Panel
GLabel configCom;
GLabel thetaLabel;
GLabel phiLabel;
GTextField comPortText;
GButton cubeConnect;
GButton cubeDisconnect;
GTextField  thetaText;
GTextField  phiText;
GButton sendAngles;
GButton sendCoords;
GButton printCoords;
GButton printPhases;
GButton randomError;
GButton sendAllCoords;

//These calculations will provide meters
//will need to watch out as most other things will be in mm
//from the kinect.
float FREQUENCY = 2.4e09; 
float LIGHTSPEED = 3.0e08;

//Element Panel
elementPanel elPanel;

//Position Panel
PositionPanel posPanel;

//Window Properties
int WINDOW_HEIGHT = 960;
int WINDOW_WIDTH = 1280;

//Antenna Tracker
AntennaTracker at;

//Key Handler
KeyHandler keyh;

udpClient UDP;  // define the UDP object
//MedusaMessageHandler mh;
//MedusaSQLHandler mSQL;
KinectHandler kh;
AntennaElementHandler ah;
MedusaCubeHandler mch;
//GuiColorPicker cp;


// Controls used for colour chooser dialog GUI 
GButton btnColor;
GSketchPad spad;
PGraphics pg;
int sel_col = -1;

//Controls used for Kinect Display
GCheckbox enableRGB;
GCheckbox enableDepth;
GCheckbox enableHSV;
int rgbXOffset = 0;
int rgbYOffset = 480;
int depthXOffset = 640;
int depthYOffset = 480;

// Graphic frames used to group controls
ArrayList<Rectangle> rects ;

//Kinect Display


void setup() {
  
    size(WINDOW_WIDTH, WINDOW_HEIGHT, OPENGL);
    background(240,240,240);
    
    //
    filteredRGB = new PImage(640,480);
    HSVIMAGE = new PImage(640,480);
    
    //build our classes first
      opencv = new OpenCV(this,640,480);
      UDP = new udpClient(this);
     //mSQL = new MedusaSQLHandler(this);
     kh = new KinectHandler(this);
     ah = new AntennaElementHandler(this, UDP); 
     at = new AntennaTracker(this,opencv,kh);
     keyh = new KeyHandler(this,ah,at);
     mch = new MedusaCubeHandler(this);
     
    
    //thread initialization
    tuningThread = new Thread();
    showHSVThread = new Thread();
    colorChooser = new Thread();
    elPanelUpdateThread = new Thread(); 
    trackingThread = new Thread();
       

  //for displaying the wire frame boxes
  rects = new ArrayList<Rectangle> ();
  
  //for displaying the elements in the element panel
  

  //build various GUI windows
  createColorChooserGUI(1100, 20, 160, 60, 6);
  createKinectControl(1100, 100, 160, 110, 6);
  createTuningPanel(1100, 220, 160, 410, 6);
  createTrackingPanel(1100,640,160, 100, 6);
  createCubeControlPanel(920,100,160,350,6);
  create3DGUI(1100,750,160,60,6);
  elPanel = new elementPanel(this,ah,10,10,800,480);
  posPanel = new PositionPanel(this,ah,10,500,640,480);
  scanButton = new GButton(this, 1010, 20, 80, 20, "Scan");


 }
 
 void draw()
 {
   background(240,240,240);
   for (Rectangle r : rects)
    showFrame(r);
    
    if((kh.isConnected())){
      showKinect();
      //kinectThread = new Thread(new showKinect());
      //kinectThread.start();
      showTracking();
    }
      

 }
 
 
 public void showTracking(){
      
      if(trackGreen.isSelected()){
        trackAntennaProcedure(false);
          if(!(trackingThread.isAlive())){
          trackingThread = new Thread((new trackSingleAntenna()));
          trackingThread.start();
      }
      }else if((trackRed.isSelected())){
        trackImage = true;
         trackAntennaProcedure(true);
         println("WARNING: SCREEN MAY BE NON RESPONSIVE"); 
      }else if((!trackRed.isSelected()) && (trackImage == true)){
         trackImage = false; 
      }

 }
 
 public class trackSingleAntenna implements Runnable{
   
   public trackSingleAntenna(){
     
   }
   
   public void run(){
       trackAntennaProcedure(false);
   }
  
   
 }
 
 public void trackAntennaProcedure(boolean showImage){
   trackingElement temp = elPanel.getTrackCheckedElement();
        if(temp != null){
          testCase TC = new testCase();
          
          while( TC.successes < TC.SUCCESS_LIMIT){
            println("Attempts: "+TC.attempts);
            kh.updateKinect();
            PImage rgbImage = kh.getRGBImage();
            PImage hsvImage = new PImage(640,480);
            //PImage rgbCopy = new PImage(640,480);
            //rgbCopy = rgbImage;
            at.RGB2HSV(rgbImage, hsvImage);
           
            at.findAntennaLocation(hsvImage,temp, TC, showImage);
            if(TC.attempts > TC.ATTEMPTS_LIMIT){
               println("Failed to find antenna");
              break; 
            }
          }
        }
 }
 
 //function which handles all realtime display of kinect
 public void showKinect() {
   

   kh.updateKinect();
   
   if(enableRGB.isSelected()){
     PImage rgb_image = kh.getRGBImage();
     //at.update(rgb_image);
     image(rgb_image,rgbXOffset,rgbYOffset);
     //opencv.loadImage(rgb_image);
     //PImage src = opencv.getSnapshot();
     if((rgbView.isSelected()) || (hsvView.isSelected())){
       tuneImages(rgb_image);
     image(filteredRGB,0,0);
     }else{
      //Important reset the tuning checked latch
       tuningChecked = false; 
     }
     //opencv.useColor(RGB);
     //opencv.loadImage(src);
     
     //opencv.useColor(HSB);
     //opencv.setGray(opencv.getB().clone());
     //opencv.threshold(80);
     //int detectR = 0xFFFF0000;
     //int detectRange = 0xFFAA0000;
     //opencv.inRange(detectR - detectRange/2, detectR + detectRange/2);
   }else{
     image(kh.getWhiteImage(),rgbXOffset,rgbYOffset);
   }
   
   if(enableDepth.isSelected()){
      image(kh.getDepthImage(),depthXOffset,depthYOffset); 
   }else{
     image(kh.getWhiteImage(),depthXOffset,depthYOffset);
   }
   
   if(enableHSV.isSelected()){
      PImage rgbImage = kh.getRGBImage();
      if(!(showHSVThread.isAlive())){
         showHSVThread = new Thread(new convertHSV(rgbImage));
         showHSVThread.start(); 
      }
      
      image(HSVIMAGE,0,0); 
   }
   
 }
 
 public void updateElPanel(){
   
     if(!(elPanelUpdateThread.isAlive())){
        elPanelUpdateThread = new Thread(( new elPanelUpdate()));
        elPanelUpdateThread.start(); 
     }
 }
 
 public class elPanelUpdate implements Runnable{
  
  public elPanelUpdate(){
    
  }
 
  public void run(){
     elPanel.updateRows();
  } 
 }
 
 public class convertHSV implements Runnable {
    
    PImage rgbImage = new PImage(640,480);
    PImage hsvImage = new PImage(640,480);
    
    public convertHSV(PImage _rgbImage){
     this.rgbImage = _rgbImage;
    }
   
   public void run(){
    at.RGB2HSV(rgbImage,hsvImage);
    HSVIMAGE = hsvImage;
   } 
 }

 public void tuneImages(PImage rgbImage){
   //PImage hsvImage = new PImage(640,480);
  // PImage displayImage = new PImage(640,480);
  
  //Latch the input of a tuning check
  int rThresh = 0;
  int gThresh = 0;
  int bThresh = 0;
  int rlow = 0;
  int glow = 0;
  int blow = 0;

   changeTuningLabels();

      //Mat rgbMat = new Mat(480,640,CvType.CV_8UC3,new Scalar(0,0,0));
      
      if(!tuningChecked){
        trackingElement temp = elPanel.getFilterCheckedElement();
        if(temp != null){
           presetTuningLabels(temp);
        }else{
          rThresh = (int) (redSlider.getValueF()*255.0);
      tuningLabel1.setText("RHigh "+rThresh, GAlign.LEFT, GAlign.MIDDLE);
       gThresh = (int) (greenSlider.getValueF()*255.0);
      tuningLabel2.setText("GHigh "+gThresh, GAlign.LEFT, GAlign.MIDDLE);
       bThresh = (int) (blueSlider.getValueF()*255.0);
      tuningLabel3.setText("BHigh "+bThresh, GAlign.LEFT, GAlign.MIDDLE);
       rlow = (int) (redSliderLow.getValueF()*255.0) - 1;
      tuningLabel4.setText("Rlow "+rlow, GAlign.LEFT, GAlign.MIDDLE);
       glow = (int) (greenSliderLow.getValueF()*255.0) - 1;
      tuningLabel5.setText("Glow "+glow, GAlign.LEFT, GAlign.MIDDLE);
       blow = (int) (blueSliderLow.getValueF()*255.0) - 1;
      tuningLabel6.setText("Blow"+blow, GAlign.LEFT, GAlign.MIDDLE);
        }
      }else{
      
       rThresh = (int) (redSlider.getValueF()*255.0);
      tuningLabel1.setText("RHigh "+rThresh, GAlign.LEFT, GAlign.MIDDLE);
       gThresh = (int) (greenSlider.getValueF()*255.0);
      tuningLabel2.setText("GHigh "+gThresh, GAlign.LEFT, GAlign.MIDDLE);
       bThresh = (int) (blueSlider.getValueF()*255.0);
      tuningLabel3.setText("BHigh "+bThresh, GAlign.LEFT, GAlign.MIDDLE);
       rlow = (int) (redSliderLow.getValueF()*255.0) - 1;
      tuningLabel4.setText("Rlow "+rlow, GAlign.LEFT, GAlign.MIDDLE);
       glow = (int) (greenSliderLow.getValueF()*255.0) - 1;
      tuningLabel5.setText("Glow "+glow, GAlign.LEFT, GAlign.MIDDLE);
       blow = (int) (blueSliderLow.getValueF()*255.0) - 1;
      tuningLabel6.setText("Blow"+blow, GAlign.LEFT, GAlign.MIDDLE);
      }
      
      //Main tuning thread
      if(!(tuningThread.isAlive())){
          tuningThread = new Thread((new updateTuningLabels(rlow,glow,blow,rThresh,gThresh,bThresh,rgbImage)));
          tuningThread.start();
      }

    //Important Tuning Checked must be true!!!
    tuningChecked = true;

 }
 
 public void presetTuningLabels(trackingElement temp){
   float rHigh = (float) ((int) temp.filterHigh.red & 0x00FF);
   float gHigh = (float) ((int) temp.filterHigh.green & 0x00FF);
   float bHigh = (float) ((int) temp.filterHigh.blue & 0x00FF);
   float rLow = (float) ((int) temp.filterLow.red & 0x00FF);
   float gLow = (float) ((int) temp.filterLow.green & 0x00FF);
   float bLow = (float) ((int) temp.filterLow.blue & 0x00FF);
   redSlider.setValue(rHigh/255.0);
   tuningLabel1.setText("RHigh "+((int)rHigh), GAlign.LEFT, GAlign.MIDDLE);
   greenSlider.setValue( gHigh/255.0);
   tuningLabel2.setText("GHigh "+((int)gHigh), GAlign.LEFT, GAlign.MIDDLE);
   blueSlider.setValue( bHigh/255.0);
   tuningLabel3.setText("BHigh "+((int)bHigh), GAlign.LEFT, GAlign.MIDDLE);
   redSliderLow.setValue( rLow/255.0);
   tuningLabel4.setText("Rlow "+((int)rLow), GAlign.LEFT, GAlign.MIDDLE);
   greenSliderLow.setValue( gLow/255.0);
   tuningLabel5.setText("Glow "+((int)gLow), GAlign.LEFT, GAlign.MIDDLE);
   blueSliderLow.setValue( bLow/255.0);
   tuningLabel6.setText("Blow "+((int)bLow), GAlign.LEFT, GAlign.MIDDLE);
 }
 
 public class updateTuningLabels implements Runnable {
    int r1,g1,b1,r2,g2,b2;
    PImage hsvImage = new PImage(640,480);
    PImage rgbImage = new PImage(640,480);
    PImage displayImage = new PImage(640,480);
    
    public updateTuningLabels(int _r1, int _g1, int _b1, int _r2, int _g2, int _b2, PImage _rgbImage){
       r1 = _r1;
       g1 = _g1;
       b1 = _b1;
       r2 = _r2;
       g2 = _g2;
       b2 = _b2; 
       rgbImage = _rgbImage;
    }
    
    public void run(){
      Mat rgbMat = new Mat(480,640,CvType.CV_8UC3,new Scalar(0,0,0));
      PImage displayImage = new PImage(640,480);

      if(hsvView.isSelected()){
        at.RGB2HSV(rgbImage,hsvImage);
        at.PImagetoM3(this.hsvImage,rgbMat);
      }  
      else{
        at.PImagetoM3(this.rgbImage,rgbMat);
      }
      
      Core.inRange(rgbMat, new Scalar(this.b1,this.g1,this.r1), new Scalar(this.b2,this.g2,this.r2),rgbMat);
      at.M3toPImage(rgbMat,displayImage);
      filteredRGB = displayImage;
      //opencv.loadImage(displayImage);
      //image(opencv.getSnapshot(),0,0);
    } 
 }
 
public void handleTextEvents(GEditableTextControl textControl, GEvent event) { 
  //displayEvent(textControl.tag, event);
}
 
 public void handleButtonEvents(GButton button, GEvent event) { 
   if (button == btnColor){
    //handleColorChooser();
    if(!(colorChooser.isAlive())){
      colorChooser = new Thread((new handleNewColor()));
      colorChooser.start();
      //updateElPanel();
      //elPanel.updateRows();
    }
   }
   
   if(button == elPanel.refresh){
     //ah.updateAllElementInfo();
     //delay(1000);
      elPanel.updateRows(); 
      //updateElPanel();
   }
   
   if(button == elPanel.discover){
      ah.discoverAll();
       //delay(1000);
      //elPanel.updateRows(); 
   }
   
   if(button == posPanel.refresh){
     ah.discoverAllYawPitchRoll();
     delay(1000);
      posPanel.updateRows(); 
   }
   
   if(button == setFilter){
     applyFilters();
   }
   
   if(button == scanButton){
     scanElements();
   }
   
   if(button == start3d){
     if(at3d == null){
        at3d = new Antenna3D(800,800,ah);
        
        WindowListener listener = new WindowAdapter(){
          
            public void windowClosing(WindowEvent w){
               at3d = null;
            }
        };
        
        at3d.addWindowListener(listener);
     } 
   }
   
   if(button == cubeConnect){
     String temp = comPortText.getText();
     
      mch.setComPort(temp);
   }
   
   if(button == cubeDisconnect){
     mch.serialStop();
   }
   
   if(button == sendAngles){
     String theta = thetaText.getText();
     String phi = phiText.getText();
     trim(phi);
     trim(theta);
     
     mch.sendCubeThetaPhi((float)Integer.parseInt(theta),(float)Integer.parseInt(phi),mch.INPUT_DEGREES);
   }
   
   if(button == sendCoords){
     AntennaElement tempEl = elPanel.getCoordsCheckedElement();
     
     if(tempEl != null){
       PVector pos = tempEl.getPhysicalLocation();
       int antNum = tempEl.getAntennaNumber();
       float wavelength = LIGHTSPEED/FREQUENCY;
       float WLmm = wavelength*1000;
       println("wlmm "+WLmm);
       println("Sending Coords ANT: "+tempEl.getAntennaNumber()+" x: "+pos.x/WLmm+" y: "+pos.y/WLmm+" z: "+pos.z/WLmm);
          mch.sendCubeElementLocations(pos.x/WLmm,pos.y/WLmm,pos.z/WLmm,antNum);
     }else
        println("No checkbox for send coords"); 
   }
   
   if(button == sendAllCoords){
     if(elPanel.elementRows != null){
     
     for(int i = 0; i<elPanel.elementRows.size(); ++i){
       delay(500);
       elementRow elRow = elPanel.elementRows.get(i);
         elPanel.ah.updateTrackingHash();
         AntennaElement tempEl = elRow.el;
         
         if(tempEl != null){
       PVector pos = tempEl.getPhysicalLocation();
       int antNum = tempEl.getAntennaNumber();
       float wavelength = LIGHTSPEED/FREQUENCY;
       float WLmm = wavelength*1000;
       println("wlmm "+WLmm);
       println("Sending Coords ANT: "+tempEl.getAntennaNumber()+" x: "+pos.x/WLmm+" y: "+pos.y/WLmm+" z: "+pos.z/WLmm);
          mch.sendCubeElementLocations(pos.x/WLmm,pos.y/WLmm,pos.z/WLmm,antNum);
     }else
        println("Element in row not initialized"); 

     }
     
     println("ALL COORDS SENT SUCCESSFULLY");
   }else{
    println("element rows in element panel not initialized, exiting routine");
   }
     
   }
   
   if(button == printCoords){
      mch.sendCubePrintLocations();
      //float wavelength = LIGHTSPEED/FREQUENCY;
       //float WLmm = wavelength*1000;
       //elPanel.printActiveElementLocations(WLmm); 
   }
   
   if(button == printPhases){
      mch.sendCubePrintPhases(); 
   }
   
   if(button == randomError){
      elPanel.addRandomOneMMError(); 
   }
   
   
   
   
   
}

public void scanElements(){
  
  Calendar cal = Calendar.getInstance();
  long timeNow = System.currentTimeMillis();
  long timeNext = System.currentTimeMillis();
  long diff = timeNext - timeNow;
  boolean showImage = true;
  println("DIFF "+diff);
    for(int i = 0; i<elPanel.elementRows.size(); ++i){
       delay(1000);
       elementRow elRow = elPanel.elementRows.get(i);
       ah.updateTrackingHash();
       ah.blackout();
       neoColor cl = ah.trackingHash.get(elRow.el.getID()).trackColor;
       ah.sendColor(cl,elRow.el.getIPAsString(),ah.PORT);
       timeNow = System.currentTimeMillis();
       /*while(diff < 3000){
         trackingElement temp = elPanel.ah.trackingHash.get(elRow.el.getID());
         if(temp != null){
          testCase TC = new testCase();
          
          while( TC.successes < TC.SUCCESS_LIMIT){
            println("Attempts: "+TC.attempts);
            kh.updateKinect();
            PImage rgbImage = kh.getRGBImage();
            PImage hsvImage = new PImage(640,480);
            //PImage rgbCopy = new PImage(640,480);
            //rgbCopy = rgbImage;
            at.RGB2HSV(rgbImage, hsvImage);
           
            at.findAntennaLocation(hsvImage,temp, TC, showImage);
            if(TC.attempts > TC.ATTEMPTS_LIMIT){
               println("Failed to find antenna");
              break; 
            }
          }
        }
        timeNext = System.currentTimeMillis();
        diff = timeNext - timeNow;
       }*/
       
       diff = 0;
       
    }

}

public void applyFilters(){
      int rThresh = (int) (redSlider.getValueF()*255.0);
      int gThresh = (int) (greenSlider.getValueF()*255.0);
      int bThresh = (int) (blueSlider.getValueF()*255.0);
      int rlow = (int) (redSliderLow.getValueF()*255.0) - 1;
      int glow = (int) (greenSliderLow.getValueF()*255.0) - 1;
      int blow = (int) (blueSliderLow.getValueF()*255.0) - 1;
      
      int hsv = 0;
      
      //select a pixel number of antenna element to define the color of the entire element
      int pixelnum = 1;
      
      if(hsvView.isSelected())
        hsv = 1;
        
      neoColor fHigh = new neoColor((byte) rThresh, (byte) gThresh, (byte) bThresh);
      neoColor fLow = new neoColor((byte) rlow, (byte) glow, (byte) blow);
      
      elPanel.applyNewFilters(hsv,pixelnum,fHigh,fLow);

}



public void handlePanelEvents(GPanel panel, GEvent even){
   return; 
}

public void handleToggleControlEvents(GToggleControl checkbox, GEvent event){
 return; 
}

// G4P code for colour chooser
public void handleColorChooser() {
  sel_col = G4P.selectColor();
  
      //elPanel.newColorAnalyzePanel(sel_col);
  //println("SELECT COLOR "+ hex(sel_col));
  //(new Thread(new handleNewColor(sel_col))).start();
  pg.beginDraw();
  pg.background(sel_col);
  pg.endDraw();
}

public class handleNewColor implements Runnable {
  
    int selectColor = 0;
    
    public handleNewColor(){ 
    }
 
   public void run(){
     sel_col = G4P.selectColor();
      elPanel.newColorAnalyzePanel(sel_col);
      pg.beginDraw();
      pg.background(sel_col);
      pg.endDraw();
      //elPanel.updateRows();
   } 
}


// Simple graphical frame to group controls
public void showFrame(Rectangle r) {
  noFill();
  strokeWeight(1);
  stroke(color(240, 240, 255));
  rect(r.x, r.y, r.width, r.height);
  stroke(color(0));
  rect(r.x+1, r.y+1, r.width, r.height);
}

public void createColorChooserGUI(int x, int y, int w, int h, int border) {
  // Store picture frame
  rects.add(new Rectangle(x, y, w, h));
  // Set inner frame position
  x += border; 
  y += border;
  w -= 2*border; 
  h -= 2*border;
  GLabel title = new GLabel(this, x, y, w, 20);
  title.setText("Color picker dialog", GAlign.LEFT, GAlign.MIDDLE);
  title.setOpaque(true);
  title.setTextBold();
  btnColor = new GButton(this, x, y+26, 80, 20, "Choose");
  sel_col = color(255);
  pg = createGraphics(60, 20, JAVA2D);
  pg.beginDraw();
  pg.background(sel_col);
  pg.endDraw();
  spad = new GSketchPad(this, x+88, y+26, pg.width, pg.height);
  spad.setGraphic(pg);
}

public void create3DGUI(int x, int y, int w, int h, int border) {
  // Store picture frame
  rects.add(new Rectangle(x, y, w, h));
  // Set inner frame position
  x += border; 
  y += border;
  w -= 2*border; 
  h -= 2*border;
  GLabel title = new GLabel(this, x, y, w, 20);
  title.setText("Start 3D", GAlign.LEFT, GAlign.MIDDLE);
  title.setOpaque(true);
  title.setTextBold();
  start3d = new GButton(this, x, y+26, 80, 20, "Start3D");
}

public void createKinectControl(int x, int y, int w, int h, int border) {
  // Store picture frame
  rects.add(new Rectangle(x, y, w, h));
  // Set inner frame position
  x += border; 
  y += border;
  w -= 2*border; 
  h -= 2*border;
  GLabel title = new GLabel(this, x, y, w, 20);
  title.setText("Enable Kinect Images", GAlign.LEFT, GAlign.MIDDLE);
  title.setOpaque(true);
  title.setTextBold();
  enableRGB = new GCheckbox(this, x, y+26, 80, 20, "RGB");
  enableRGB.setSelected(false);
  enableDepth = new GCheckbox(this, x, y+26*2, 80, 20, "Depth");
  enableDepth.setSelected(false);
  enableHSV = new GCheckbox(this, x, y+26*3, 80, 20, "HSV");
  enableHSV.setSelected(false);
}

public void createTrackingPanel(int x, int y, int w, int h, int border) {
  // Store picture frame
  rects.add(new Rectangle(x, y, w, h));
  // Set inner frame position
  x += border; 
  y += border;
  w -= 2*border; 
  h -= 2*border;
  GLabel title = new GLabel(this, x, y, w, 20);
  title.setText("Tracking Panel", GAlign.LEFT, GAlign.MIDDLE);
  title.setOpaque(true);
  title.setTextBold();
  trackRed = new GCheckbox(this, x, y+26, 120, 20, "Track with Image");
  trackRed.setSelected(false);
  trackGreen = new GCheckbox(this, x, y+26*2, 120, 20, "Track no Image");
  trackGreen.setSelected(false);
  //trackBlue = new GCheckbox(this, x, y+26*3, 80, 20, "Blue");
  //trackBlue.setSelected(false);
  //trackRGB = new GCheckbox(this, x, y+26*4, 80, 20, "RGB");
  //trackRGB.setSelected(false);
  
}

public void createCubeControlPanel(int x, int y, int w, int h, int border) {
  // Store picture frame
  rects.add(new Rectangle(x, y, w, h));
  // Set inner frame position
  x += border; 
  y += border;
  w -= 2*border; 
  h -= 2*border;
  GLabel title = new GLabel(this, x, y, w, 20);
  title.setText("Cube Control", GAlign.LEFT, GAlign.MIDDLE);
  title.setOpaque(true);
  title.setTextBold();
  
  configCom = new GLabel(this, x, y+26, w, 20);
  configCom.setText("Config Com", GAlign.LEFT,GAlign.MIDDLE);
  comPortText = new GTextField(this, x, y+26*2, 50, 20);
  comPortText.tag = "comPort";
  comPortText.setPromptText(mch.getComPort());
  
  cubeConnect = new GButton(this, x, y+26*3, 80, 20, "Connect");
  cubeDisconnect = new GButton(this, x, y+26*4, 80, 20, "Disconnect");

  thetaLabel = new GLabel(this, x+60, y+26*5, w, 20);
  thetaLabel.setText("Theta",GAlign.LEFT,GAlign.MIDDLE);
  
  thetaText = new GTextField(this, x, y+26*5, 50, 20);
  thetaText.tag = "theta";
  thetaText.setPromptText("0");
  
  phiLabel = new GLabel(this, x+60, y+26*6, w, 20);
  phiLabel.setText("Phi",GAlign.LEFT,GAlign.MIDDLE);
  phiText = new GTextField(this, x, y+26*6, 50, 20);
  phiText.tag = "phi";
  phiText.setPromptText("0");
  
  sendAngles = new GButton(this, x, y+26*7, 80, 20, "Send Angles");
  sendCoords = new GButton(this, x, y+26*8, 80, 20, "Send Coords");
  printCoords = new GButton(this, x, y+26*9, 80, 20, "Print Coords");
  printPhases = new GButton(this, x, y+26*10, 80, 20, "Print Phases");
  randomError = new GButton(this, x, y+26*11, 80, 20, "Rand Error");
  sendAllCoords = new GButton(this, x, y+26*12, 80, 20, "All Coords");

  
}

public void createTuningPanel(int x, int y, int w, int h, int border) {
  // Store picture frame
  rects.add(new Rectangle(x, y, w, h));
  // Set inner frame position
  x += border; 
  y += border;
  w -= 2*border; 
  h -= 2*border;
  GLabel title = new GLabel(this, x, y, w, 20);
  title.setText("Image Tuning Panel", GAlign.LEFT, GAlign.MIDDLE);
  title.setOpaque(true);
  title.setTextBold();
  rgbView = new GCheckbox(this, x, y+26, 50, 20, "RGB");
  rgbView.setSelected(false);
  hsvView = new GCheckbox(this, x+60, y+26,50, 20, "HSV");
  hsvView.setSelected(false);
  tuningLabel1 = new GLabel(this, x, y+26*2, w, 20);
  tuningLabel1.setText("RHigh", GAlign.LEFT, GAlign.MIDDLE);
  tuningLabel1.setOpaque(true);
  tuningLabel1.setTextBold();
  tuningLabel2 = new GLabel(this, x, y + 26*6, w, 20);
  tuningLabel2.setText("BHigh", GAlign.LEFT, GAlign.MIDDLE);
  tuningLabel2.setOpaque(true);
  tuningLabel2.setTextBold();
  tuningLabel3 = new GLabel(this, x, y + 26*10, w, 20);
  tuningLabel3.setText("GHigh", GAlign.LEFT, GAlign.MIDDLE);
  tuningLabel3.setOpaque(true);
  tuningLabel3.setTextBold();
  tuningLabel4 = new GLabel(this, x, y + 26*4, w, 20);
  tuningLabel4.setText("RLow", GAlign.LEFT, GAlign.MIDDLE);
  tuningLabel4.setOpaque(true);
  tuningLabel4.setTextBold();
  tuningLabel5 = new GLabel(this, x, y + 26*8, w, 20);
  tuningLabel5.setText("BLow", GAlign.LEFT, GAlign.MIDDLE);
  tuningLabel5.setOpaque(true);
  tuningLabel5.setTextBold();
  tuningLabel6 = new GLabel(this, x, y + 26*12, w, 20);
  tuningLabel6.setText("GLow", GAlign.LEFT, GAlign.MIDDLE);
  tuningLabel6.setOpaque(true);
  tuningLabel6.setTextBold();
  redSlider = new GSlider(this, x, y+26*3, 150, 20, 15);
  blueSlider = new GSlider(this, x, y+26*11, 150, 20, 15);
  greenSlider = new GSlider(this, x, y+26*7,150, 20, 15);
  redSliderLow = new GSlider(this, x, y+26*5, 150, 20, 15);
  blueSliderLow = new GSlider(this, x, y+26*13, 150, 20, 15);
  greenSliderLow = new GSlider(this, x, y+26*9,150, 20, 15);
  setFilter = new GButton(this, x, y+26*14, 80, 20, "Set Filter");
}

public void changeTuningLabels(){
   if(hsvView.isSelected()){
    tuningLabel1.setText("H", GAlign.LEFT, GAlign.MIDDLE);
    tuningLabel2.setText("S", GAlign.LEFT, GAlign.MIDDLE);
    tuningLabel3.setText("V", GAlign.LEFT, GAlign.MIDDLE);
   }else{
    tuningLabel1.setText("RHigh", GAlign.LEFT, GAlign.MIDDLE);
    tuningLabel2.setText("BHigh", GAlign.LEFT, GAlign.MIDDLE);
    tuningLabel3.setText("GHigh", GAlign.LEFT, GAlign.MIDDLE);
   } 
}

public void handleSliderEvents(GValueControl slider, GEvent event) { 
  /*if (slider == redSlider)  // The slider being configured?
    println("Red "+redSlider.getValueS() + "    " + event);
   if(slider == blueSlider)
    println("Blue "+blueSlider.getValueS() + "    " + event);
   if(slider == greenSlider)  
    println("Green "+ greenSlider.getValueS() + "    " + event);*/
}

void keyReleased() {
    at.colorToChange = -1; 
  }
 
  void keyPressed() {
  keyh.handleKeys(key);
 }
 
 void mousePressed(){
  //color c = get(mouseX, mouseY);
  //println("r: " +red(c) + "g: " + green(c) + " b: "+ blue(c));
  
  
  if(enableDepth.isSelected()){
    userClickDistance();
  }
  
  if(enableRGB.isSelected()){
     selectHues(); 
  }
  
  
}

 public void userClickDistance(){
   
   //if( (mouseX > depthXOffset) && (mouseY > depthYOffset)){
     if( (mouseX < 640) && (mouseY < 480)){

    int[] depthValues = kh.getDepthMap();
    PVector[] realDepthValues = kh.getDepthMapRealWorld();
  //  int clickPosition = (mouseX-depthXOffset) + ((mouseY - depthYOffset) * 640);
  int clickPosition = (mouseX) + ((mouseY) * 640);
    int clickedDepth = depthValues[clickPosition];
    PVector cReal = realDepthValues[clickPosition];
  
    float inches = clickedDepth / 25.4;
    float millis = clickedDepth;
    println("inches : "+inches+ " millis: "+millis);
    println("x: "+cReal.x+" y: "+cReal.y+" z: "+cReal.z); 
   }
 }
 
 public void selectHues(){
   if (at.colorToChange > -1) {
    
    color c = get(mouseX, mouseY);
    println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
   
    int hue = int(map(hue(c), 0, 255, 0, 180));
    
    at.colors[at.colorToChange-1] = c;
    at.hues[at.colorToChange-1] = hue;
    
    println("color index " + (at.colorToChange-1) + ", value: " + hue);
  }
 }
   
 
 void receive( byte[] data ) {       // <-- default handler
 //void receive( byte[] data, String ip, int port ) {  // <-- extended handler

 //mh.decipherPacket(data);
 ah.readPacket(data);
 //for(int i=0; i < data.length; i++)
 //print(hex(data[i]));
 println();
 }
