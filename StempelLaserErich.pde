import processing.serial.*;

boolean arduino = false;
long staemps = 0;
long freeStaemps = 0;

long last_staemps = 0;
long last_freeStaemps = 0;

Serial port;

void setup() {
  String[] c = loadStrings("current.txt");

  if (c.length == 2) {
    last_staemps = parseInt(c[0]);
    last_freeStaemps = parseInt(c[1]);
  }

  String portName = getArduino(Serial.list());
  if (portName.length() > 0) {
    arduino = true;
  }

  if (arduino) {
    port = new Serial(this, portName, 9600);
    // Send current state to Arduino

    port.write("S" + last_staemps + "#");
    port.write("F" + last_freeStaemps + "#");
  }
}

void draw() {

  if (staemps - last_staemps > 0) {
    println("new stamps: " + (staemps - last_staemps));
    // send to Arduino:
    if (arduino) {
      port.write("s" + (staemps - last_staemps) + "#");
    }

    last_staemps = staemps;
    saveCurrent();
  }

  if (freeStaemps - last_freeStaemps > 0) {
    println("new freeStamps: " + (freeStaemps - last_freeStaemps));
    // send to Arduino:
    if (arduino) {
      port.write("f" + (freeStaemps - last_freeStaemps) + "#");
    }

    last_freeStaemps = freeStaemps;
    saveCurrent();
  }


  if (frameCount % 600 == 0) {
    try {
      getStamps();
      getFreeStamps();
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
  }
}

void saveCurrent() {
  String[] s = {  Long.toString(last_staemps), Long.toString(last_freeStaemps) };
  saveStrings("data/current.txt", s);
}

void getStamps() {
  String[] lines = loadStrings("https://www.xn--stmps-hra.de/api/v1/office/stamps");
  String data = join(lines, " ");
  data = data.trim();

  int count = parseInt(data);
  //println("stamps: " + count);
  if (count > 0) {
    staemps = count;
  }
}

void getFreeStamps() {
  String[] lines = loadStrings("https://www.xn--stmps-hra.de/api/v1/office/freestamps");
  String data = join(lines, " ");
  data = data.trim();

  int count = parseInt(data);
  //println("freestamps: " + count);

  if (count > 0) {
    freeStaemps = count;
  }
}

String getArduino(String[] list) {
  String portName = "";

  printArray(Serial.list());
  for (int i = 0; i < list.length; i++) {
    if (list[i].indexOf("arduino") >= 0 || list[i].indexOf("usbmodem") >= 0) {
      portName = list[i];
    }
  }

  return portName;
}
