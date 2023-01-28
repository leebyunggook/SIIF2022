class NormalHumSkl {
  int cHeight = 180; //60 110;
                                                                                                 
  NormalHumSkl() {
  }
  
  void draw() {
    if(lhs.nFlag == false) {
      nomalize(lhs);
      lhs.nFlag = true;                                                                                      
      // displayAngles(hsf, index);
    }
    draw(lhs);
  }  
  
  void draw(HumSkl hs) {
    int j, j0, j1;
    int w = 20, h = 20;
    pushMatrix();
    translate(width-(hs.id+1)*rMargin/2, height-cHeight-2*h);
    noFill();
    strokeWeight(3);
    stroke(64);
    for(j=0; j<num-1; j++) {
      j0 = keypoint_ids[j][0];
      j1 = keypoint_ids[j][1];
      line(hs.nPt[j0].x*w, hs.nPt[j0].y*h, hs.nPt[j1].x*w, hs.nPt[j1].y*h);
    }  
    strokeWeight(1);

    stroke(128);
    rect(-w, -h, 2*w, 2*h);
    line(0, -h, 0, h);
    line(-w, 0, w, 0);
    popMatrix();
  }  

  void nomalize(HumSkl hs) {
    float cx, cy;
    int i, j, j0 = 1; // neck // back waist
    float weight, unit = scale;
    if((hs.ulength = getLength(hs)) < 0) return;
    calAngles(hs);
    cx = hs.pt[j0].x;
    cy = hs.pt[j0].y;
    weight = unit/hs.ulength;
    for(j=0; j<num; j++) {
      hs.nPt[j] = new PVector((hs.pt[j].x-cx)*weight, (hs.pt[j].y-cy)*weight);
    }
  }
  // chest center
  // unit length
  
  float getLength(HumSkl hs) {
    int i, j, j0, j1, count=0;
//    int[] k = {13, 14, 15, 19}; // {5, 14}, {14, 15}, {15, 16}, {15, 20} 
    int[] k = {1, 2, 4, 5}; // {5, 14}, {14, 15}, {15, 16}, {15, 20} 
    float l=0;
    
    for(i=0; i<4; i++) {
      j = k[i];
      j0 = keypoint_ids[j][0];
      j1 = keypoint_ids[j][1];
      if(hs.prob[j0] < threshold || hs.prob[j1] < threshold) continue;
      PVector v = PVector.sub(hs.pt[j0], hs.pt[j1]);
      l+=v.mag(); 
      count++;
    }
    if(count > 0) {
      return l/count;
    }
    else {
      hs.id = -2;
      return -1;
    }  
  }  
  
  // Calculate the joint angles for elbow, hip and knee
  float calc_angle(PVector p1, PVector p2, PVector p3) {
    PVector dp1 = PVector.sub(p1, p2);
    PVector dp2 = PVector.sub(p3, p2);
    float fp1 = p1.mag(), fp2 = p2.mag(), fp3 = p3.mag();
    if(fp1*fp2 < eps) {
      if(fp3 < eps) return -1;
      else return 0;
    }
    else { 
      return PVector.angleBetween(dp1, dp2);
      //return dp1.dot(dp2)/(fp1*fp2);
    }  
  }

  // Calculate angles for shouder
  float calc_angle_shoulder(PVector p1, PVector p2, PVector p3) {
    PVector dp1 = PVector.sub(p1, p2);
    PVector dp2 = PVector.sub(p3, p2);
    float fp1 = p1.mag(), fp2 = p2.mag(), fp3 = p3.mag();
    if(fp1*fp2*fp3 < eps) return 0;
    else 
      return PVector.angleBetween(dp1, dp2);
      //return dp1.dot(dp2)/(fp1*fp2);
  }
  
  void calAngles(HumSkl hs) {
    hs.theta[0] = calc_angle(hs.pt[0], hs.pt[1], hs.pt[2]);           //a_r_neck_shoulder
    hs.theta[1] = calc_angle_shoulder(hs.pt[1], hs.pt[2], hs.pt[3]);  //a_r_shoulder
    hs.theta[2] = calc_angle(hs.pt[2], hs.pt[3], hs.pt[4]);           //a_r_elbow
    hs.theta[3] = calc_angle_shoulder(hs.pt[0], hs.pt[1], hs.pt[5]);  //a_l_neck_shoulder
    hs.theta[4] = calc_angle_shoulder(hs.pt[1], hs.pt[5], hs.pt[6]);  //a_l_shoulder
    hs.theta[5] = calc_angle(hs.pt[5], hs.pt[6], hs.pt[7]);           //a_l_elbow
    hs.theta[6] = calc_angle(hs.pt[1], hs.pt[8], hs.pt[9]);           //a_r_hip
    hs.theta[7] = calc_angle(hs.pt[8], hs.pt[9], hs.pt[10]);          //a_r_knee
    hs.theta[8] = calc_angle(hs.pt[1], hs.pt[11], hs.pt[12]);         //a_l_hip
    hs.theta[9] = calc_angle(hs.pt[11], hs.pt[12], hs.pt[13]);        //a_l_knee
    return;
  }

  void displayAngles(HumSklFrames hsf, int index) {
    int i, j; 
    println(nf(index,4,0)+"   000102    010203    020304    000105"+
      "    010506    050607    010809    080910    011112    111213");
    for(i=0; i<hsf.humSkls.size(); i++) {
      HumSkl hs = hsf.humSkls.get(i);
      print(nf(hs.id,2,0)+" :  ");
      if(hs.id < 0) {
        println();
        continue;
      }
      for(j=0; j<10; j++) 
        print(nfs(hs.theta[j],3,4)+" ");    //acos(t) radian
      println();
      print("degree");
      for(j=0; j<10; j++) { 
        float t = degrees(hs.theta[j]);        //t radian -> PI : 180       
        print(nfs(t,3,4)+" ");            
      }  
      println();
    }
    return;
  }
}

