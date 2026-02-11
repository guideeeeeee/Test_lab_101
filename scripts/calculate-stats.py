#!/usr/bin/env python3
"""
Statistical Calculator for Performance Testing
Calculates mean, median, std dev, min/max, percentiles
สคริปต์คำนวณสถิติสำหรับผล performance testing
"""

import sys
import json
import statistics
from typing import List, Dict, Any

def calculate_stats(data: List[float]) -> Dict[str, float]:
    """
    Calculate comprehensive statistics for a dataset
    
    Args:
        data: List of numeric values (e.g., latencies in ms)
    
    Returns:
        Dictionary with statistical measures
    """
    if not data:
        raise ValueError("Empty dataset")
    
    sorted_data = sorted(data)
    n = len(sorted_data)
    
    return {
        # Basic statistics
        "count": n,
        "min": min(sorted_data),
        "max": max(sorted_data),
        "mean": statistics.mean(sorted_data),
        "median": statistics.median(sorted_data),
        
        # Dispersion measures
        "stdev": statistics.stdev(sorted_data) if n > 1 else 0.0,
        "variance": statistics.variance(sorted_data) if n > 1 else 0.0,
        
        # Percentiles
        "p50": percentile(sorted_data, 50),
        "p90": percentile(sorted_data, 90),
        "p95": percentile(sorted_data, 95),
        "p99": percentile(sorted_data, 99),
        
        # Range
        "range": max(sorted_data) - min(sorted_data),
        
        # Coefficient of variation (normalized std dev)
        "cv": (statistics.stdev(sorted_data) / statistics.mean(sorted_data) * 100) if statistics.mean(sorted_data) != 0 else 0.0
    }


def percentile(sorted_data: List[float], p: float) -> float:
    """
    Calculate percentile using linear interpolation
    
    Args:
        sorted_data: Sorted list of values
        p: Percentile (0-100)
    
    Returns:
        Value at given percentile
    """
    if not 0 <= p <= 100:
        raise ValueError("Percentile must be between 0 and 100")
    
    n = len(sorted_data)
    if n == 0:
        raise ValueError("Empty dataset")
    
    if n == 1:
        return sorted_data[0]
    
    # Linear interpolation method
    rank = (p / 100) * (n - 1)
    lower = int(rank)
    upper = lower + 1
    
    if upper >= n:
        return sorted_data[-1]
    
    weight = rank - lower
    return sorted_data[lower] * (1 - weight) + sorted_data[upper] * weight


def compare_datasets(baseline: List[float], treatment: List[float]) -> Dict[str, Any]:
    """
    Compare two datasets and calculate differences
    
    Args:
        baseline: Baseline measurements (e.g., classical TLS)
        treatment: Treatment measurements (e.g., PQC hybrid)
    
    Returns:
        Dictionary with comparison metrics
    """
    baseline_stats = calculate_stats(baseline)
    treatment_stats = calculate_stats(treatment)
    
    def percent_change(old, new):
        if old == 0:
            return float('inf') if new != 0 else 0.0
        return ((new - old) / old) * 100
    
    return {
        "baseline": baseline_stats,
        "treatment": treatment_stats,
        "comparison": {
            "mean_diff": treatment_stats["mean"] - baseline_stats["mean"],
            "mean_diff_pct": percent_change(baseline_stats["mean"], treatment_stats["mean"]),
            
            "median_diff": treatment_stats["median"] - baseline_stats["median"],
            "median_diff_pct": percent_change(baseline_stats["median"], treatment_stats["median"]),
            
            "p95_diff": treatment_stats["p95"] - baseline_stats["p95"],
            "p95_diff_pct": percent_change(baseline_stats["p95"], treatment_stats["p95"]),
            
            "p99_diff": treatment_stats["p99"] - baseline_stats["p99"],
            "p99_diff_pct": percent_change(baseline_stats["p99"], treatment_stats["p99"]),
        }
    }


def parse_apache_bench_output(output: str) -> List[float]:
    """
    Parse Apache Bench output to extract request times
    
    Example output line:
    Time per request:       15.234 [ms] (mean)
    """
    times = []
    for line in output.split('\n'):
        if 'Time per request:' in line and 'mean' in line:
            # Extract number between ':' and '[ms]'
            parts = line.split(':')[1].split('[ms]')
            time_ms = float(parts[0].strip())
            times.append(time_ms)
    return times


def parse_curl_timing(output: str) -> List[float]:
    """
    Parse curl timing output (-w format)
    
    Expected format:
    time_total: 0.156
    """
    times = []
    for line in output.split('\n'):
        if line.startswith('time_total:') or 'time_total' in line:
            parts = line.split(':')
            if len(parts) >= 2:
                time_s = float(parts[1].strip())
                times.append(time_s * 1000)  # Convert to ms
    return times


def format_report(stats: Dict[str, float], title: str = "Statistics Report") -> str:
    """
    Format statistics as readable text report
    """
    lines = [
        "=" * 60,
        title.center(60),
        "=" * 60,
        "",
        f"Sample Count:       {stats['count']:>10}",
        f"Min:                {stats['min']:>10.3f} ms",
        f"Max:                {stats['max']:>10.3f} ms",
        f"Mean:               {stats['mean']:>10.3f} ms",
        f"Median:             {stats['median']:>10.3f} ms",
        f"Std Dev:            {stats['stdev']:>10.3f} ms",
        f"Variance:           {stats['variance']:>10.3f} ms²",
        f"Range:              {stats['range']:>10.3f} ms",
        f"CV (Coef. Var):     {stats['cv']:>10.2f} %",
        "",
        "Percentiles:",
        f"  P50 (median):     {stats['p50']:>10.3f} ms",
        f"  P90:              {stats['p90']:>10.3f} ms",
        f"  P95:              {stats['p95']:>10.3f} ms",
        f"  P99:              {stats['p99']:>10.3f} ms",
        "=" * 60,
    ]
    return "\n".join(lines)


