import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.PriorityQueue;

public class Scheduler {

  private static final int SCREENS = 4;
  private static final int MINS = 6;
  private List<Session> sessions = new ArrayList<Session>();

  public Scheduler() {
    reset();
  }

  public void reset() {
    sessions.clear();
  }

  public void schedule(List<Programme> progs) {
    PriorityQueue<PlayFreq> pq = createQueue(progs);
    int[] nextFreeSlot = new int[SCREENS];
    for (int s = 0; s < SCREENS; s++) {
      nextFreeSlot[s] = 0;
    }
    List<PlayFreq> selectedPFs = new ArrayList<PlayFreq>();
    List<Programme> selectedProgs = new ArrayList<Programme>();
    for (int m = 0; m < MINS; m++) {
      System.out.println(pq);
      for (int checked = 0; checked < SCREENS; checked++) { // attempt to fill in all free screens at time m
        if (nextFreeSlot[checked] <= m) { // free screen found
          int startScr = checked;
          int blockSize;
          for (blockSize = 1; checked + blockSize < SCREENS; blockSize++) { // consecutive free screens
            if (nextFreeSlot[checked + blockSize] > m) {
              break;
            }
          }
          checked += blockSize;
          int filled = 0;
          while (!pq.isEmpty() && filled < blockSize) { // get enough programmes to fill consecutive free screens
            PlayFreq pf = pq.peek();
            if (pf.prog.getScreens() > blockSize - filled) {
              break;
            }
            pq.remove();
            if (pf.prog.getDuration() <= 2 * (MINS - m)) { // select programme if at least half of it can be played
              selectedPFs.add(pf);
              selectedProgs.add(pf.prog);
              filled += pf.prog.getScreens();
            }
          }
          Collections.sort(selectedProgs); // sort programmes in ascending duration order
          boolean alignLeft = true; // indicates whether programmes should be aligned left or right
          if (startScr == 0 && blockSize < SCREENS ||
              startScr > 0 && startScr + blockSize < SCREENS &&
              nextFreeSlot[startScr - 1] > nextFreeSlot[startScr + blockSize]) { // align left
            Collections.reverse(selectedProgs);
          } else if (startScr + blockSize == SCREENS && blockSize < SCREENS ||
              startScr > 0 && startScr + blockSize < SCREENS &&
              nextFreeSlot[startScr - 1] > nextFreeSlot[startScr + blockSize]) { // align right
            alignLeft = false;
          } else { // all screens free or no preference for alignment
            if (Math.random() < 0.5) {
              Collections.reverse(selectedProgs);
            } else {
              alignLeft = false;
            }
          }
          if (!alignLeft) {
            startScr += blockSize - filled;
          }
          while (!selectedProgs.isEmpty()) { // schedule all selected programmes
            Programme prog = selectedProgs.remove(0);
            if (m + prog.getDuration() <= MINS) {
              sessions.add(new Session(prog, startScr, m));
              for (int i = 0; i < prog.getScreens(); i++) {
                nextFreeSlot[startScr + i] = m + prog.getDuration();
              }
            } else {
              sessions.add(new Session(prog, startScr, m, MINS));
              for (int i = 0; i < prog.getScreens(); i++) {
                nextFreeSlot[startScr + i] = MINS;
              }
            }
            startScr += prog.getScreens();
          }
          // schedule fillers if necessary
          selectedProgs.clear();
          requeue(selectedPFs, pq);
          selectedPFs.clear();
        }
      }
      
//      while (filled < SIZE && Programme.defProgs.length > 0) { // screens not completely filled
//        int attempts = 0;
//        Programme prog = Programme.defProgs[(int)(Math.random() * Programme.defProgs.length)];
//        if (filled + prog.getSize() <= SIZE) { // within size limits
//          toScreen.add(new Session(prog, filled, m));
//          filled += prog.getSize();
//          attempts = 0;
//        } else {
//          attempts++;
//          if (attempts >= 3) { // arbitrary value to break loop if no appropriate programme is found
//            break;
//          }
//        }
//      }
//      sessions.addAll(toScreen);
//      onScreen = toScreen;
    }
  }