/*
    p_neck = get(1)
    p_r_shoulder =  get(2)
    p_r_elbow =  get(3)
    p_r_wrist =  get(4)
    a_r_shoulder = calc_angle_shoulder(p_neck, p_r_shoulder, p_r_elbow)
    a_r_elbow = calc_angle(p_r_shoulder, p_r_elbow, p_r_wrist)

    p_l_shoulder =  get(5)
    p_l_elbow =  get(6)
    p_l_wrist =  get(7)
    a_l_shoulder = calc_angle_shoulder(p_neck, p_l_shoulder, p_l_elbow)
    a_l_elbow = calc_angle(p_l_shoulder, p_l_elbow, p_l_wrist)

    p_r_hip = get(8)
    p_r_knee = get(9)
    p_r_ankle = get(10)
    a_r_hip = calc_angle(p_neck, p_r_hip, p_r_knee)
    a_r_knee = calc_angle(p_r_hip, p_r_knee, p_r_ankle)

    p_l_hip = get(11)
    p_l_knee = get(12)
    p_l_ankle = get(13)
    a_l_hip = calc_angle(p_neck, p_l_hip, p_l_knee)
    a_l_knee = calc_angle(p_l_hip, p_l_knee, p_l_ankle)

    angles = [a_r_shoulder, a_r_elbow, a_l_shoulder, a_l_elbow, a_r_hip, a_r_knee, a_l_hip, a_l_knee]
    return np.array(angles)

def pose_normalization(x):
    def retrain_only_body_joints(x_input):
        x0 = x_input.copy()
        x0 = x0[2:2+13*2]
        return x0

    def normalize(x_input):
        # Separate original data into x_list and y_list
        lx = []
        ly = []
        N = len(x_input)
        i = 0
        while i<N:
            lx.append(x_input[i])
            ly.append(x_input[i+1])
            i+=2
        lx = np.array(lx)
        ly = np.array(ly)

        # Get rid of undetected data (=0)
        non_zero_x = []
        non_zero_y = []
        for i in range(int(N/2)):
            if lx[i] != 0:
                non_zero_x.append(lx[i])
            if ly[i] != 0:
                non_zero_y.append(ly[i])
        if len(non_zero_x) == 0 or len(non_zero_y) == 0:
            return np.array([0] * N)

        # Normalization x/y data according to the bounding box
        origin_x = np.min(non_zero_x)
        origin_y = np.min(non_zero_y)
        len_x = np.max(non_zero_x) - np.min(non_zero_x)
        len_y = np.max(non_zero_y) - np.min(non_zero_y)
        eps = 0.0001
        if len_x < eps:
            len_x = 1
        if len_y < eps:
            len_y = 1
        x_new = []
        for i in range(int(N/2)):
            if (lx[i] + ly[i]) == 0:
                x_new.append(-1)
                x_new.append(-1)
            else:
                x_new.append((lx[i] - origin_x) / len_x)
                x_new.append((ly[i] - origin_y) / len_y)
        return x_new

    x_body_joints_xy = retrain_only_body_joints(x)
    x_body_joints_xy = normalize(x_body_joints_xy)
    return x_body_joints_xy
*/    
