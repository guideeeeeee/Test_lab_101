#!/usr/bin/env python3
"""
Create Interactive HTML Dashboard for PQC Performance Data
สร้าง Dashboard แบบ Interactive สำหรับข้อมูล PQC
"""

import json
import argparse
import os
import sys
from datetime import datetime

DASHBOARD_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PQC Migration Dashboard</title>
    <script src="https://cdn.plot.ly/plotly-2.26.0.min.js"></script>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}
        .container {{
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }}
        h1 {{
            text-align: center;
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 2.5em;
        }}
        .subtitle {{
            text-align: center;
            color: #7f8c8d;
            margin-bottom: 30px;
            font-size: 1.1em;
        }}
        .metrics {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }}
        .metric-card {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }}
        .metric-card:hover {{
            transform: translateY(-5px);
        }}
        .metric-card h3 {{
            font-size: 0.9em;
            margin-bottom: 10px;
            opacity: 0.9;
        }}
        .metric-card .value {{
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }}
        .metric-card .change {{
            font-size: 0.9em;
            opacity: 0.8;
        }}
        .chart-container {{
            margin-bottom: 40px;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 15px;
        }}
        .chart-title {{
            font-size: 1.3em;
            color: #2c3e50;
            margin-bottom: 15px;
            font-weight: 600;
        }}
        .footer {{
            text-align: center;
            color: #7f8c8d;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ecf0f1;
        }}
        .tabs {{
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 2px solid #ecf0f1;
        }}
        .tab {{
            padding: 12px 24px;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1em;
            color: #7f8c8d;
            transition: all 0.3s;
            border-bottom: 3px solid transparent;
        }}
        .tab.active {{
            color: #667eea;
            border-bottom-color: #667eea;
        }}
        .tab-content {{
            display: none;
        }}
        .tab-content.active {{
            display: block;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 PQC Migration Dashboard</h1>
        <p class="subtitle">Post-Quantum Cryptography Performance Analysis</p>
        <p class="subtitle" style="font-size: 0.9em;">Generated: {generated_date}</p>
        
        <!-- Key Metrics -->
        <div class="metrics">
            <div class="metric-card">
                <h3>Handshake Overhead</h3>
                <div class="value">{handshake_overhead_percent:.1f}%</div>
                <div class="change">+{handshake_overhead_ms:.2f} ms</div>
            </div>
            <div class="metric-card">
                <h3>CPU Overhead</h3>
                <div class="value">{cpu_overhead_percent:.1f}%</div>
                <div class="change">{cpu_interpretation}</div>
            </div>
            <div class="metric-card">
                <h3>Memory Overhead</h3>
                <div class="value">{memory_overhead_percent:.1f}%</div>
                <div class="change">{memory_interpretation}</div>
            </div>
            <div class="metric-card">
                <h3>Throughput Impact</h3>
                <div class="value">{throughput_degradation_percent:.1f}%</div>
                <div class="change">degradation</div>
            </div>
        </div>
        
        <!-- Tabs -->
        <div class="tabs">
            <button class="tab active" onclick="showTab('overview')">Overview</button>
            <button class="tab" onclick="showTab('handshake')">Handshake</button>
            <button class="tab" onclick="showTab('resources')">Resources</button>
            <button class="tab" onclick="showTab('throughput')">Throughput</button>
        </div>
        
        <!-- Tab: Overview -->
        <div id="overview" class="tab-content active">
            <div class="chart-container">
                <div class="chart-title">Performance Comparison Overview</div>
                <div id="chart-overview"></div>
            </div>
        </div>
        
        <!-- Tab: Handshake -->
        <div id="handshake" class="tab-content">
            <div class="chart-container">
                <div class="chart-title">TLS Handshake Time Distribution</div>
                <div id="chart-handshake"></div>
            </div>
        </div>
        
        <!-- Tab: Resources -->
        <div id="resources" class="tab-content">
            <div class="chart-container">
                <div class="chart-title">CPU & Memory Usage</div>
                <div id="chart-resources"></div>
            </div>
        </div>
        
        <!-- Tab: Throughput -->
        <div id="throughput" class="tab-content">
            <div class="chart-container">
                <div class="chart-title">Throughput Under Different Loads</div>
                <div id="chart-throughput"></div>
            </div>
        </div>
        
        <div class="footer">
            <p>📊 Data collected from Labs 02 (Classical TLS) and Lab 04 (PQC Hybrid)</p>
            <p>🔬 Algorithms: Classical (RSA-2048 + ECDHE-P256) vs Hybrid (X25519+ML-KEM-768 + ECDSA+ML-DSA-65)</p>
        </div>
    </div>
    
    <script>
        // Data from Python
        const data = {data_json};
        
        // Tab switching
        function showTab(tabName) {{
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            event.target.classList.add('active');
            document.getElementById(tabName).classList.add('active');
        }}
        
        // Chart 1: Overview (Radar Chart)
        const overviewTrace1 = {{
            type: 'scatterpolar',
            r: [100, 100, 100, 100],
            theta: ['Handshake', 'CPU', 'Memory', 'Throughput'],
            fill: 'toself',
            name: 'Classical TLS',
            marker: {{ color: '#3498db' }}
        }};
        
        const overviewTrace2 = {{
            type: 'scatterpolar',
            r: [
                100 - {handshake_overhead_percent:.1f},
                100 - {cpu_overhead_percent:.1f},
                100 - {memory_overhead_percent:.1f},
                100 + {throughput_degradation_percent:.1f}
            ],
            theta: ['Handshake', 'CPU', 'Memory', 'Throughput'],
            fill: 'toself',
            name: 'PQC Hybrid',
            marker: {{ color: '#e74c3c' }}
        }};
        
        Plotly.newPlot('chart-overview', [overviewTrace1, overviewTrace2], {{
            polar: {{
                radialaxis: {{
                    visible: true,
                    range: [0, 120]
                }}
            }},
            height: 500
        }});
        
        // Chart 2: Handshake (Box Plot)
        const handshakeClassical = {{
            y: [/* simulated data */],
            type: 'box',
            name: 'Classical TLS',
            marker: {{ color: '#3498db' }}
        }};
        
        const handshakeHybrid = {{
            y: [/* simulated data */],
            type: 'box',
            name: 'PQC Hybrid',
            marker: {{ color: '#e74c3c' }}
        }};
        
        Plotly.newPlot('chart-handshake', [handshakeClassical, handshakeHybrid], {{
            yaxis: {{ title: 'Handshake Time (ms)' }},
            height: 400
        }});
        
        // Chart 3: Resources (Grouped Bar)
        const resourcesTrace1 = {{
            x: ['CPU Idle', 'CPU Load', 'Memory Idle', 'Memory Load'],
            y: [{cpu_idle_classical:.1f}, {cpu_load_classical:.1f}, {memory_idle_classical:.1f}, {memory_load_classical:.1f}],
            name: 'Classical TLS',
            type: 'bar',
            marker: {{ color: '#3498db' }}
        }};
        
        const resourcesTrace2 = {{
            x: ['CPU Idle', 'CPU Load', 'Memory Idle', 'Memory Load'],
            y: [{cpu_idle_hybrid:.1f}, {cpu_load_hybrid:.1f}, {memory_idle_hybrid:.1f}, {memory_load_hybrid:.1f}],
            name: 'PQC Hybrid',
            type: 'bar',
            marker: {{ color: '#e74c3c' }}
        }};
        
        Plotly.newPlot('chart-resources', [resourcesTrace1, resourcesTrace2], {{
            barmode: 'group',
            height: 400
        }});
        
        // Chart 4: Throughput (Line Chart)
        const throughputTrace1 = {{
            x: ['Low (10)', 'Medium (50)', 'High (100)'],
            y: [{throughput_low_classical}, {throughput_med_classical}, {throughput_high_classical}],
            mode: 'lines+markers',
            name: 'Classical TLS',
            line: {{ color: '#3498db', width: 3 }},
            marker: {{ size: 10 }}
        }};
        
        const throughputTrace2 = {{
            x: ['Low (10)', 'Medium (50)', 'High (100)'],
            y: [{throughput_low_hybrid}, {throughput_med_hybrid}, {throughput_high_hybrid}],
            mode: 'lines+markers',
            name: 'PQC Hybrid',
            line: {{ color: '#e74c3c', width: 3 }},
            marker: {{ size: 10 }}
        }};
        
        Plotly.newPlot('chart-throughput', [throughputTrace1, throughputTrace2], {{
            xaxis: {{ title: 'Concurrency Level' }},
            yaxis: {{ title: 'Requests per Second' }},
            height: 400
        }});
    </script>
</body>
</html>
"""


def extract_metrics(data: dict) -> dict:
    """Extract metrics from aggregated data for dashboard"""
    classical = data.get('classical', {})
    hybrid = data.get('hybrid', {})
    comparison = data.get('comparison', {})
    
    return {
        'handshake_overhead_ms': comparison.get('handshake_overhead_ms', 0),
        'handshake_overhead_percent': comparison.get('handshake_overhead_percent', 0),
        'cpu_overhead_percent': comparison.get('cpu_overhead_percent', 0),
        'memory_overhead_percent': comparison.get('memory_overhead_percent', 0),
        'throughput_degradation_percent': comparison.get('throughput_degradation_percent', 0),
        
        # CPU
        'cpu_idle_classical': classical.get('cpu', {}).get('idle_percent', 0),
        'cpu_load_classical': classical.get('cpu', {}).get('load_mean_percent', 0),
        'cpu_idle_hybrid': hybrid.get('cpu', {}).get('idle_percent', 0),
        'cpu_load_hybrid': hybrid.get('cpu', {}).get('load_mean_percent', 0),
        
        # Memory
        'memory_idle_classical': classical.get('memory', {}).get('idle_mb', 0),
        'memory_load_classical': classical.get('memory', {}).get('load_mean_mb', 0),
        'memory_idle_hybrid': hybrid.get('memory', {}).get('idle_mb', 0),
        'memory_load_hybrid': hybrid.get('memory', {}).get('load_mean_mb', 0),
        
        # Throughput
        'throughput_low_classical': classical.get('throughput', {}).get('low_load_rps', 0),
        'throughput_med_classical': classical.get('throughput', {}).get('medium_load_rps', 0),
        'throughput_high_classical': classical.get('throughput', {}).get('high_load_rps', 0),
        'throughput_low_hybrid': hybrid.get('throughput', {}).get('low_load_rps', 0),
        'throughput_med_hybrid': hybrid.get('throughput', {}).get('medium_load_rps', 0),
        'throughput_high_hybrid': hybrid.get('throughput', {}).get('high_load_rps', 0),
        
        # Interpretations
        'cpu_interpretation': 'Acceptable' if comparison.get('cpu_overhead_percent', 0) < 20 else 'High',
        'memory_interpretation': 'Acceptable' if comparison.get('memory_overhead_percent', 0) < 20 else 'High',
        
        # Meta
        'generated_date': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        'data_json': json.dumps(data)
    }


def main():
    parser = argparse.ArgumentParser(
        description='Create interactive HTML dashboard for PQC performance analysis'
    )
    
    parser.add_argument(
        'data_file',
        help='Path to aggregated data JSON (from aggregate-data.py)'
    )
    
    parser.add_argument(
        '--output', '-o',
        default='visualizations/dashboard.html',
        help='Output HTML file path (default: visualizations/dashboard.html)'
    )
    
    args = parser.parse_args()
    
    try:
        # Load data
        print(f"Loading data from {args.data_file}...")
        with open(args.data_file, 'r') as f:
            data = json.load(f)
        
        # Extract metrics
        metrics = extract_metrics(data)
        
        # Generate HTML
        print("Generating interactive dashboard...")
        html = DASHBOARD_TEMPLATE.format(**metrics)
        
        # Write output
        os.makedirs(os.path.dirname(args.output), exist_ok=True)
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(html)
        
        print(f"✓ Dashboard created: {args.output}")
        print(f"\nOpen in browser:")
        print(f"  firefox {args.output}")
        print(f"  or")
        print(f"  file://{os.path.abspath(args.output)}")
    
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
