# Workshop 4: CI/CD Integration
# ผสาน PQC Testing เข้า CI/CD Pipeline

**Duration:** 60 minutes  
**Difficulty:** Advanced  
**Language:** YAML, Bash, Python

---

## 🎯 Objective

Integrate PQC testing into CI/CD pipelines to:
1. Automatically test PQC configuration changes
2. Run performance benchmarks on every commit
3. Generate regression reports
4. Block deployments if performance degrades

---

## 📋 Requirements

### For GitHub Actions:
- GitHub account with repository access
- `.github/workflows/` directory

### For GitLab CI:
- GitLab account
- `.gitlab-ci.yml` file

### Tools:
```bash
# Already available in lab environment
- Docker
- Apache Bench (ab)
- Python 3.8+
```

---

## 🏗️ CI/CD Pipeline Architecture

```
┌────────────────┐
│  Git Push      │
│  (trigger)     │
└───────┬────────┘
        │
┌───────▼────────────────┐
│  1. Build Phase        │
│  - Build Docker images │
│  - Install dependencies│
└───────┬────────────────┘
        │
┌───────▼────────────────┐
│  2. Test Phase         │
│  - Unit tests          │
│  - TLS tests           │
│  - PQC verification    │
└───────┬────────────────┘
        │
┌───────▼────────────────┐
│  3. Benchmark Phase    │
│  - Run performance test│
│  - Compare to baseline │
└───────┬────────────────┘
        │
┌───────▼────────────────┐
│  4. Report Phase       │
│  - Generate charts     │
│  - Upload artifacts    │
│  - Comment on PR       │
└───────┬────────────────┘
        │
┌───────▼────────────────┐
│  5. Deploy Phase       │
│  - Deploy if tests pass│
│  - Rollback if needed  │
└────────────────────────┘
```

---

## 📝 Task 1: GitHub Actions Workflow (25 min)

### Goal
Create a GitHub Actions workflow that tests PQC configuration.

### Implementation

Create `.github/workflows/pqc-test.yml`:

```yaml
name: PQC TLS Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  OPENSSL_VERSION: "3.1.0"
  LIBOQS_VERSION: "0.9.0"

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      # TODO Task 1.1: Checkout code
      - name: Checkout repository
        uses: actions/checkout@v3
      
      # TODO Task 1.2: Set up Docker Buildx
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      # TODO Task 1.3: Build PQC NGINX image
      - name: Build NGINX with PQC
        run: |
          cd labs/00-setup/docker
          # Build the image (reuse from Lab 00)
          docker build -t pqc-nginx:test -f nginx.Dockerfile .
      
      # TODO Task 1.4: Start test environment
      - name: Start test containers
        run: |
          docker-compose -f labs/00-setup/docker-compose.yml up -d
          # Wait for services to be ready
          sleep 10
      
      # TODO Task 1.5: Run TLS tests
      - name: Test TLS configuration
        run: |
          # Test if NGINX accepts PQC connections
          # Use openssl s_client or custom script
          bash labs/01-manual-discovery/scripts/test-tls.sh
      
      # TODO Task 1.6: Run performance benchmark
      - name: Run performance benchmark
        run: |
          python3 labs/07-advanced-workshop/workshops/02-benchmark/benchmark.py \
            --config pqc \
            --iterations 100 \
            --output benchmark-results.json
      
      # TODO Task 1.7: Generate report
      - name: Generate report
        if: always()
        run: |
          python3 labs/07-advanced-workshop/workshops/03-reporting/build_report.py \
            --input benchmark-results.json \
            --output report.html
      
      # TODO Task 1.8: Upload artifacts
      - name: Upload benchmark results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: benchmark-results
          path: |
            benchmark-results.json
            report.html
      
      # TODO Task 1.9: Cleanup
      - name: Stop containers
        if: always()
        run: |
          docker-compose -f labs/00-setup/docker-compose.yml down

  # Job 2: Performance regression check
  regression-check:
    runs-on: ubuntu-latest
    needs: build-and-test
    
    steps:
      - name: Download current results
        uses: actions/download-artifact@v3
        with:
          name: benchmark-results
      
      # TODO: Compare with baseline
      - name: Check for regression
        run: |
          # Download baseline from previous run
          # Compare handshake time, throughput
          # Fail if degradation > 10%
          python3 scripts/check-regression.py \
            --current benchmark-results.json \
            --baseline baseline.json \
            --threshold 10
```

