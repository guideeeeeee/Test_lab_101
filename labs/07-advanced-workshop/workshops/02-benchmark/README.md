# Workshop 2: Automated Benchmarking
# Benchmark TLS Performance อัตโนมัติ

**Duration:** 60 minutes  
**Difficulty:** Intermediate-Advanced  
**Language:** Python 3.8+, Bash

---

## 🎯 Objective

Build an automated benchmarking system that:
1. Tests TLS handshake performance (classical vs PQC)
2. Measures throughput and latency
3. Monitors system resources (CPU, memory)
4. Generates comparison reports

---

## 📋 Requirements

```bash
# Python packages
pip install requests matplotlib pandas psutil

# System tools (already installed in labs)
sudo apt install apache2-utils  # ab (Apache Bench)
```

---

## 🏗️ Architecture

```
┌─────────────────────┐
│  Benchmark Script   │
│   benchmark.py      │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼────┐   ┌───▼────┐
│ TLS    │   │ System │
│ Tests  │   │ Monitor│
└───┬────┘   └───┬────┘
    │            │
    │  ┌─────────▼────────┐
    │  │  Data Collector  │
    │  │  (JSON/CSV)      │
    │  └─────────┬────────┘
    │            │
    └────────┬───┘
             │
    ┌────────▼────────┐
    │ Report Builder  │
    │ (Charts, Tables)│
    └─────────────────┘
```

---

## 🚀 Getting Started

### File Structure

```
workshops/02-benchmark/
├── README.md (this file)
├── benchmark.py         # Main script (you create)
├── monitor.py          # System monitoring (starter provided)
├── config.yaml         # Test configurations
├── results/            # Output directory
│   ├── classical/
│   └── pqc/
└── visualize.py        # Chart generation (bonus)
```

---

## 📝 Task 1: TLS Handshake Benchmarking (20 min)

### Goal
Measure TLS handshake time for different cipher suites.

### Implementation

Create `benchmark.py`:

```python
#!/usr/bin/env python3
import time
import ssl
import socket
from typing import Dict, List
import statistics

def benchmark_handshake(host: str, port: int, cipher: str, iterations: int = 100) -> Dict:
    """
    Benchmark TLS handshake time.
    
    Args:
        host: Target hostname
        port: Target port
        cipher: Cipher suite to test
        iterations: Number of handshakes to perform
    
    Returns:
        Statistics dictionary
    """
    handshake_times = []
    
    for i in range(iterations):
        # TODO: Implement handshake timing
        # 1. Create SSL context with specific cipher
        # 2. Measure time to complete handshake
        # 3. Close connection
        # 4. Append time to handshake_times
        
        pass
    
    return {
        "cipher": cipher,
        "iterations": iterations,
        "mean": statistics.mean(handshake_times),
        "median": statistics.median(handshake_times),
        "stdev": statistics.stdev(handshake_times) if len(handshake_times) > 1 else 0,
        "min": min(handshake_times),
        "max": max(handshake_times)
    }

# Test configuration
TESTS = [
    {"name": "Classical RSA", "cipher": "ECDHE-RSA-AES256-GCM-SHA384"},
    {"name": "PQC Hybrid", "cipher": "TLS_AES_256_GCM_SHA384"},  # Adjust for your setup
]

if __name__ == "__main__":
    for test in TESTS:
        print(f"Testing: {test['name']}")
        result = benchmark_handshake("localhost", 8443, test['cipher'])
        print(f"  Mean: {result['mean']:.3f}s")
        print(f"  Median: {result['median']:.3f}s")
        print()
```

### Hints

**Timing handshake:**
```python
context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
context.set_ciphers(cipher)
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

start = time.perf_counter()
with socket.create_connection((host, port)) as sock:
    with context.wrap_socket(sock, server_hostname=host) as ssock:
        pass  # Handshake complete
end = time.perf_counter()

handshake_time = end - start
```

### Expected Output

```
Testing: Classical RSA
  Mean: 0.042s
  Median: 0.040s
  Stdev: 0.008s

Testing: PQC Hybrid
  Mean: 0.125s
  Median: 0.120s
  Stdev: 0.015s
  
Overhead: +197% (PQC vs Classical)
```

