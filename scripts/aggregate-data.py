#!/usr/bin/env python3
"""
Aggregate Performance Data from Multiple Tests
Combines JSON files from baseline and hybrid tests
รวบรวมข้อมูล performance จากการทดสอบหลายครั้ง
"""

import json
import os
import glob
import argparse
from typing import Dict, List, Any
from datetime import datetime
import sys

def load_json_files(pattern: str) -> List[Dict]:
    """
    Load all JSON files matching glob pattern
    
    Args:
        pattern: Glob pattern (e.g., "results/*.json")
    
    Returns:
        List of loaded JSON objects
    """
    files = glob.glob(pattern)
    
    if not files:
        print(f"WARNING: No files found matching pattern: {pattern}", file=sys.stderr)
        return []
    
    data = []
    for filepath in files:
        try:
            with open(filepath, 'r') as f:
                obj = json.load(f)
                obj['_source_file'] = os.path.basename(filepath)
                data.append(obj)
        except Exception as e:
            print(f"ERROR loading {filepath}: {e}", file=sys.stderr)
    
    print(f"✓ Loaded {len(data)} files from pattern: {pattern}", file=sys.stderr)
    return data


def aggregate_by_metric(data: List[Dict], metric_key: str) -> Dict[str, List[float]]:
    """
    Group data by test name and extract specific metric
    
    Args:
        data: List of test results
        metric_key: Key to extract (e.g., "handshake_time_ms")
    
    Returns:
        Dictionary mapping test name to list of values
    """
    aggregated = {}
    
    for entry in data:
        test_name = entry.get('test_name', 'unknown')
        
        if metric_key in entry:
            if test_name not in aggregated:
                aggregated[test_name] = []
            
            value = entry[metric_key]
            if isinstance(value, (int, float)):
                aggregated[test_name].append(float(value))
    
    return aggregated


def merge_baseline_and_hybrid(baseline_dir: str, hybrid_dir: str) -> Dict[str, Any]:
    """
    Merge baseline and hybrid test results
    
    Args:
        baseline_dir: Directory with baseline (classical TLS) results
        hybrid_dir: Directory with hybrid (PQC) results
    
    Returns:
        Merged data structure with both datasets
    """
    baseline_files = os.path.join(baseline_dir, "*.json")
    hybrid_files = os.path.join(hybrid_dir, "*.json")
    
    baseline_data = load_json_files(baseline_files)
    hybrid_data = load_json_files(hybrid_files)
    
    return {
        "metadata": {
            "aggregation_time": datetime.now().isoformat(),
            "baseline_tests": len(baseline_data),
            "hybrid_tests": len(hybrid_data),
        },
        "baseline": baseline_data,
        "hybrid": hybrid_data,
    }


def extract_metrics(data: Dict[str, Any], metrics: List[str]) -> Dict[str, Dict[str, List[float]]]:
    """
    Extract multiple metrics from aggregated data
    
    Args:
        data: Merged baseline + hybrid data
        metrics: List of metric keys to extract
    
    Returns:
        Nested dict: {baseline: {metric: [values]}, hybrid: {metric: [values]}}
    """
    result = {
        "baseline": {},
        "hybrid": {},
    }
    
    for metric in metrics:
        # Baseline
        baseline_values = []
        for entry in data.get("baseline", []):
            if metric in entry:
                baseline_values.append(entry[metric])
        
        if baseline_values:
            result["baseline"][metric] = baseline_values
        
        # Hybrid
        hybrid_values = []
        for entry in data.get("hybrid", []):
            if metric in entry:
                hybrid_values.append(entry[metric])
        
        if hybrid_values:
            result["hybrid"][metric] = hybrid_values
    
    return result


