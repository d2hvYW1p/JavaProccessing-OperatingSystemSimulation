 int tss; 
class RoundRobin extends ProcessScheduler {

  //Inputs

  //Outputs

  //Internal
// ts is the time slice that we need in order to change
  
  RoundRobin(String c, String nm,int ts) {
    super(c, nm);
    tss= ts;
  }
  @Override 
  void preempt(){
   os.Preemptive = false;
   System.out.println(" Interupt ");
   initialise();
  }
  void initialise() {
    message = "RoundRobin >> started search for process to run";
    os.interruptsEnabled = true;
    os.switchTo(this);
  }

  void execute() {
    os.active = os.readyQueue.get(0);
    message = "RoundRobin >> found process "+os.readyQueue.get(0).pid+", program: "+os.readyQueue.get(0).name;
    os.readyQueue.remove(0);
    this.state=READY;
    os.active.state=RUNNING;
    os.interruptsEnabled = true;
  }
 

}
