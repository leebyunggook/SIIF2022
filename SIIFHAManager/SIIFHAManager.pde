import java.io.File;
import java.util.*;
import controlP5.*;
ControlP5 cp5;

int num = 18; //18
int step = 5;
int trace = 5;
int oldK = -1;
int lMargin = 160;
int rMargin = 200;
int numKey = -1;

int count, i, id, max_id;
int index, fIndex, tIndex, eIndex, eFrames;
int oldIndex, oldeIndex, oldeFrames;
int preIndex, preeIndex, preeFrames;
int dLabel[] = {0, 0};
int oldLabel[] = {0, 0};
int preLabel[] = {0, 0};
int labelCount=2, detailLabelCount=5;
int mWidth = 640; //1920
int mHeight = 480; //1080

float eps = 0.0001;
float threshold = 0.1;
float rotX=0, rotY=radians(180), scalef=250.;

PFont f;
PImage myMovie;
PImage skeletonID;
HumSklFrames hsfs = new HumSklFrames();
NormalHumSkl nHSK = new NormalHumSkl();
MyControlP5 myCP5; 
ReadData rdHA;
HumSkl lhs;

int scale = 1;
int priorityFlag = 0;
boolean loadFlag = false;
boolean loopFlag = false;
boolean videoFlag = false;
boolean labelFlag = false;
boolean traceFlag = false;
boolean display3DFlag = false;
boolean displaySKFlag = false;
boolean labelInitFlag = true;
boolean autoPre2CurrFlag = false;
/*
  "Left Ear", "Left Eye", "Right Ear", "Right Eye", "Nose", "Neck", //5
  "Left Shoulder", "Left Elbow", "Left Wrist", "Left Palm", //9
  "Right Shoulder", "Right Elbow", "Right Wrist", "Right Palm", "Back", "Waist", //15
  "Left Hip", "Left Knee", "Left Ankle", "Left Foot", //19
  "Right Hip", "Right Knee", "Right Ankle", "Right Foot"}; //23
*/

String[] joint_label = {
  "Nose", "Neck", "Right Shoulder", "Right Elbow", "Right Wrist", "Left Shoulder", "Left Elbow", "Left Wrist", 
  "Right Hip", "Right Knee", "Right Ankle", "Left Hip", "Left Knee", "Left Ankle",
  "Right Eye", "Right Ear", "Left Eye", "Left Ear"}; //23
  
int[][] keypoint_ids = {
  {0, 1}, {1, 8}, {8, 9}, {9, 10}, {1, 11}, {11, 12}, {12, 13}, {1, 2}, {2, 3}, {3, 4}, 
  {1, 5}, {5, 6}, {6, 7}, {0, 14}, {14, 16}, {0, 15}, {15, 17}};

String filename = "null";
String rootPath = "C:\\SIIF2022\\";
String csvName = "M";
boolean csvName2DataFlag = false; // filename 에서 csv label data 수정 
boolean sortFlag = false;

void setup() {
  size(1280, 960, P3D); scale = 2; //, P3D
  //size(1920, 1080); scale = 1;
  //size(2560, 1440); scale = 2;

  smooth();
  skeletonID = loadImage("human_pose.png"); //560x680 480x700 skeleton human_pose_f
  f = createFont("Georgia", 20);
  strokeWeight(2);
  textFont(f);
  fill(0);

  id = 0;
  max_id = 1;
  index = fIndex = tIndex = eIndex = 0;
  cp5 = new ControlP5(this);  
  rdHA = new ReadData(rootPath+"process\\", csvName2DataFlag);
  count = hsfs.count/max_id;
  myCP5 = new MyControlP5(count); 
  setCurrentFrame();  
  videoFlag = false;
  noFill();
}

void draw() {
  background(112);
  if(display3DFlag) {
    pushMatrix();
    translate(width/2, height/2);
    rotateX(rotX);
    rotateY(rotY);
    scale(scalef, scalef, scalef);
    drawAxis3D(1);
    nHSK.draw(); 
    drawSkeleton3D(0.1);
    drawJoint3D(0.1);
    popMatrix();
  }
  else {
    drawBackground();
    drawJoint(3*scale);
    nHSK.draw(); 
    drawSkeleton();
    drawTrace();
    drawTurbo();  
  }
  drawMsg();
  drawPoseImage();
  if(loopFlag && ((frameCount%step==0) || step==1)) 
    nextStep(1);
}

