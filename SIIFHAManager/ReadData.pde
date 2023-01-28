import java.util.Collections;  // added
import java.util.Comparator;   // added 

class ReadData {
  int i, rows;
  int labelIndex = 4;
  int imageIndex = 6;
  int poseIndex = 7;
  //JSONArray values;
  JSONArraySortable values;
  
  ReadData(String dirName, boolean flag) {
    i = count = 0;
    hsfs.humSkls.clear();
    File dir = new File(dirName);
    File [] files = dir.listFiles();
/*    
    for (int k=0; k<files.length; k++) {
      String path = files[k].getAbsolutePath();
      String[] list = split(path, '\\');
      String csvName = list[list.length-1];
      String fileName = path+"\\csv\\"+csvName+".csv";
      if(flag) parsingCVSName(csvName);
      loadCSVData(k, fileName, csvName, flag);
    }
*/
    for (int k=0; k<files.length; k++) {
      String path = files[k].getAbsolutePath();
      String[] list = split(path, '\\');
      String filename = list[list.length-1];
      String csvName = split(filename, '.')[0];
      if(flag) parsingCVSName(csvName);
      loadCSVData(k, path, csvName, flag);
    }
  }
  
  void loadCSVData(int k, String filename, String csvName, boolean flag) {
    Table table = loadTable(filename);
    int j, l, oldeIndex=-1, eFrames=0;
    boolean firstLine = true;
    float x, y, z;
    HumSkl hs;
    if(table == null) {
      println("loading error - " + filename);
      return;
    }
    // table to JSONarray
    // sorting by (5,0)
    // JSONarray to table
    sorting(table);
    for(l=0; l<rows; l++) {
      JSONObject row = values.getJSONObject(l); 
      hs = new HumSkl();
      hs.i = i++;
      hs.id = 0;
      hs.index = row.getInt(str(0));                // 
      hs.tIndex = row.getLong(str(1));              // time_number
      hs.fIndex = row.getInt(str(2));               // frame_number 
      hs.eIndex = row.getInt(str(3));               // tag_index 운동 횟수
      if(oldeIndex != hs.eIndex) {
        hs.eFrames = eFrames = 0;
        oldeIndex = hs.eIndex;
      }
      else {
        eFrames++;
        hs.eFrames = eFrames;
      }
      hs.dir = csvName;
      hs.image = row.getString(str(imageIndex));
      if(flag) {
        for(j=0; j<labelCount; j++)
          hs.dLabel[j] = dLabel[j];
      }
      else {
        for(j=0; j<labelCount; j++)
          hs.dLabel[j] = row.getInt(str(labelIndex+j));
      }
      for(j=0; j<num; j++) {
        x = row.getFloat(str(poseIndex+j*4)); 
        y = row.getFloat(str(poseIndex+j*4+1));
        z = row.getFloat(str(poseIndex+j*4+2));
        hs.pt[j] = new PVector(x, y, z);
        hs.dPt[j] = new PVector(x*mWidth, y*mHeight, z);
        hs.prob[j] = row.getFloat(str(poseIndex+j*4+1));
      }  
      hsfs.humSkls.add(hs);
    }
    count=hsfs.count=hsfs.humSkls.size();
    if(csvName.length()<21) 
      println(nf(k, 3, 0)+" "+csvName+" \t\t"+hsfs.count+" ... ");
    else 
      println(nf(k, 3, 0)+" "+csvName+" \t"+hsfs.count+" ... ");
  }
  
  void sorting(Table table) {
    int j, k;
    boolean firstLine = true;
    // values = new JSONArray();
    values = new JSONArraySortable();  // change to extended class

    rows = 0;
    for(TableRow row : table.rows()) {
      if(firstLine) { // skip head line
        firstLine=false;
        continue;
      }
      JSONObject exp = new JSONObject();    
      exp.setInt("0", row.getInt(0));
      exp.setLong("1", row.getLong(1));
      for(j=2; j<6; j++) 
        exp.setInt(str(j), row.getInt(j));
      exp.setString("6", row.getString(imageIndex));
      for(j=0; j<num; j++) {
        for(k=0; k<4; k++)
          exp.setFloat(str(poseIndex+j*4+k), row.getFloat(poseIndex+j*4+k));
      }  
      values.setJSONObject(rows++, exp);
    }  
    if(sortFlag) values.sort();
  }

  /*
  0 : place
  1 : actor 
  2 : yyyymmdd
  3 : action type
  4 : dLabel 0 normal N1 left AB12 right AB23 extra AB34 
  5 : camera type
  6 : 
  7 : index 
  */
  
  void parsingCVSName(String csvName) {
    String[] list = split(csvName, '_');
    // list[0] place + person id
    // list[1] exercise type 4 squart, sholuder press, dead lift, bench press
    // list[2] detail label 4 normal, ab1, ab2, ab3
    // list[3] camera type 
    // list[4] exercise count
    int k = 1, j = 0;
    if(list[k].equals("Benchpress")) dLabel[j] = 0;
    else if(list[i].equals("Shoulder")) dLabel[j] = 1;
    else if(list[i].equals("Deadlift")) dLabel[j] = 2;
    else if(list[i].equals("Squart")) dLabel[j] = 3;
    else dLabel[j] = 4;

    k = 2;
    j = 1;
    if(list[k].equals("N")) dLabel[j] = 0;
    else if(list[i].equals("AB1")) dLabel[j] = 1;
    else if(list[i].equals("AB2")) dLabel[j] = 2;
    else if(list[i].equals("AB3")) dLabel[j] = 3;
    else dLabel[j] = 4;    
  }
  
