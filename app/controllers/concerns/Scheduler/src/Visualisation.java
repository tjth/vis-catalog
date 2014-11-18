public class Visualisation {
  
  private String name;
  private int duration;
  
  public static final Visualisation[] defVis = {
    new Visualisation(" D01 ", 1),
    new Visualisation(" D02 ", 1),
    new Visualisation(" D03 ", 1)};
  
  public Visualisation(String name, int duration) {
    this.name = name;
    this.duration = duration;
  }
  
  public int getDuration() {
    return duration;
  }
  
  @Override
  public String toString() {
    return name;
  }
  
}
