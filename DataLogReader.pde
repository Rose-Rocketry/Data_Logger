import processing.serial.*;
import java.util.List;
import java.util.Arrays;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
byte[] dataBuffer;

Serial port;

int dummy_thicc;

File outputFile = null;

int packageSize = 12;

void setup(){
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  port = new Serial(this, Serial.list()[0], 9600);
  println(sketchPath());
  List<String> names = Arrays.asList(new File(sketchPath() + "/data").list());
  for(int i = 0; outputFile == null; i++){
    if(!names.contains("log" + i + ".txt")){
      outputFile = new File(sketchPath() + "/data/log" + i + ".txt");
    }
  }
  try{
    outputFile.createNewFile();
  }catch(Exception e){
    System.out.println(e);  
  }
  println(outputFile.getPath());
  
  frameRate(30);
  
  delay(500);
}

int data;
void draw(){
  //port.write('A');
  if((data = port.read()) != -1){
    //println((int)data);
    println(bytesSoFar + "/" + byteCount);
    onByte();
  }else if(state == -1){
    port.write('p'); // p for pog or please depending on how it's going
  }
}

int state = -1;
int byteCount = 0;
int bytesSoFar = 0;
byte[] fileData;
byte sizeRegister;
void onByte(){
  switch(state){
    case -1:
      state++;
      break;
    case 0:
      byteCount = 0;
      byteCount |= (data << 0);
      println(byteCount);
      state++;
      break;
    case 1:
      byteCount |= (data << 8);
      println(byteCount);
      state++;
      break;
    case 2:
      byteCount |= (data << 16);
      println(byteCount);
      state++;
      break;
    case 3:
      byteCount |= (data << 24);
      println(byteCount);
      fileData = new byte[byteCount];
      state++;
      break;
    case 4:
      fileData[bytesSoFar] = (byte)data;
      bytesSoFar++;
      if(bytesSoFar == byteCount){
        parseData();
        state = 7;
        byteCount = 0;
        bytesSoFar = 0;
      }
      break;
    case 7:
      println("??: " + (int)data);
      break;
      
  }
}

float[] parsedData;
void parseData(){
  parsedData = new float[fileData.length / 4];
  for(int i = 0; i < parsedData.length; i++){
    byte[] bytes = {fileData[i * 4], fileData[i * 4 + 1], fileData[i * 4 + 2], fileData[i * 4 + 3]};
    parsedData[i] = byteArrayToFloat(bytes);
    //parsedData[i] = ByteBuffer.wrap(bytes).order(ByteOrder.BIG_ENDIAN).getFloat();
    
  }
  printArray(parsedData);
  try{
    PrintWriter pw = new PrintWriter(outputFile);
    for(int p = 0; p < parsedData.length / packageSize; p++){
      for(int i = 0; i < packageSize; i++){
        pw.print(parsedData[p * packageSize + i] + ",");
      }
      pw.println();
    }
    pw.close();
  }catch(Exception e){
    println(e);
  }
}

public float byteArrayToFloat(byte test[]) { 
    int MASK = 0xff; 
    int bits = 0; 
    int i = 3; 
    for (int shifter = 3; shifter >= 0; shifter--) { 
    bits |= ((int) test[i] & MASK) << (shifter * 8); 
    i--; 
    } 
    return Float.intBitsToFloat(bits); 
} // Credit for conversion script cadomanis of the Processing Forum. 
