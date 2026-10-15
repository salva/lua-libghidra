/* MIT Copyright 2026 Salvador Fandiño. Dependency smoke, not M0 fixture suite. */
__attribute__((noinline)) int native_smoke(int x) { return x * 3 + 7; }
int main(void) { return native_smoke(4) != 19; }
volatile int authored_value = 23;
__attribute__((noinline)) int read_authored_value(void) { return authored_value + 5; }
