# Lab 05: Analysis & Reporting
# การวิเคราะห์และสร้างรายงาน

⏱️ **Duration:** 90 minutes  
🎯 **Objective:** Compare results, visualize data, and generate professional reports

---

## 📖 Overview | ภาพรวม

The final core lab! You've collected performance data from both classical and hybrid TLS. Now we'll:
- Compare results systematically
- Visualize differences with charts
- Generate bilingual (EN/TH) PDF reports
- Create NIST compliance mapping
- Make data-driven recommendations

Lab สุดท้ายของ Core! คุณเก็บข้อมูลประสิทธิภาพจาก TLS แบบ classical และ hybrid แล้ว ตอนนี้เราจะ:
- เปรียบเทียบผลลัพธ์อย่างเป็นระบบ
- แสดงภาพความแตกต่างด้วยกราฟ
- สร้างรายงาน PDF แบบสองภาษา (EN/TH)
- แมพกับมาตรฐาน NIST
- ให้ข้อเสนอแนะโดยอิงข้อมูล

---

## 🎯 Learning Objectives

After this lab, you will be able to:
- Aggregate data from multiple experiments
- Calculate statistical significance
- Create professional visualizations
- Generate executive summaries
- Map to compliance frameworks (NIST, ISO)
- Write data-driven migration recommendations

---

## 📊 Part 1: Data Aggregation (20 min)

### Step 1.1: Collect All Data

```bash
cd ~/pqcv2/labs/05-analysis-reporting

# Copy results from previous labs
mkdir -p data/{classical,hybrid}

# Classical data (Lab 02)
cp ../02-baseline-testing/results/* data/classical/

# Hybrid data (Lab 04)
cp ../04-hybrid-testing/results/* data/hybrid/
```

### Step 1.2: Run Aggregation Script

```bash
python3 scripts/aggregate-data.py \
  --classical data/classical/ \
  --hybrid data/hybrid/ \
  --output data/aggregated.json
```

**This creates:**
```json
{
  "classical": {
    "handshake_ms": {"mean": 12.3, "median": 11.8, "std": 2.1},
    "cpu_percent": {"idle": 2.5, "load": 23.4},
    "throughput_rps": 2341,
    "cert_size_bytes": 1220
  },
  "hybrid": {
    ...similar structure...
  },
  "comparison": {
    "handshake_overhead_ms": 35.2,
    "handshake_overhead_percent": 186.2,
    ...
  }
}
```

📖 **Script documentation:** [scripts/README-aggregate.md](scripts/README-aggregate.md)

---

## 📈 Part 2: Data Visualization (25 min)

### Step 2.1: Generate Comparison Charts

```bash
python3 scripts/generate-charts.py data/aggregated.json
```

**Creates charts:**
1. `handshake-comparison.png` - Bar chart
2. `cpu-usage-comparison.png` - Grouped bar chart
3. `throughput-comparison.png` - Line chart
4. `certificate-size.png` - Size comparison
5. `overhead-breakdown.png` - Pie chart

### Step 2.2: Customize Charts (Optional)

Edit `scripts/generate-charts.py` to:
- Change colors
- Add Thai labels
- Adjust sizes
- Add annotations

### Step 2.3: Interactive Dashboard (Optional)

```bash
# Generate interactive HTML dashboard
python3 scripts/create-dashboard.py data/aggregated.json

# Open in browser
firefox visualizations/dashboard.html
```

---

## 📝 Part 3: Report Generation (30 min)

### Step 3.1: Customize Report Template

Edit `templates/report-template.html`:

```html
<h1>Post-Quantum Cryptography Migration Analysis</h1>
<h2>การวิเคราะห์การย้ายไป Post-Quantum Cryptography</h2>

<div class="executive-summary">
  <h2>Executive Summary | บทสรุปสำหรับผู้บริหาร</h2>
  <p>
    <strong>EN:</strong> This report presents performance analysis
    of hybrid post-quantum TLS implementation...
  </p>
  <p>
    <strong>TH:</strong> รายงานนี้นำเสนอการวิเคราะห์ประสิทธิภาพ
    ของการนำ TLS แบบ hybrid post-quantum มาใช้...
  </p>
</div>
```

