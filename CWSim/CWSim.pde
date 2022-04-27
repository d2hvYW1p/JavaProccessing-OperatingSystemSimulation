//OS Gobal constants related
static final int NEW = 0;
static final int READY = 1;
static final int RUNNING = 2;
static final int BLOCKED = 3;
static final int EXITING = 4;

static final int RAMBanks = 4;
static final int RAMSizeInBank = 50;
static final int BLOCKTIME = 10;

ArrayList<KernelProcess> kernel;
static int lastAssignedPID = 0;

Simulator sim;
Hardware myPC;
SOS os;

//>>>>>>>>>> SETUP AND HELPER METHODS <<<<<<<<<<<<<<<<<<

void setup() {
  size(1400, 800);
  surface.setLocation(4500-width, 100);
  sim = new Simulator();
  myPC=new Hardware(RAMBanks*RAMSizeInBank);
  os = new SOS();
  FirstFit memoryManager = new FirstFit("*$", "Kernel-FirstFit");
  // NextFit memoryManager = new NextFit("*$", "Kernel-NextFit");
  //WorstFit memoryManager = new WorstFit("*$", "Kernel-WorstFit");
  FCFS scheduler = new FCFS("*$", "Kernel-FCFS");
  //MyProccessScheduler scheduler = new MyProccessScheduler("***$,"Kernel-MyProccessScheduler");
  //SJF scheduler = new SJF("***$", "Kernel-SJF");
  //RoundRobin scheduler = new RR("*$", "Kernel-RR", 3);
  sim.compileKernel(memoryManager, scheduler);
  os.BootSystem();
  setupRequests();
}

//used for consistency in experiments. Feel free to modify this
void setupRequests() {
  os.userInput.add(new Request(4, "program1.exe"));
  os.userInput.add(new Request(31, "program2.exe"));
  os.userInput.add(new Request(60, "program3.exe"));
  os.userInput.add(new Request(73, "program1.exe"));
  os.userInput.add(new Request(90, "program1.exe"));
  os.userInput.add(new Request(129, "program2.exe"));
  os.userInput.add(new Request(159, "program2.exe"));
  os.userInput.add(new Request(198, "program3.exe"));
  os.userInput.add(new Request(230, "program3.exe"));
  os.userInput.add(new Request(250, "program1.exe"));
}

void draw() {
  sim.draw();
  if (sim.step % sim.speed ==0 && sim.isRunning) {
    myPC.clock++;
    os.step();
  }
  if (sim.isRunning) {
    sim.step++;
  }
}

//Handles key presses. You may add your own key repsonces here
void keyPressed() {
  if (key == '1') {
    os.loadProgram(myPC.clock, "program1.exe");
  } else if (key == '2') {
    os.loadProgram(myPC.clock, "program2.exe");
  } else if (key == '3') {
    os.loadProgram(myPC.clock, "program3.exe");
  } else if (key =='V' || key =='v') {
    sim.totalTime = myPC.clock;
    sim.saveStatsToFile("stats.txt");
    // exit();
    sim.isRunning = false;
  } else if (key =='P' || key =='p') {
    if (sim.isRunning) sim.isRunning = false;
    else sim.isRunning = true;
  } else if (key =='C' || key =='c') {
    // compacting();    
  } else if (key =='s' || key =='S') {
    if (!sim.isRunning) {
      myPC.clock++;
      os.step();
      println(os.OSstate);
    }
  } else if (key =='q' || key =='Q') {
    exit();
  } else if (key == CODED) {
    if (keyCode == LEFT) {
      sim.speed +=5;
    } else if (keyCode == RIGHT) {
      sim.speed -=5;
    }
    sim.speed = constrain(sim.speed, 1, 30);
  }
}
