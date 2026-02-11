# Data Aggregation Script Documentation
# เอกสารประกอบ Script รวบรวมข้อมูล

**Script:** `aggregate-data.py`  
**Purpose:** Merge data from multiple experiments (Classical vs PQC)  
**Location:** `/home/pqc/pqcv2/scripts/aggregate-data.py` (global)

---

## 📖 Overview

This script collects performance data from Lab 02 (baseline) and Lab 04 (hybrid) and creates a unified JSON for analysis and reporting.

---

## 🚀 Usage

### Basic Usage

```bash
python3 scripts/aggregate-data.py \
  --classical data/classical/ \
  --hybrid data/hybrid/ \
  --output data/aggregated.json
```

### With Custom Metrics

```bash
python3 scripts/aggregate-data.py \
  --classical ../02-baseline-testing/results/ \
  --hybrid ../04-hybrid-testing/results/ \
  --metric handshake,cpu,memory,throughput \
  --format json \
  --output data/full-report.json
```

---

## 📊 Input Data Format

### Expected Directory Structure

```
data/
├── classical/
│   ├── handshake-times.csv
│   ├── cpu-usage.csv
│   ├── memory-usage.csv
│   └── throughput.csv
└── hybrid/
    ├── handshake-times.csv
    ├── cpu-usage.csv
    ├── memory-usage.csv
    └── throughput.csv
```

### CSV Format Example

**handshake-times.csv:**
```csv
timestamp,time_connect_ms,time_appconnect_ms,time_total_ms
2025-01-15T10:00:01,12.3,45.6,58.2
2025-01-15T10:00:02,11.8,44.2,57.1
...
```

**cpu-usage.csv:**
```csv
timestamp,container,cpu_percent
2025-01-15T10:00:01,target-nginx,12.5
2025-01-15T10:00:02,target-nginx,23.4
...
```

---

## 📈 Output Format

### JSON Schema

```json
{
  "metadata": {
    "timestamp": "2025-01-15T14:30:00Z",
    "test_duration_minutes": 30,
    "data_sources": {
      "classical": "/path/to/classical/",
      "hybrid": "/path/to/hybrid/"
    }
  },
  
  "classical": {
    "handshake": {
      "count": 20,
      "mean_ms": 12.34,
      "median_ms": 12.10,
      "std_ms": 2.15,
      "min_ms": 9.80,
      "max_ms": 18.20,
      "p95_ms": 15.60,
      "p99_ms": 17.50
    },
    "cpu": {
      "idle_percent": 2.5,
      "load_mean_percent": 23.4,
      "load_peak_percent": 45.2
    },
    "memory": {
      "idle_mb": 145.2,
      "load_mean_mb": 178.5,
      "load_peak_mb": 235.8
    },
    "throughput": {
      "low_load_rps": 1234,
      "medium_load_rps": 2341,
      "high_load_rps": 3456
    },
    "certificate": {
      "size_bytes": 1220,
      "rsa_key_bits": 2048,
      "ecdhe_curve": "P-256"
    }
  },
  
  "hybrid": {
    "handshake": {
      "count": 20,
      "mean_ms": 35.42,
      "median_ms": 34.80,
      ...
    },
    ...
  },
  
  "comparison": {
    "handshake_overhead_ms": 23.08,
    "handshake_overhead_percent": 186.9,
    "cpu_overhead_percent": 15.3,
    "memory_overhead_percent": 18.7,
    "throughput_degradation_percent": -12.4,
    "certificate_size_increase_bytes": 3200,
    "certificate_size_increase_percent": 262.3
  },
  
  "interpretation": {
    "handshake": "Significant overhead (>100%)",
    "cpu": "Acceptable overhead (<20%)",
    "memory": "Acceptable overhead (<20%)",
    "throughput": "Moderate degradation (10-15%)",
    "overall": "Migration feasible with optimization"
  }
}
```

---

## ⚙️ Advanced Options

### Filtering Outliers

```bash
# Remove outliers beyond 2 standard deviations
python3 scripts/aggregate-data.py \
  --classical data/classical/ \
  --hybrid data/hybrid/ \
  --remove-outliers 2.0 \
  --output data/cleaned.json
```

### Specific Time Range

```bash
# Only analyze data from specific period
python3 scripts/aggregate-data.py \
  --classical data/classical/ \
  --hybrid data/hybrid/ \
  --start "2025-01-15T10:00:00" \
  --end "2025-01-15T11:00:00" \
  --output data/hourly.json
```

### Custom Percentiles

```bash
# Calculate custom percentiles (default: 50, 95, 99)
python3 scripts/aggregate-data.py \
  --classical data/classical/ \
  --hybrid data/hybrid/ \
  --percentiles 50,75,90,95,99 \
  --output data/detailed.json
```

---

## 🧪 Example Workflow

### Step 1: Collect Data

```bash
# Ensure Labs 02 and 04 results exist
ls ../02-baseline-testing/results/
ls ../04-hybrid-testing/results/
```

### Step 2: Run Aggregation

```bash
python3 ../../scripts/aggregate-data.py \
  --classical ../02-baseline-testing/results/ \
  --hybrid ../04-hybrid-testing/results/ \
  --output data/aggregated.json \
  --format json \
  --verbose
```

### Step 3: Verify Output

```bash
# Check JSON structure
cat data/aggregated.json | jq '.comparison'

# Should output:
# {
#   "handshake_overhead_ms": 23.08,
#   "handshake_overhead_percent": 186.9,
#   ...
# }
```

### Step 4: Use in Visualization

```bash
# Pass aggregated data to chart generator
python3 ../../scripts/generate-charts.py data/aggregated.json
```

---

## 🐛 Troubleshooting

### Error: "File not found"

```bash
# Check if paths are correct
ls -la ../02-baseline-testing/results/
ls -la ../04-hybrid-testing/results/

# Use absolute paths if needed
python3 scripts/aggregate-data.py \
  --classical ~/pqcv2/labs/02-baseline-testing/results/ \
  --hybrid ~/pqcv2/labs/04-hybrid-testing/results/ \
  --output data/aggregated.json
```

### Error: "No data in CSV"

```bash
# Check if CSV files have content
wc -l ../02-baseline-testing/results/*.csv

# Verify CSV format
head ../02-baseline-testing/results/handshake-times.csv
```

### Error: "Invalid JSON output"

```bash
# Validate JSON
cat data/aggregated.json | jq .

# If error, regenerate with verbose mode
python3 scripts/aggregate-data.py \
  --classical data/classical/ \
  --hybrid data/hybrid/ \
  --output data/aggregated.json \
  --verbose
```

---

## 📚 Related Scripts

- **calculate-stats.py** - Statistical calculations (mean, std, percentiles)
- **generate-charts.py** - Create visualizations from aggregated data
- **create-dashboard.py** - Interactive HTML dashboard

---

## 💡 Tips

1. **Always verify input data exists** before running aggregation
2. **Use `--verbose`** to see progress and debug issues
3. **Check output JSON** with `jq` for correctness
4. **Keep raw data** - aggregated.json can be regenerated
5. **Run multiple times** with different options to compare

---

<div align="center">

[← Back to Lab 05](../README.md) | [View Script Source](../../../scripts/aggregate-data.py)

</div>
