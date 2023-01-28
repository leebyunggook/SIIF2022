
class HumSklFrames {
  int index, count;  
  ArrayList<HumSkl> humSkls = new ArrayList<HumSkl>();
}

class HumSkl {
  int i, id, index;
  int fIndex, eIndex, eFrames;
  long tIndex;
  int [] dLabel = new int[5];
  boolean nFlag = false;
  String type, dir, image;
  float ulength;
  float[] prob = new float[num];
  PVector[] pt = new PVector[num];      // integer coordinate (x, y) & probability  
  PVector[] nPt = new PVector[num];     // normalized float coordinate 
  PVector[] dPt = new PVector[num];     // normalized float coordinate 
  float[] theta = new float[num];
}
