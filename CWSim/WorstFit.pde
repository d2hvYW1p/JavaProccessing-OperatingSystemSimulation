class WorstFit extends MemoryManager {

  
  WorstFit(String c, String nm) {
    super(c, nm);
  }

  void initialise(String fn) {
    filename = fn;
    initialise();
  }

  void initialise() {
    message = "WorstFit >> Starting search of partition of ("+filename+")";
    os.interruptsEnabled = false;
    os.switchTo(this);
  }
 // Dont mind i tried many things but that has a potential  for the future, the real implementation is down
 // void execute() {
 //   result = null;
//int requestedSize = myPC.HDD.get(filename).length()+os.processAppendix.length();
 //   int max= -1;
  //  int index= -1;
 //   for(int  i=0; i< os.partitionTable.size(); i++) {
  //    if (os.partitionTable.get(i).getSize() > max && partition.isFree){
  //     max = os.partitionTable.get(i).getSize();
  //   //  index =i;
  //    }
//    }
//     if(requestedSize > max){
//     message = "WorstFit >> No partition for "+filename+" was found. Will try again in 100 ticks";
//      os.loadProgram(myPC.clock+100, filename);
//      }else{
 //       message = "WorststFit >> Partition created at base address "+result.baseAddress+" ("+filename+")";
 //       os.interruptsEnabled = false;}    
 //     if (partition.size>=requestedSize){ 
 //       int secondPartBA = partition.baseAddress + requestedSize;
 //       int secondPartSize = partition.size - requestedSize;
 //       int fistPartSize = requestedSize;
  //      int partIndex = os.partitionTable.indexOf(partition);
 //       
 //         os.partitionTable.add(partIndex+1, new PartitionInfo(secondPartSize, secondPartBA));
 //       }
 //       partition.size = fistPartSize;
 //       result = partition;      }
//      
 // }
void execute()
{
result = null;
int requestedSize = myPC.HDD.get(filename).length() + os.processAppendix.length();
PartitionInfo biggestPartititon = null;
int max = -1;
for(PartitionInfo partition : os.partitionTable ){   
  if( max < ( partition.size - requestedSize ) && partition.isFree && partition.size >= requestedSize){
  max = partition.size - requestedSize;
  biggestPartititon = partition;}
  
  else if(partition.size < requestedSize){
  message = "WorstFit >> No partition for "+filename+" was found.";
  biggestPartititon = null  ;
  break;}
  }

if (biggestPartititon !=null && !biggestPartititon.equals(" ") ) {
  int secondPartBA = biggestPartititon.baseAddress + requestedSize;
  int secondPartSize = biggestPartititon.size - requestedSize;
  int fistPartSize = requestedSize;
  int partIndex = os.partitionTable.indexOf(biggestPartititon);
  if (biggestPartititon.size>=requestedSize){
      os.partitionTable.add(partIndex+1, new PartitionInfo(secondPartSize,secondPartBA));}
  biggestPartititon.size= fistPartSize;
  result = biggestPartititon;}

  if (result==null){
      message = "WorstFit >> No partition for "+filename+" was found. Will try again in 100 ticks";
      os.loadProgram(myPC.clock+100, filename);
 }else{
    message = "WorstFit >> Partition created at base address "+result.baseAddress+" ("+filename+")";
    os.interruptsEnabled = false;}


}
}
