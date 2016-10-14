import processing.serial.*;

public class MedusaSerialHandler{
 
 private Serial serialPort;  // Create object from Serial class
 private int BAUD_RATE = 9600;
 private int PARITY = 1;
 private String COM_PORT = "COM1";
 private PApplet app;
 private int[] buffer = new int[1024];
 
 private Thread receiveThread;
 
 public ArrayList<String> availablePorts;

public MedusaSerialHandler(PApplet _app){
   app = _app;
   receiveThread = new Thread();
   availablePorts = new ArrayList<String>();
   updateAvailablePorts();
   if(checkPortExists(COM_PORT)){
     serialPort = new Serial(this.app, COM_PORT, BAUD_RATE);
     if(!(receiveThread.isAlive())){
        receiveThread = new Thread((new receiveAll()));
        receiveThread.start(); 
     }
   }
}

//Getters
public String getComPort(){
   return COM_PORT; 
}

public int getParity(){
   return PARITY; 
}

public int getBaudRate(){
   return BAUD_RATE; 
}

//Setters
public void setComPort(String port){
    serialStop();
    COM_PORT = port;
    if(checkPortExists(COM_PORT)){
      serialPort = new Serial(this.app, COM_PORT, BAUD_RATE);
      if(!(receiveThread.isAlive())){
        receiveThread = new Thread((new receiveAll()));
        receiveThread.start(); 
     }
    }
}

public void setBaudRate(int rate){
   BAUD_RATE = rate; 
}

public void setParity(int parity){
  PARITY = parity; 
}

//Other functions

public void serialStop(){
  if(serialPort != null){
   serialPort.stop();
  } 
}

public void updateAvailablePorts(){
  availablePorts.clear();
  String[] ports = serialPort.list();
  //println("AVAILABLE PORTS: ");
  for(int i = 0; i < ports.length; ++i){
      availablePorts.add(ports[i]);
      //println(ports[i]);
  }
}

private boolean checkPortExists(String port){
 
   for(int i = 0; i < availablePorts.size(); ++i){
      if(port.equals(availablePorts.get(i))){
         println("Port "+port+" Found");
         return true; 
      }
   }
  println("Port "+COM_PORT+" was not found");
  return false; 
}


//All writing functions according to processing...
//////////////////////////////////////////////////
public void serialWrite(byte[] chars){
  if(serialPort != null){
    for(int i = 0; i < chars.length; ++i){
       serialPort.write(chars[i]); 
    }
  }
}

public void serialWrite(char[] chars){
  if(serialPort != null){
    for(int i = 0; i < chars.length; ++i){
       serialPort.write(chars[i]); 
    }
  }
}

public void serialWrite(ArrayList<Character> chars){
  if(serialPort != null){
    for(int i = 0; i < chars.size(); ++i){
       serialPort.write(chars.get(i)); 
    }
  }
}

public void serialWrite(byte newByte){
  if(serialPort != null)
   serialPort.write(newByte); 
}

public void serialWrite(char newChar){
  if(serialPort != null)
   serialPort.write(newChar); 
}

public void serialWrite(String _string){
  if(serialPort != null)
   serialPort.write(_string); 
}

//RECEIVING

public void startReceiving(){
  
}

public class receiveAll implements Runnable{
 
  private boolean running;
  private boolean watchNext;
  private int counter;
  
 public receiveAll(){
   running = true;
   watchNext = false;
   counter = 0;
 }
 
 public void stopRunning(){
     running = false;
 }

public void run(){
  
  while(running){
    if(serialPort != null){
       while (serialPort.available() > 0) {
          int inByte = serialPort.read();
          buffer[counter] = inByte;
          ++counter;
          if(watchNext){
             if(inByte == 10){
                printBuffer(counter);
                watchNext = false;
                counter = 0;
             } 
          }
          
          if(inByte == 13){
            watchNext = true;
          }

        } 
    }
  }
 
} 
  
}

public void printBuffer(int stop){
  String ps = "";
  stop += -2;
   for(int i = 0; i < stop; ++i){
        ps += str(char(buffer[i]));
   }
  println(ps); 
}
  
  
  
  
}
