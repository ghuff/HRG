//Main Window to handle main program
//Written by Jeff Jensen 2015

UDP udp;  // define the UDP object
MedusaMessageHandler mh;
MedusaSQLHandler mSQL;
GuiColorPicker cp;

void setup() {
   
   //for some reason the window must be declared before the UDP is instantiated
    size(640, 360, P3D);
    background(0);
 
 udp = new UDP( this, 6000 );  // create a new datagram connection on port 6000
 mh = new MedusaMessageHandler();
 mSQL = new MedusaSQLHandler(this);
 //udp.log( true );     // <-- printout the connection activity
 udp.listen( true );           // and wait for incoming message
 
 cp = new GuiColorPicker( 10, 10, 400, 400, 255 );
 

 }
 
 void draw()
 {
   
   /*lights();
  background(204);
  float cameraY = height/2.0;
  float fov = mouseX/float(width) * PI/2;
  float cameraZ = cameraY / tan(fov / 2.0);
  float aspect = float(width)/float(height);
  if (mousePressed) {
    aspect = aspect / 2.0;
  }
  perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
  
  translate(width/2+30, height/2, 0);
  rotateX(-PI/6);
  rotateY(PI/3 + mouseY/float(height) * PI);
  box(45);
  translate(0, 0, -50);
  box(30);*/
  
  cp.render();
 }
 
  void keyPressed() {
 String ip       = "192.168.1.255";  // the remote IP address
 int port        = 1337;    // the destination port
 
 //int checksum =  startByte +  0x0003 +  LIGHTS_SOLID_COLOR +  0x00FA +  0x00FE +  0x00CC;
  //int checksum =  mh.STARTBYTE +  0x0003 +  mh.LIGHTS_SPARKLE +  0x00FA +  0x00FE +  0x00CC;
 //byte finalChecksum = (byte) ((checksum % 256) & 0x00FF);
 //final byte mydata[] = {(byte)startByte,(byte)0x03,(byte)LIGHTS_SOLID_COLOR,(byte)0xFA,(byte)0xFE,(byte)0xCC,finalChecksum};
  //final byte mydata[] = {(byte)mh.STARTBYTE,(byte)0x03,(byte) mh.LIGHTS_SPARKLE,(byte)0xFA,(byte)0xFE,(byte)0xCC,finalChecksum};
  
  if(key == 'I'){
     udp.send(mh.getElementInformation((byte) 0x00), ip, port ); 
  }
  
  if(key == 'i'){
   HashMap colorMap = new HashMap();
   neoColor redColor = new neoColor((byte) 0xFF, (byte) 0x00, (byte) 0x00);
   neoColor greenColor = new neoColor((byte) 0x00, (byte) 0xFF, (byte) 0x00);
   neoColor blueColor = new neoColor((byte) 0x00, (byte) 0x00, (byte) 0xFF);
   neoColor whiteColor = new neoColor((byte) 0xFF, (byte) 0xFF, (byte) 0xFF);
   colorMap.put(1,redColor);
   colorMap.put(2,greenColor);
   colorMap.put(3,blueColor);
   colorMap.put(4,whiteColor);
   udp.send(mh.sendIndividualColorChange(colorMap), ip, port );   // the message to send 
  }
  
  if(key == '1')
 udp.send(mh.sendColorChange((byte)cp.red,(byte)cp.green,(byte)cp.blue), ip, port );   // the message to send 
  
 if(key == 'r')
 udp.send(mh.sendColorChange((byte)0xFF,(byte)0x00,(byte)0x00), ip, port );   // the message to send
 
 if(key == 'R')
  udp.send(mh.sendSparkle((byte)0xFF,(byte)0x00,(byte)0x00), ip, port );   // the message to send
  
  if(key == 'g')
 udp.send(mh.sendColorChange((byte)0x00,(byte)0xFF,(byte)0x00), ip, port );   // the message to send
 
 if(key == 'G')
  udp.send(mh.sendSparkle((byte)0x00,(byte)0xFF,(byte)0x00), ip, port );   // the message to send
  
  if(key == 'b')
 udp.send(mh.sendColorChange((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 
 if(key == 'B')
  udp.send(mh.sendSparkle((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 }