📖 **Template guide:** [templates/customization-guide.md](templates/customization-guide.md)

### Step 3.2: Generate PDF Report

```bash
python3 scripts/build-report.py \
  --data data/aggregated.json \
  --template templates/report-template.html \
  --charts visualizations/ \
  --output reports/pqc-migration-report.pdf
```

**Report includes:**
- Executive summary (bilingual)
- Methodology description
- Performance comparison tables
- Visualizations (charts)
- Statistical analysis
- Recommendations
- NIST compliance mapping
- Appendices

### Step 3.3: Generate HTML Version

```bash
# For web viewing
python3 scripts/build-report.py \
  --format html \
  --output reports/pqc-migration-report.html
```

---

## 🗺️ Part 4: NIST Compliance Mapping (15 min)

### Step 4.1: Check NIST Requirements

📝 **[worksheets/nist-compliance-checklist.md](worksheets/nist-compliance-checklist.md)**

```markdown
# NIST PQC Migration Readiness

## FIPS 203 (ML-KEM) Compliance
- [x] Uses NIST-approved algorithm (MLKEM768)
- [ ] Proper key generation
- [x] Secure parameter sizes (security level 3)
- Comment: _____________________

## FIPS 204 (ML-DSA) Compliance
- [x] Uses NIST-approved signature (MLDSA65)
- [ ] Certificate validation implemented
- [x] Secure parameter sizes (security level 3)

## Hybrid Approach (NIST Recommendation)
- [x] Combines classical + PQC
- [x] Fails securely if one component breaks
- [x] Uses XOR or KDF for key combination

## Timeline (NIST Guidance)
- [ ] Migration started before 2025
- [ ] Full deployment by 2030
- [ ] "Harvest now, decrypt later" mitigation
```

---

## 💡 Part 5: Recommendations & Conclusions (15 min)

### Step 5.1: Decision Matrix

📝 **[worksheets/decision-matrix.md](worksheets/decision-matrix.md)**

| Factor | Weight | Classical | Hybrid PQC | Winner |
|--------|--------|-----------|------------|--------|
| Security (Quantum) | 40% | 0/10 | 10/10 | Hybrid |
| Performance | 25% | 10/10 | 7/10 | Classical |
| Compatibility | 20% | 10/10 | 8/10 | Classical |
| Future-proof | 15% | 2/10 | 10/10 | Hybrid |
| **Weighted Score** | | **5.9/10** | **8.8/10** | **Hybrid** ✅ |

### Step 5.2: Migration Recommendation

Based on your data, fill in:

```markdown
# Migration Recommendation | ข้อเสนอแนะการย้ายระบบ

## Performance Impact Summary
- Handshake overhead: +____% 
- Throughput impact: -____%
- Certificate size: +____%

## Recommendation: [Immediate / Short-term / Long-term]

### For Production Deployment:
✅ **Recommended IF:**
- High-security requirements
- Long-term data confidentiality needed
- Can accept ___% performance overhead
- Certificate bandwidth not critical

⚠️ **Caution IF:**
- Extremely high-frequency trading
- IoT devices with limited resources
- Legacy client compatibility required

### Phased Rollout Strategy:
1. **Phase 1** (Months 1-3): Test in staging
2. **Phase 2** (Months 4-6): Deploy to internal services
3. **Phase 3** (Months 7-9): Deploy to public-facing APIs
4. **Phase 4** (Months 10-12): Full production rollout

### Monitoring & Rollback:
- Monitor handshake failures
- Track performance metrics
- Have classical fallback ready
- Review quarterly
```

---

## 🎯 Lab Checklist

- [ ] Aggregated data from Labs 02 & 04
- [ ] Generated comparison charts (5+ visualizations)
- [ ] Created statistical analysis
- [ ] Customized report template
- [ ] Generated PDF report (bilingual)
- [ ] Completed NIST compliance checklist
- [ ] Filled decision matrix
- [ ] Wrote migration recommendations
- [ ] Created executive summary
- [ ] Reviewed final report

