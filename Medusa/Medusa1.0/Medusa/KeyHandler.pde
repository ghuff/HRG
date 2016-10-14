

class KeyHandler{
  
 private AntennaElementHandler ah;
 private AntennaTracker at;
 private PApplet app;
 private boolean lookForNumber = false;
 
 public KeyHandler(){
  
 }
 
 public KeyHandler(PApplet _app, AntennaElementHandler _ah, AntennaTracker _at){
    this.app = _app;
    this.ah = _ah;
    this.at = _at; 
 }
 
 

 public void handleKeys(char k){
   String ip = ah.BROADCAST_ADDRESS;
   int port = ah.PORT;
   
  if(k == 'I'){
     //UDP.sendPacket(mh.getElementInformation((byte) 0x00), ip, port );
    ah.discoverAll(); 
  }
  
  if(k == 'M'){
   ah.getElementMACAddress(ah.BROADCAST_ADDRESS); 
  }
  
  if(k == 'P'){
   ah.getElementIPAddress(ah.BROADCAST_ADDRESS); 
  }
  
  if(k == 'D'){
   ah.getElementYawPitchRoll(ah.BROADCAST_ADDRESS); 
  }
  
  if((k == 'N') || (lookForNumber)){
     if(lookForNumber){
        ah.changeElementNumber((byte) k,ah.BROADCAST_ADDRESS);
        lookForNumber = false;
     }else{
       lookForNumber = true;
     } 
  }
  
  if(k == 'i'){
   ah.sendRGBW();
  }
  
 /*if (k == '1') {
    at.colorToChange = 1;
    
  } else if (k == '2') {
    at.colorToChange = 2;
    
  } else if (k == '3') {
    at.colorToChange = 3;
    
  } else if (k == '4') {
    at.colorToChange = 4;
  }*/
  
 if(k == 'r'){
    //UDP.sendPacket(mh.sendColorChange((byte)0xFF,(byte)0x00,(byte)0x00), ip, port );   // the message to send
    neoColor newColor = new neoColor((byte) 0xFF, (byte) 0x00, (byte) 0x00);
    ah.sendColor(newColor,ip,port);
 }
 
 if(k == 'R'){
  //UDP.sendPacket(mh.sendSparkle((byte)0xFF,(byte)0x00,(byte)0x00), ip, port );   // the message to send
  neoColor newColor = new neoColor((byte) 0xFF, (byte) 0x00, (byte) 0x00);
    ah.sendSparkle(newColor,ip,port);
 }
  
  if(k == 'g'){
 //UDP.sendPacket(mh.sendColorChange((byte)0x00,(byte)0xFF,(byte)0x00), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0x00, (byte) 0xFF, (byte) 0x00);
    ah.sendColor(newColor,ip,port);
  }
 
 if(k == 'G'){
 //UDP.sendPacket(mh.sendSparkle((byte)0x00,(byte)0xFF,(byte)0x00), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0x00, (byte) 0xFF, (byte) 0x00);
    ah.sendSparkle(newColor,ip,port);
 }
  
  if(k == 'b'){
 //UDP.sendPacket(mh.sendColorChange((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0x00, (byte) 0x00, (byte) 0xFF);
    ah.sendColor(newColor,ip,port);
  }
 
 if(k == 'B'){
 //UDP.sendPacket(mh.sendSparkle((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0x00, (byte) 0x00, (byte) 0xFF);
    ah.sendSparkle(newColor,ip,port);
 }
 
 if(k == 'y'){
 //UDP.sendPacket(mh.sendColorChange((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0xFF, (byte) 0xFF, (byte) 0x00);
    ah.sendColor(newColor,ip,port);
  }
 
 if(k == 'Y'){
 //UDP.sendPacket(mh.sendSparkle((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0xFF, (byte) 0xFF, (byte) 0x00);
    ah.sendSparkle(newColor,ip,port);
 }
 
  if(k == 't'){
 //UDP.sendPacket(mh.sendColorChange((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0x00, (byte) 0xFF, (byte) 0xFF);
    ah.sendColor(newColor,ip,port);
  }
 
 if(k == 'T'){
 //UDP.sendPacket(mh.sendSparkle((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0x00, (byte) 0xFF, (byte) 0xFF);
    ah.sendSparkle(newColor,ip,port);
 }
 
 if(k == '-'){
 //UDP.sendPacket(mh.sendSparkle((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0x00, (byte) 0x00, (byte) 0x00);
    ah.sendColor(newColor,ip,port);
 }
 
 if(k == '+'){
 //UDP.sendPacket(mh.sendSparkle((byte)0x00,(byte)0x00,(byte)0xFF), ip, port );   // the message to send
 neoColor newColor = new neoColor((byte) 0xFF, (byte) 0xFF, (byte) 0xFF);
    ah.sendColor(newColor,ip,port);
 }
 } 
  
  
  
}
