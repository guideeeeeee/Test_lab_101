#!/usr/bin/env python3
"""
Build Professional PDF/HTML Report from PQC Performance Data
สร้างรายงาน PDF/HTML จากข้อมูลประสิทธิภาพ PQC
"""

import json
import argparse
import sys
import os
from datetime import datetime
from pathlib import Path

# Try imports (graceful failure if not installed)
try:
    from jinja2 import Environment, FileSystemLoader, select_autoescape
    JINJA_AVAILABLE = True
except ImportError:
    JINJA_AVAILABLE = False
    print("WARNING: jinja2 not installed. Install with: pip install jinja2", file=sys.stderr)

try:
    import pdfkit
    PDFKIT_AVAILABLE = True
except ImportError:
    PDFKIT_AVAILABLE = False
    print("WARNING: pdfkit not installed. Install with: pip install pdfkit", file=sys.stderr)
    print("         Also requires wkhtmltopdf: apt install wkhtmltopdf", file=sys.stderr)


def load_data(filepath: str) -> dict:
    """Load aggregated performance data JSON"""
    with open(filepath, 'r') as f:
        return json.load(f)


def format_number(value, decimals=2):
    """Format number with locale awareness"""
    if isinstance(value, (int, float)):
        return f"{value:.{decimals}f}"
    return str(value)


def interpret_overhead(overhead_percent: float) -> dict:
    """Interpret overhead percentage"""
    if overhead_percent < 10:
        level = "Excellent"
        color = "green"
        recommendation = "No action needed"
    elif overhead_percent < 25:
        level = "Good"
        color = "lightgreen"
        recommendation = "Acceptable for most use cases"
    elif overhead_percent < 50:
        level = "Moderate"
        color = "yellow"
        recommendation = "Consider optimization"
    else:
        level = "Significant"
        color = "orange"
        recommendation = "Optimization required"
    
    return {
        "level": level,
        "color": color,
        "recommendation": recommendation
    }


def generate_html_report(data: dict, template_path: str, charts_dir: str) -> str:
    """Generate HTML report using Jinja2 template"""
    if not JINJA_AVAILABLE:
        raise RuntimeError("jinja2 is required for HTML generation")
    
    # Setup Jinja2 environment
    template_dir = os.path.dirname(template_path)
    template_name = os.path.basename(template_path)
    
    env = Environment(
        loader=FileSystemLoader(template_dir),
        autoescape=select_autoescape(['html', 'xml'])
    )
    
    # Custom filters
    env.filters['format_number'] = format_number
    
    template = env.get_template(template_name)
    
    # Prepare context for template
    context = {
        "generated_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "data": data,
        "charts_dir": charts_dir,
        "interpretation": {
            "handshake": interpret_overhead(
                data.get('comparison', {}).get('handshake_overhead_percent', 0)
            ),
            "cpu": interpret_overhead(
                data.get('comparison', {}).get('cpu_overhead_percent', 0)
            ),
            "memory": interpret_overhead(
                data.get('comparison', {}).get('memory_overhead_percent', 0)
            )
        }
    }
    
    # Render HTML
    html_content = template.render(**context)
    return html_content


def generate_pdf_report(html_content: str, output_path: str, options: dict = None) -> None:
    """Convert HTML to PDF using pdfkit"""
    if not PDFKIT_AVAILABLE:
        raise RuntimeError("pdfkit is required for PDF generation. Install: pip install pdfkit")
    
    default_options = {
        'page-size': 'A4',
        'margin-top': '20mm',
        'margin-right': '20mm',
        'margin-bottom': '20mm',
        'margin-left': '20mm',
        'encoding': 'UTF-8',
        'no-outline': None,
        'enable-local-file-access': None,
        'print-media-type': None
    }
    
    if options:
        default_options.update(options)
    
    pdfkit.from_string(html_content, output_path, options=default_options)


