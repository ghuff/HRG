//Jeff Jensen
//Control of antenna modules with medusa protocol

#include <EtherCard.h>
#include <IPAddress.h>
#include <Wire.h>
#include <SPI.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_LSM9DS0.h>
#include <Adafruit_Simple_AHRS.h>


//9DOF CONFIGURATION///////////////////////
// Create LSM9DS0 board instance.
Adafruit_LSM9DS0     lsm(1000);  // Use I2C, ID #1000
boolean LSM_OK = true;

//Configure Mode I2C Setup
Adafruit_Simple_AHRS ahrs(&lsm.getAccel(), &lsm.getMag());

void configureLSM9DS0(void)
{
  // 1.) Set the accelerometer range
  lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_2G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_4G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_6G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_8G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_16G);
  
  // 2.) Set the magnetometer sensitivity
  lsm.setupMag(lsm.LSM9DS0_MAGGAIN_2GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_4GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_8GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_12GAUSS);

  // 3.) Setup the gyroscope
  lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_245DPS);
  //lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_500DPS);
  //lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_2000DPS);
}


//NEO PIXEL//////////////////////////////////////////////////
#include <Adafruit_NeoPixel.h>

#define PIN 6
#define LED_COUNT 4


// Parameter 1 = number of pixels in strip
// Parameter 2 = Arduino pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(LED_COUNT, PIN, NEO_GRB + NEO_KHZ800);

byte neoPixels [4][3] = { {0xFF,0x00,0x00},
                          {0xFF,0x00,0x00},
                          {0xFF,0x00,0x00},
                          {0xFF,0x00,0x00}};  //schema (r,g,b)

//END NEO PIXEL

//PROTOCOL CONFIGURATION

//header information
#define STARTBYTE 0x70

//information commands
#define INFO_GET_ALL 0xE0
#define INFO_GET_MAC 0xE1
#define INFO_GET_MAC_OK 0xE2
#define INFO_GET_MAC_BAD 0xE3
#define INFO_GET_IP 0xE4
#define INFO_GET_IP_OK 0xE5
#define INFO_GET_IP_BAD 0xE6
#define INFO_GET_PIXELS 0xE7
#define INFO_GET_YAW_PITCH_ROLL 0xE8

//defines different control and configuration of lights
#define LIGHTS_SOLID_COLOR 0xA0
#define LIGHTS_SPARKLE 0xA1
#define LIGHTS_INDIVIDUAL_COLOR 0xA2

//CONFIGURATION COMMANDS
#define CHANGE_ANTENNA_NUMBER 0xB0
#define CHANGE_ANTENNA_NUMBER_OK 0xB1
#define CHANGE_ANTENNA_NUMBER_BAD 0xB2

///////////////////////////////////////////////////


//START ETHERCARD CONFIGURATION/////////////////////////////////////////////
#define STATIC 1  // set to 1 to disable DHCP (adjust myip/gwip values below)
static byte currentState = 0x00;
static byte antennaNum = 0x13;




#if STATIC
// ethernet interface ip address
static byte myip[] = { 192,168,1,219 };
// gateway ip address
static byte gwip[] = { 192,168,1,200 };
static byte gw_netmask[] = {255,255,255,0}; //must add netmask in order for Ethercard to generate the correct destination MAC Address

static uint16_t nSourcePort = 1234;
static uint16_t nDestinationPort = 6000;
//dns ip address
static byte dnsip[] = {192,168,1,200};
#endif

// ethernet mac address - must be unique on your network
static byte mymac[] = { 0x70,0x69,0x69,0x2D,0x30,0x43 };

byte Ethernet::buffer[500]; // tcp/ip send and receive buffer

//END ETHERCARD CONFIGURATION/////////////////////////////////////////////////

//callback that prints received packets to the serial port
void udpSerialPrint(word port, byte ip[4], const char *data, word len) {
  IPAddress src(ip[0], ip[1], ip[2], ip[3]);
  Serial.println(src);
  Serial.println(port);
  Serial.println(data);
  Serial.println(len);
  decipherPacket(data,len);
  
  //char payload[] = "My UDP message";
  //ether.sendUdp(payload, sizeof(payload), nSourcePort, gwip, nDestinationPort);

}

