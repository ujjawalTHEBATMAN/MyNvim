import java.util.*;
import java.io.*;

public class $(FNOEXT) {
    static BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    static PrintWriter out = new PrintWriter(new BufferedOutputStream(System.out));
    static StringTokenizer st;

    public static void main(String[] args) throws IOException {
        int t = 1;
        // t = nextInt(); // Uncomment for multiple test cases
        
        while (t-- > 0) {
            solve();
        }
        
        out.flush();
        out.close();
    }

    static void solve() throws IOException {
        // Your solution here
        
    }

    // ============== FAST I/O ==============
    static String next() throws IOException {
        while (st == null || !st.hasMoreTokens())
            st = new StringTokenizer(br.readLine());
        return st.nextToken();
    }

    static int nextInt() throws IOException {
        return Integer.parseInt(next());
    }

    static long nextLong() throws IOException {
        return Long.parseLong(next());
    }

    static double nextDouble() throws IOException {
        return Double.parseDouble(next());
    }

    static String nextLine() throws IOException {
        return br.readLine();
    }

    static int[] nextIntArray(int n) throws IOException {
        int[] arr = new int[n];
        for (int i = 0; i < n; i++) arr[i] = nextInt();
        return arr;
    }

    static long[] nextLongArray(int n) throws IOException {
        long[] arr = new long[n];
        for (int i = 0; i < n; i++) arr[i] = nextLong();
        return arr;
    }

    // ============== UTILITY ==============
    static void print(Object... args) {
        for (Object o : args) out.print(o + " ");
        out.println();
    }

    static void debug(Object... args) {
        System.err.print("DEBUG: ");
        for (Object o : args) System.err.print(o + " ");
        System.err.println();
    }

    static long gcd(long a, long b) {
        return b == 0 ? a : gcd(b, a % b);
    }

    static long lcm(long a, long b) {
        return a / gcd(a, b) * b;
    }

    static long mod = 1_000_000_007L;

    static long power(long x, long y, long m) {
        long res = 1;
        x %= m;
        while (y > 0) {
            if ((y & 1) == 1) res = res * x % m;
            y >>= 1;
            x = x * x % m;
        }
        return res;
    }
}
