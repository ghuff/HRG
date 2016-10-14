import hypermedia.net.*;


class udp_client{
  
  private UDP udp;  // define the UDP object
  private MedusaMessageHandler mh;
  private int PORT = 6000;
  
  public udp_client(){
     udp = null;
     mh = null; 
  }


 public udp_client(PApplet app){
 
 udp = new UDP( app, PORT );  // create a new datagram connection on port 6000
 mh = new MedusaMessageHandler();
 //udp.log( true );     // <-- printout the connection activity
 udp.listen( true );           // and wait for incoming message
 }

 public void sendPacket(byte[] data, String ip, int dstPort){
   
 }

 void receive( byte[] data ) {       // <-- default handler
 //void receive( byte[] data, String ip, int port ) {  // <-- extended handler

 mh.decipherPacket(data);
 for(int i=0; i < data.length; i++)
 print(hex(data[i]));
 println();
 }
 }