void drawAxis3D(int l) {
  stroke(32);
  strokeWeight(0.01);
  noFill();
  box(2*l);
  stroke(255, 0, 0);
  line(-l, 0, 0, l, 0, 0);
  stroke(0, 255, 0);
  line(0, -l, 0, 0, l, 0);
  stroke(0, 0, 255);
  line(0, 0, -l, 0, 0, l);
  strokeWeight(1);
}

void drawSkeleton3D(float zScale) {
  int j, j0, j1;
  stroke(0, 255, 0);
  strokeWeight(0.01);
  for(j=0; j<num-1; j++) { //num-1 -5
    j0 = keypoint_ids[j][0];
    j1 = keypoint_ids[j][1];
    line(lhs.pt[j0].x, lhs.pt[j0].y, lhs.pt[j0].z*zScale, 
      lhs.pt[j1].x, lhs.pt[j1].y, lhs.pt[j1].z*zScale);
  }  
  strokeWeight(1);
}

void drawJoint3D(float zScale) {
  float x, y, z;
  pushMatrix();
  stroke(64, 0, 64);
  for(int j=0; j<num; j++) {    
    x = lhs.pt[j].x;
    y = lhs.pt[j].y;
    z = lhs.pt[j].z*zScale;
    pushMatrix();
    translate(x, y, z);
    scale(0.0075);
    sphere(1);
    popMatrix();
  }  
  popMatrix();
}

void nextStep(int delta) {
  keepPreLabel(delta);
  tIndex+=delta;
  if(tIndex>=count) tIndex=0;
  if(tIndex<0) tIndex=count-1;
  setCurrentFrame();  
  
  if(autoPre2CurrFlag && delta==1) {
    keepOldLabel();
    copyPre2CurrLabel();
    setCPLabel();
  }
}

void copyPre2CurrLabel() {
  for(int i=0; i<labelCount; i++) 
    dLabel[i] = preLabel[i];
  saveFrameLabel();  
}

void keepPreLabel(int j) {
  if(j == 1) {
    preIndex = index;
    preeIndex = eIndex;
    preeFrames = eFrames;
    for(int i=0; i<labelCount; i++) 
      preLabel[i] = dLabel[i];
  }
  else {
    preIndex = preeIndex = preeFrames = 0;
    for(int i=0; i<labelCount; i++) 
      preLabel[i] = 0;
  }
}

void keepOldLabel() {
  preIndex = index;
  preeIndex = eIndex;
  preeFrames = eFrames;
  for(int i=0; i<labelCount; i++) 
    oldLabel[i] = dLabel[i];
}

void restoreOldLabel() {
  for(int i=0; i<labelCount; i++) 
    dLabel[i] = oldLabel[i];
  saveFrameLabel();  
}

void drawBackground() {
  int tm = 19;
  if(videoFlag) {
    image(myMovie, 0, 0, width, height);
    stroke(198);
    fill(198, 128+96);
    rect(0, 0, lMargin, height);            
    fill(198, 128+96);
    rect(width-(rMargin), 0, width, height);
    fill(232, 128+96);
    rect(0, 0, width, 2.65*tm);
  }  
  else {
    stroke(32);
    line(width-(rMargin), 0, width-(rMargin), height);
    line(lMargin, 2.65*tm, lMargin, height);
  }
  stroke(128);
  int margin = 100;
  line(width/2-2*margin, 2*margin, width/2-2*margin, height-2*margin);
  line(width/2, margin, width/2, height-margin);
  line(width/2+2*margin, 2*margin, width/2+2*margin, height-2*margin);
  if(videoFlag) myCP5.sliderMenuBg();
}

void setCurrentFrame() {
  lhs = hsfs.humSkls.get(tIndex*max_id+id);
  if(videoFlag) {
    filename = rootPath+lhs.dir+"\\color\\"+lhs.image;
    myMovie = loadImage(filename);
  }
  i = lhs.i;
  index = lhs.index;
  fIndex = lhs.fIndex;
  eIndex = lhs.eIndex;
  eFrames = lhs.eFrames;
  for(int j=0; j<labelCount; j++) 
    dLabel[j] = lhs.dLabel[j];
  setCPLabel();
}  