byte calculateChecksum(word check){
  return ((check % 256 ) & 0x00FF);
}

void cacheAllPixelColor(byte red, byte green, byte blue){
  for(int i = 0; i < strip.numPixels(); ++i){
     neoPixels[i][0] = red;
     neoPixels[i][1] = green;
     neoPixels[i][2] = blue;
  } 
}

void decipherPacket(const char *data, int len){

  //receive buffer parameters  
  byte length = 0x00;
  byte control = 0x00;
  byte checksum = 0x00;
  word calcChecksum = 0x0000;
  byte finalChecksum = 0x00;
  //create a fixed buffer for the data received max. 200 bytes due to ethercard max.
  byte controlData[30] = {0};
  
  //send buffer parameters
  char sendBuffer[32] = {0};
  byte sendLength = 0x00;
  word sendChecksum = 0x0000;
  
  if(data){
    //read the packet within its bounds
      if(len >= 3){
        if(data[0] == STARTBYTE){
           calcChecksum += STARTBYTE;
           length = data[1];
           control = data[2];
           calcChecksum += length;
           calcChecksum += control;
           
           if( (3+length) >= len ){
             char lengthTooLong[] = "Length too Long";
            ether.sendUdp(lengthTooLong, sizeof(lengthTooLong), nSourcePort, gwip, nDestinationPort);
            return;
           }
           
           for(int i = 3; i < 3 + length; ++i){
              controlData[i - 3] = data[i];
              calcChecksum += controlData[i-3];
           }
           
           //calcChecksum %= 256;
           
           //finalChecksum = calcChecksum & 0x00FF;
           finalChecksum = calculateChecksum(calcChecksum);
           checksum = data[len-1];
           if(finalChecksum == checksum){
             //char okMessage[] = "Message OK";
            //ether.sendUdp(okMessage, sizeof(okMessage), nSourcePort, gwip, nDestinationPort);
            
            //used in individual color
            int counter = 0;
            uint16_t pixel = 0;
            byte tempdata[] = {0,0,0};
            sensors_vec_t orientation; //used for LSM get orientation stuff
            
            switch(control){
             
             case LIGHTS_SOLID_COLOR:
                 //Serial.print("C1 ");Serial.print(controlData[0]);Serial.print(" C2 ");Serial.print(controlData[1]);Serial.print(" C3 ");Serial.print(controlData[2]);Serial.println();
                 colorWipe(strip.Color(controlData[0], controlData[1], controlData[2]), 50);
                 cacheAllPixelColor(controlData[0], controlData[1], controlData[2]);
                 break;
                 
             case LIGHTS_SPARKLE:
                 theaterChase(strip.Color(controlData[0], controlData[1], controlData[2]), 50); 
                 cacheAllPixelColor(controlData[0], controlData[1], controlData[2]);
                 break;
                 
             case CHANGE_ANTENNA_NUMBER:
                 antennaNum = controlData[0];
                 sendLength = 0x07; //7 bytes including MAC, AntennaNUM
                  sendBuffer[0] = STARTBYTE;
                  sendChecksum += STARTBYTE;
                  sendBuffer[1] = sendLength;
                  sendChecksum += sendLength;
                  sendBuffer[2] = CHANGE_ANTENNA_NUMBER_OK;
                  sendChecksum += CHANGE_ANTENNA_NUMBER_OK;
                  
                  for(int i = 0; i < sizeof(mymac); ++i){ //6
                    sendBuffer[3+i] = mymac[i];
                    sendChecksum += mymac[i];
                  }
                  
                  sendBuffer[9] = antennaNum;
                  sendChecksum += antennaNum;
                  
                  sendBuffer[10] = calculateChecksum(sendChecksum);
                  ether.sendUdp(sendBuffer,sendLength + 0x04, nSourcePort, gwip, nDestinationPort);
                 
                 break;
                 
                 
                 
             case LIGHTS_INDIVIDUAL_COLOR:
                 //see the MedusaMessageHandler.java for implementation on changing individual color pixels
                 //the color codes for each pixel are stored in a class neoColor.java
                 
                 //create a safe for loop that will write colors every three data points
                 //since we're using UDP communication, there is a chance that the data will get lost
                  counter = 0;
                  pixel = 0;
                 
                 for(int i = 0; i < length; ++i){
                   tempdata[counter] = controlData[i];
                   ++counter;
                   
                   if(counter == 3){
                     individualColorWipe(pixel,strip.Color(tempdata[0],tempdata[1],tempdata[2]),50);
                     neoPixels[pixel][0] = tempdata[0]; //red
                     neoPixels[pixel][1] = tempdata[1]; // green
                     neoPixels[pixel][2] = tempdata[2]; //blue
                     ++pixel;
                     counter = 0;
                   }
                 }
                 break;
                 
              case INFO_GET_ALL:
                  sendLength = 0x1C; //29 bytes including MAC, IP, NETMASK, CURRENT_STATE, PIXELS 
                  sendBuffer[0] = STARTBYTE;
                  sendChecksum += STARTBYTE;
                  sendBuffer[1] = sendLength;
                  sendChecksum += sendLength;
                  sendBuffer[2] = INFO_GET_ALL;
                  sendChecksum += INFO_GET_ALL;
                  
                  for(int i = 0; i < sizeof(mymac); ++i){ //6
                    sendBuffer[3+i] = mymac[i];
                    sendChecksum += mymac[i];
                  }
                  for(int i = 0; i < sizeof(myip); ++i){//4
                    sendBuffer[9+i] = myip[i];
                    sendChecksum += myip[i];
                  }
                  for(int i = 0; i < sizeof(gw_netmask); ++i){//4
                    sendBuffer[13+i] = gw_netmask[i];
                    sendChecksum += gw_netmask[i];
                  }
                  sendBuffer[17] = currentState; // 1
                  sendChecksum += currentState;
                  for(int i = 0; i < 4; ++i){
                    for(int j = 0; j < 3; ++j){
                      sendBuffer[18 + (i*3 + j)] = neoPixels[i][j];
                      sendChecksum += sendBuffer[18+ (i*3+j)];
                    } 
                  }
                  
                  sendBuffer[30] = antennaNum;
                  sendChecksum += antennaNum;
                  
                  sendBuffer[31] = calculateChecksum(sendChecksum);
                  
                  ether.sendUdp(sendBuffer,sendLength + 0x04, nSourcePort, gwip, nDestinationPort);
                  break;
                  
              case INFO_GET_MAC:
                  sendLength = 0x07; //7 bytes including MAC, AntennaNUM
                  sendBuffer[0] = STARTBYTE;
                  sendChecksum += STARTBYTE;
                  sendBuffer[1] = sendLength;
                  sendChecksum += sendLength;
                  sendBuffer[2] = INFO_GET_MAC_OK;
                  sendChecksum += INFO_GET_MAC_OK;
                  
                  for(int i = 0; i < sizeof(mymac); ++i){ //6
                    sendBuffer[3+i] = mymac[i];
                    sendChecksum += mymac[i];
                  }
                  
                  sendBuffer[9] = antennaNum;
                  sendChecksum += antennaNum;
                  
                  sendBuffer[10] = calculateChecksum(sendChecksum);
                  ether.sendUdp(sendBuffer,sendLength + 0x04, nSourcePort, gwip, nDestinationPort);
              break;
              
              case INFO_GET_IP:
                  sendLength = 0x0F; //15 bytes including MAC, IP, NETMASK, CURRENT_STATE, PIXELS 
                  sendBuffer[0] = STARTBYTE;
                  sendChecksum += STARTBYTE;
                  sendBuffer[1] = sendLength;
                  sendChecksum += sendLength;
                  sendBuffer[2] = INFO_GET_IP_OK;
                  sendChecksum += INFO_GET_IP_OK;
                  
                  for(int i = 0; i < sizeof(mymac); ++i){ //6
                    sendBuffer[3+i] = mymac[i];
                    sendChecksum += mymac[i];
                  }
                  
                  for(int i = 0; i < sizeof(myip); ++i){//4
                    sendBuffer[9+i] = myip[i];
                    sendChecksum += myip[i];
                  }
                  
                  for(int i = 0; i < sizeof(gw_netmask); ++i){//4
                    sendBuffer[13+i] = gw_netmask[i];
                    sendChecksum += gw_netmask[i];
                  }
                  
                  sendBuffer[17] = antennaNum;
                  sendChecksum += antennaNum;
                  
                  sendBuffer[18] = calculateChecksum(sendChecksum);
                  ether.sendUdp(sendBuffer,sendLength + 0x04, nSourcePort, gwip, nDestinationPort);
              break;
              
              case INFO_GET_YAW_PITCH_ROLL:
                  sendLength = 0x0D; //19 bytes including MAC, YAW, PITCH, ROLL, ANTNUM
                  sendBuffer[0] = STARTBYTE;
                  sendChecksum += STARTBYTE;
                  sendBuffer[1] = sendLength;
                  sendChecksum += sendLength;
                  sendBuffer[2] = INFO_GET_YAW_PITCH_ROLL;
                  sendChecksum += INFO_GET_YAW_PITCH_ROLL;
                  
                  for(int i = 0; i < sizeof(mymac); ++i){ //6
                    sendBuffer[3+i] = mymac[i];
                    sendChecksum += mymac[i];
                  }
                  
                  ahrs.getOrientation(&orientation);
                  /*sendBuffer[9] = (byte)((((int)orientation.heading) & 0xFF000000) >> 24); //MSB
                  sendChecksum += sendBuffer[9];
                  sendBuffer[10] = (byte)((((int)orientation.heading) & 0x00FF0000) >> 16); //MSB
                  sendChecksum += sendBuffer[10];
                  sendBuffer[11] = (byte)((((int)orientation.heading) & 0x0000FF00) >> 8); //MSB
                  sendChecksum += sendBuffer[11];
                  sendBuffer[12] = (byte)(((int)orientation.heading) & 0x000000FF); //MSB
                  sendChecksum += sendBuffer[12];
                  
                  sendBuffer[13] = (byte)((((int)orientation.pitch) & 0xFF000000) >> 24); //MSB
                  sendChecksum += sendBuffer[13];
                  sendBuffer[14] = (byte)((((int)orientation.pitch) & 0x00FF0000) >> 16); //MSB
                  sendChecksum += sendBuffer[14];
                  sendBuffer[15] = (byte)((((int)orientation.pitch) & 0x0000FF00) >> 8); //MSB
                  sendChecksum += sendBuffer[15];
                  sendBuffer[16] = (byte)(((int)orientation.pitch) & 0x000000FF); //MSB
                  sendChecksum += sendBuffer[16];
                  
                  sendBuffer[17] = (byte)((((int)orientation.roll) & 0xFF000000) >> 24); //MSB
                  sendChecksum += sendBuffer[17];
                  sendBuffer[18] = (byte)((((int)orientation.roll) & 0x00FF0000) >> 16); //MSB
                  sendChecksum += sendBuffer[18];
                  sendBuffer[19] = (byte)((((int)orientation.roll) & 0x0000FF00) >> 8); //MSB
                  sendChecksum += sendBuffer[19];
                  sendBuffer[20] = (byte)(((int)orientation.roll) & 0x000000FF); //MSB
                  sendChecksum += sendBuffer[20];*/
                  sendBuffer[9] = (byte)((((int)orientation.heading) & 0x0000FF00) >> 8); //MSB
                  sendChecksum += sendBuffer[9];
                  sendBuffer[10] = (byte)(((int)orientation.heading) & 0x000000FF); //MSB
                  sendChecksum += sendBuffer[10];
                  
                  sendBuffer[11] = (byte)((((int)orientation.pitch) & 0x0000FF00) >> 8); //MSB
                  sendChecksum += sendBuffer[11];
                  sendBuffer[12] = (byte)(((int)orientation.pitch) & 0x000000FF); //MSB
                  sendChecksum += sendBuffer[12];
                  
                  sendBuffer[13] = (byte)((((int)orientation.roll) & 0x0000FF00) >> 8); //MSB
                  sendChecksum += sendBuffer[13];
                  sendBuffer[14] = (byte)(((int)orientation.roll) & 0x000000FF); //MSB
                  sendChecksum += sendBuffer[14];
                  
                  //Serial.println((int)orientation.heading,HEX);
                 // Serial.println(orientation.pitch);
                 // Serial.println(orientation.roll);
                  
                  sendBuffer[15] = antennaNum;
                  sendChecksum += antennaNum;
                  
                  sendBuffer[16] = calculateChecksum(sendChecksum);
                  ether.sendUdp(sendBuffer,sendLength + 0x04, nSourcePort, gwip, nDestinationPort);
                
              break;
              
                 
                 
             default:
               char noControl[] = "Unknown Control Message!";
               ether.sendUdp(noControl, sizeof(noControl), nSourcePort, gwip, nDestinationPort);
               break;
            }
            
           }else{
            char badChecksum[] = "Bad Checksum";
            ether.sendUdp(badChecksum, sizeof(badChecksum), nSourcePort, gwip, nDestinationPort);
           } 
        }
      }else{
        char badPacket[] = "Bad Packet, Command Header less than 3 Bytes";
        ether.sendUdp(badPacket, sizeof(badPacket), nSourcePort, gwip, nDestinationPort);
      }
  }else{
    return;
  }
}