---

## 📝 Task 2: Throughput Testing (20 min)

### Goal
Use Apache Bench to measure request throughput.

### Implementation

Create function in `benchmark.py`:

```python
import subprocess
import json

def benchmark_throughput(url: str, requests: int = 1000, concurrency: int = 10) -> Dict:
    """
    Run Apache Bench throughput test.
    
    Args:
        url: Target URL
        requests: Total number of requests
        concurrency: Concurrent connections
    
    Returns:
        Parsed ab results
    """
    cmd = [
        "ab",
        "-n", str(requests),
        "-c", str(concurrency),
        "-g", "plot.tsv",  # Generate gnuplot file
        url
    ]
    
    # TODO: Execute ab command and parse output
    # Hint: subprocess.run(cmd, capture_output=True, text=True)
    
    pass

def parse_ab_output(output: str) -> Dict:
    """
    Parse Apache Bench output text.
    
    Extract:
    - Requests per second
    - Time per request (mean)
    - Transfer rate
    - Success/failure count
    """
    # TODO: Implement regex parsing
    pass
```

### Expected Output

```json
{
  "requests_per_second": 245.32,
  "time_per_request_mean": 40.78,
  "time_per_request_p50": 38.5,
  "time_per_request_p95": 55.2,
  "time_per_request_p99": 68.1,
  "transfer_rate": 1254.6,
  "failed_requests": 0
}
```

---

## 📝 Task 3: System Resource Monitoring (15 min)

### Goal
Track CPU and memory usage during benchmarks.

### Starter Code: `monitor.py`

```python
#!/usr/bin/env python3
import psutil
import time
import json
from threading import Thread

class SystemMonitor:
    """Monitor system resources during benchmark."""
    
    def __init__(self, interval: float = 0.5):
        self.interval = interval
        self.running = False
        self.data = []
    
    def start(self):
        """Start monitoring in background thread."""
        self.running = True
        self.thread = Thread(target=self._monitor)
        self.thread.start()
    
    def stop(self) -> List[Dict]:
        """Stop monitoring and return data."""
        self.running = False
        self.thread.join()
        return self.data
    
    def _monitor(self):
        """Background monitoring loop."""
        while self.running:
            # TODO: Collect CPU, memory, network usage
            snapshot = {
                "timestamp": time.time(),
                "cpu_percent": psutil.cpu_percent(interval=None),
                "memory_percent": psutil.virtual_memory().percent,
                # TODO: Add more metrics
            }
            self.data.append(snapshot)
            time.sleep(self.interval)

# Usage example
if __name__ == "__main__":
    monitor = SystemMonitor()
    monitor.start()
    
    time.sleep(5)  # Simulate work
    
    data = monitor.stop()
    print(json.dumps(data, indent=2))
```

### Integration

```python
# In benchmark.py
from monitor import SystemMonitor

def run_benchmark_with_monitoring(test_func, *args):
    """Run a benchmark while monitoring resources."""
    monitor = SystemMonitor()
    monitor.start()
    
    result = test_func(*args)
    
    resource_data = monitor.stop()
    result["resources"] = {
        "cpu_mean": statistics.mean([d["cpu_percent"] for d in resource_data]),
        "memory_mean": statistics.mean([d["memory_percent"] for d in resource_data]),
    }
    
    return result
```

---

## 📝 Task 4: Automated Comparison (15 min + Bonus)

### Goal
Run classical vs PQC tests and generate comparison report.

### Implementation