### Hints for Task 1.5: TLS Testing Script

Create `labs/01-manual-discovery/scripts/test-tls.sh`:

```bash
#!/bin/bash
# Test TLS configuration

echo "Testing TLS connection to localhost:8443..."

# Test 1: Can we connect?
timeout 5 openssl s_client -connect localhost:8443 -servername localhost < /dev/null

if [ $? -eq 0 ]; then
    echo "✅ TLS connection successful"
else
    echo "❌ TLS connection failed"
    exit 1
fi

# Test 2: Check for PQC algorithms
echo "Checking for PQC algorithms..."
CIPHER=$(openssl s_client -connect localhost:8443 -servername localhost </dev/null 2>&1 | grep "Cipher")

if echo "$CIPHER" | grep -iE "(MLKEM|MLDSA|kyber|dilithium)"; then
    echo "✅ PQC algorithms detected"
else
    echo "⚠️  Classical algorithms only"
fi
```

---

## 📝 Task 2: Regression Detection (20 min)

### Goal
Detect performance regressions automatically.

### Implementation

Create `scripts/check-regression.py`:

```python
#!/usr/bin/env python3
"""
Check for performance regression between benchmark runs.
"""

import json
import sys
import argparse

def load_results(filepath: str) -> dict:
    """Load benchmark results from JSON."""
    with open(filepath) as f:
        return json.load(f)

def calculate_regression(current: dict, baseline: dict, metric: str) -> float:
    """
    Calculate percentage regression for a metric.
    
    Args:
        current: Current benchmark results
        baseline: Baseline benchmark results
        metric: Metric name (e.g., "handshake_ms")
    
    Returns:
        Percentage increase (positive = slower = bad)
    """
    # TODO: Extract metric values
    current_value = current.get(metric, 0)
    baseline_value = baseline.get(metric, 1)  # Avoid division by zero
    
    # Calculate percentage change
    regression = ((current_value - baseline_value) / baseline_value) * 100
    
    return regression

def main():
    parser = argparse.ArgumentParser(description='Check for performance regression')
    parser.add_argument('--current', required=True, help='Current results JSON')
    parser.add_argument('--baseline', required=True, help='Baseline results JSON')
    parser.add_argument('--threshold', type=float, default=10, help='Regression threshold (%)')
    args = parser.parse_args()
    
    # Load results
    current = load_results(args.current)
    baseline = load_results(args.baseline)
    
    # Check metrics
    metrics = [
        ("handshake_ms", "Handshake Time", "lower_is_better"),
        ("throughput_rps", "Throughput", "higher_is_better"),
        ("cpu_percent", "CPU Usage", "lower_is_better"),
    ]
    
    regressions = []
    
    for metric_key, metric_name, direction in metrics:
        regression = calculate_regression(current, baseline, metric_key)
        
        # Adjust sign based on direction
        if direction == "higher_is_better":
            regression = -regression  # Invert: decrease is bad
        
        print(f"{metric_name}: {regression:+.1f}%")
        
        if regression > args.threshold:
            regressions.append(f"{metric_name} regressed by {regression:.1f}%")
    
    # Report
    if regressions:
        print(f"\n❌ REGRESSION DETECTED:")
        for r in regressions:
            print(f"   - {r}")
        sys.exit(1)
    else:
        print(f"\n✅ No significant regression (threshold: {args.threshold}%)")
        sys.exit(0)

if __name__ == '__main__':
    main()
```

### Testing Regression Script

```bash
# Create mock data
echo '{"handshake_ms": 125}' > current.json
echo '{"handshake_ms": 100}' > baseline.json

# Run check (should fail with 25% regression)
python3 scripts/check-regression.py --current current.json --baseline baseline.json --threshold 10
```

Expected output:
```
Handshake Time: +25.0%
❌ REGRESSION DETECTED:
   - Handshake Time regressed by 25.0%
```

