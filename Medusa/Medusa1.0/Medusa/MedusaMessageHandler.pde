import java.util.*;
import java.io.*;
import java.text.*;

class MedusaMessageHandler{
  
  //Frame Structure Bytes 
  public final int STARTBYTE = 0x0070;
  
  //LIGHT COMMANDS
  public final int LIGHTS_SOLID_COLOR =  0x00A0;
  public final int LIGHTS_SPARKLE =  0x00A1;
  public final int LIGHTS_INDIVIDUAL_COLOR = 0x00A2;
  
  //INFORMATION COMMANDS
  public final int INFO_GET_ALL = 0x00E0;
  public final int INFO_GET_MAC = 0x00E1;
  public final int INFO_GET_MAC_OK = 0x00E2;
  public final int INFO_GET_MAC_BAD = 0x00E3;
  public final int INFO_GET_IP  = 0x00E4;
  public final int INFO_GET_IP_OK = 0x00E5;
  public final int INFO_GET_IP_BAD = 0x00E6;
  public final int INFO_GET_PIXELS = 0x00E7;
  public final int INFO_GET_YAW_PITCH_ROLL = 0xE8;
  
  //Configuration Commands
  public final int CHANGE_ANTENNA_NUMBER = 0x00B0;
  public final int CHANGE_ANTENNA_NUMBER_OK = 0x00B1;
  public final int CHANGE_ANTENNA_NUMBER_BAD = 0x00B2;
  
  private AntennaElementHandler ah;
  
  //constructors
  public MedusaMessageHandler(){
    ah = null;
  }
  
  public MedusaMessageHandler(AntennaElementHandler _ah){
    ah = _ah; 
  }
  