def generate_simple_html_fallback(data: dict) -> str:
    """Generate simple HTML without Jinja2 (fallback)"""
    html = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PQC Migration Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; }}
        h1 {{ color: #2c3e50; }}
        h2 {{ color: #34495e; border-bottom: 2px solid #3498db; padding-bottom: 10px; }}
        table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
        th, td {{ border: 1px solid #ddd; padding: 12px; text-align: left; }}
        th {{ background-color: #3498db; color: white; }}
        .metric {{ font-weight: bold; }}
        .good {{ color: green; }}
        .warning {{ color: orange; }}
        .bad {{ color: red; }}
    </style>
</head>
<body>
    <h1>Post-Quantum Cryptography Migration Report</h1>
    <p><strong>Generated:</strong> {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</p>
    
    <h2>Executive Summary</h2>
    <p>This report presents a performance comparison between classical TLS (RSA+ECDHE) 
    and post-quantum hybrid TLS (X25519+ML-KEM-768, ECDSA+ML-DSA-65).</p>
    
    <h2>Performance Comparison</h2>
    <table>
        <tr>
            <th>Metric</th>
            <th>Classical TLS</th>
            <th>PQC Hybrid</th>
            <th>Overhead %</th>
        </tr>
"""
    
    # Handshake
    classical = data.get('classical', {})
    hybrid = data.get('hybrid', {})
    comparison = data.get('comparison', {})
    
    if 'handshake' in classical and 'handshake' in hybrid:
        html += f"""
        <tr>
            <td class="metric">Handshake Time (mean)</td>
            <td>{classical['handshake'].get('mean_ms', 'N/A')} ms</td>
            <td>{hybrid['handshake'].get('mean_ms', 'N/A')} ms</td>
            <td class="warning">{comparison.get('handshake_overhead_percent', 'N/A')}%</td>
        </tr>
"""
    
    # CPU
    if 'cpu' in classical and 'cpu' in hybrid:
        html += f"""
        <tr>
            <td class="metric">CPU Usage (under load)</td>
            <td>{classical['cpu'].get('load_mean_percent', 'N/A')}%</td>
            <td>{hybrid['cpu'].get('load_mean_percent', 'N/A')}%</td>
            <td class="good">{comparison.get('cpu_overhead_percent', 'N/A')}%</td>
        </tr>
"""
    
    # Memory
    if 'memory' in classical and 'memory' in hybrid:
        html += f"""
        <tr>
            <td class="metric">Memory Usage (under load)</td>
            <td>{classical['memory'].get('load_mean_mb', 'N/A')} MB</td>
            <td>{hybrid['memory'].get('load_mean_mb', 'N/A')} MB</td>
            <td class="good">{comparison.get('memory_overhead_percent', 'N/A')}%</td>
        </tr>
"""
    
    html += """
    </table>
    
    <h2>Recommendation</h2>
    <p><strong>Verdict:</strong> PQC hybrid migration is <span class="good">feasible</span> 
    with acceptable performance overhead for most web applications.</p>
    
    <h2>Next Steps</h2>
    <ul>
        <li>Implement session resumption to reduce handshake overhead</li>
        <li>Enable hardware acceleration (AVX2/AVX-512)</li>
        <li>Monitor production traffic patterns</li>
        <li>Plan phased rollout strategy</li>
    </ul>
</body>
</html>
"""
    return html


def main():
    parser = argparse.ArgumentParser(
        description='Generate professional PQC migration report (PDF or HTML)'
    )
    
    parser.add_argument(
        '--data', '-d',
        required=True,
        help='Path to aggregated data JSON (from aggregate-data.py)'
    )
    
    parser.add_argument(
        '--template', '-t',
        help='Path to Jinja2 HTML template (optional, uses fallback if not provided)'
    )
    
    parser.add_argument(
        '--charts', '-c',
        help='Directory containing chart images (PNG files)'
    )
    
    parser.add_argument(
        '--output', '-o',
        required=True,
        help='Output file path (.pdf or .html)'
    )
    
    parser.add_argument(
        '--format', '-f',
        choices=['pdf', 'html', 'auto'],
        default='auto',
        help='Output format (default: auto-detect from file extension)'
    )
    
    args = parser.parse_args()
    
    try:
        # Load data
        print(f"Loading data from {args.data}...")
        data = load_data(args.data)
        
        # Determine output format
        output_format = args.format
        if output_format == 'auto':
            ext = Path(args.output).suffix.lower()
            if ext == '.pdf':
                output_format = 'pdf'
            elif ext in ['.html', '.htm']:
                output_format = 'html'
            else:
                print(f"ERROR: Unknown file extension '{ext}'. Please specify --format", file=sys.stderr)
                sys.exit(1)
        
        # Generate HTML
        print("Generating HTML report...")
        if args.template and os.path.exists(args.template):
            html_content = generate_html_report(data, args.template, args.charts or '')
        else:
            if args.template:
                print(f"WARNING: Template {args.template} not found, using simple fallback")
            html_content = generate_simple_html_fallback(data)
        
        # Output
        if output_format == 'html':
            print(f"Writing HTML to {args.output}...")
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(html_content)
            print(f"✓ HTML report generated: {args.output}")
        
        elif output_format == 'pdf':
            print(f"Converting to PDF: {args.output}...")
            generate_pdf_report(html_content, args.output)
            print(f"✓ PDF report generated: {args.output}")
        
        print("\nReport generation complete!")
        print(f"View report: file://{os.path.abspath(args.output)}")
    
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