---

## 📝 Task 3: PR Comment with Results (15 min + Bonus)

### Goal
Post benchmark results as a comment on GitHub Pull Requests.

### Implementation

Add to `.github/workflows/pqc-test.yml`:

```yaml
  comment-results:
    runs-on: ubuntu-latest
    needs: build-and-test
    if: github.event_name == 'pull_request'
    
    steps:
      - name: Download results
        uses: actions/download-artifact@v3
        with:
          name: benchmark-results
      
      - name: Generate comment
        id: comment
        run: |
          # Parse JSON and create Markdown comment
          python3 <<EOF
          import json
          
          with open('benchmark-results.json') as f:
              results = json.load(f)
          
          comment = f"""
          ## 🔐 PQC Benchmark Results
          
          | Metric | Value |
          |--------|-------|
          | Handshake Time | {results.get('handshake_ms', 'N/A')} ms |
          | Throughput | {results.get('throughput_rps', 'N/A')} req/s |
          | CPU Usage | {results.get('cpu_percent', 'N/A')}% |
          
          [View full report](https://github.com/${{github.repository}}/actions/runs/${{github.run_id}})
          """
          
          # Write to file for next step
          with open('comment.md', 'w') as f:
              f.write(comment)
          EOF
      
      - name: Post comment
        uses: actions/github-script@v6
        with:
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            const fs = require('fs');
            const comment = fs.readFileSync('comment.md', 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

---

## 🧪 Testing CI/CD Pipeline

### Test 1: Local Testing

Before pushing to GitHub, test locally:

```bash
# Install act (GitHub Actions local runner)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow locally
act push -W .github/workflows/pqc-test.yml
```

### Test 2: Push to GitHub

```bash
git add .github/workflows/pqc-test.yml
git commit -m "Add PQC CI/CD pipeline"
git push origin feature/pqc-ci

# Create PR and check Actions tab
```

### Test 3: Trigger Manual Run

```yaml
# Add to workflow triggers
on:
  workflow_dispatch:  # Manual trigger
```

Then trigger from GitHub UI: Actions → PQC TLS Testing → Run workflow

---

## ✅ Success Criteria

Your CI/CD pipeline should:
- [x] Build PQC Docker images automatically
- [x] Run TLS configuration tests
- [x] Execute performance benchmarks
- [x] Detect performance regressions
- [x] Generate and upload reports
- [x] Post results to PR comments
- [x] Fail builds on significant regressions

---

## 🎓 Bonus Challenges

### Bonus 1: GitLab CI Version

Create `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - benchmark
  - report

variables:
  DOCKER_DRIVER: overlay2

build:
  stage: build
  script:
    - docker build -t pqc-nginx:$CI_COMMIT_SHA -f labs/00-setup/docker/nginx.Dockerfile .

test:
  stage: test
  script:
    - docker-compose up -d
    - bash labs/01-manual-discovery/scripts/test-tls.sh

benchmark:
  stage: benchmark
  script:
    - python3 labs/07-advanced-workshop/workshops/02-benchmark/benchmark.py
  artifacts:
    paths:
      - benchmark-results.json

report:
  stage: report
  script:
    - python3 labs/07-advanced-workshop/workshops/03-reporting/build_report.py
  artifacts:
    paths:
      - report.html
```

### Bonus 2: Slack/Discord Notifications

Add to GitHub Actions:

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'PQC benchmark failed! Check results.'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Bonus 3: Cache Dependencies

Speed up builds with caching:

```yaml
- name: Cache Python dependencies
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-
```

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Docker in CI/CD](https://docs.docker.com/ci-cd/github-actions/)

---

## 🔗 Completion

Congratulations! You've completed all 4 workshops in Lab 07:

1. ✅ TLS Scanner
2. ✅ Automated Benchmarking
3. ✅ Reporting Dashboard
4. ✅ CI/CD Integration

---

<div align="center">

[← Workshop 3](../03-reporting/) | [Back to Lab 07](../../README.md)

**🎉 Lab 07 Complete! Return to main labs.**

</div>