  void saveCSVData(String filename) {  
    Calendar now = Calendar.getInstance();
    String stime = String.format("%1$ty%1$tm%1$td_%1$tH%1$tM", now);
    String savefilename = rootPath+"\\"+filename+stime+".csv";
    Table table = new Table();
    int k=-1, j, poseIndex = 6;
    for(j=0; j<num*2+6; j++) //18*2+6=36+6=42
      table.addColumn(str(j));

    HumSkl hs;
    //table.clearRows();
    for(k=0; k<count; k++) {
      hs = hsfs.humSkls.get(k);
      TableRow newRow = table.addRow();
      newRow.setInt(0, hs.i);
      newRow.setInt(1, hs.index);
      newRow.setInt(2, hs.eIndex);
      newRow.setInt(3, hs.eFrames);
      for(j=0; j<labelCount; j++)
        newRow.setInt(labelIndex+j, hs.dLabel[j]); // labelIndex
      for(j=0; j<num; j++) {
        newRow.setFloat(poseIndex+j*2, hs.pt[j].x);
        newRow.setFloat(poseIndex+j*2+1, hs.pt[j].y);
      }  
    }
    saveTable(table, savefilename);    
    println(savefilename+" ... save done!!");
  }
}

class JSONArraySortable extends JSONArray {
  // pairwise comparison logic for sort is in the Comparator
  class JSONComparator implements Comparator<JSONObject> {
    @Override
      public int compare (JSONObject a, JSONObject b) {
      return -((b.getInt("5")-a.getInt("5"))*1000+(b.getInt("0")-a.getInt("0")));
    }
  }
  
  // utility -- sort will need to get all objects from private ArrayList
  ArrayList<JSONObject> getAll() {
    ArrayList<JSONObject> myobjs = new ArrayList<JSONObject>();
    for (int i=0; i<this.size(); i++) {
      myobjs.add((JSONObject)this.get(i));
    }
    return myobjs;
  }
  
  // utility -- sort will need to clear all objects from private ArrayList
  public void clear() {
    for (int i=this.size()-1; i>=0; i--) {
      this.remove(i);
    }
  }
  
  // sort by getting all objects, sorting with comparator, clearing, and appending
  public void sort() {
    ArrayList<JSONObject> myobjs = this.getAll();
    Collections.sort(myobjs, new JSONComparator());
    this.clear();
    for (int i=0; i<myobjs.size(); i++) {
      this.append(myobjs.get(i));
    }
  }
}

/*  
  for(TableRow row : table.rows()) {
    if(firstLine) { // skip head line
      firstLine=false;
      continue;
    }
    hs = new HumSkl();
    hs.i = i++;
    hs.id = 0;
    hs.index = row.getInt(0);                // 
    hs.tIndex = row.getLong(1);              // time_number
    hs.fIndex = row.getInt(2);               // frame_number 
    hs.eIndex = row.getInt(3);               // tag_index 운동 횟수
    if(oldeIndex != hs.eIndex) {
      hs.eFrames = eFrames = 0;
      oldeIndex = hs.eIndex;
    }
    else {
      eFrames++;
      hs.eFrames = eFrames;
    }
    hs.dir = csvName;
    hs.image = row.getString(imageIndex);
    if(flag) {
      for(j=0; j<labelCount; j++)
        hs.dLabel[j] = dLabel[j];
    }
    else {
      for(j=0; j<labelCount; j++)
        hs.dLabel[j] = row.getInt(labelIndex+j);
    }
    for(j=0; j<num; j++) {
      x = row.getFloat(poseIndex+j*4); 
      y = row.getFloat(poseIndex+j*4+1);
      z = row.getFloat(poseIndex+j*4+2);
      hs.pt[j] = new PVector(x, y, z);
      hs.dPt[j] = new PVector(x*mWidth, y*mHeight, z);
      hs.prob[j] = row.getFloat(poseIndex+j*4+1);
    }  
    hsfs.humSkls.add(hs);
  }

  
  table = new Table();
  
  table.addColumn("id");
  table.addColumn("species");
  table.addColumn("name");
  
  TableRow newRow = table.addRow();
  newRow.setInt("id", table.lastRowIndex());
  newRow.setString("species", "Panthera leo");
  newRow.setString("name", "Lion");
  
  void saveCSVData() {
    int i=-1;
    HumSkl hs;
    for (TableRow row : table.rows()) {
      if(i==-1) {
        i++;
        continue;
      }
      hs = hsfs.humSkls.get(i);
      row.setInt(5, hs.label);
      for(int d=0; d<5; d++)
        row.setInt(6+d, hs.dLabel[d]);
      i++;  
    }
  }

*/