def create_summary(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Create summary statistics for aggregated data
    """
    import statistics
    
    summary = {
        "metadata": data.get("metadata", {}),
        "metrics": {}
    }
    
    for test_type in ["baseline", "hybrid"]:
        if test_type not in data:
            continue
        
        for test in data[test_type]:
            test_name = test.get("test_name", "unknown")
            
            if test_name not in summary["metrics"]:
                summary["metrics"][test_name] = {}
            
            # Extract numeric metrics
            for key, value in test.items():
                if isinstance(value, (int, float)) and not key.startswith("_"):
                    if key not in summary["metrics"][test_name]:
                        summary["metrics"][test_name][key] = {
                            "baseline": [],
                            "hybrid": []
                        }
                    
                    summary["metrics"][test_name][key][test_type].append(value)
    
    # Calculate statistics
    for test_name in summary["metrics"]:
        for metric in summary["metrics"][test_name]:
            for test_type in ["baseline", "hybrid"]:
                values = summary["metrics"][test_name][metric][test_type]
                
                if values:
                    summary["metrics"][test_name][metric][test_type] = {
                        "count": len(values),
                        "mean": statistics.mean(values),
                        "median": statistics.median(values),
                        "min": min(values),
                        "max": max(values),
                        "stdev": statistics.stdev(values) if len(values) > 1 else 0,
                        "raw_values": values
                    }
    
    return summary


def main():
    parser = argparse.ArgumentParser(
        description='Aggregate performance data from multiple test runs'
    )
    
    parser.add_argument(
        '--baseline', '-b',
        required=True,
        help='Directory containing baseline (classical TLS) test results'
    )
    
    parser.add_argument(
        '--hybrid', '-y',
        required=True,
        help='Directory containing hybrid (PQC) test results'
    )
    
    parser.add_argument(
        '--output', '-o',
        required=True,
        help='Output file for aggregated data (JSON)'
    )
    
    parser.add_argument(
        '--metrics', '-m',
        nargs='+',
        default=['handshake_time_ms', 'request_time_ms', 'throughput_mbps', 
                 'cpu_percent', 'memory_mb'],
        help='Metrics to extract (default: handshake, request time, throughput, CPU, memory)'
    )
    
    parser.add_argument(
        '--summary', '-s',
        action='store_true',
        help='Create summary statistics instead of raw aggregation'
    )
    
    args = parser.parse_args()
    
    try:
        # Validate directories
        if not os.path.isdir(args.baseline):
            print(f"ERROR: Baseline directory not found: {args.baseline}", file=sys.stderr)
            sys.exit(1)
        
        if not os.path.isdir(args.hybrid):
            print(f"ERROR: Hybrid directory not found: {args.hybrid}", file=sys.stderr)
            sys.exit(1)
        
        # Merge data
        print("Aggregating data...", file=sys.stderr)
        merged = merge_baseline_and_hybrid(args.baseline, args.hybrid)
        
        # Create output
        if args.summary:
            output_data = create_summary(merged)
            print("✓ Created summary statistics", file=sys.stderr)
        else:
            output_data = merged
            print("✓ Merged raw data", file=sys.stderr)
        
        # Write output
        with open(args.output, 'w') as f:
            json.dump(output_data, f, indent=2)
        
        print(f"✓ Aggregated data written to: {args.output}", file=sys.stderr)
        
        # Print summary
        baseline_count = len(merged.get("baseline", []))
        hybrid_count = len(merged.get("hybrid", []))
        
        print("", file=sys.stderr)
        print("=" * 50, file=sys.stderr)
        print("AGGREGATION SUMMARY", file=sys.stderr)
        print("=" * 50, file=sys.stderr)
        print(f"Baseline tests:  {baseline_count}", file=sys.stderr)
        print(f"Hybrid tests:    {hybrid_count}", file=sys.stderr)
        print(f"Total tests:     {baseline_count + hybrid_count}", file=sys.stderr)
        print(f"Metrics:         {', '.join(args.metrics)}", file=sys.stderr)
        print(f"Output file:     {args.output}", file=sys.stderr)
        print("=" * 50, file=sys.stderr)
        
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
