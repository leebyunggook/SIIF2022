class MyControlP5 {  
  Group menu, priority;
  RadioButton prb;
  Group[] gps = new Group[labelCount];
  RadioButton[] rbs = new RadioButton[labelCount];
  int leftPos=rMargin-10, cWidth=rMargin-21;
  int yMargin=8, upPos=8, bHeight=18, oldK=-1;  

  String detailLabel[][] = {
    {"type", "bench_press", "shoulder_press", "deadlift", "squat", "unknown"},
    {"pose", "normal", "left", "right", "drop", "unknown"}
  };

  MyControlP5(int count) {
    cp5.setFont(createFont("Arial Bold", 12));
    setSliderMenu(count);
    setLabel();
    //hideLabel();
  }     

  void setSliderMenu(int count) {
    int pos = height-40;
    cp5.addSlider("JSON").setPosition(width-leftPos, pos)
      .setSize(cWidth-40, 15).setRange(0, count).setValue(0)
      .setNumberOfTickMarks(11).setSliderMode(Slider.FLEXIBLE);
  }
  
  void sliderMenuBg() {
    int pos = height-40;
    fill(32, 128);
    rect(width-leftPos-2, pos-2, cWidth+1, 32);
  }
  
  void setLabel() { 
    int count, i, j, pos;//98+110+ +58+yMargin
    RadioButton lrbt;
    for(j=0; j<labelCount; j++) {
      pos = upPos+70+140*j;
      i=0;
      count = detailLabel[j].length;
      gps[j] = cp5.addGroup("myGroup_"+j+"_"+i+"_").setPosition(width-leftPos, pos)
        .setWidth(cWidth).activateEvent(false).setBackgroundColor(color(16,128)).setBarHeight(bHeight) 
        .setBackgroundHeight((bHeight+1)*(count)).setLabel(detailLabel[j][i]);

      lrbt = cp5.addRadioButton(j+""+detailLabel[j][i])
        .setPosition(6,9).setSize(bHeight, bHeight);
        
      for(i=1; i<count; i++) 
        lrbt = lrbt.addItem(j+""+(i-1)+" "+detailLabel[j][i], i-1);
      lrbt.setGroup(gps[j]);
      rbs[j] = lrbt;
      // rbs[j].activate(0);
      pos += (bHeight+1)*(count+1)+yMargin;
    }  
  }     

  void hideLabel() {
    for(int j=0; j<labelCount; j++) {
      gps[j].hide(); 
      rbs[j].hide();
    }  
  }  
  
  void showLabel() {
    for(int j=0; j<labelCount; j++) {
      gps[j].show(); 
      rbs[j].show();
    }  
  }  
}

/*
    pos += bHeight*(count+3)+yMargin;
    count = 5;
    myGp2 = cp5.addGroup("myGroup2").setPosition(width-leftPos, pos)
      .setWidth(cWidth).activateEvent(true).setBackgroundColor(color(16,128))
      .setBackgroundHeight(bHeight*(count+2)).setLabel("Eye...");
    cp5.addRadioButton("Eye").setPosition(10,10).setSize(bHeight,bHeight)
      .addItem("look ahead", 0)
      .addItem("look up", 1)
      .addItem("look down", 2)
      .addItem("look left", 3)
      .addItem("look right", 4)
      .setGroup(myGp2);
      
    pos += bHeight*(count+3)+yMargin;
    count = 2;
    myGp3 = cp5.addGroup("myGroup3").setPosition(width-leftPos, pos)
      .setWidth((rMargin-20)*scale).activateEvent(true).setBackgroundColor(color(16,128))
      .setBackgroundHeight(bHeight*(count+2)).setLabel("Knee and Elbow distance...");
    cp5.addRadioButton("Knee and Elbow distance").setPosition(10,10).setSize(bHeight,bHeight)
      .addItem("close", 0)
      .addItem("not close", 1)
      .setGroup(myGp3);
  
    pos += bHeight*(count+3)+yMargin;
    count = 3;
    myGp4 = cp5.addGroup("myGroup4").setPosition(width-leftPos, pos)
      .setWidth(cWidth).activateEvent(true).setBackgroundColor(color(16,128))
      .setBackgroundHeight(bHeight*(count+2)).setLabel("Direction of the knee...");
    cp5.addRadioButton("Direction of the knee").setPosition(10,10).setSize(bHeight,bHeight)
      .addItem("in front", 0)
      .addItem("from the side", 1)
      .addItem("slightly in front", 2)
      .setGroup(myGp4);
  
    pos += bHeight*(count+3)+yMargin;
    count = 3;
    myGp5 = cp5.addGroup("myGroup5").setPosition(width-leftPos, pos)
      .setWidth(cWidth).activateEvent(true).setBackgroundColor(color(16,128))
      .setBackgroundHeight(bHeight*(count+2)).setLabel("Hand position...");
    cp5.addRadioButton("Hand position").setPosition(10,10).setSize(bHeight,bHeight)
      .addItem("behind the head", 0)
      .addItem("both hands down - attention", 1)
      .addItem("on the ears", 2)
      .setGroup(myGp5);

  
  myGroup = cp5.addGroup("myGroup").setPosition(width-160, 60)
    .setWidth((rMargin-20)*scale).activateEvent(true).setBackgroundColor(color(16,128))
    .setBackgroundHeight(cHeight).setLabel("controlP5...");
  cp5.addSlider("s1").setPosition(10,80).setSize(sWidth*scale,12).setGroup(myGroup);
  cp5.addSlider("s2").setPosition(10,94).setSize(sWidth*scale,12).setGroup(myGroup);
  cp5.addRadioButton("radio").setPosition(10,10).setSize(12,12)
    .addItem("black",0)
    .addItem("red",1)
    .addItem("green",2)
    .addItem("blue",3)
    .addItem("grey",4)
    .setGroup(myGroup);
*/
