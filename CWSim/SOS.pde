class SOS {
  ArrayList<ProcessInfo> processTable;
  ArrayList<ProcessInfo> readyQueue;
  ArrayList<PartitionInfo> partitionTable;
  ProcessInfo active;
  int physicalAddress;
  int physicalAddressUpdate;
  final String processAppendix = "hhhsss";
  boolean interruptsEnabled;
  ArrayList<Request> userInput;
  String OSstate;
  String userInputMessage="";
  int userInputMessageDisplay;
  boolean Preemptive;
  int numberofwhateever;
  

  SystemIdle idle;
  ProcessCreator creator;
  ProcessAdmitter admitter;
  ProcessDeleter deleter;
  MemoryManager memoryManager;
  ProcessScheduler scheduler;

  boolean fetchNotExecute = false;

  SOS() {
    OSstate ="Initialising";
    physicalAddress = 0;
    physicalAddressUpdate = physicalAddress;
    processTable = new ArrayList<ProcessInfo>();
    readyQueue = new ArrayList<ProcessInfo>();
    partitionTable = new ArrayList<PartitionInfo>();
    userInput = new ArrayList<Request>();
  }

  //create a partition at the start and load there the OS file 
  void BootSystem() {
    String kernelCode = myPC.HDD.get("kernel");
    PartitionInfo kernelPartition = new PartitionInfo(kernelCode.length(), 0);
    partitionTable.add(kernelPartition);
    kernelPartition.isFree = false;

    int ba = 0;
    for (KernelProcess kp : kernel) {
      kp.baseAddress = ba;
      processTable.add(kp);
      kp.state = READY;
      kp.copyToRAM(ba);
      ba += kp.code.length();
    }
    idle = ((SystemIdle) kernel.get(0));
    creator = ((ProcessCreator) kernel.get(1));
    admitter = ((ProcessAdmitter) kernel.get(2));
    deleter = ((ProcessDeleter) kernel.get(3));
    memoryManager = ((MemoryManager) kernel.get(4));
    scheduler = ((ProcessScheduler) kernel.get(5));

    active = idle;
    idle.initialise();
    active.state = RUNNING;

    int partitionSize = (myPC.RAM.length-partitionTable.get(0).size);
    PartitionInfo userPartition = new PartitionInfo(partitionSize, partitionTable.get(0).size);
    partitionTable.add(userPartition);
    interruptsEnabled = true;
  }

  //add a request to the request list. the list is shorted by request time
  void loadProgram(int time, String filename) {
    boolean requestInserted = false;
    if (userInput.isEmpty()) {
      userInput.add(new Request(time, filename));
    } else {
      for (int i=0; i<userInput.size(); i++) {
        if (userInput.get(i).time>time) {
          userInput.add(i, new Request(time, filename));
          requestInserted = true;
          break;
        }
      }
      if (!requestInserted) {
        userInput.add(new Request(time, filename));
      }
    }
  }

  // Do one step of the OS.
  
  void step() {
    //First check if any blocked process should be unblocked
    checkForUnblocking();
    //Do either a fetch OR an execute
    fetchExecute();
    //If we are alloweed to be interrupted, and there are requests pending, handle the first one
    if (interruptsEnabled && !userInput.isEmpty()) {
      if (userInput.get(0).time<=myPC.clock) {
        memoryManager.initialise(userInput.get(0).filename);
        userInputMessage = "New input >> "+userInput.get(0).filename+" ("+myPC.clock+")" ;
        userInputMessageDisplay = 0;
        userInput.remove(0);
      }
    }
    //if there are ready processes and the system is idel invoke the scheduler
    if (active == idle && !readyQueue.isEmpty()) {
      scheduler.initialise();
    }
    //if the scheduler should preempt, start the scheduler
    if(os.Preemptive){
    scheduler.preempt();}
    //prepare for the next step
    updatePhysicalAddress();
    if (userInputMessageDisplay<4) userInputMessageDisplay++;
    else userInputMessage = "";
  }

  //switched any process (user OR kernel) to a kernel process
  void switchTo(KernelProcess pi) {
    if (active instanceof KernelProcess) {
      active.state = READY;
    } else {
      if (active.state == RUNNING) {
        active.state = READY;
        readyQueue.add(active);
      }
    }
    active = pi;
    active.state = RUNNING;
    active.programCounter = 0;
  }
//>>>>>>>>>HELPER METHODS FOR THE STEP<<<<<<<<<<<<<<<<<
  void updatePhysicalAddress() {
    physicalAddressUpdate = active.programCounter+active.baseAddress;
  }

  void fetchExecute() {
    fetchNotExecute = !fetchNotExecute;
    if (fetchNotExecute) fetch();
    else execute();
  }

  void fetch() {
    physicalAddress = physicalAddressUpdate;
    myPC.fetchInstruction(physicalAddress);
    OSstate = "At time "+myPC.clock+" fetched instruction from "+physicalAddress;
  }

  void execute() {
    char c = myPC.executeInstruction();
    if (c=='*') {
      active.programCounter++;
      if (active instanceof KernelProcess) {
        OSstate = ((KernelProcess) active).message;
        sim.contextSwitchTime++;
      } 
      else {
        OSstate = "At time "+myPC.clock+" excuted "+c+" of process "+active.pid;
        if (active.programCounter == 1) active.responceTime = myPC.clock - active.loadTime;
        sim.utilisationTime++;
        //Uncomment the below lines for the RR algorithm
      //  numberofwhateever++;
      //  if(numberofwhateever % tss == 0 ){
      //   Preemptive = true;
      //   numberofwhateever=0;}
      }
    }
    else if (c=='$') {
      numberofwhateever =0;
      if (active == idle) {
        OSstate = idle.message;
        idle.programCounter = 0;
        sim.idleTime++;
      } else if (active == creator) {
        sim.contextSwitchTime++;
        creator.execute();
        OSstate = creator.message;
        admitter.initialise(creator.result);
      } else if (active == admitter) {
        sim.contextSwitchTime++;
        admitter.execute();
        OSstate = admitter.message;
        scheduler.initialise();
      } else if (active == deleter) {
        sim.contextSwitchTime++;
        deleter.execute();
        OSstate = deleter.message;
        idle.initialise();
      } else if (active == memoryManager) {
        sim.contextSwitchTime++;
        memoryManager.execute();
        OSstate = memoryManager.message;
        if (memoryManager.result == null) {
          idle.initialise();
        } else {
          creator.initialise(memoryManager.result, memoryManager.filename);
        }
      } else if (active == scheduler) {
        sim.contextSwitchTime++;
        scheduler.execute();
        OSstate = scheduler.message;
      } else {
        sim.utilisationTime++;
        OSstate = "Process completed.";
        deleter.initialise(active);
      }
    } else if (c=='@') {
      numberofwhateever =0;
      sim.utilisationTime++;
      //Block the process
      active.state=BLOCKED;
      active.blockTime = myPC.clock;
      active.programCounter++;
      OSstate =  "At time "+myPC.clock+" process "+active.pid+" blocked";
      idle.initialise();
    }
  }

  void checkForUnblocking() {
    //search for blocked process in the process table
    for (ProcessInfo p : processTable) {
      //if one is found check if the time passed from blockTime is surpassed
      if (p.state==BLOCKED) {
        //if the block time is more 
        if (p.blockTime+BLOCKTIME == myPC.clock) {
          //then make it ready AND add it to the ready queue
          p.state=READY;
          readyQueue.add(p);
        }
      }
    }
  }
  
  
  
}