def format_comparison(comparison: Dict[str, Any]) -> str:
    """
    Format comparison report
    """
    baseline = comparison['baseline']
    treatment = comparison['treatment']
    comp = comparison['comparison']
    
    lines = [
        "=" * 70,
        "PERFORMANCE COMPARISON".center(70),
        "=" * 70,
        "",
        "BASELINE (Classical TLS):".ljust(30) + "TREATMENT (PQC Hybrid):".ljust(30),
        "-" * 70,
        f"Mean:     {baseline['mean']:>10.3f} ms".ljust(35) + f"Mean:     {treatment['mean']:>10.3f} ms",
        f"Median:   {baseline['median']:>10.3f} ms".ljust(35) + f"Median:   {treatment['median']:>10.3f} ms",
        f"P95:      {baseline['p95']:>10.3f} ms".ljust(35) + f"P95:      {treatment['p95']:>10.3f} ms",
        f"P99:      {baseline['p99']:>10.3f} ms".ljust(35) + f"P99:      {treatment['p99']:>10.3f} ms",
        f"Std Dev:  {baseline['stdev']:>10.3f} ms".ljust(35) + f"Std Dev:  {treatment['stdev']:>10.3f} ms",
        "",
        "=" * 70,
        "DIFFERENCES (Treatment - Baseline):".center(70),
        "=" * 70,
        "",
        f"Mean difference:       {comp['mean_diff']:>10.3f} ms  ({comp['mean_diff_pct']:>+6.2f}%)",
        f"Median difference:     {comp['median_diff']:>10.3f} ms  ({comp['median_diff_pct']:>+6.2f}%)",
        f"P95 difference:        {comp['p95_diff']:>10.3f} ms  ({comp['p95_diff_pct']:>+6.2f}%)",
        f"P99 difference:        {comp['p99_diff']:>10.3f} ms  ({comp['p99_diff_pct']:>+6.2f}%)",
        "",
        "=" * 70,
    ]
    return "\n".join(lines)


def main():
    """
    CLI interface for statistical calculator
    
    Usage examples:
        # Calculate stats from JSON file
        python3 calculate-stats.py --input data.json --metric handshake_time
        
        # Compare two datasets
        python3 calculate-stats.py --compare baseline.json hybrid.json --metric latency
        
        # Read from stdin (pipe)
        cat measurements.txt | python3 calculate-stats.py --stdin
    """
    import argparse
    
    parser = argparse.ArgumentParser(description='Calculate statistics for performance testing')
    parser.add_argument('--input', '-i', help='Input JSON file with measurements')
    parser.add_argument('--compare', '-c', nargs=2, metavar=('BASELINE', 'TREATMENT'),
                       help='Compare two datasets (baseline vs treatment)')
    parser.add_argument('--metric', '-m', default='value',
                       help='Metric name to extract from JSON (default: value)')
    parser.add_argument('--output', '-o', help='Output file (default: stdout)')
    parser.add_argument('--format', choices=['text', 'json'], default='text',
                       help='Output format')
    parser.add_argument('--stdin', action='store_true',
                       help='Read newline-separated values from stdin')
    
    args = parser.parse_args()
    
    try:
        if args.stdin:
            # Read values from stdin
            data = [float(line.strip()) for line in sys.stdin if line.strip()]
            stats = calculate_stats(data)
            
            if args.format == 'json':
                output = json.dumps(stats, indent=2)
            else:
                output = format_report(stats)
        
        elif args.compare:
            # Compare two datasets
            with open(args.compare[0], 'r') as f:
                baseline_json = json.load(f)
            
            with open(args.compare[1], 'r') as f:
                treatment_json = json.load(f)
            
            # Extract metric
            baseline_data = [item[args.metric] for item in baseline_json if args.metric in item]
            treatment_data = [item[args.metric] for item in treatment_json if args.metric in item]
            
            comparison = compare_datasets(baseline_data, treatment_data)
            
            if args.format == 'json':
                output = json.dumps(comparison, indent=2)
            else:
                output = format_comparison(comparison)
        
        elif args.input:
            # Single dataset
            with open(args.input, 'r') as f:
                data_json = json.load(f)
            
            # Extract metric
            if isinstance(data_json, list):
                data = [item[args.metric] for item in data_json if args.metric in item]
            elif isinstance(data_json, dict) and args.metric in data_json:
                data = data_json[args.metric]
            else:
                raise ValueError(f"Cannot find metric '{args.metric}' in JSON")
            
            stats = calculate_stats(data)
            
            if args.format == 'json':
                output = json.dumps(stats, indent=2)
            else:
                output = format_report(stats)
        
        else:
            parser.print_help()
            return
        
        # Write output
        if args.output:
            with open(args.output, 'w') as f:
                f.write(output)
            print(f"✓ Output written to {args.output}")
        else:
            print(output)
    
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