  private PriorityQueue<PlayFreq> createQueue(List<Programme> progs) {
    PriorityQueue<PlayFreq> pq = new PriorityQueue<PlayFreq>();
    for (Programme prog : progs) {
      pq.add(new PlayFreq(prog));
    }
    return pq;
  }
  
  private void requeue(List<PlayFreq> pfs, PriorityQueue<PlayFreq> pq) {
    for (PlayFreq pf : pfs) {
      pf.setNextPlay();
      pq.add(pf);
    }
  }
  
  @Override
  public String toString() {
    String[][] visNames = new String[MINS][SCREENS];
    boolean[][] strokes = new boolean[MINS][SCREENS];
    boolean[][] dashes = new boolean[MINS][SCREENS];
    boolean[][] plusses = new boolean[MINS][SCREENS];
    for (int r = 0; r < MINS; r++) {
      for (int c = 0; c < SCREENS; c++) {
        visNames[r][c] = " NIL ";
        strokes[r][c] = true;
        dashes[r][c] = true;
        plusses[r][c] = true;
      }
    }
    for (Session session : sessions) {
      Visualisation vis = session.getVis();
      int startTime = session.getStartTime();
      int origEndTime = startTime + vis.getDuration();
      int startScreen = session.getStartScreen();
      int endScreen = session.getEndScreen();
      for (int m = startTime; m < Math.min(origEndTime, MINS); m++) {
        for (int s = startScreen; s <= endScreen; s++) {
          visNames[m][s] = "     ";
        }
      }
      visNames[startTime][startScreen] = vis.toString();
      for (int m = startTime; m < Math.min(origEndTime, MINS); m++) {
        for (int s = startScreen; s <= endScreen - 1; s++) {
          strokes[m][s] = false;
        }
      }
      for (int m = startTime; m < Math.min(origEndTime - 1, MINS); m++) {
        for (int s = startScreen; s <= endScreen; s++) {
          dashes[m][s] = false;
        }
      }
      
      for (int m = startTime; m < Math.min(origEndTime - 1, MINS); m++) {
        for (int s = startScreen; s <= endScreen - 1; s++) {
          plusses[m][s] = false;
        }
      }
    }
    StringBuilder spaces = new StringBuilder("       ");
    StringBuilder dash = new StringBuilder("-------");
    
    StringBuilder disp = new StringBuilder();
    disp.append("Screen:");
    for (int s = 0; s < SCREENS; s++) {
      disp.append("    " + s + "   ");
    }
    disp.append("\n");

    disp.append(spaces + "+");
    for (int s = 0; s < SCREENS; s++) {
      disp.append(dash + "+");
    }
    disp.append(" 0 \n");

    for (int m = 0; m < MINS; m++) {
      disp.append(spaces + "|");
      for (int s = 0; s < SCREENS; s++) {
        disp.append(" " + visNames[m][s] + " ");
        disp.append(strokes[m][s] ? "|" : " ");
      }
      disp.append("\n");

      disp.append(spaces + "+");
      for (int s = 0; s < SCREENS; s++) {
        disp.append(dashes[m][s] ? dash : spaces);
        disp.append(plusses[m][s] ? "+" : " ");
      }
      disp.append(" " + (m + 1) + "\n");
    }
    return disp.toString();
  }

  private class PlayFreq implements Comparable<PlayFreq> {
    Programme prog;
    float whenToPlay;
    
    PlayFreq(Programme prog) {
      this.prog = prog;
      whenToPlay = prog.getPeriod();
    }

    void setNextPlay() {
      whenToPlay += prog.getPeriod();
    }
    
    @Override
    public String toString() {
      return prog.toString() + ": " + whenToPlay;
    }
    
    @Override
    public int compareTo(PlayFreq p) {
      float timeDiff = whenToPlay - p.whenToPlay;
      return (int)Math.signum(Math.abs(timeDiff) < 0.001 ? Math.random() * 2 - 1 : timeDiff);
    }
  }
  
}