// Fill the dots one after the other with a color
void colorWipe(uint32_t c, uint8_t wait) {
  for(uint16_t i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
      strip.show();
      delay(wait);
  }
  currentState = LIGHTS_SOLID_COLOR;
}

void individualColorWipe(uint16_t pixNum, uint32_t c, uint8_t wait){
      strip.setPixelColor(pixNum, c);
      strip.show();
      delay(wait);
  currentState = LIGHTS_INDIVIDUAL_COLOR;
}

void theaterChase(uint32_t c, uint8_t wait) {
  for (int j=0; j<10; j++) {  //do 10 cycles of chasing
    for (int q=0; q < 3; q++) {
      for (int i=0; i < strip.numPixels(); i=i+3) {
        strip.setPixelColor(i+q, c);    //turn every third pixel on
      }
      strip.show();
     
      delay(wait);
     
      for (int i=0; i < strip.numPixels(); i=i+3) {
        strip.setPixelColor(i+q, 0);        //turn every third pixel off
      }
    }
  }
  currentState = LIGHTS_SPARKLE;
}



void setup(){
  
  //NEOPIXEL INIT
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
  colorWipe(strip.Color(255, 0, 0), 50); // Red
  
  //9DOF INIT
  /*if(!lsm.begin())
  {
    // There was a problem detecting the LSM9DS0 ... check your connections
    Serial.print(F("LSM Couldn't be detected!"));
    LSM_OK = false;
  }else{
   LSM_OK = true;
   configureLSM9DS0();
  }*/
  
  
  Serial.begin(57600);
  //Serial.println(F("\n[backSoon]"));

  if (ether.begin(sizeof Ethernet::buffer, mymac) == 0)
    Serial.println(F("Failed to access Ethernet controller"));
#if STATIC
  ether.staticSetup(myip, gwip,dnsip,gw_netmask);
#else
  if (!ether.dhcpSetup())
    Serial.println(F("DHCP failed"));
#endif

  ether.printIp("IP:  ", ether.myip);
  ether.printIp("GW:  ", ether.gwip);
  ether.printIp("DNS: ", ether.dnsip);

  //register udpSerialPrint() to port 1337
  ether.udpServerListenOnPort(&udpSerialPrint, 1337);

  //register udpSerialPrint() to port 42.
  ether.udpServerListenOnPort(&udpSerialPrint, 42);
}

void loop(){
  //this must be called for ethercard functions to work.
  ether.packetLoop(ether.packetReceive());
}
