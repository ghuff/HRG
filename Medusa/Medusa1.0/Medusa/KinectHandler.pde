import SimpleOpenNI.*;

class KinectHandler{
  
  private SimpleOpenNI kinect;
  private final int kinectWidth = 640;
  private final int kinectHeight = 480;
  private PImage whiteImage = null;
  private boolean isConnected = false;
 
  
 public KinectHandler(){
    kinect = null;
    initWhiteImage();
 }

 public KinectHandler(PApplet app){
    kinect = new SimpleOpenNI(app);
    
    if(kinect.enableDepth() == false){
       println("Problem reading depth stream from Kinect");
       kinect = null;
       isConnected = false;
      return; 
    }
    
    if(kinect.enableRGB() == false){
       println("Problem reading RGB stream from Kinect");
       kinect = null;
       isConnected = false;
       return; 
    }
    
    //tell openNi to line up color pixels with depth data
    kinect.alternativeViewPointDepthToImage();
    
    initWhiteImage();
    
    isConnected = true;
 }
 
 public boolean isConnected(){
    return isConnected; 
 }

//need to stick this function in main loop of MedusaMain
 public void updateKinect(){
    if(kinect != null){
      kinect.update(); 
    }
 }

 public PImage getDepthImage(){
    if(kinect != null)
      return kinect.depthImage();
    else
      return whiteImage;
 }
 
 public int[] getDepthMap(){
   return kinect.depthMap();
 }
 
 public PVector[] getDepthMapRealWorld(){
    return kinect.depthMapRealWorld(); 
 }
 
 public void convertRealWorldToPixels(PVector realW, PVector pix){
    if(isConnected){
       kinect.convertRealWorldToProjective(realW,pix);
    } 
 }
 
 public PImage getRGBImage(){
    if(kinect != null)
       return kinect.rgbImage();
    else
       return whiteImage; 
 }
 
 public PImage getWhiteImage(){
    return whiteImage; 
 }

 private void initWhiteImage(){
   whiteImage = createImage(kinectWidth, kinectHeight, RGB);
    whiteImage.loadPixels();
    for (int i = 0; i < whiteImage.pixels.length; i++) {
      whiteImage.pixels[i] = color(240, 240, 240); 
    }
 } 
  
}
