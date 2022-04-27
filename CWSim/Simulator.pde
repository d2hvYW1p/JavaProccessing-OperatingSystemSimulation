class Simulator {
  static final color lightgreen = #28F741;
  static final color green = #28AD1F;
  static final color darkgreen = #075D32;

  static final color pink = #FFC4F5;
  static final color red = #F22735;
  static final color maroon =#A00606;

  static final color aqua = #62C1FA;
  static final color blue = #4C55EA;
  static final color darkblue = #0A05A7;

  static final color yellow = #FAF026;
  static final color orange = #FC8F00;

  static final color white = #FFFFFF;
  static final color black = #000000;

  static final color lightgray =#CCCCCC;
  static final color gray = #777777;
  static final color darkgray = #333333;

  float rectSize;
  float bankDist;
  float partBorder;
  float partHeight;


  PFont courierBold;
  PFont courier;

  //Statistics related
  ArrayList<ProcessInfo> processStatistics;
  int idleTime;
  int contextSwitchTime;
  int utilisationTime;
  int timesBlocked;
  int totalTime;
  PrintWriter output;

  int step;
  int speed;
  boolean isRunning;

  color fetchExecute;
  color CPUoutColor;
  color CPUinColor;
  color busColor;

  float requestsX, requestsY, requestsW;
  float ramX, ramY, ramW;
  float cpuX, cpuY, cpuW;
  float processTableX, processTableY, processTableW;
  float readyQueueX, readyQueueY, readyQueueW;
  float clockX, clockY, clockW;

  Simulator() {
    float firstcolX = 10;
    float firstrowY = 50;
    float secondrowY = 350;
    float dist = 10;
    requestsX = firstcolX;
    requestsY = firstrowY; 
    requestsW = 230;
    ramX = firstcolX + requestsW + dist;
    ramY = firstrowY;
    ramW = 1100;
    processTableX = ramX;
    processTableY = secondrowY;
    processTableW = 500;
    cpuX = processTableX + processTableW + dist;
    cpuY = secondrowY;
    cpuW = 100;
    clockX = cpuX+cpuW/2;
    clockY = cpuY+cpuW*2;
    clockW = 100;
    readyQueueX = cpuX + cpuW +dist;
    readyQueueY = secondrowY;
    readyQueueW = 500;
    step = 0;
    isRunning = true;
    speed = 20;
    rectSize = ramW / (RAMSizeInBank+1);
    bankDist = 1.5*rectSize;
    partBorder = rectSize*0.3;
    partHeight = rectSize+2*partBorder;
    courierBold = createFont("courbd.ttf", 18);
    courier = createFont("cour.ttf", 18);
    processStatistics = new ArrayList<ProcessInfo>();
    frameRate(30);
    isRunning = false;
  }

  void draw() {
    background(aqua);
    if (os.fetchNotExecute) {
      fetchExecute = yellow;
      CPUoutColor = yellow;
      CPUinColor = white;
      busColor = yellow;
    } else {
      fetchExecute = lightgreen;
      CPUoutColor = white;
      CPUinColor = lightgreen;
      busColor = lightgreen;
    } 
    //drawUserInput(10, 40, 18);
    drawRequests(18);
    drawRAM();
    drawProcessTable(18);
    drawCPU();
    drawClock();
    drawQueue(18);
    drawSystemState(width/2, 20);
  }

  int findPI(int address) {
    for (PartitionInfo p : os.partitionTable) {
      if (address>=p.baseAddress && address<p.baseAddress+p.size) {
        return os.partitionTable.indexOf(p);
      }
    }
    return -1;
  }

  void drawBusLine(int row, int col, float endX, color c) {
    float x1, x2, y1, y2; 
    strokeWeight(3);
    stroke(c);
    fill(c);
    //line A (vertical inside)
    x1 = (1.5+col)*rectSize;
    y1 = 0.5*partHeight+row*(partHeight+bankDist);
    x2 = x1;
    y2 = y1+ 0.5*(partHeight+bankDist);
    line(x1, y1, x2, y2);
    //line B (horizontal inside) 
    x1 = x2;
    y1 = y2;
    circle(x1, y1, 5);
    x2 = 0;
    y2 = y1;
    circle(x2, y2, 5);
    line(x1, y1, x2, y2);
    //line C (vertical outside)
    x1 = x2;
    y1 = y2;
    x2 = x1;
    y2 = RAMBanks*(partHeight+bankDist);
    line(x1, y1, x2, y2);
    //line D (horizontal outside)
    x1 = x2;
    y1 = y2;
    x2 = endX;
    y2 = y1;
    line(x1, y1, x2, y2);
    //line E (To CPU)
    x1 = x2;
    y1 = y2;
    x2 = endX;
    y2 = y1+50;
    line(x1, y1, x2, y2);
  }

  void drawPartition(int row, int col) {
    rectMode(CENTER);
    color c;
    int partitionIndex = findPI(col+row*RAMSizeInBank);
    if (partitionIndex%2==1) {
      c=white;
    } else {
      c=black;
    }
    fill(c);
    noStroke();
    rect((1.5+col)*rectSize, 0.5*partHeight+row*(partHeight+bankDist), rectSize, partHeight);
  }

  void drawRAMSq(int row, int col, color c) {
    strokeWeight(1);
    stroke(black);
    fill(c);
    rectMode(CENTER);
    rect((1.5+col)*rectSize, 0.5*partHeight+row*(partHeight+bankDist), rectSize, rectSize);
    fill(black);
    textAlign(CENTER, CENTER);
    text(myPC.RAM[col+row*RAMSizeInBank], (1.5+col)*rectSize, 0.5*partHeight+row*(partHeight+bankDist));
  }

  void drawRAM() {
    pushMatrix();
    pushStyle();
    translate(ramX, ramY);
    textFont(courierBold);
    textSize(rectSize*0.7);
    textAlign(CENTER, CENTER);

    for (int j=0; j<RAMBanks; j++) {
      for (int i=0; i<RAMSizeInBank; i++) {
        drawBusLine(j, i, ramW/2, black);
        drawPartition(j, i);
        if ( myPC.RAM[i+j*RAMSizeInBank]==' ') {
          drawRAMSq(j, i, white);
        } else { 
          drawRAMSq(j, i, pink);
        }
      }
    }
    for (int j=0; j<RAMBanks; j++) {
      for (int i=0; i<RAMSizeInBank; i++) {
        if (os.physicalAddress == i+j*RAMSizeInBank) {
          drawBusLine(j, i, ramW/2, busColor);
          drawRAMSq(j, i, fetchExecute);
        }
      }
    }
    pushStyle();
    popMatrix();
  }

  void drawProcessTable(int ts) {
    pushMatrix();
    translate(processTableX, processTableY);

    noStroke();
    rectMode(CORNER);
    textSize(ts);
    textFont(courierBold);

    fill(darkgreen);
    rect(0, 0, processTableW, ts*1.2);
    textAlign(CENTER, CENTER);
    fill(white);
    text("PROCESS TABLE", processTableW/2, ts/2-2);

    fill(green);
    rect(0, ts*1.2, processTableW, ts*1.2);
    textAlign(LEFT, CENTER);
    fill(white);
    text(" PID : Counter : State   : Name", 0, ts*1.2+ts/2-2);

    textFont(courier);
    int count =0;
    for (ProcessInfo p : os.processTable) {
      if (count<kernel.size()) fill(lightgray);
      else fill(white);
      rect(0, (count+2)*ts*1.2, processTableW, ts*1.2+2);
      if (p.state==BLOCKED) fill(red);
      else if (p.state==RUNNING) fill(blue);
      else if (p.state==READY) fill(darkgreen);
      else fill(black);
      text(p.toString(), 0, (count+2)*ts*1.2+ts/2-2);
      count++;
    }
    popMatrix();
  }

  void drawCPU() {
    pushMatrix();
    translate(cpuX, cpuY);
    rectMode(CORNER);
    textFont(courierBold);
    stroke(0);
    strokeWeight(5);
    fill(CPUoutColor);
    rect(0, 0, cpuW, cpuW);
    strokeWeight(1);
    fill(CPUinColor);
    rect(cpuW*0.16, cpuW*0.16, cpuW*0.68, cpuW*0.68, 7);
    fill(black);
    pushStyle();
    textSize(50);
    textAlign(CENTER, CENTER);
    text(myPC.executeInstruction(), cpuW*0.5, cpuW*0.5);
    popStyle();
    triangle(cpuW*0.05, cpuW*0.85, cpuW*0.05, cpuW*0.95, cpuW*0.15, cpuW*0.95);
    pushStyle();
    textAlign(CENTER, CENTER);
    textSize(10);
    strokeWeight(5);
    if (os.interruptsEnabled) {
      fill(green); 
      rect(0, cpuW, cpuW, cpuW*0.40);
      fill(black);
      text("Int/pts Enabled", cpuW*0.5, cpuW*1.2);
    } else {
      fill(red);
      rect(0, cpuW, cpuW, cpuW*0.40);
      fill(black);
      text("Int/pts Disabled", cpuW*0.5, cpuW*1.2);
    }
    popStyle();
    popMatrix();
  }

  void drawQueue(int ts) {
    pushMatrix();
    translate(readyQueueX, readyQueueY);

    noStroke();
    rectMode(CORNER);
    textSize(ts);
    textFont(courierBold);

    fill(darkgreen);
    rect(0, 0, readyQueueW, ts*1.2);
    textAlign(CENTER, CENTER);
    fill(white);
    text("READY QUEUE", readyQueueW/2, ts/2-2);

    fill(green);
    rect(0, ts*1.2, readyQueueW, ts*1.2);
    textAlign(LEFT, CENTER);
    fill(white);
    text(" PID : Counter : State   : Name", 0, ts*1.2+ts/2-2);

    int count =0;
    textFont(courier);
    for (ProcessInfo p : os.readyQueue) {    
      fill(white);
      rect(0, (count+2)*ts*1.2, readyQueueW, ts*1.2+2);
      fill(black);
      text(p.toString(), 0, (count+2)*ts*1.2+ts/2-2);
      count++;
    }
    popMatrix();
  }

  void drawRequests(int ts) {
    pushMatrix();
    translate(requestsX, requestsY);

    noStroke();
    rectMode(CORNER);
    textSize(ts);
    textFont(courierBold);

    fill(darkgreen);
    rect(0, 0, requestsW, ts*1.2);
    textAlign(CENTER, CENTER);
    fill(white);
    text("USER REQUESTS", requestsW/2, ts/2-2);


    fill(green);
    rect(0, ts*1.2, requestsW, ts*1.2);
    textAlign(LEFT, CENTER);
    fill(white);
    text(" time : Name", 0, ts*1.2+ts/2-2);

    textFont(courier);
    int count =0;
    for (Request r : os.userInput) {    
      fill(white);
      rect(0, (count+2)*ts*1.2, requestsW, ts*1.2+2);
      fill(black);
      text(r.toString(), 0, (count+2)*ts*1.2+ts/2-2);
      count++;
    }
    popMatrix();
  }

  void drawClock() {
    stroke(0);
    fill(fetchExecute);
    float inc = (step % speed)*TWO_PI/speed;
    arc(clockX, clockY, clockW, clockW, -HALF_PI, -HALF_PI+inc, PIE);
    pushStyle();
    textSize(clockW*0.4);
    fill(black);
    textAlign(CENTER, CENTER);
    text(myPC.clock, clockX, clockY);
    popStyle();
  }

  void drawUserInput(float x, float y, float ts) {
    pushMatrix();
    translate(x, y);
    if (!os.userInput.isEmpty()) {
        fill(red);
        textFont(courierBold);
        textSize(ts);
        textAlign(LEFT);
        text(os.userInputMessage, 0, 0);
    }
    popMatrix();
  }

  void saveStatsToFile(String filename) {
    output = createWriter(filename);
    output.println(os.scheduler.name);
    output.println(os.memoryManager.name);
    output.println("Simulation lasted "+totalTime+" steps.");
    output.println("CPU was idle for "+idleTime+" steps.");
    output.println("Total time lost in context switch "+contextSwitchTime);
    output.println("Total utilisation time "+utilisationTime);
    output.println("------------Process statistics-------------");
    output.println("pid, load Time, response Time, turnarround Time");
    float avLoadTime=0;
    float avResponceTime=0;
    float avTurnarroundTime=0;
    for (ProcessInfo pi : processStatistics) {
      output.println(pi.pid+", "+pi.loadTime+", "+pi.responceTime+", "+pi.turnarroundTime);
      avLoadTime += pi.loadTime;
      avResponceTime += pi.responceTime;
      avTurnarroundTime += pi.turnarroundTime;
    }
    avLoadTime /= processStatistics.size();
    avResponceTime /= processStatistics.size();
    avTurnarroundTime /= processStatistics.size();
    output.println("------------Average statistics-------------");
    output.println("-- , "+avLoadTime+", "+avResponceTime+", "+avTurnarroundTime);
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
  }

  void drawSystemState(int x, int y) {
    textFont(courierBold);
    fill(black);
    textAlign(CENTER, CENTER);
    text(os.OSstate, x, y);
  }

  void compileKernel(MemoryManager mm, ProcessScheduler ps) {
    kernel = new ArrayList<KernelProcess>();
    kernel.add(new SystemIdle("$", "Kernel-SystemIdle"));
    kernel.add(new ProcessCreator("**$", "Kernel-Creator"));
    kernel.add(new ProcessAdmitter("*$", "Kernel-Admitter"));
    kernel.add(new ProcessDeleter("*$", "Kernel-Deleter"));
    kernel.add(mm);
    kernel.add(ps);
    String kernelCode="";
    for (KernelProcess kp : kernel) {
      kernelCode+=kp.code;
    }
    myPC.HDD.put("kernel", kernelCode);
  }
}
