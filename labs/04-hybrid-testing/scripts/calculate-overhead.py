#!/usr/bin/env python3
"""
Calculate Performance Overhead (Percentage Difference)
Compares baseline vs treatment to calculate overhead
คำนวณ overhead ระหว่าง classical TLS กับ PQC hybrid
"""

import json
import argparse
import sys
from typing import Dict, Any

def calculate_overhead(baseline: float, treatment: float) -> Dict[str, float]:
    """
    Calculate overhead metrics
    
    Args:
        baseline: Baseline value (e.g., classical TLS performance)
        treatment: Treatment value (e.g., PQC hybrid performance)
    
    Returns:
        Dictionary with absolute difference, percentage, and interpretation
    """
    if baseline == 0:
        return {
            "baseline": baseline,
            "treatment": treatment,
            "absolute_diff": treatment,
            "percent_diff": float('inf') if treatment != 0 else 0,
            "interpretation": "Cannot calculate (baseline is zero)"
        }
    
    abs_diff = treatment - baseline
    pct_diff = (abs_diff / baseline) * 100
    
    # Interpretation
    if abs_diff > 0:
        if pct_diff < 10:
            interp = "Negligible degradation (<10%)"
        elif pct_diff < 25:
            interp = "Acceptable degradation (10-25%)"
        elif pct_diff < 50:
            interp = "Moderate degradation (25-50%)"
        else:
            interp = "Significant degradation (>50%)"
    elif abs_diff < 0:
        interp = f"Improvement ({abs(pct_diff):.1f}% faster)"
    else:
        interp = "No difference"
    
    return {
        "baseline": baseline,
        "treatment": treatment,
        "absolute_diff": abs_diff,
        "percent_diff": pct_diff,
        "interpretation": interp
    }


def load_summary_file(filepath: str) -> Dict[str, Any]:
    """
    Load aggregated summary JSON (output from aggregate-data.py)
    """
    with open(filepath, 'r') as f:
        return json.load(f)


def extract_metrics_from_summary(data: Dict, metric_path: str):
    """
    Extract specific metric from nested summary structure
    
    metric_path example: "handshake_test.time_connect.baseline.mean"
    """
    keys = metric_path.split('.')
    current = data
    
    try:
        for key in keys:
            current = current[key]
        return current
    except (KeyError, TypeError):
        return None


def main():
    parser = argparse.ArgumentParser(
        description='Calculate performance overhead percentage'
    )
    
    parser.add_argument(
        '--baseline', '-b',
        type=float,
        help='Baseline value (e.g., classical TLS mean time)'
    )
    
    parser.add_argument(
        '--treatment', '-t',
        type=float,
        help='Treatment value (e.g., PQC hybrid mean time)'
    )
    
    parser.add_argument(
        '--summary', '-s',
        help='Aggregated summary JSON file (output from aggregate-data.py)'
    )
    
    parser.add_argument(
        '--metric', '-m',
        help='Metric to compare (e.g., handshake_time_ms, cpu_percent)'
    )
    
    parser.add_argument(
        '--all-metrics', '-a',
        action='store_true',
        help='Calculate overhead for all common metrics'
    )
    
    parser.add_argument(
        '--format', '-f',
        choices=['text', 'json'],
        default='text',
        help='Output format'
    )
    
    args = parser.parse_args()
    
    try:
        results = []
        
        if args.baseline is not None and args.treatment is not None:
            # Simple mode: direct values
            result = calculate_overhead(args.baseline, args.treatment)
            results.append({
                "metric": "custom",
                **result
            })
        
        elif args.summary:
            # Summary mode: load from aggregated file
            data = load_summary_file(args.summary)
            
            if args.all_metrics:
                # Calculate for common metrics
                common_metrics = [
                    'handshake_time_ms',
                    'request_time_ms',
                    'throughput_mbps',
                    'cpu_percent',
                    'memory_mb'
                ]
                
                for metric in common_metrics:
                    # Try to find metric in summary
                    baseline_val = None
                    treatment_val = None
                    
                    # Search in metrics dict
                    if 'metrics' in data:
                        for test_name, test_data in data['metrics'].items():
                            if metric in test_data:
                                m = test_data[metric]
                                if 'baseline' in m and isinstance(m['baseline'], dict):
                                    baseline_val = m['baseline'].get('mean')
                                if 'hybrid' in m and isinstance(m['hybrid'], dict):
                                    treatment_val = m['hybrid'].get('mean')
                                break
                    
                    if baseline_val is not None and treatment_val is not None:
                        result = calculate_overhead(baseline_val, treatment_val)
                        results.append({
                            "metric": metric,
                            **result
                        })
            
            elif args.metric:
                # Specific metric from summary
                # Simplified path: metrics.*.{metric}.baseline.mean
                baseline_val = None
                treatment_val = None
                
                if 'metrics' in data:
                    for test_name, test_data in data['metrics'].items():
                        if args.metric in test_data:
                            m = test_data[args.metric]
                            if 'baseline' in m and isinstance(m['baseline'], dict):
                                baseline_val = m['baseline'].get('mean')
                            if 'hybrid' in m and isinstance(m['hybrid'], dict):
                                treatment_val = m['hybrid'].get('mean')
                            break
                
                if baseline_val is not None and treatment_val is not None:
                    result = calculate_overhead(baseline_val, treatment_val)
                    results.append({
                        "metric": args.metric,
                        **result
                    })
                else:
                    print(f"ERROR: Could not find metric '{args.metric}' in summary", file=sys.stderr)
                    sys.exit(1)
        
        else:
            parser.print_help()
            print("\nERROR: Must provide either --baseline + --treatment, or --summary + --metric", file=sys.stderr)
            sys.exit(1)
        
        # Output
        if args.format == 'json':
            output = {
                "overhead_analysis": results
            }
            print(json.dumps(output, indent=2))
        
        else:  # text
            print("=" * 70)
            print("PERFORMANCE OVERHEAD ANALYSIS")
            print("=" * 70)
            print()
            
            for r in results:
                print(f"Metric: {r['metric']}")
                print(f"  Baseline (Classical TLS):  {r['baseline']:.3f}")
                print(f"  Treatment (PQC Hybrid):    {r['treatment']:.3f}")
                print(f"  Absolute Difference:       {r['absolute_diff']:+.3f}")
                print(f"  Percentage Difference:     {r['percent_diff']:+.2f}%")
                print(f"  Assessment:                {r['interpretation']}")
                print()
            
            print("=" * 70)
            print("INTERPRETATION GUIDE:")
            print("=" * 70)
            print("  < 10%     Negligible overhead (excellent)")
            print("  10-25%    Acceptable overhead (good)")
            print("  25-50%    Moderate overhead (review use case)")
            print("  > 50%     Significant overhead (optimization needed)")
            print("=" * 70)
    
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
