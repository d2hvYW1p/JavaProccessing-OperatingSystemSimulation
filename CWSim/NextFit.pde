class NextFit extends MemoryManager {
private int lastSearched ;
  
  NextFit(String c, String nm) {
    super(c, nm);
    lastSearched=1;
  }

  void initialise(String fn) {
    filename = fn;
    initialise();
  }

  void initialise() {
    message = "NextFit >> Starting from  where it was left...searching of partition for program ("+filename+")";
    os.interruptsEnabled = false;
    os.switchTo(this);
  }

  void execute() {
    result = null;
    int requestedSize = myPC.HDD.get(filename).length()+os.processAppendix.length();
    for (int i =lastSearched;i<os.partitionTable.size();i++) {
      PartitionInfo partition = os.partitionTable.get(i);
      if (partition.isFree && partition.size>=requestedSize) {
        lastSearched = i;
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
    if (  result == null  ){
    for (int i =1;i<lastSearched;i++) {
      PartitionInfo partition = os.partitionTable.get(i);
      if (partition.isFree && partition.size>=requestedSize) {
        lastSearched = i;        
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
    }}
    if (result==null) {
      message = "NextFit >> No partition for "+filename+" was found. Will try again in 100 ticks";
      os.loadProgram(myPC.clock+100, filename);
    }else message = "NexttFit >> Partition created at base address "+result.baseAddress+" ("+filename+")";
    os.interruptsEnabled = false;
  }
}
