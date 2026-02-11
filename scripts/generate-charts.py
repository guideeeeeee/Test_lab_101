#!/usr/bin/env python3
"""
Generate Performance Comparison Charts
Creates visualizations from aggregated test data
สร้างกราฟเปรียบเทียบ performance ระหว่าง Classical TLS และ PQC Hybrid
"""

import json
import argparse
import sys
from typing import Dict, List, Any

try:
    import matplotlib
    matplotlib.use('Agg')  # Use non-interactive backend
    import matplotlib.pyplot as plt
    import numpy as np
except ImportError:
    print("ERROR: matplotlib not installed. Run: pip install matplotlib", file=sys.stderr)
    sys.exit(1)

# Set style
plt.style.use('seaborn-v0_8-darkgrid')
COLORS = {
    'baseline': '#2E86AB',  # Blue
    'hybrid': '#A23B72',    # Purple
    'improvement': '#06A77D', # Green
    'degradation': '#D62828'  # Red
}

def load_aggregated_data(filepath: str) -> Dict[str, Any]:
    """Load aggregated JSON data"""
    with open(filepath, 'r') as f:
        return json.load(f)


def extract_metric_comparison(data: Dict, metric: str) -> Dict[str, List[float]]:
    """
    Extract baseline vs hybrid values for a specific metric
    
    Returns:
        {"baseline": [values], "hybrid": [values]}
    """
    result = {"baseline": [], "hybrid": []}
    
    # Handle summary format
    if "metrics" in data:
        for test_name in data["metrics"]:
            if metric in data["metrics"][test_name]:
                metric_data = data["metrics"][test_name][metric]
                
                if "baseline" in metric_data and isinstance(metric_data["baseline"], dict):
                    result["baseline"] = metric_data["baseline"].get("raw_values", [])
                
                if "hybrid" in metric_data and isinstance(metric_data["hybrid"], dict):
                    result["hybrid"] = metric_data["hybrid"].get("raw_values", [])
    
    # Handle raw format
    elif "baseline" in data and "hybrid" in data:
        for entry in data["baseline"]:
            if metric in entry:
                result["baseline"].append(entry[metric])
        
        for entry in data["hybrid"]:
            if metric in entry:
                result["hybrid"].append(entry[metric])
    
    return result


def create_comparison_bar_chart(data: Dict, metric: str, output: str, 
                                 title: str = None, ylabel: str = None):
    """
    Create bar chart comparing baseline vs hybrid
    
    Args:
        data: Aggregated data
        metric: Metric key to plot
        output: Output filename
        title: Chart title (optional)
        ylabel: Y-axis label (optional)
    """
    values = extract_metric_comparison(data, metric)
    
    if not values["baseline"] or not values["hybrid"]:
        print(f"WARNING: No data for metric '{metric}'", file=sys.stderr)
        return
    
    # Calculate means
    baseline_mean = np.mean(values["baseline"])
    hybrid_mean = np.mean(values["hybrid"])
    
    # Calculate std dev
    baseline_std = np.std(values["baseline"])
    hybrid_std = np.std(values["hybrid"])
    
    # Create figure
    fig, ax = plt.subplots(figsize=(10, 6))
    
    x = np.arange(2)
    width = 0.6
    
    bars = ax.bar(x, [baseline_mean, hybrid_mean], width,
                   color=[COLORS['baseline'], COLORS['hybrid']],
                   yerr=[baseline_std, hybrid_std],
                   capsize=5, alpha=0.8, edgecolor='black', linewidth=1.5)
    
    # Labels
    ax.set_ylabel(ylabel or metric, fontsize=12, fontweight='bold')
    ax.set_title(title or f'{metric} Comparison', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(['Classical TLS\n(Baseline)', 'PQC Hybrid\n(ML-KEM + ML-DSA)'],
                       fontsize=11)
    ax.grid(axis='y', alpha=0.3)
    
    # Add value labels on bars
    for i, bar in enumerate(bars):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.2f}',
                ha='center', va='bottom', fontsize=11, fontweight='bold')
    
    # Add percentage difference
    pct_diff = ((hybrid_mean - baseline_mean) / baseline_mean) * 100
    color = COLORS['degradation'] if pct_diff > 0 else COLORS['improvement']
    ax.text(0.5, max(baseline_mean, hybrid_mean) * 0.95,
            f'{pct_diff:+.1f}%',
            ha='center', fontsize=14, fontweight='bold',
            color=color,
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8, edgecolor=color, linewidth=2))
    
    plt.tight_layout()
    plt.savefig(output, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"✓ Created: {output}", file=sys.stderr)


