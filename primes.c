// multiply a and b
int mul(int a, int b) {
  int result = 0;
  while(b-- > 0) {
    result += a;
  }
  return result;
}

// find largest prime less than n
int largest_prime(unsigned int n) {
  // initialize array of n numbers
  int primes[n];
  int i;
  for(i=2; i<n; i++) {
    primes[i] = i;
  }
  // filter non-prime numbers
  int p = 2;
  for(p=2; mul(p,p)<n; p++) {
    if(primes[p] != 0) {
      i = 2;
      while(1) {
        int idx = mul(i,p);
        if(idx>=n) {
          break;
        }
        primes[idx] = 0;
        i++;
      }
    }
  }
  // extract largest prime
  for(i=n-1; i>=2; i--) {
    if(primes[i]) {
      return i;
    }
  }
  // should only happen if n<=2
  return 0;
}

int main() {
  largest_prime(28);
  return 0;
}
