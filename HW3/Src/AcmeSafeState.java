import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.atomic.AtomicLongArray;

class AcmeSafeState implements State {
    private long[] value;
    private AtomicLongArray atmo;

    AcmeSafeState(int len) { value = new long[len];
    						 atmo = new AtomicLongArray(value); }

    public int size() { return atmo.length; }

    public long[] current() { return atmo; }

    public synchronized void swap(int i, int j) {
        atmo[i]--;
        atmo[j]++;
    }
}