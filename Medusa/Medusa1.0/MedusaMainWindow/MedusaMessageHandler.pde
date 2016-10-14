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
  public final int INFO_GET_IP  = 0x00E2;
  public final int INFO_GET_PIXELS = 0x00E3;
  
  //constructors
  public MedusaMessageHandler(){
    
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
    //payload length will be 3 bytes
    byte LENGTH = 0x0001;
    
    int checksum =  STARTBYTE +  LENGTH +  INFO_GET_ALL +  options;
    
    byte mydata[] = {(byte)STARTBYTE,(byte)LENGTH,(byte)INFO_GET_ALL,(byte) options,calcChecksum(checksum)};
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
        
        for(int i = 3; i < payloadLength + 4; ++i){
           controlData.add(data[i]);
           receiveChecksum += data[i];
        }
        
        finalChecksum = calcChecksum(receiveChecksum);
        
        
        if((byte)(finalChecksum & data[4+payloadLength]) != (byte)finalChecksum){
           println("Checksum "+hex(finalChecksum)+ " is not " + hex(data[3+payloadLength+1]));
          return; 
        }else{
         
            switch(command){
             
             case (byte) INFO_GET_ALL:
             printGetAllInfo(controlData);
              //println("INFO GET ALL");
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
  
 public void printGetAllInfo(List<Byte> data){
   String mac = "";
   String ip = "";
   String netmask = "";
   String currentState ="";
   String pixel1 = "";
   String pixel2 = "";
   String pixel3 = "";
   String pixel4 = "";

   
      for(int i = 0; i < 6; ++i){
         mac += hex(data.get(i));
      } 
      
      for(int i = 6; i < 10; ++i){
        int temp = 0x00FF;
        ip += (temp & data.get(i)) + "."; 
      }
      
      for(int i = 10; i < 14; ++i){
        int temp = 0x00FF;
        netmask += (temp & data.get(i)) + "."; 
      }
      
      currentState += hex(data.get(14));
      
      for(int i = 15; i < 18; ++i){
        int temp = 0x00FF;
        pixel1 += ( temp & data.get(i)) + ",";
      }
      
      for(int i = 18; i < 21; ++i){
        int temp = 0x00FF;
        pixel2 += ( temp & data.get(i)) + ",";
      }
      
      for(int i = 21; i < 24; ++i){
       int temp = 0x00FF;
        pixel3 += ( temp & data.get(i)) + ",";
      }
      
      for(int i = 24; i < 27; ++i){
        int temp = 0x00FF;
        pixel4 += ( temp & data.get(i)) + ",";
      }
      
      println("MAC: "+mac);
      println("IP: "+ip);
      println("NETMASK: "+netmask);
      println("STATE: "+currentState);
      println("PIX1: "+pixel1+" PIX2: "+pixel2+" PIX3: "+pixel3+" PIX4: "+pixel4);
 }
 
  
  
  
}
