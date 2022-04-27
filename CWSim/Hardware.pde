class Hardware {
  /*Instruction Set
     * = any normal instruction add, sub, load etc
     $ = exit the program (normal exit)
     @ = block for a short ammount of time
     d = a variable
     an example of a program: ***@*****$ddddd
  */
  
  //CPU
  char CPU;
  //RAM
  char[] RAM;
  //HDD
  HashMap<String, String> HDD;
  //clock
  int clock;
  
  Hardware(int RAMsize){
    RAM = new char[RAMsize];
    HDD = new HashMap<String, String>();
    clock=0;
    RAMinit();
    moundHDD();
  }
  
  void RAMinit(){
    for(int i=0; i<RAM.length; i++){
      RAM[i] = ' ';
    }
  }
  
  void moundHDD(){
    //Kernel will have the process in the following order:
    //Idle-CreateProcess-admitProcess-deleteProcess-memoryManager-Scheduler
    //Add the compacting process at the end. Remember to add it at the compileKernel()
    HDD.put(new String("kernel"), new String("1"));
    HDD.put(new String("program1.exe"), new String("**@**@***$ddd"));
    HDD.put(new String("program2.exe"), new String("*****$ddd"));
    HDD.put(new String("program3.exe"), new String("*****@************$d"));
  }
  
  void fetchInstruction(int address){
    CPU = RAM[address];
  }
  
  char executeInstruction(){
    return CPU;
  }
  
}
