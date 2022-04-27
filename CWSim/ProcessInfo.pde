class ProcessInfo{
  int pid;//int PID; //Who am I?
  int state; //What is my state?
  int baseAddress; //Where am I?
  int programCounter; //How far have I progressed?
  int blockTime; //when did I last block?
  int loadTime; //When was I created?
  int size; //How big am I?
  String name; //What is the program?
  int responceTime ; //how much time did it pass to run the first instruction?
  int turnarroundTime; //how much time did it pass to run the last instruction?
  int meanTime;
  
  ProcessInfo(int ba, int s, String nm){
    pid = lastAssignedPID++;
    state = NEW;
    baseAddress = ba;
    programCounter = 0;
    blockTime = -1;
    loadTime = -1;
    this.size = s;
    name = nm;
    meanTime =0;
  }
  public int getMeanTime(){
    return meanTime;
  }
  public void setMeanTime(int meanTime){
    this.meanTime = meanTime;
  }
  
  public int getSize(){
    return size;
  }
  public void setSize(int size){
    this.size = size;
  }
  public int getblockTime(){
    return blockTime;
  }
  public void setblockTime(int blockTime){
    this.blockTime = blockTime;
  }
  public int getTurnarroundTime(){
    return turnarroundTime;
  }
  public void setTurnarroundTime(int turnarroundTime){
    this.turnarroundTime = turnarroundTime;
  }
  public int getResponceTime(){
    return responceTime;
  }
  public void setResponceTime(int responceTime){
    this.responceTime = responceTime;
  }
  
  String toString(){
    String result="  ";
    if(pid<10){
      result += pid+"  :    ";
    }else{
      result += pid+" :    ";
    }
    if(programCounter<10){
      result += programCounter+"    : ";
    }else{
      result += programCounter+"   : ";
    }
    if(state == 0)      result += "NEW     ";
    else if(state == 1) result += "READY   ";
    else if(state == 2) result += "RUNNING ";
    else if(state == 3) result += "BLOCKED ";
    else                result += "EXITING ";
    result += ": "+name;
    return result;  
  }
  }

  
  
