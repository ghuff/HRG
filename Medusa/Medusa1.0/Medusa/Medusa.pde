
import hypermedia.net.*;

class udpClient{
  
  private UDP udp;  // define the UDP object
  private int PORT = 6000;
  
  public udpClient(){
     udp = null;
  }


 public udpClient(PApplet app){
 
 udp = new UDP( app, PORT, "192.168.1.200" );  // create a new datagram connection on port 6000
 //udp.log( true );     // <-- printout the connection activity
 udp.listen( true );           // and wait for incoming message
 }

 public void sendPacket(byte[] data, String ip, int dstPort){
   udp.send(data,ip,dstPort);
 }

 
 }