def create_distribution_plot(data: Dict, metric: str, output: str,
                              title: str = None, xlabel: str = None):
    """
    Create violin/box plot showing distribution
    """
    values = extract_metric_comparison(data, metric)
    
    if not values["baseline"] or not values["hybrid"]:
        print(f"WARNING: No data for metric '{metric}'", file=sys.stderr)
        return
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Create violin plot
    parts = ax.violinplot([values["baseline"], values["hybrid"]],
                           positions=[1, 2],
                           showmeans=True,
                           showmedians=True,
                           widths=0.7)
    
    # Color the violins
    colors = [COLORS['baseline'], COLORS['hybrid']]
    for i, pc in enumerate(parts['bodies']):
        pc.set_facecolor(colors[i])
        pc.set_alpha(0.6)
    
    # Labels
    ax.set_ylabel(xlabel or metric, fontsize=12, fontweight='bold')
    ax.set_title(title or f'{metric} Distribution', fontsize=14, fontweight='bold')
    ax.set_xticks([1, 2])
    ax.set_xticklabels(['Classical TLS', 'PQC Hybrid'], fontsize=11)
    ax.grid(axis='y', alpha=0.3)
    
    # Add statistics text
    baseline_stats = f"μ={np.mean(values['baseline']):.2f}, σ={np.std(values['baseline']):.2f}"
    hybrid_stats = f"μ={np.mean(values['hybrid']):.2f}, σ={np.std(values['hybrid']):.2f}"
    
    ax.text(1, max(values['baseline']) * 0.95, baseline_stats,
            ha='center', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.7))
    
    ax.text(2, max(values['hybrid']) * 0.95, hybrid_stats,
            ha='center', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.7))
    
    plt.tight_layout()
    plt.savefig(output, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"✓ Created: {output}", file=sys.stderr)


def create_multi_metric_comparison(data: Dict, metrics: List[str], output: str):
    """
    Create multi-panel comparison for several metrics
    """
    n_metrics = len(metrics)
    fig, axes = plt.subplots(1, n_metrics, figsize=(5*n_metrics, 5))
    
    if n_metrics == 1:
        axes = [axes]
    
    for i, metric in enumerate(metrics):
        values = extract_metric_comparison(data, metric)
        
        if not values["baseline"] or not values["hybrid"]:
            continue
        
        ax = axes[i]
        
        baseline_mean = np.mean(values["baseline"])
        hybrid_mean = np.mean(values["hybrid"])
        baseline_std = np.std(values["baseline"])
        hybrid_std = np.std(values["hybrid"])
        
        x = np.arange(2)
        bars = ax.bar(x, [baseline_mean, hybrid_mean], 0.6,
                      color=[COLORS['baseline'], COLORS['hybrid']],
                      yerr=[baseline_std, hybrid_std],
                      capsize=5, alpha=0.8, edgecolor='black')
        
        ax.set_title(metric, fontsize=11, fontweight='bold')
        ax.set_xticks(x)
        ax.set_xticklabels(['Classical', 'PQC Hybrid'], fontsize=9, rotation=15)
        ax.grid(axis='y', alpha=0.3)
        
        # Add percentage
        pct_diff = ((hybrid_mean - baseline_mean) / baseline_mean) * 100
        color = COLORS['degradation'] if pct_diff > 0 else COLORS['improvement']
        ax.text(0.5, max(baseline_mean, hybrid_mean) * 0.9,
                f'{pct_diff:+.1f}%',
                ha='center', fontsize=10, fontweight='bold', color=color)
    
    plt.suptitle('Performance Metrics Comparison: Classical vs PQC Hybrid',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(output, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"✓ Created: {output}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        description='Generate performance comparison charts'
    )
    
    parser.add_argument(
        '--input', '-i',
        required=True,
        help='Input JSON file (aggregated data)'
    )
    
    parser.add_argument(
        '--output-dir', '-o',
        default='charts',
        help='Output directory for charts (default: charts/)'
    )
    
    parser.add_argument(
        '--metrics', '-m',
        nargs='+',
        default=['handshake_time_ms', 'request_time_ms', 'throughput_mbps'],
        help='Metrics to plot'
    )
    
    parser.add_argument(
        '--format', '-f',
        choices=['png', 'pdf', 'svg'],
        default='png',
        help='Output format (default: png)'
    )
    
    args = parser.parse_args()
    
    try:
        # Load data
        data = load_aggregated_data(args.input)
        
        # Create output directory
        import os
        os.makedirs(args.output_dir, exist_ok=True)
        
        # Generate charts for each metric
        for metric in args.metrics:
            # Bar chart
            bar_output = os.path.join(args.output_dir, f'{metric}_comparison.{args.format}')
            create_comparison_bar_chart(data, metric, bar_output,
                                         title=f'{metric.replace("_", " ").title()} Comparison')
            
            # Distribution plot
            dist_output = os.path.join(args.output_dir, f'{metric}_distribution.{args.format}')
            create_distribution_plot(data, metric, dist_output,
                                      title=f'{metric.replace("_", " ").title()} Distribution')
        
        # Multi-metric comparison
        multi_output = os.path.join(args.output_dir, f'multi_metric_comparison.{args.format}')
        create_multi_metric_comparison(data, args.metrics, multi_output)
        
        print("", file=sys.stderr)
        print("=" * 50, file=sys.stderr)
        print("CHART GENERATION COMPLETE", file=sys.stderr)
        print("=" * 50, file=sys.stderr)
        print(f"Charts generated: {len(args.metrics) * 2 + 1}", file=sys.stderr)
        print(f"Output directory: {args.output_dir}", file=sys.stderr)
        print("=" * 50, file=sys.stderr)
        
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
