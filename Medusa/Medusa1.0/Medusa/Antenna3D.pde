import javax.swing.*; 
import peasy.*;

PeasyCam cam;

GPanel pnl;
GSlider sx, sy, sz;
GLabel label;
int ax, ay, az;

float[] offsets = new float[3];
float[] rotations = new float[3];
double distance = 0.0f;

int lastSx, lastSy, lastSz;
int currSx, currSy, currSz;

public class Antenna3D extends JFrame {
  public View3D v3d;
  private AntennaElementHandler ah;
  
  public Antenna3D(){
    
  }
  
  //main constructor
  public Antenna3D(int width, int height, AntennaElementHandler _ah){
    this.ah = _ah;
    setBounds(0, 0, width, height);
    v3d = new View3D();
    add(v3d);
    v3d.init();
    v3d.setAntennaHandler(this.ah);
    show();
  }
  
  public Antenna3D(int width, int height) {
    setBounds(100, 100, width, height);
    v3d = new View3D();
    add(v3d);
    v3d.init();
    show();
  }
}
public class View3D extends PApplet {
  
  private AntennaElementHandler ah;
  
  public void setup() {
    size(800, 800, P3D);


  // Create a PeasyCam object
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5000);

  }

  public void draw() {


  background(0);
  // Draw big box
  ah.updateElementHash();
  //box(5);
  drawAllAntennas();
  
  // Synchronise the actual rotations and slider positions

  }
  
  public void setAntennaHandler(AntennaElementHandler _ah){
   this.ah = _ah; 
  }
  
  public void drawAllAntennas(){
     Set<Integer> keys = ah.elementHash.keySet();
     for(Integer key: keys){
        drawAntenna(ah.elementHash.get(key));
     } 
  }
  
  public void drawAntenna(AntennaElement el){
    PVector loc = el.getPhysicalLocation();
    int antWidth = 100;
    int antHeight = 100;
    int pWidth = 6;
    int pHeight = 6;
    int pThick = 6;
    int cWidth = 25;
    int cLength = 35;
    fill(0,153,0);
    //rotateX(el.getYaw());
    rotateY(el.getPitch());
    rotateZ(el.getRoll());
   beginShape();
   vertex(loc.x - (antWidth/2),loc.y - (antHeight/2),0);
   vertex(loc.x - (antWidth/2),loc.y + (antHeight/2),0);
   vertex(loc.x + (antWidth/2),loc.y + (antHeight/2),0);
   vertex(loc.x + (antWidth/2),loc.y - (antHeight/2),0);
   vertex(loc.x - (antWidth/2),loc.y - (antHeight/2),0);
   endShape();
   fill(0,59,0);
   beginShape();
   vertex(loc.x - (cWidth/2),loc.y - (cLength/2),1);
   vertex(loc.x - (cWidth/2),loc.y + (cLength/2),1);
   vertex(loc.x + (cWidth/2),loc.y + (cLength/2),1);
   vertex(loc.x + (cWidth/2),loc.y - (cLength/2),1);
   vertex(loc.x - (cWidth/2),loc.y - (cLength/2),1);
   endShape();
   
   fill(255);
   textSize(10);
   String antText = "Num: "+str(el.getAntennaNumber())+" \nx: "+str(loc.x)+" \ny: "+str(loc.y)+" \nz: "+str(loc.z);
   text(antText,loc.x,loc.y,2);
   
   translate(loc.x - (antWidth/2) + (pWidth/2),loc.y - (antHeight/2) + (pHeight /2) , (pThick/2));
   fill(el.getPixel(1));
   box(6);
  
  translate(antWidth - (pWidth),0 , 0);
   fill(el.getPixel(2));
   box(6); 
  
  translate(0 ,antWidth - pWidth , 0);
   fill(el.getPixel(3));
   box(6);
 
 translate(-1*antWidth + pWidth,0 , 0);
   fill(el.getPixel(4));
   box(6);   
  }


}


