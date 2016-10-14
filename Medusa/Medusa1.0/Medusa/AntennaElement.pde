import java.net.InetAddress;

class AntennaElement{
  
  private byte[] mac;
  private byte[] ip;
  private byte[] netmask;
  private int pixel1;
  private int pixel2;
  private int pixel3;
  private int pixel4;
  private int id;
  private Byte currentState;
  private byte antennaNum;
  
  private PVector physicalLocation; //physical 3-D location of the Antenna
  
  private PVector phy1,phy2,phy3,phy4; //physical 3-D location of all pixels on the antenna
  
  private short yaw,pitch,roll;
  
  private double physicalConfidence;
  
  public final Byte ACTIVE_STATE = (byte) 0x0010;
  
  
  
  public AntennaElement(){
    
  }
  
  public AntennaElement(byte[] _mac, byte[] _ip, byte[] _netmask){
    this.mac = _mac;
    this.ip = _ip;
    this.netmask = _netmask;
    this.pixel1 = 0;
    this.pixel2 = 0;
    this.pixel3 = 0;
    this.pixel4 = 0;
    this.antennaNum = (byte) 0x00; 
    id = getID();
    currentState = ACTIVE_STATE;
    physicalLocation = new PVector(0.0,0.0,0.0);
    phy1 = new PVector();
    phy2 = new PVector();
    phy3 = new PVector();
    phy4 = new PVector();
    physicalConfidence = 0.0;
    yaw = 0;
    pitch = 0;
    roll = 0;
  }
  
  public AntennaElement(byte[] _mac, byte[] _ip, byte[] _netmask, int _pixel1, int _pixel2, int _pixel3, int _pixel4){
    this.mac = _mac;
    this.ip = _ip;
    this.netmask = _netmask;
    this.pixel1 = _pixel1;
    this.pixel2 = _pixel2;
    this.pixel3 = _pixel3;
    this.pixel4 = _pixel4;
    this.antennaNum = (byte) 0x00; 
    id = getID();
    currentState = ACTIVE_STATE;
    physicalLocation = new PVector(0.0,0.0,0.0);
    phy1 = new PVector();
    phy2 = new PVector();
    phy3 = new PVector();
    phy4 = new PVector();
    physicalConfidence = 0.0;
    yaw = 0;
    pitch = 0;
    roll = 0;
  }
  
  public AntennaElement(byte[] _mac, byte[] _ip, byte[] _netmask, int _pixel1, int _pixel2, int _pixel3, int _pixel4, byte _antNum){
    this.mac = _mac;
    this.ip = _ip;
    this.netmask = _netmask;
    this.pixel1 = _pixel1;
    this.pixel2 = _pixel2;
    this.pixel3 = _pixel3;
    this.pixel4 = _pixel4;
    this.antennaNum = (byte) _antNum; 
    id = getID();
    currentState = ACTIVE_STATE;
    physicalLocation = new PVector(0.0,0.0,0.0);
    phy1 = new PVector();
    phy2 = new PVector();
    phy3 = new PVector();
    phy4 = new PVector();
    physicalConfidence = 0.0;
    yaw = 0;
    pitch = 0;
    roll = 0;
  }
  
  public AntennaElement(String _mac, String _ip, String _netmask, int _pixel1, int _pixel2, int _pixel3, int _pixel4){
    this.mac = macStringToBytes(_mac);
    this.ip = ipStringToBytes(_ip);
    this.netmask = ipStringToBytes(_netmask);
    this.pixel1 = _pixel1;
    this.pixel2 = _pixel2;
    this.pixel3 = _pixel3;
    this.pixel4 = _pixel4; 
    id = getID();
    currentState = ACTIVE_STATE;
    physicalLocation = new PVector(0.0,0.0,0.0);
    phy1 = new PVector();
    phy2 = new PVector();
    phy3 = new PVector();
    phy4 = new PVector();
    physicalConfidence = 0.0;
    yaw = 0;
    pitch = 0;
    roll = 0;
  }
  
