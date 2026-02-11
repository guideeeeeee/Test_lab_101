# Workshop 3: Reporting Dashboard
# สร้าง Dashboard รายงานผล

**Duration:** 60 minutes  
**Difficulty:** Intermediate  
**Language:** Python 3.8+, HTML/JavaScript

---

## 🎯 Objective

Build an interactive reporting dashboard that:
1. Reads benchmark data from JSON files
2. Generates charts and tables
3. Exports to HTML report
4. (Bonus) Creates live dashboard with auto-refresh

---

## 📋 Requirements

```bash
pip install pandas matplotlib plotly jinja2 pyyaml
```

---

## 🏗️ Architecture

```
┌─────────────────────┐
│  Benchmark Results  │
│   (JSON/CSV files)  │
└──────────┬──────────┘
           │
    ┌──────▼──────────────┐
    │  Data Aggregator    │
    │  (pandas DataFrame) │
    └──────┬──────────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼────┐   ┌───▼────────┐
│ Charts │   │ Statistics │
│(plotly)│   │  (tables)  │
└───┬────┘   └───┬────────┘
    │            │
    └────┬───────┘
         │
    ┌────▼────────────┐
    │  HTML Template  │
    │    (Jinja2)     │
    └────┬────────────┘
         │
    ┌────▼─────────┐
    │ Final Report │
    │  report.html │
    └──────────────┘
```

---

## 🚀 Getting Started

### File Structure

```
workshops/03-reporting/
├── README.md (this file)
├── build_report.py      # Main script (you create)
├── templates/
│   └── report.html.j2   # Jinja2 template (starter provided)
├── static/
│   └── style.css        # Report styling
└── output/
    └── report.html      # Generated report
```

---

## 📝 Task 1: Data Aggregation (15 min)

### Goal
Load and combine benchmark results from multiple JSON files.

### Implementation

Create `build_report.py`:

```python
#!/usr/bin/env python3
import json
import pandas as pd
from pathlib import Path
from typing import List, Dict

def load_benchmark_data(results_dir: str = "../02-benchmark/results") -> pd.DataFrame:
    """
    Load all JSON benchmark results into a pandas DataFrame.
    
    Args:
        results_dir: Directory containing JSON results
    
    Returns:
        DataFrame with all benchmark data
    """
    data = []
    results_path = Path(results_dir)
    
    # TODO: Find all JSON files in results directory
    # Hint: results_path.glob("**/*.json")
    
    for json_file in []:  # Replace with glob pattern
        with open(json_file) as f:
            result = json.load(f)
            # TODO: Extract relevant data and append to list
            pass
    
    # TODO: Convert to DataFrame
    df = pd.DataFrame(data)
    return df

def calculate_statistics(df: pd.DataFrame) -> Dict:
    """
    Calculate summary statistics from benchmark data.
    
    Returns:
        Dictionary with statistics
    """
    stats = {}
    
    # TODO: Calculate:
    # - Mean handshake time by cipher type
    # - Throughput comparison
    # - CPU/Memory usage
    # - Overhead percentages
    
    return stats

if __name__ == "__main__":
    df = load_benchmark_data()
    print(df.head())
    
    stats = calculate_statistics(df)
    print(json.dumps(stats, indent=2))
```

### Expected DataFrame Structure

```
| test_name      | handshake_ms | throughput_rps | cpu_percent | memory_percent | timestamp           |
|----------------|--------------|----------------|-------------|----------------|---------------------|
| Classical TLS  | 42.5         | 245            | 15.2        | 2.3            | 2026-01-15 10:30:00 |
| PQC Hybrid     | 125.3        | 87             | 42.1        | 3.8            | 2026-01-15 10:35:00 |
```

---

## 📝 Task 2: Chart Generation (20 min)

### Goal
Create interactive charts using Plotly.

### Implementation

Add to `build_report.py`:

