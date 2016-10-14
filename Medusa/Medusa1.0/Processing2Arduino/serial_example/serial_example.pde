import processing.serial.*;

//Serial myPort;  // Create object from Serial class

MedusaCubeHandler mch;

void setup() 
{
  size(200,200); //make our canvas 200 x 200 pixels big
  //String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  //println(portName);
  //myPort = new Serial(this, portName, 9600);
  //msh = new MedusaSerialHandler(this);
  mch = new MedusaCubeHandler(this);
}

void draw() {

  
}

void mousePressed() {
  if (mouseButton == LEFT) {
    fill(255);
     //myPort.write('H');         //send a 1
     //msh.serialWrite('H');
     //mch.sendCubeThetaPhi(90.0,30.0,mch.INPUT_DEGREES);
     mch.sendCubeElementLocations();
  } else if (mouseButton == RIGHT) {
    //myPort.write('L'); 
    //msh.serialWrite('L');
    mch.sendCubePrintLocations();
    fill(0);
  } else {
    fill(126);
  }
}