  public AntennaElement(String _mac, String _ip, String _netmask, int _pixel1, int _pixel2, int _pixel3, int _pixel4, byte _antNum){
    this.mac = macStringToBytes(_mac);
    this.ip = ipStringToBytes(_ip);
    this.netmask = ipStringToBytes(_netmask);
    this.pixel1 = _pixel1;
    this.pixel2 = _pixel2;
    this.pixel3 = _pixel3;
    this.pixel4 = _pixel4;
    this.antennaNum = (byte) _antNum; 
    id = getID();
    currentState = ACTIVE_STATE;
    physicalLocation = new PVector(0.0,0.0,0.0);
    phy1 = new PVector();
    phy2 = new PVector();
    phy3 = new PVector();
    phy4 = new PVector();
    physicalConfidence = 0.0;
    yaw = 0;
    pitch = 0;
    roll = 0;
  }
  
  //Getters
  
  //Since the MAC will be unique, we can place it in a string and get a unique hashcode
  public int getID(){
      String id = "";
      for(int i = 0; i < mac.length; ++i){
          id += hex(mac[i]);
      }
      return id.hashCode();
  }
  
  
  public byte[] getIP(){
     return ip; 
  }
  
  public byte getAntennaNumber(){
     return antennaNum;
  }
  
  public double getConfidence(){
      return physicalConfidence;
  }  
  
  public PVector getPhysicalLocation(){
     return physicalLocation; 
  }
  
  public short getYaw(){
   return yaw; 
  }
  
  public short getPitch(){
    return pitch;
  }
  
  public short getRoll(){
   return roll; 
  }
  
  public String getIPAsString(){
    String id = "";
      for(int i = 0; i < ip.length; ++i){
        if( (i+1) != ip.length)
          id += (0x00FF & ip[i]) +".";
        else
          id += (0x00FF & ip[i]);
      }
      return id;
  }
  
  public byte[] getMac(){
     return mac; 
  }
  
  public String getMacAsString(){
    String id = "";
      for(int i = 0; i < mac.length; ++i){
         if( (i+1) != mac.length)
            id += hex(mac[i]) +":";
          else
            id += hex(mac[i]);
      }
      return id;
  }
  
  public byte[] getNetmask(){
     return netmask; 
  }
  
  public String getNetmaskAsString(){
    String id = "";
      for(int i = 0; i < netmask.length; ++i){
          if( (i+1) != netmask.length)
            id += (0x00FF & netmask[i]) +".";
          else
            id += (0x00FF & netmask[i]);
      }
      return id;
  }
  
  public int getPixel(int number){
     switch(number){
        case 1:
           return pixel1;
        case 2:
          return pixel2;
        case 3:
          return pixel3;
        case 4:
          return pixel4;
        default:
          return pixel1;
     } 
  }
  
  public PVector getPixelPhysicalLocation(int number){
     switch(number){
        case 1:
           return phy1;
        case 2:
          return phy2;
        case 3:
          return phy3;
        case 4:
          return phy4;
        default:
          return phy1;
     } 
  }
  
  public byte getCurrentState(){
     return currentState; 
  }
  
  public byte getRed(int pixelColor){
      return (byte) ( (pixelColor & 0x00FF0000) >> 16);
  }
  
  public byte getGreen(int pixelColor){
      return (byte) ( (pixelColor & 0x0000FF00) >> 8);
  }
  
  public byte getBlue(int pixelColor){
      return (byte) ( (pixelColor & 0x000000FF));
  }
  
  //Setters
  public void setIP(byte[] _ip){
   this.ip = _ip; 
  }
  
  public void setMac(byte[] _mac){
   this.mac = _mac; 
  }
  
  public void setNetmask(byte[] _netmask){
   this.netmask = _netmask; 
  }
  
  public void setCurrentState(byte _state){
     currentState = _state; 
  }
  
  public void setAntennaNumber(byte _antNum){
     antennaNum = _antNum; 
  }
  
  public void setConfidence(double _conf){
     physicalConfidence = _conf; 
  }
  
  public void setYaw(short _yaw){
     yaw = _yaw; 
  }
  