```python
import plotly.graph_objects as go
import plotly.express as px

def create_handshake_chart(df: pd.DataFrame) -> str:
    """
    Create bar chart comparing handshake times.
    
    Returns:
        HTML string with embedded chart
    """
    # TODO: Group by test_name and calculate mean handshake_ms
    grouped = df.groupby('test_name')['handshake_ms'].mean()
    
    fig = go.Figure(data=[
        go.Bar(
            x=grouped.index,
            y=grouped.values,
            text=[f"{v:.1f} ms" for v in grouped.values],
            textposition='auto',
        )
    ])
    
    fig.update_layout(
        title="TLS Handshake Time Comparison",
        xaxis_title="Configuration",
        yaxis_title="Handshake Time (ms)",
        template="plotly_white"
    )
    
    # Return as HTML div
    return fig.to_html(full_html=False, include_plotlyjs='cdn')

def create_resource_usage_chart(df: pd.DataFrame) -> str:
    """
    Create grouped bar chart for CPU and memory usage.
    """
    # TODO: Implement grouped bar chart
    # X-axis: test_name
    # Y-axis: cpu_percent, memory_percent
    pass

def create_throughput_comparison(df: pd.DataFrame) -> str:
    """
    Create horizontal bar chart showing requests per second.
    """
    # TODO: Implement horizontal bar chart
    pass

def create_overhead_chart(stats: Dict) -> str:
    """
    Create stacked bar chart showing overhead percentages.
    """
    # TODO: Implement stacked bar chart
    # Categories: Handshake, Throughput, CPU, Memory
    # Values: percentage overhead
    pass
```

### Expected Charts

1. **Handshake Time Bar Chart:**
   - Classical: 42.5 ms (green)
   - PQC: 125.3 ms (orange)

2. **Resource Usage Grouped Chart:**
   - CPU: Classical 15%, PQC 42%
   - Memory: Classical 2.3%, PQC 3.8%

3. **Overhead Summary:**
   - Handshake: +194%
   - Throughput: -64%
   - CPU: +177%

---

## 📝 Task 3: HTML Report Generation (20 min)

### Goal
Use Jinja2 to generate a professional HTML report.

### Starter Template: `templates/report.html.j2`

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PQC Benchmark Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .section {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .stat-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #666;
            margin-top: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #667eea;
            color: white;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔐 Post-Quantum Cryptography Benchmark Report</h1>
        <p>Generated: {{ timestamp }}</p>
    </div>

    <div class="section">
        <h2>📊 Summary Statistics</h2>
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-value">{{ stats.handshake_overhead }}%</div>
                <div class="stat-label">Handshake Overhead</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{{ stats.throughput_reduction }}%</div>
                <div class="stat-label">Throughput Reduction</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{{ stats.cpu_increase }}%</div>
                <div class="stat-label">CPU Increase</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{{ stats.memory_increase }}%</div>
                <div class="stat-label">Memory Increase</div>
            </div>
        </div>
    </div>

    <div class="section">
        <h2>⏱️ Handshake Performance</h2>
        {{ charts.handshake | safe }}
    </div>

    <div class="section">
        <h2>🚀 Throughput Comparison</h2>
        {{ charts.throughput | safe }}
    </div>

    <div class="section">
        <h2>💻 Resource Usage</h2>
        {{ charts.resources | safe }}
    </div>

    <div class="section">
        <h2>📋 Detailed Results</h2>
        {{ tables.detailed_results | safe }}
    </div>

    <div class="section">
        <h2>💡 Recommendations</h2>
        <ul>
            {% for rec in recommendations %}
            <li>{{ rec }}</li>
            {% endfor %}
        </ul>
    </div>
</body>
</html>
```

### Implementation

Add to `build_report.py`:

```python
from jinja2 import Environment, FileSystemLoader
from datetime import datetime

def generate_html_report(df: pd.DataFrame, stats: Dict, charts: Dict) -> str:
    """
    Generate HTML report using Jinja2 template.
    
    Args:
        df: Benchmark data DataFrame
        stats: Summary statistics
        charts: Dictionary of chart HTML strings
    
    Returns:
        Path to generated HTML file
    """
    # TODO: Set up Jinja2 environment
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('report.html.j2')
    
    # TODO: Prepare data for template
    context = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "stats": stats,
        "charts": charts,
        "tables": {
            "detailed_results": df.to_html(index=False, classes="data-table")
        },
        "recommendations": generate_recommendations(stats)
    }
    
    # TODO: Render template
    html = template.render(context)
    
    # TODO: Save to file
    output_path = "output/report.html"
    with open(output_path, "w") as f:
        f.write(html)
    
    return output_path