void setCPLabel() {
  boolean debug = false; //false true
  if(numKey == -1) {
    if(debug) println("fIndex : "+fIndex);
    for(int j=0; j<labelCount; j++) {
      if(debug) print("activate(dLabel[j]) "+j+" ");
      myCP5.rbs[j].activate(dLabel[j]);  
    } 
  }  
  else { 
    int j = numKey/10;
    int k = numKey%10;
    println("change "+j+" "+dLabel[j]+" --> "+j+" "+k); 
    myCP5.rbs[j].activate(k);  
    numKey = -1;
  }
}  

public void controlEvent(ControlEvent theEvent) {
  int i, j;
  if (theEvent.isFrom("JSON")) {
    tIndex = int(theEvent.getValue());
    if(tIndex<0) tIndex=0;
    if(tIndex>count) tIndex=count-1;
    if(tIndex>0) {
      keepPreLabel(-1);
      setCurrentFrame();  
    }
  }
  else if(theEvent.isGroup()) {
    j = (int)(theEvent.getGroup().getName().charAt(0)-'0');
    i = (int)theEvent.getGroup().getValue();
    String tmp = theEvent.getGroup().getName()+" "+j+" "+i;
    if(dLabel[j]!=i) { 
      tmp+=" ("+dLabel[0]+","+dLabel[1]+") --> ";
      dLabel[j]=i;
      saveFrameLabel();
      tmp+="("+dLabel[0]+","+dLabel[1]+") ...";
      println(tmp);
    }
  } 
}

void saveFrameLabel() {
  HumSkl hs;
  for(int d=0; d<max_id; d++) {
    hs = hsfs.humSkls.get(tIndex*max_id+d);
    hs.eIndex = eIndex;
    for(int j=0; j<labelCount; j++)
      hs.dLabel[j] = dLabel[j];
  }  
}  

void drawSkeleton() {
  int j, j0, j1;
  stroke(0, 255, 0);
  strokeWeight(2);
  for(j=0; j<num-1; j++) { //num-1 -5
    j0 = keypoint_ids[j][0];
    j1 = keypoint_ids[j][1];
    line(lhs.pt[j0].x*width, lhs.pt[j0].y*height, 
      lhs.pt[j1].x*width, lhs.pt[j1].y*height);
  }  
  strokeWeight(1);
}

void drawJoint(int w) {
  int x, y;
  for(int j=0; j<num; j++) {    
    x = int(lhs.pt[j].x*width);
    y = int(lhs.pt[j].y*height);
    fill(0, 255, 255);
    noStroke();
    ellipse(x, y, w, w);
    noFill();
    stroke(255, 0, 0);
    ellipse(x, y, 2*w, 2*w);
    if(labelFlag) {
      fill(0);
      text(j+" "+joint_label[j], x+w, y-w);
    }  
  }  
}

void drawTrace() {
  int j, k, t, x, y, x0, y0, x1, y1, w = 2*scale;
  if(traceFlag == false) return;
  t = trace;
  if(tIndex < trace) 
    t = tIndex;  
  fill(255, 64, 64);
  stroke(32, 64, 32);
  for(j=0; j<num; j++) {    
    HumSkl ohs = hsfs.humSkls.get(tIndex);
    x0 = int(ohs.pt[j].x*width);
    y0 = int(ohs.pt[j].y*height);
    for(k=1; k<t; k++) {
      HumSkl hs = hsfs.humSkls.get(tIndex-k);
      x1 = int(hs.pt[j].x*width);
      y1 = int(hs.pt[j].y*height);
      ellipse(x1, y1, w, w);
      line(x0, y0, x1, y1); 
      x0 = x1;
      y0 = y1;
    }
  }  
}

void drawTurbo() {
  int i, x0=40, x1=x0+40, y1=height-312-40, y0=y1-256;
  strokeWeight(1);
  for(i=0; i<256; i++) {
    stroke(turbo[i]);
    line(x0, y0+i, x1, y0+i);
  }  
  fill(0);
  for(i=0; i<=100; i+=25) {
    String msg = nf(i/100.,1,2);
    text(msg, x1+6, y1-i*2.56+5);
  }  
}