  public void setPitch(short _pitch){
     pitch = _pitch; 
  }
  
  public void setRoll(short _roll){
     roll = _roll; 
  }
  
  public void setPixel(int number, int _color){
    
     switch(number){
        case 1:
           this.pixel1 = _color;
          break;
        
        case 2:
          this.pixel2 = _color;
          break;
          
        case 3:
          this.pixel3 = _color;
          break;
          
        case 4:
          this.pixel4 = _color;
          break;
        
        default:
          this.pixel1 = _color;
          break;
     } 
  }
  
  public void setPixelPhysicalLocation(int number, PVector _loc){
    
     switch(number){
        case 1:
           this.phy1 = _loc;
          break;
        
        case 2:
          this.phy2 = _loc;
          break;
          
        case 3:
          this.phy3 = _loc;
          break;
          
        case 4:
          this.phy4 = _loc;
          break;
        
        default:
          this.phy1 = _loc;
          break;
     } 
  }
  
  public void setPixelPhysicalLocations(PVector[] _locs){
     if(_locs.length == 4){
      phy1 = _locs[0];
      phy2 = _locs[1];
      phy3 = _locs[2];
      phy4 = _locs[3];
     } 
  }
  
  public void setPhysicalLocation(PVector _loc){
     physicalLocation = _loc; 
  }
  
  
  
  public byte[] macStringToBytes(String _mac){
       String altered = _mac.replace(":","");
     
     return hexStringToByteArray(altered); 
  }
  
  public byte[] hexStringToByteArray(String s) {
    int len = s.length();
    byte[] data = new byte[len / 2];
    for (int i = 0; i < len; i += 2) {
        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                             + Character.digit(s.charAt(i+1), 16));
    }
    return data;
}
  
  public byte[] ipStringToBytes(String _ip){
    InetAddress address = null;
    try{
      address = InetAddress.getByName(_ip);
    }catch(Exception e){
     println("Couldn't get IP Address"); 
    }
     
     return address.getAddress(); 
  } 
  
}

///////CLASS FOR NEO COLOR
public class neoColor{
     public byte red,green,blue;
    
    public neoColor(){
     
    }
   
   public neoColor(byte _red, byte _green, byte _blue){
      this.red = _red;
      this.green = _green;
      this.blue = _blue;
   }
  
  public neoColor(int _color){
   this.red = (byte) ((_color & 0x00FF0000) >> 16);
   this.green = (byte) ((_color & 0x0000FF00) >> 8);
   this.blue = (byte) (_color & 0x000000FF);
  }
 
  public void setColor(int _color){
   this.red = (byte) ((_color & 0x00FF0000) >> 16);
   this.green = (byte) ((_color & 0x0000FF00) >> 8);
   this.blue = (byte) (_color & 0x000000FF);
  }
  
  public void setColor(byte _red, byte _green, byte _blue){
     this.red = _red;
     this.green = _green;
     this.blue = _blue; 
  }
 
 public int getColorAsInt(){
     int returnColor = 0x0000;
     int temp = 0x00FF;
     returnColor += (this.red & temp);
     returnColor = returnColor << 8;
     returnColor += (this.green & temp);
     returnColor = returnColor << 8;
     returnColor += (this.blue & temp);
     returnColor = returnColor | 0xFF000000;
     return returnColor;
 }
}

//Tracking Element
public class trackingElement{
   public int elementID;
   public int hsv;
   public neoColor trackColor,filterHigh,filterLow;
  
  public trackingElement(){
   this.elementID = 0;
   this.hsv = 0;
   this.trackColor = new neoColor();
   this.filterHigh = new neoColor();
   this.filterLow = new neoColor();
  }
 
  public trackingElement(int _el, int _hsv, int _trackingColor, int _filterHigh, int _filterLow){
   this.elementID = _el;
   this.hsv = _hsv;
   this.trackColor = new neoColor(_trackingColor);
   this.filterHigh = new neoColor(_filterHigh);
   this.filterLow = new neoColor(_filterLow); 
  }
}