def generate_recommendations(stats: Dict) -> List[str]:
    """
    Generate recommendations based on benchmark results.
    """
    recommendations = []
    
    if stats.get("handshake_overhead", 0) > 200:
        recommendations.append(
            "⚠️ High handshake overhead detected. Consider connection pooling or session resumption."
        )
    
    if stats.get("throughput_reduction", 0) > 50:
        recommendations.append(
            "⚠️ Significant throughput reduction. Monitor API latency carefully."
        )
    
    # TODO: Add more conditional recommendations
    
    return recommendations
```

---

## 📝 Task 4: Complete Workflow (Bonus)

### Goal
Tie everything together with a main function.

### Implementation

```python
def main():
    """Generate complete benchmark report."""
    print("📊 PQC Benchmark Report Generator")
    print("=" * 50)
    
    # Step 1: Load data
    print("\n1. Loading benchmark data...")
    df = load_benchmark_data()
    print(f"   Loaded {len(df)} test results")
    
    # Step 2: Calculate statistics
    print("\n2. Calculating statistics...")
    stats = calculate_statistics(df)
    
    # Step 3: Generate charts
    print("\n3. Generating charts...")
    charts = {
        "handshake": create_handshake_chart(df),
        "throughput": create_throughput_comparison(df),
        "resources": create_resource_usage_chart(df),
    }
    
    # Step 4: Generate HTML report
    print("\n4. Building HTML report...")
    output_path = generate_html_report(df, stats, charts)
    
    print(f"\n✅ Report generated: {output_path}")
    print(f"   Open in browser: file://{Path(output_path).absolute()}")

if __name__ == "__main__":
    main()
```

---

## 🧪 Testing Your Report

### Test 1: Generate Sample Report

```bash
# Create sample data first
python3 ../02-benchmark/benchmark.py

# Generate report
python3 build_report.py
```

Expected: `output/report.html` created

### Test 2: Open in Browser

```bash
firefox output/report.html
# or
xdg-open output/report.html
```

Expected: Professional-looking report with interactive charts

---

## ✅ Success Criteria

Your reporting tool should:
- [x] Load JSON benchmark results
- [x] Calculate summary statistics
- [x] Generate 3+ interactive charts (Plotly)
- [x] Create HTML report from template
- [x] Display detailed results table
- [x] Provide conditional recommendations
- [x] Support multiple benchmark runs

---

## 🎓 Bonus Challenges

### Bonus 1: Live Dashboard

Install Flask:
```bash
pip install flask
```

Create `dashboard.py`:

```python
from flask import Flask, render_template, jsonify
import json

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('dashboard.html')

@app.route('/api/data')
def get_data():
    # TODO: Load latest benchmark data
    return jsonify({...})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### Bonus 2: PDF Export

```bash
pip install weasyprint
```

```python
from weasyprint import HTML

def export_to_pdf(html_path: str):
    """Convert HTML report to PDF."""
    HTML(html_path).write_pdf("output/report.pdf")
```

### Bonus 3: Email Report

```python
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def email_report(html_content: str, recipient: str):
    """Email the HTML report."""
    # TODO: Configure SMTP and send email
    pass
```

---

## 📚 Resources

- [Plotly Python Documentation](https://plotly.com/python/)
- [Jinja2 Template Designer](https://jinja.palletsprojects.com/)
- [Pandas Visualization](https://pandas.pydata.org/docs/user_guide/visualization.html)

---

## 🔗 Next Steps

- Test with real benchmark data from Workshop 2
- Customize report template styling
- Move to [Workshop 4: CI/CD Integration](../04-cicd/)

---

<div align="center">

[← Workshop 2](../02-benchmark/) | [Back to Lab 07](../../README.md) | [Workshop 4 →](../04-cicd/)

</div>
