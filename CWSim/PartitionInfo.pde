class PartitionInfo{
  int size;
  boolean isFree;
  int baseAddress;
  
  PartitionInfo(int s, int ba){
    this.size = s;
    isFree = true;
    baseAddress = ba;
  }
  public int getSize(){
    return size;
  }
  public void setSize(int size){
    this.size = size;
  }
  String toString(){
    return "BA "+baseAddress+" Size: "+size+" free: "+isFree;
  }
  
}