void drawPoseImage() {
  if(skeletonID != null)
    image(skeletonID, scale, height-286-2, 156, 286); // //320x620 480x637
}

void drawMsg() {
  int x = 10, m = 22, y = m-2;
  String msg;
  fill(0);
  text("copyPre2CurLabel(q) keepLabel(a) restoreLabel(w) autoPre2CurrFlag(z):"+autoPre2CurrFlag+ 
    " loopFlag(space):"+loopFlag+" labelFlag(b):"+labelFlag, x, y); y+=m;  
  text("save csv file(s) sortFlag(e):"+sortFlag+" traceFlag(c):"+traceFlag+
    " trace(t/y) - "+trace+" speed(q/w) - "+step+"/20"+" tIndex(left/right) - "+
    tIndex+"/"+count+" videoFlag(v):"+videoFlag, x, y); y+=m;
/*
  msg = getPreIndexMsg(); 
  text(msg, lMargin+4, height-12-4*m); 
  msg = getIndexMsg(); 
  text(msg, lMargin+4, height-12-3*m); 
  msg = getOldIndexMsg(); 
  text(msg, lMargin+4, height-12-2*m); 
*/
  msg = getLabelMsg();
  text(msg, lMargin+4, height-12-m); 
  text(lhs.image, lMargin+4, height-12); //filename 
}

String getPreIndexMsg() { 
  String msg = "Prev ["+preIndex+", "+preeIndex+", "+preeFrames+"] - ("+preLabel[0]+","+preLabel[1]+")";  
  return msg;
}

String getOldIndexMsg() { 
  String msg = "Keep ["+oldIndex+", "+oldeIndex+", "+oldeFrames+"] - ("+oldLabel[0]+", "+oldLabel[1]+")";  
  return msg;
}

String getIndexMsg() { 
  String msg = "Curr ["+index+", "+eIndex+", "+eFrames+"] - ("+dLabel[0]+", "+dLabel[1]+")";  
  return msg;
}

String getLabelMsg() { 
  String msg = "Exer ["+i+", "+index+", "+eIndex+", "+eFrames+"] - ("+dLabel[0]+", "+dLabel[1]+")";
  return msg;
}

void mousePressed() {
  int margin = 200;
  if(!display3DFlag && mouseButton == LEFT) {
    if(mouseX>width/2-margin && mouseX<width/2) nextStep(-1);
    if(mouseX>width/2 && mouseX<width/2+margin) nextStep(1);
  }
}

void mouseDragged() {
  rotY += (mouseX-pmouseX)/100.;
  rotX += (pmouseY-mouseY)/100.;  
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      nextStep(-1);
    } 
    else if (keyCode == RIGHT) {
      nextStep(1);
    } 
  } 
  else if (key >= '0' && key <= '9') {
    if(numKey == -1) {
      numKey = (key - '0');
    }
    else if(numKey >= 0 && numKey <= 9) {
      numKey = numKey*10+(key - '0');
      setCPLabel();
    }
  } 
  else if (key == ' ') {
    loopFlag = !loopFlag;
  } 
  else if (key == 'o' || key == 'O') {
    selectInput("open csv file :", "fileSelected");
  }
  else if (key == 'b' || key == 'B') {
    labelFlag = !labelFlag;
  } 
  else if (key == 'c' || key == 'C') {
    traceFlag = !traceFlag;
  } 
  else if (key == 'v' || key == 'V') {
    videoFlag = !videoFlag;
  } 
  else if (key == 'e' || key == 'E') {
    sortFlag = !sortFlag;
    rdHA = new ReadData(rootPath+"process\\", csvName2DataFlag);
  } 
  else if (key == 'r' || key == 'R') {
  } 
  else if (key == 't' || key == 'T') {
    if(trace > 1) trace--;
  } 
  else if (key == 'y' || key == 'Y') {
    if(trace < 20) trace++;
  } 
  else if (key == 'd' || key == 'D') {
    display3DFlag = !display3DFlag;
  } 
  else if (key == 'f' || key == 'F') {
  } 
  else if (key == 'g' || key == 'g') {
    if(step > 0) step--;
  } 
  else if (key == 'h' || key == 'h') {
    if(step < 20) step++;
  } 
  else if (key == 'p' || key == 'P') {
    priorityFlag = 1-priorityFlag;
    myCP5.prb.activate(priorityFlag);
  } 
  else if (key == 's' || key == 'S') {
    rdHA.saveCSVData(csvName);
    loopFlag = false;
  } 
  else if (key == 'n' || key == 'N') {
    autoPre2CurrFlag = !autoPre2CurrFlag;
  } 
  else if (key == 'a' || key == 'A') {
    keepOldLabel();
  } 
  else if (key == 'q' || key == 'Q') {
    keepOldLabel();
    copyPre2CurrLabel();
    setCPLabel();
  } 
  else if (key == 'w' || key == 'W') {
    restoreOldLabel();
    setCPLabel();
  } 
  else if(key == 'z' || key == 'Z') {
    scalef *= 1.1;    
  }
  else if(key == 'x' || key == 'X') {
    scalef *= 0.9;    
  }
}

