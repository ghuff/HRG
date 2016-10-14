import SimpleOpenNI.*;

SimpleOpenNI kinect;

void setup(){
  size(640*2, 480);
  kinect = new SimpleOpenNI(this);
  
  kinect.enableDepth();
  //kinect.enableRGB();
}

void draw(){
  kinect.update();
  
  PImage depthImage = kinect.depthImage();
  image(depthImage,0,0);
  //image(kinect.rgbImage(), 640, 0);
}

void mousePressed(){
  //color c = get(mouseX, mouseY);
  //println("r: " +red(c) + "g: " + green(c) + " b: "+ blue(c));
  
  int[] depthValues = kinect.depthMap();
  int clickPosition = mouseX + (mouseY * 640);
  int clickedDepth = depthValues[clickPosition];
  
  float inches = clickedDepth / 25.4;
  println("inches : "+inches);
}

