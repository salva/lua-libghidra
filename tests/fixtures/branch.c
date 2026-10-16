/* MIT Copyright 2026 Salvador Fandiño. Authored nontrivial CFG fixture. */
volatile int m3_branch_sink;
__attribute__((noinline)) int m3_branch(int x) {
    if (x > 5) m3_branch_sink = x + 7;
    else m3_branch_sink = x - 3;
    return m3_branch_sink;
}
int main(void) { return m3_branch(8) != 15; }