```python
def run_full_benchmark():
    """Run complete benchmark suite."""
    results = {
        "timestamp": datetime.now().isoformat(),
        "tests": []
    }
    
    configurations = [
        {
            "name": "Classical TLS",
            "port": 8443,
            "cipher": "ECDHE-RSA-AES256-GCM-SHA384"
        },
        {
            "name": "PQC Hybrid",
            "port": 8444,
            "cipher": "TLS_AES_256_GCM_SHA384"
        }
    ]
    
    for config in configurations:
        print(f"\n{'='*60}")
        print(f"Testing: {config['name']}")
        print(f"{'='*60}\n")
        
        # Test 1: Handshake
        print("1. TLS Handshake...")
        handshake_result = run_benchmark_with_monitoring(
            benchmark_handshake,
            "localhost",
            config["port"],
            config["cipher"]
        )
        
        # Test 2: Throughput
        print("2. Throughput...")
        throughput_result = benchmark_throughput(
            f"https://localhost:{config['port']}/"
        )
        
        results["tests"].append({
            "name": config["name"],
            "handshake": handshake_result,
            "throughput": throughput_result
        })
    
    # Save results
    with open("results/benchmark-results.json", "w") as f:
        json.dump(results, f, indent=2)
    
    return results

# Calculate overhead
def calculate_overhead(classical, pqc):
    """Calculate percentage overhead."""
    return ((pqc - classical) / classical) * 100
```

### Expected Output

```
===========================================================
Benchmark Comparison Report
===========================================================

Handshake Performance:
  Classical:  42.5 ms (±8.2 ms)
  PQC Hybrid: 125.3 ms (±15.1 ms)
  Overhead:   +194.8%

Throughput:
  Classical:  245 req/s
  PQC Hybrid: 87 req/s
  Overhead:   -64.5%

System Resources:
  Classical:  CPU 15%, Memory 2.3%
  PQC Hybrid: CPU 42%, Memory 3.8%
```

---

## 🧪 Testing Your Benchmark Tool

### Test 1: Baseline Classical TLS

```bash
python3 benchmark.py --config classical --iterations 100
```

Expected: Fast handshakes, low CPU usage

### Test 2: PQC Hybrid TLS

```bash
python3 benchmark.py --config pqc --iterations 100
```

Expected: Slower handshakes, higher CPU usage

### Test 3: Stress Test

```bash
python3 benchmark.py --config pqc --iterations 1000 --concurrency 50
```

Expected: Sustained high load, stable measurements

---

## ✅ Success Criteria

Your benchmarking tool should:
- [x] Measure TLS handshake time accurately
- [x] Run Apache Bench throughput tests
- [x] Monitor CPU and memory usage
- [x] Compare classical vs PQC performance
- [x] Save results to JSON/CSV
- [x] Calculate percentage overhead
- [x] Handle errors gracefully (connection failures)

---

## 🎓 Bonus Challenges

### Bonus 1: Visualization

Create `visualize.py`:

```python
import matplotlib.pyplot as plt
import json

def plot_handshake_comparison(results):
    """Plot handshake time comparison."""
    # TODO: Create bar chart comparing classical vs PQC
    pass

def plot_throughput_over_time(results):
    """Plot requests per second over time."""
    # TODO: Line chart showing throughput
    pass
```

### Bonus 2: Percentile Analysis

Calculate and plot latency percentiles (p50, p90, p95, p99):

```python
def calculate_percentiles(data: List[float]) -> Dict:
    import numpy as np
    return {
        "p50": np.percentile(data, 50),
        "p90": np.percentile(data, 90),
        "p95": np.percentile(data, 95),
        "p99": np.percentile(data, 99)
    }
```

### Bonus 3: Configuration File

Create `config.yaml`:

```yaml
benchmarks:
  - name: Classical TLS
    endpoint: https://localhost:8443
    cipher: ECDHE-RSA-AES256-GCM-SHA384
    iterations: 100
    
  - name: PQC Hybrid
    endpoint: https://localhost:8444
    cipher: TLS_AES_256_GCM_SHA384
    iterations: 100

thresholds:
  max_handshake_ms: 200
  min_throughput_rps: 50
  max_cpu_percent: 80
```

---

## 📚 Resources

- [Apache Bench Documentation](https://httpd.apache.org/docs/2.4/programs/ab.html)
- [psutil Documentation](https://psutil.readthedocs.io/)
- [matplotlib Examples](https://matplotlib.org/stable/gallery/index.html)

---

## 🔗 Next Steps

- Review your implementation
- Compare with reference solution (if provided)
- Move to [Workshop 3: Reporting Dashboard](../03-reporting/)

---

<div align="center">

[← Workshop 1](../01-scanner/) | [Back to Lab 07](../../README.md) | [Workshop 3 →](../03-reporting/)

</div>