---

## 📁 Files Structure

```
labs/05-analysis-reporting/
├── README.md (this file)
│
├── data/
│   ├── classical/ (from Lab 02)
│   ├── hybrid/ (from Lab 04)
│   └── aggregated.json ⭐ (combined data)
│
├── scripts/
│   ├── aggregate-data.py (combine data sources)
│   ├── generate-charts.py (matplotlib/plotly)
│   ├── build-report.py (HTML/PDF generation)
│   ├── create-dashboard.py (interactive dashboard)
│   └── statistical-tests.py (t-test, significance)
│
├── templates/
│   ├── report-template.html (main template)
│   ├── executive-summary.md (customizable)
│   ├── nist-compliance.md (checklist template)
│   └── styles.css (report styling)
│
├── worksheets/
│   ├── nist-compliance-checklist.md ⭐
│   ├── decision-matrix.md ⭐
│   └── recommendations-template.md
│
├── visualizations/
│   ├── handshake-comparison.png
│   ├── cpu-usage-comparison.png
│   ├── throughput-comparison.png
│   ├── certificate-size.png
│   └── dashboard.html
│
└── reports/
    ├── pqc-migration-report.pdf ⭐⭐⭐ (final report)
    ├── pqc-migration-report.html
    └── executive-summary.pdf (1-page version)
```

---

## 📊 Sample Report Sections

### Executive Summary Example

```
[LOGO]

POST-QUANTUM CRYPTOGRAPHY MIGRATION ANALYSIS
EXECUTIVE SUMMARY

Prepared by: [Your Name]
Date: [Today's Date]
Lab: Hybrid Classical-Post-Quantum TLS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

KEY FINDINGS

✓ Hybrid PQC successfully implemented with MLKEM768 + MLDSA65
✓ Performance overhead: +186% handshake time, -15% throughput
✓ Security: Quantum-resistant for 20+ years
✓ Compliance: Meets NIST FIPS 203/204 standards

RECOMMENDATION: Proceed with phased migration over 12 months

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Detailed sections follow...]
```

---

## 🐛 Troubleshooting

### Issue: Charts not generating

```bash
# Install required Python packages
pip3 install matplotlib pandas numpy

# Or use requirements.txt
pip3 install -r requirements.txt
```

### Issue: PDF generation fails

```bash
# Install wkhtmltopdf
sudo apt-get install wkhtmltopdf

# Or use alternative
python3 -m pip install pdfkit weasyprint
```

### Issue: Data files not found

```bash
# Check paths
ls -R data/

# Re-run tests if data missing
cd ../02-baseline-testing && ./scripts/collect-metrics.sh
cd ../04-hybrid-testing && ./scripts/collect-metrics.sh
```

---

## 💡 Key Takeaways

- **Data-driven decisions** are crucial for PQC migration
- **Visualization** helps communicate technical findings
- **Bilingual reporting** increases accessibility
- **NIST compliance** provides credibility
- **Phased rollout** reduces risk
- **Performance overhead is acceptable** for most applications
- **Quantum threat is real** - migration justified

---

## 🎉 Congratulations!

You've completed the 5 core labs! You now have:

✅ Understanding of quantum threats  
✅ Hands-on PQC implementation experience  
✅ Performance measurement skills  
✅ Data analysis capabilities  
✅ Professional reporting skills  
✅ Migration planning framework  

### What's Next?

- **Bonus Lab 06:** VPN Hybrid Implementation
- **Bonus Lab 07:** Automation Workshop
- **Bonus Lab 08:** Compliance Mapping Deep Dive

Or apply these skills to your own infrastructure!

<div align="center">

[← Lab 04](../04-hybrid-testing/) | [Main](../../README.md) | [Bonus Labs →](../06-vpn-hybrid/)

**✅ CORE LABS COMPLETE! 🎓**

</div>