void checkSkeleton() {
/*  
  for(int i=0; i<count; i++) {
    HumSklFrames hsf = hsfs.get(i);
    HumSkl hs = hsf.humSkls.get(0);
    validData(hs, 14, 16);
    validData(hs, 16, 14);
    validData(hs, 15, 17);
    validData(hs, 17, 15);
    validData(hs, 4, 2);
    validData(hs, 3, 2);
    validData(hs, 7, 5);
    validData(hs, 6, 5);
    validData(hs, 10, 8);
    validData(hs, 9, 8);
    validData(hs, 13, 11);
    validData(hs, 12, 11);
  }
*/  
}

void validData(HumSkl hs, int j, int k) {
  if(hs.pt[j].x < eps || hs.pt[j].y < eps) {
    hs.pt[j].x = hs.pt[k].x;
    hs.pt[j].y = hs.pt[k].y;
  }  
}

int lmap(float x) {
  int i = (int) map(x, 1, 0, 0, 255);
  if(i < 0) i=0;
  if(i > 255) i=255;
  return i;
}

color[] turbo = {
  color(48,18,59),color(50,21,67),color(51,24,74),color(52,27,81),color(53,30,88),color(54,33,95),color(55,36,102),color(56,39,109),
  color(57,42,115),color(58,45,121),color(59,47,128),color(60,50,134),color(61,53,139),color(62,56,145),color(63,59,151),color(63,62,156),
  color(64,64,162),color(65,67,167),color(65,70,172),color(66,73,177),color(66,75,181),color(67,78,186),color(68,81,191),color(68,84,195),
  color(68,86,199),color(69,89,203),color(69,92,207),color(69,94,211),color(70,97,214),color(70,100,218),color(70,102,221),color(70,105,224),
  color(70,107,227),color(71,110,230),color(71,113,233),color(71,115,235),color(71,118,238),color(71,120,240),color(71,123,242),color(70,125,244),
  color(70,128,246),color(70,130,248),color(70,133,250),color(70,135,251),color(69,138,252),color(69,140,253),color(68,143,254),color(67,145,254),
  color(66,148,255),color(65,150,255),color(64,153,255),color(62,155,254),color(61,158,254),color(59,160,253),color(58,163,252),color(56,165,251),
  color(55,168,250),color(53,171,248),color(51,173,247),color(49,175,245),color(47,178,244),color(46,180,242),color(44,183,240),color(42,185,238),
  color(40,188,235),color(39,190,233),color(37,192,231),color(35,195,228),color(34,197,226),color(32,199,223),color(31,201,221),color(30,203,218),
  color(28,205,216),color(27,208,213),color(26,210,210),color(26,212,208),color(25,213,205),color(24,215,202),color(24,217,200),color(24,219,197),
  color(24,221,194),color(24,222,192),color(24,224,189),color(25,226,187),color(25,227,185),color(26,228,182),color(28,230,180),color(29,231,178),
  color(31,233,175),color(32,234,172),color(34,235,170),color(37,236,167),color(39,238,164),color(42,239,161),color(44,240,158),color(47,241,155),
  color(50,242,152),color(53,243,148),color(56,244,145),color(60,245,142),color(63,246,138),color(67,247,135),color(70,248,132),color(74,248,128),
  color(78,249,125),color(82,250,122),color(85,250,118),color(89,251,115),color(93,252,111),color(97,252,108),color(101,253,105),color(105,253,102),
  color(109,254,98),color(113,254,95),color(117,254,92),color(121,254,89),color(125,255,86),color(128,255,83),color(132,255,81),color(136,255,78),
  color(139,255,75),color(143,255,73),color(146,255,71),color(150,254,68),color(153,254,66),color(156,254,64),color(159,253,63),color(161,253,61),
  color(164,252,60),color(167,252,58),color(169,251,57),color(172,251,56),color(175,250,55),color(177,249,54),color(180,248,54),color(183,247,53),
  color(185,246,53),color(188,245,52),color(190,244,52),color(193,243,52),color(195,241,52),color(198,240,52),color(200,239,52),color(203,237,52),
  color(205,236,52),color(208,234,52),color(210,233,53),color(212,231,53),color(215,229,53),color(217,228,54),color(219,226,54),color(221,224,55),
  color(223,223,55),color(225,221,55),color(227,219,56),color(229,217,56),color(231,215,57),color(233,213,57),color(235,211,57),color(236,209,58),
  color(238,207,58),color(239,205,58),color(241,203,58),color(242,201,58),color(244,199,58),color(245,197,58),color(246,195,58),color(247,193,58),
  color(248,190,57),color(249,188,57),color(250,186,57),color(251,184,56),color(251,182,55),color(252,179,54),color(252,177,54),color(253,174,53),
  color(253,172,52),color(254,169,51),color(254,167,50),color(254,164,49),color(254,161,48),color(254,158,47),color(254,155,45),color(254,153,44),
  color(254,150,43),color(254,147,42),color(254,144,41),color(253,141,39),color(253,138,38),color(252,135,37),color(252,132,35),color(251,129,34),
  color(251,126,33),color(250,123,31),color(249,120,30),color(249,117,29),color(248,114,28),color(247,111,26),color(246,108,25),color(245,105,24),
  color(244,102,23),color(243,99,21),color(242,96,20),color(241,93,19),color(240,91,18),color(239,88,17),color(237,85,16),color(236,83,15),
  color(235,80,14),color(234,78,13),color(232,75,12),color(231,73,12),color(229,71,11),color(228,69,10),color(226,67,10),color(225,65,9),
  color(223,63,8),color(221,61,8),color(220,59,7),color(218,57,7),color(216,55,6),color(214,53,6),color(212,51,5),color(210,49,5),
  color(208,47,5),color(206,45,4),color(204,43,4),color(202,42,4),color(200,40,3),color(197,38,3),color(195,37,3),color(193,35,2),
  color(190,33,2),color(188,32,2),color(185,30,2),color(183,29,2),color(180,27,1),color(178,26,1),color(175,24,1),color(172,23,1),
  color(169,22,1),color(167,20,1),color(164,19,1),color(161,18,1),color(158,16,1),color(155,15,1),color(152,14,1),color(149,13,1),
  color(146,11,1),color(142,10,1),color(139,9,2),color(136,8,2),color(133,7,2),color(129,6,2),color(126,5,2),color(122,4,3)};

/*
String[] joint_label = {"nose", "chest", 
  "right shoulder", "right elbow", "right wrist",
  "left shoulder", "left elbow", "left wrist",
  "right hip", "right knee", "right ankle",
  "left hip", "left knee", "left ankle",
  "right eye", "left eye", "right ear", "left ear"};
  
int[][] keypoint_ids = {
  {1, 2}, {1, 5}, {2, 3}, {3, 4}, {5, 6}, {6, 7}, {1, 8}, {8, 9}, {9, 10}, 
  {1, 11}, {11, 12}, {12, 13}, {1, 0}, {0, 14}, {14, 16}, {0, 15}, {15, 17}};


void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
    println("User selected " + selection.getAbsolutePath());
    String[] list = split(selection.getAbsolutePath(), '\\');
    csvName = split(list[list.length-1], '.')[0];
    rdHA.loadCSVData(0, csvName, csvName);
    count = hsfs.count/max_id;
    myCP5 = new MyControlP5(count); 
    setCurrentFrame();  
    videoFlag = true;
  }
}
*/
