//Abstract class for the kernel process

abstract class KernelProcess extends ProcessInfo {
  String code;
  String message;

  KernelProcess(String c, String nm) {
    super(-1, c.length(), nm);
    code = c;
  }

  void copyToRAM(int address) {
    baseAddress = address;
    for (int i=0; i<code.length(); i++) {
      myPC.RAM[baseAddress+i] = code.charAt(i);
    }
  }

  abstract void initialise();
  abstract void execute();
}

///////////////////////////////////////////////////////
//abstract class for the memory manager
abstract class MemoryManager extends KernelProcess {

  //Inputs
  String filename;
 
  //Outputs
   PartitionInfo result;
  
  //Internal

  MemoryManager(String c, String nm) {
    super(c, nm);
  }

  abstract void initialise(String fn);
}

///////////////////////////////////////////////////////
//anstract class for the process scheduler
abstract class ProcessScheduler extends KernelProcess {

  ProcessScheduler(String c, String nm) {
    super(c, nm);
  }

  //overwrite this method if the scheduler should be preempted.
  //Specificaly, write that the scheduler should be loaded if some condition occures
  
  void preempt() {
 //  if(Preemptive == true)
  //preempt();
   }
}

///////////////////////////////////////////////////////
//Use this template for the compacting process 
class TemplateProcess extends KernelProcess {

  //Inputs

  //Outputs

  //Internal


  TemplateProcess(String c, String name) {
    super(c, name);
  }

  void initialise() {
    message = "Some description about what we will do";
    os.interruptsEnabled = false; //but can also be true;
    os.switchTo(this);
  }

  void execute() {
    //Write the code of what is happening here
    message = "Some description about what happened";
    os.interruptsEnabled = true; //but can also be false;
  }
}

///////////////////////////////////////////////////////
class SystemIdle extends KernelProcess {

  //Inputs

  //Outputs

  //Internal

  SystemIdle(String c, String nm) {
    super(c, nm);
  }

  void initialise() {
    message = "SystemIdle >> Waiting for user input";
    os.interruptsEnabled = true;
    os.switchTo(this);
  }

  void execute() {
    message = "SystemIdle >> Waiting for user input";
    os.interruptsEnabled = true;
  }
}

///////////////////////////////////////////////////////
class ProcessCreator extends KernelProcess {

  //Inputs
  PartitionInfo pi;
  String filename;
  
  //Outputs
  ProcessInfo result;
  
  //Internal

  ProcessCreator(String c, String nm) {
    super(c, nm);
  }

  void initialise(PartitionInfo partition, String name) {
    pi = partition;
    filename = name;
    initialise();
  }

  void initialise() {
    message = "ProcessCreator >> Staring process creation ("+filename+")";
    os.interruptsEnabled = false;
    os.switchTo(this);
  }

  void execute() {
    String processImage = myPC.HDD.get(filename)+os.processAppendix;
    result = new ProcessInfo(pi.baseAddress, processImage.length(), filename);
    os.processTable.add(result);
    for (int i=0; i<processImage.length(); i++) {
      myPC.RAM[i+pi.baseAddress] = processImage.charAt(i);
    }
    pi.isFree = false;
    message = "ProcessCreator >> Process ("+result.pid+") creation completed ("+filename+")";
    os.interruptsEnabled = false;
  }
}


///////////////////////////////////////////////////////
class ProcessAdmitter extends KernelProcess {

  //Inputs
  ProcessInfo result;
  //Outputs

  //Internal

  ProcessAdmitter(String c, String nm) {
    super(c, nm);
  }

  void initialise(ProcessInfo process) {
    result = process;
    initialise();
  }

  void initialise() {
    message = "ProcessAdmiter >> Staring admission of process ("+result.pid+")";
    os.interruptsEnabled = false;
    os.switchTo(this);
  }

  void execute() {
    result.state = READY;
    result.loadTime = myPC.clock;
    os.readyQueue.add(result);
    message = "ProcessAdmiter >> Process ("+result.pid+") admission completed";
    result.loadTime = myPC.clock;
    os.interruptsEnabled = true;
  }
}

///////////////////////////////////////////////////////
class ProcessDeleter extends KernelProcess {