  public byte[] sendColorChange(byte red, byte green, byte blue){
    
    //payload length will be 3 bytes
    byte LENGTH = 0x0003;
    
    int checksum =  STARTBYTE +  0x0003 +  LIGHTS_SOLID_COLOR +  red +  green +  blue;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)LIGHTS_SOLID_COLOR,(byte)red,(byte)green,(byte)blue,calcChecksum(checksum)};
    
    return mydata;
    
  }
  
  public byte[] sendSparkle(byte red, byte green, byte blue){
    
    //payload length will be 3 bytes
    byte LENGTH = 0x0003;
    
    int checksum =  STARTBYTE +  LENGTH +  LIGHTS_SPARKLE +  red +  green +  blue;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)LIGHTS_SPARKLE,(byte)red,(byte)green,(byte)blue,calcChecksum(checksum)};
    return mydata;
  }
  
  public byte[] sendIndividualColorChange(HashMap colors)
  {
    byte LENGTH = (byte) (colors.size()*3); //three colors per neoColor
    
    
    int checksum =  STARTBYTE +  LENGTH +  LIGHTS_INDIVIDUAL_COLOR;
    List<Byte> mydata = new ArrayList<Byte>();
    mydata.add((byte)STARTBYTE);
    mydata.add((byte)LENGTH);
    mydata.add((byte)LIGHTS_INDIVIDUAL_COLOR);
    
    for(int i = 1; i<colors.size()+1; ++i){
         neoColor temp = (neoColor) colors.get(i);
         if(temp != null){
           checksum += temp.red + temp.green + temp.blue;
           mydata.add((byte) temp.red);
           mydata.add((byte) temp.green);
           mydata.add((byte) temp.blue);
         }else{
           println("neoColor was not initialized");
         } 
    }
    
    mydata.add((byte) calcChecksum(checksum));
    
    byte returndata[] = new byte[mydata.size()];
    
    for(int i = 0; i < mydata.size(); ++i){
      returndata[i] = mydata.get(i); 
    }
    //byte finalChecksum = (byte) ((checksum % 256) & 0x00FF);
    return returndata;
  }
  
  public byte[] getElementInformation(byte options){
    //payload length will be 1 bytes
    byte LENGTH = 0x0001;
    
    int checksum =  STARTBYTE +  LENGTH +  INFO_GET_ALL +  options;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)INFO_GET_ALL,(byte) options,calcChecksum(checksum)};
    return mydata;
  }
  
  public byte[] getElementMACAddress(){
    byte LENGTH = 0x0000;
    
    int checksum =  STARTBYTE +  LENGTH +  INFO_GET_MAC;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)INFO_GET_MAC,calcChecksum(checksum)};
    return mydata;
  }
  
  public byte[] getElementIPAddress(){
    byte LENGTH = 0x0000;
    
    int checksum =  STARTBYTE +  LENGTH +  INFO_GET_IP;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)INFO_GET_IP,calcChecksum(checksum)};
    return mydata;
  }
  
  public byte[] changeElementNumber(byte number){
    byte LENGTH = 0x0001;
    
    int checksum =  STARTBYTE +  LENGTH +  CHANGE_ANTENNA_NUMBER + (byte) number;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)CHANGE_ANTENNA_NUMBER,(byte) number, calcChecksum(checksum)};
    return mydata;
  }
  
  public byte[] getElementYawPitchRoll(){
    byte LENGTH = 0x0000;
    
    int checksum =  STARTBYTE +  LENGTH +  INFO_GET_YAW_PITCH_ROLL;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)INFO_GET_YAW_PITCH_ROLL,calcChecksum(checksum)};
    return mydata;
  } 
  

  
  private byte calcChecksum(int checksum){
      return (byte)((checksum % 256) & 0x00FF);  
  }
  
  public void decipherPacket(byte[] data){
    
    int packetLength;
    byte startbyte;
    byte payloadLength;
    byte command;
    List<Byte> controlData = new ArrayList<Byte>();
    int receiveChecksum = 0;
    byte finalChecksum = (byte) 0x00;
    
    //begin processing packet
   if(data != null){
     packetLength = data.length;
    
    if(packetLength >= 3){
     startbyte = data[0];
     payloadLength = data[1];
     command = data[2];
     
     receiveChecksum += startbyte + payloadLength + command;
    
      if(startbyte == (byte)STARTBYTE){
        
        if((3+payloadLength) >= packetLength){
          println("Length "+hex(payloadLength) + " is incorrect");
          return;
        }
        
        for(int i = 3; i < payloadLength + 3; ++i){
           controlData.add(data[i]);
           receiveChecksum += data[i];
        }
        
        finalChecksum = calcChecksum(receiveChecksum);
        
        
        if((byte)(finalChecksum & data[3+payloadLength]) != (byte)finalChecksum){
           println("Checksum "+hex(finalChecksum)+ " is not " + hex(data[3+payloadLength]));
          return; 
        }else{
             println("\n");
            switch(command){
             
             case (byte) INFO_GET_ALL:
               printGetAllInfo(controlData);
              //println("INFO GET ALL");
             break;
             
             case (byte) INFO_GET_MAC_OK:
               getMACOk(controlData);
              //println("INFO GET ALL");
             break;
             
             case (byte) INFO_GET_IP_OK:
               getIPOk(controlData);
              //println("INFO GET ALL");
             break;
             
             case (byte) CHANGE_ANTENNA_NUMBER_OK:
               getMACOk(controlData);
              break;
              
             case (byte) INFO_GET_YAW_PITCH_ROLL:
               getYawPitchRoll(controlData);
               break;
          
             default:
             println("Case not known");
             break;   
            }
          
        }
        
      
      }else{
       println("Received "+ hex(startbyte) + " expected "+hex(STARTBYTE)); 
      }
    
    }else{
     println("Received broken packet with length of "+packetLength); 
    }
    
    
    
   } 
    
  }
  
 public void getMACOk(List<Byte> data){
   String printString = "";
   byte[] mac = new byte[6];
   byte curState = (byte) 0x00;
   byte antennaNum = (byte) 0x00;

      printString += "MAC: ";
      for(int i = 0; i < 6; ++i){
        if(i != 5)
         printString += hex(data.get(i)) + ":";
        else
         printString += hex(data.get(i));
         mac[i] = data.get(i);
      }
      
      printString += "\n";
      antennaNum = data.get(6);
      printString += "ANTNUM: " + hex(antennaNum);
      println(printString);
      
 }
 
 public void getIPOk(List<Byte> data){
   String printString = "";
   byte[] mac = new byte[6];
   byte[] ip = new byte[4];
   byte[] netmask = new byte[4];
   byte antennaNum = (byte) 0x00;

      printString += "MAC: ";
      for(int i = 0; i < 6; ++i){
        if(i != 5)
         printString += hex(data.get(i)) + ":";
        else
         printString += hex(data.get(i));
         mac[i] = data.get(i);
      }
      
      printString += "\nIP: "; 
      
      for(int i = 6; i < 10; ++i){
        int temp = 0x00FF;
        if(i != 9)
          printString += (temp & data.get(i)) + ".";
        else
          printString += (temp & data.get(i));
          
        ip[i-6] = data.get(i); 
      }
      printString += "\nNETMASK: "; 
      
      for(int i = 10; i < 14; ++i){
        int temp = 0x00FF;
        if(i != 13)
          printString += (temp & data.get(i)) + ".";
        else
          printString += (temp & data.get(i));
        netmask[i-10] = data.get(i);
      }
      
      printString += "\n";
      antennaNum = data.get(14);
      printString += "ANTNUM: " + hex(antennaNum);
      println(printString);
 }
 
 public void getYawPitchRoll(List<Byte> data){
   String printString = "";
   byte[] mac = new byte[6];
   int yaw = 0x0000;
   int pitch = 0x0000;
   int roll = 0x0000;
   short _yaw = 0x0000;
   short _pitch = 0x0000;
   short _roll = 0x0000;
   byte curState = (byte) 0x00;
   byte antennaNum = (byte) 0x00;

      printString += "MAC: ";
      for(int i = 0; i < 6; ++i){
        if(i != 5)
         printString += hex(data.get(i)) + ":";
        else
         printString += hex(data.get(i));
         mac[i] = data.get(i);
      }
      
      printString += "\nYAW: ";
      for(int i = 6; i < 8; ++i){
        int temp = 0x00FF;
         yaw += (temp & data.get(i));
         if(i != 7)
         yaw =  yaw << 8; 
      }
      
      _yaw = (short) yaw;
      
      printString += _yaw + "\nPITCH: ";
      
      for(int i = 8; i < 10; ++i){
        int temp = 0x00FF;
         pitch += (temp & data.get(i));
         if(i != 9)
         pitch = pitch << 8; 
      }
      
      _pitch = (short) pitch;
      
      printString += _pitch + "\nROLL: ";
      for(int i = 10; i < 12; ++i){
        int temp = 0x00FF;
         roll += (temp & data.get(i));
         if(i != 11)
         roll = roll << 8; 
      }
      
      _roll = (short) roll;
      printString += _roll + "\n ";
      
      antennaNum = data.get(12);
      printString += "ANTNUM: " + hex(antennaNum);
      println(printString);
      
      
      int lookupKey = convertID(mac);
      if(ah != null){
        if(ah.elementHash.containsKey(lookupKey)){
          
            AntennaElement updateElement = ah.elementHash.get(lookupKey);
            updateElement.setYaw(_yaw);
            updateElement.setPitch(_pitch);
            updateElement.setRoll(_roll);
            ah.addElementRotation(updateElement);
        }
     }
 }
  
 public void printGetAllInfo(List<Byte> data){
   String printString = "";
   byte[] mac = new byte[6];
   byte[] ip = new byte[4];
   byte[] netmask = new byte[4];
   int px1 =  0x00;
   int px2 =  0x00;
   int px3 =  0x00;
   int px4 =  0x00;
   byte curState = (byte) 0x00;
   byte antennaNum = (byte) 0x00;

      printString += "MAC: ";
      for(int i = 0; i < 6; ++i){
        if(i != 5)
         printString += hex(data.get(i)) + ":";
        else
         printString += hex(data.get(i));
         mac[i] = data.get(i);
      }
      
      printString += "\nIP: "; 
      
      for(int i = 6; i < 10; ++i){
        int temp = 0x00FF;
        if(i != 9)
          printString += (temp & data.get(i)) + ".";
        else
          printString += (temp & data.get(i));
          
        ip[i-6] = data.get(i); 
      }
      printString += "\nNETMASK: "; 
      
      for(int i = 10; i < 14; ++i){
        int temp = 0x00FF;
        if(i != 13)
          printString += (temp & data.get(i)) + ".";
        else
          printString += (temp & data.get(i));
        netmask[i-10] = data.get(i);
      }
      printString += "\nCURRENT STATE: "; 
      
      //for current state
      printString += hex(data.get(14));
      printString += "\nPIX1: "; 
      
      curState = data.get(14);
      
      for(int i = 15; i < 18; ++i){
        int temp = 0x00FF;
        if(i != 17)
          printString += ( temp & data.get(i)) + ",";
        else
          printString += ( temp & data.get(i));

        px1 += (data.get(i) & temp);
        if(i != 17)
        px1 = px1 << 8;
      }
      
       px1 = px1 | 0xFF000000;
       
      printString += "\nPIX2: "; 
      
      for(int i = 18; i < 21; ++i){
        int temp = 0x00FF;
        if(i != 20)
          printString += ( temp & data.get(i)) + ",";
        else
          printString += ( temp & data.get(i));
          
        px2 += (data.get(i)&temp);
        if(i != 20)
        px2 = px2 << 8;
      }
      px2 = px2 | 0xFF000000;
      printString += "\nPIX3: "; 
      
      for(int i = 21; i < 24; ++i){
       int temp = 0x00FF;
        if(i != 23)
          printString += ( temp & data.get(i)) + ",";
        else
          printString += ( temp & data.get(i));
        px3 += (data.get(i) & temp);
        if(i != 23)
        px3 = px3 << 8;
      }
      px3 = px3 | 0xFF000000;
      printString += "\nPIX4: "; 
      
      for(int i = 24; i < 27; ++i){
        int temp = 0x00FF;
        if(i != 26)
          printString += ( temp & data.get(i)) + ",";
        else
          printString += ( temp & data.get(i));
          
        px4 += (data.get(i) & temp);
        if(i != 26)
        px4 = px4 << 8;
      }
      px4 = px4 | 0xFF000000;
      printString += "\n";
      
      antennaNum = (byte) data.get(27);
      printString += "NUM: "+hex(antennaNum)+"\n";
     
     AntennaElement newElement = new AntennaElement(mac,ip,netmask,px1,px2,px3,px4,antennaNum);
     //newElement.setCurrentState(curState);
     if(ah != null){
        ah.addAntenna(newElement);
        neoColor white = new neoColor((byte) 0xFF, (byte) 0xFF, (byte) 0xFF);
        //ah.addTrackingElement(newElement,1,white,white,white);
     } 
      
      println(printString);
 }
 
 //function used to convert a mac string to an id, same as in Antenna Element
 public int convertID(byte[] _mac){
    String id = "";
      for(int i = 0; i < _mac.length; ++i){
          id += hex(_mac[i]);
      }
      return id.hashCode();
  }
 
  
  
  
}
