

public class MedusaCubeHandler{
  
  private PApplet app;
  private MedusaSerialHandler msh;
  
  //Protocol Bytes for message
  private final char abord = 27;
  private final char startFlag = 'B';
  private final char ack = 19;
  private final char delimiter = 59; //';'
  public final int INPUT_DEGREES = 0;
  public final int INPUT_RADIANS = 1;
  
  
 public MedusaCubeHandler(PApplet _app){
   this.app = _app;
   this.msh = new MedusaSerialHandler(this.app);
 }
 
 public void sendCubeThetaPhi(float theta,float phi,float input){
     if(input == 0){
       theta = radians(theta);
       phi = radians(phi);
     }
       float xshift = -1.0*PI*sin(theta)*cos(phi)*(180.0/PI);
       float yshift = -1.0*PI*sin(theta)*sin(phi)*(180.0/PI);
       float zshift = -1.0*PI*cos(theta)*(180.0/PI);
       
       sendCubePhaseMessage((int) xshift, (int) yshift, (int) zshift);
 }

 public void sendCubePhaseMessage(int xshift, int yshift, int zshift){
    int start = 255;
    int packLength = 3;
    int frameNum = 200;
    int frameID = 1;
    int checksum = start + packLength + frameNum + frameID + xshift + yshift+zshift;
    checksum = checksum % 256;
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(start));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(packLength));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameNum));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameID));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(xshift));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(yshift));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(zshift));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(checksum));
    msh.serialWrite(ack);
    
    //if(msh != null)
     // msh.serialWrite(msg);
 }
 
 public void sendCubeElementLocations(){
   sendDynamicCoordsActivate();
   sendCubeCoordsMessage(0.1,0.1,0.1,1);
 }
 
 public void sendCubePrintLocations(){
   int start = 255;
    int packLength = 1;
    int frameNum = 97; //the frame type
    int frameID = 1;
    int dummy = 1;
    int checksum = start + packLength + frameNum + frameID + dummy;
    checksum = checksum % 256;
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(start));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(packLength));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameNum));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameID));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(dummy));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(checksum));
    msh.serialWrite(ack);
 }
 
 public void sendCubeDynamicCoordsDeActivate(){
  int start = 255;
    int packLength = 1;
    int frameNum = 98; //the frame type
    int frameID = 1;
    int dummy = 1;
    int checksum = start + packLength + frameNum + frameID + dummy;
    checksum = checksum % 256;
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(start));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(packLength));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameNum));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameID));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(dummy));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(checksum));
    msh.serialWrite(ack); 
 }
 
 public void sendDynamicCoordsActivate(){
   int start = 255;
    int packLength = 1;
    int frameNum = 99; //the frame type
    int frameID = 1;
    int dummy = 1;
    int checksum = start + packLength + frameNum + frameID + dummy;
    checksum = checksum % 256;
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(start));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(packLength));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameNum));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameID));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(dummy));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(checksum));
    msh.serialWrite(ack);
 }
 
  public void sendCubeCoordsMessage(float xpos, float ypos, float zpos, int antNum){
    int start = 255;
    int packLength = 3;
    int frameNum = 200+1;
    int frameID = 1;
    int x = (int) (xpos*100);
    int y = (int) (ypos*100);
    int z = (int) (zpos*100);
    int checksum = start + packLength + frameNum + frameID + x + y+z;
    checksum = checksum % 256;
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(start));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(packLength));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameNum));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(frameID));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(x));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(y));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(z));
    msh.serialWrite(ack);
    msh.serialWrite(startFlag);
    msh.serialWrite(Integer.toString(checksum));
    msh.serialWrite(ack);
    
    //if(msh != null)
     // msh.serialWrite(msg);
 }

  
  
  
  
  
}
