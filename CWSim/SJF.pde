class SJF extends ProcessScheduler {

  //Inputs

  //Outputs

  //Internal

  SJF(String c, String nm) {
    super(c, nm);
  }

  void initialise() {
    message = "SJF >> started search for the smallest process to run";
    os.interruptsEnabled = false;
    os.switchTo(this);
  }

  void execute() {
    
      int min = os.readyQueue.get(0).getSize();
   for (int i = 0;i < os.readyQueue.size();i++ ){
    if (os.readyQueue.get(i).getSize() < min){
       min = os.readyQueue.get(i).getSize();
       os.readyQueue.get(0).setSize(min);
          
      }
    }
   // os.readyQueue.get(0).setSize(min);
    os.active = os.readyQueue.get(0);
    message = "SJF >> found process "+os.readyQueue.get(0).pid+", program: "+os.readyQueue.get(0).name;
    os.readyQueue.remove(0);
    
    
    this.state=READY;
    os.active.state=RUNNING;
    os.interruptsEnabled = true;
  }
}