  //Inputs
  ProcessInfo processToDelete;
  //Outputs

  //Internal


  ProcessDeleter(String c, String nm) {
    super(c, nm);
  }

  void initialise(ProcessInfo pi) {
    processToDelete = pi;
    initialise();
  }

  void initialise() {
    message = "ProcessDeleter >> Starting deletion of process ("+processToDelete.pid+")";
    os.interruptsEnabled = false;
    processToDelete.state = EXITING;
    os.switchTo(this);
  }

  void execute() {
    //1 find the partition
    int partitionIndex =-1;
    for (int i=1; i<os.partitionTable.size(); i++) {
      if (os.partitionTable.get(i).baseAddress == processToDelete.baseAddress) {
        partitionIndex = i;
        break;
      }
    }
    //2 empty the partition
    for (int i=0; i<os.partitionTable.get(partitionIndex).size; i++) {
      myPC.RAM[i+os.partitionTable.get(partitionIndex).baseAddress] = ' ';
    }
    os.partitionTable.get(partitionIndex).isFree=true;

    //3. do coallescing
    if (partitionIndex<os.partitionTable.size()-1) {
      if (os.partitionTable.get(partitionIndex+1).isFree) {
        os.partitionTable.get(partitionIndex).size += os.partitionTable.get(partitionIndex+1).size;
        os.partitionTable.remove(partitionIndex+1);
      }
    }
    if (partitionIndex>0) {
      if (os.partitionTable.get(partitionIndex-1).isFree) {
        os.partitionTable.get(partitionIndex-1).size += os.partitionTable.get(partitionIndex).size;
        os.partitionTable.remove(partitionIndex);
      }
    }

    //4. delete it from the process Table
    processToDelete.turnarroundTime = myPC.clock - processToDelete.loadTime;
    sim.processStatistics.add(processToDelete);
    //println(processToDelete.toString());
    os.processTable.remove(processToDelete);
    
    message = "ProcessDeleter >> Process ("+processToDelete.pid+ ") deleted";
    os.interruptsEnabled = true;
  }
}


///////////////////////////////////////////////////////
class FirstFit extends MemoryManager {

  FirstFit(String c, String nm) {
    super(c, nm);
  }

  void initialise(String fn) {
    filename = fn;
    initialise();
  }

  void initialise() {
    message = "FirstFit >> Starting search of partition for program ("+filename+")";
    os.interruptsEnabled = false;
    os.switchTo(this);
  }

  void execute() {
    result = null;
    int requestedSize = myPC.HDD.get(filename).length()+os.processAppendix.length();
    for (PartitionInfo partition : os.partitionTable) {
      if (partition.isFree && partition.size>=requestedSize) {
        //insert a new partition after this one 
        int secondPartBA = partition.baseAddress + requestedSize;
        int secondPartSize = partition.size - requestedSize;
        int fistPartSize = requestedSize;
        int partIndex = os.partitionTable.indexOf(partition);
        if (partition.size>requestedSize) {
          os.partitionTable.add(partIndex+1, new PartitionInfo(secondPartSize, secondPartBA));
        }
        partition.size = fistPartSize;
        result = partition;
        break;
      }
    }
    if (result==null) {
      message = "FirstFit >> No partition for "+filename+" was found. Will try again in 100 ticks";
      os.loadProgram(myPC.clock+100, filename);
    }else message = "FirstFit >> Partition created at base address "+result.baseAddress+" ("+filename+")";
    os.interruptsEnabled = false;
  }
}



///////////////////////////////////////////////////////
class FCFS extends ProcessScheduler {

  //Inputs

  //Outputs

  //Internal

  FCFS(String c, String nm) {
    super(c, nm);
  }

  void initialise() {
    message = "FCFS >> started search for process to run";
    os.interruptsEnabled = false;
    os.switchTo(this);
  }

  void execute() {
    os.active = os.readyQueue.get(0);
    message = "FCFS >> found process "+os.readyQueue.get(0).pid+", program: "+os.readyQueue.get(0).name;
    os.readyQueue.remove(0);
    this.state=READY;
    os.active.state=RUNNING;
    os.interruptsEnabled = true;
  }
}
