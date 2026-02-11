# References | แหล่งอ้างอิง

Academic papers, standards, and resources used in this lab.

---

## 🏛️ Official Standards & Publications

### NIST Post-Quantum Cryptography

1. **NIST FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard**
   - Published: August 13, 2024
   - URL: https://csrc.nist.gov/pubs/fips/203/final
   - Description: ML-KEM (formerly CRYSTALS-Kyber) standard
   - Relevant: ML-KEM-768 used in Lab 03-05

2. **NIST FIPS 204: Module-Lattice-Based Digital Signature Standard**
   - Published: August 13, 2024
   - URL: https://csrc.nist.gov/pubs/fips/204/final
   - Description: ML-DSA (formerly CRYSTALS-Dilithium) standard
   - Relevant: ML-DSA-65 used in Lab 03-05

3. **NIST SP 800-207: Zero Trust Architecture**
   - Published: August 2020
   - URL: https://csrc.nist.gov/publications/detail/sp/800-207/final
   - Relevance: Context for enterprise deployment (Lab 08)

4. **NIST IR 8413: Status Report on the Third Round of the NIST Post-Quantum Cryptography Standardization Process**
   - Published: July 2022
   - URL: https://csrc.nist.gov/publications/detail/nistir/8413/final

### IETF Standards & Drafts

5. **RFC 8446: The Transport Layer Security (TLS) Protocol Version 1.3**
   - Published: August 2018
   - URL: https://www.rfc-editor.org/rfc/rfc8446
   - Relevance: TLS 1.3 baseline

6. **draft-ietf-tls-hybrid-design: Hybrid key exchange in TLS 1.3**
   - Status: Internet-Draft (Active)
   - URL: https://datatracker.ietf.org/doc/draft-ietf-tls-hybrid-design/
   - Relevance: Hybrid KEM composition (Lab 03)

7. **draft-ounsworth-pq-composite-sigs: Composite Signatures For Use In Internet PKI**
   - Status: Internet-Draft
   - URL: https://datatracker.ietf.org/doc/draft-ounsworth-pq-composite-sigs/
   - Relevance: Hybrid signature algorithms

8. **RFC 7748: Elliptic Curves for Security**
   - Published: January 2016
   - URL: https://www.rfc-editor.org/rfc/rfc7748
   - Relevance: X25519 algorithm (classical component)

### ISO/IEC Standards

9. **ISO/IEC 27001:2022 - Information security management**
   - Relevance: Compliance considerations (Lab 08)

10. **ISO/IEC 27002:2022 - Information security controls**
    - Relevance: Security controls mapping (Lab 08)

---

## 📚 Research Papers

### Quantum Computing Threats

11. **Shor, P. W. (1997). "Polynomial-Time Algorithms for Prime Factorization and Discrete Logarithms on a Quantum Computer"**
    - SIAM Journal on Computing, 26(5), 1484-1509
    - DOI: 10.1137/S0097539795293172
    - Relevance: Foundation of quantum threat to RSA/ECC

12. **Mosca, M. (2018). "Cybersecurity in an Era with Quantum Computers: Will We Be Ready?"**
    - IEEE Security & Privacy, 16(5), 38-41
    - DOI: 10.1109/MSP.2018.3761723
    - Relevance: Timeline and readiness (Lab 01)

### Post-Quantum Cryptography

13. **Alagic, G., et al. (2020). "Status Report on the Second Round of the NIST Post-Quantum Cryptography Standardization Process"**
    - NIST Interagency Report 8309
    - URL: https://csrc.nist.gov/publications/detail/nistir/8309/final

14. **Bos, J., et al. (2018). "CRYSTALS-Kyber: A CCA-Secure Module-Lattice-Based KEM"**
    - 2018 IEEE European Symposium on Security and Privacy (EuroS&P)
    - DOI: 10.1109/EuroSP.2018.00032
    - Relevance: ML-KEM-768 algorithm design

15. **Ducas, L., et al. (2018). "CRYSTALS-Dilithium: A Lattice-Based Digital Signature Scheme"**
    - IACR Transactions on Cryptographic Hardware and Embedded Systems, 2018(1)
    - DOI: 10.13154/tches.v2018.i1.238-268
    - Relevance: ML-DSA-65 algorithm design

### Performance & Implementation

16. **Sikeridis, D., et al. (2020). "Post-Quantum Authentication in TLS 1.3: A Performance Study"**
    - Proceedings of NDSS 2020
    - DOI: 10.14722/ndss.2020.24203
    - Relevance: Performance benchmarking methodology (Lab 02, 04)

17. **Paquin, C., Stebila, D., & Tamvada, G. (2020). "Benchmarking Post-Quantum Cryptography in TLS"**
    - Post-Quantum Cryptography, PQCrypto 2020
    - DOI: 10.1007/978-3-030-44223-1_7
    - Relevance: Comparative analysis (Lab 05)

18. **Kampanakis, P., et al. (2021). "The Viability of Post-Quantum X.509 Certificates"**
    - IACR Cryptology ePrint Archive, Report 2021/601
    - URL: https://eprint.iacr.org/2021/601
    - Relevance: Certificate size overhead (Lab 03)

### Hybrid Approaches

19. **Bindel, N., et al. (2019). "Transitioning to a Quantum-Resistant Public Key Infrastructure"**
    - Post-Quantum Cryptography, PQCrypto 2017
    - DOI: 10.1007/978-3-319-59879-6_22
    - Relevance: Migration strategy (Lab 08)

20. **Hoffman, P. (2022). "The Transition from Classical to Post-Quantum Cryptography"**
    - The Internet Protocol Journal, 25(2)
    - Relevance: Deployment considerations (Lab 08)

---

## 🛠️ Software & Libraries

### Open Quantum Safe Project

21. **liboqs - C library for quantum-resistant cryptographic algorithms**
    - GitHub: https://github.com/open-quantum-safe/liboqs
    - Documentation: https://openquantumsafe.org/liboqs/
    - Version used: 0.10.0+
    - License: MIT

22. **oqs-provider - OpenSSL 3 provider for post-quantum cryptography**
    - GitHub: https://github.com/open-quantum-safe/oqs-provider
    - Documentation: https://github.com/open-quantum-safe/oqs-provider/wiki
    - Version used: 0.6.0+
    - License: MIT

23. **OQS-OpenSSL - Fork of OpenSSL with PQC support**
    - GitHub: https://github.com/open-quantum-safe/openssl
    - Note: Labs use OpenSSL 3.x + oqs-provider instead

### Testing & Analysis Tools

24. **testssl.sh - Testing TLS/SSL encryption**
    - GitHub: https://github.com/drwetter/testssl.sh
    - Version: 3.0+
    - License: GPLv2
    - Used in: Lab 01

25. **OpenSSL - Cryptography and SSL/TLS Toolkit**
    - Website: https://www.openssl.org/
    - Version: 3.0.0+
    - License: Apache License 2.0
    - Used in: All labs

---

## 📖 Books & Textbooks

26. **Bernstein, D. J., & Lange, T. (2017). "Post-quantum cryptography"**
    - Nature, 549(7671), 188-194
    - Overview article for general audience

27. **Chen, L., et al. (Eds.). (2016). "Report on Post-Quantum Cryptography"**
    - NIST Interagency Report 8105
    - Comprehensive introduction to PQC

28. **Katz, J., & Lindell, Y. (2020). "Introduction to Modern Cryptography" (3rd Edition)**
    - CRC Press
    - ISBN: 978-0815354369
    - General cryptography textbook

---

## 🌐 Online Resources

### Documentation & Wikis

29. **Open Quantum Safe Documentation**
    - URL: https://openquantumsafe.org/
    - Comprehensive guides, algorithms, integration

30. **NIST PQC Project Page**
    - URL: https://csrc.nist.gov/projects/post-quantum-cryptography
    - Official standards, news, updates

31. **PQShield Blog - Post-Quantum Cryptography**
    - URL: https://pqshield.com/blog/
    - Industry perspectives, case studies

### Tutorials & Courses

32. **Coursera: Quantum Computing Fundamentals**
    - Platform: Coursera
    - Institution: Various
    - Background for understanding quantum threats

33. **Applied Cryptography course materials (Dan Boneh, Stanford)**
    - URL: https://crypto.stanford.edu/~dabo/courses/
    - Cryptography foundations

---

## 🎥 Videos & Presentations

34. **NIST PQC Standardization: Announcement of Draft Standards (2022)**
    - URL: https://csrc.nist.gov/presentations/2022/announcement-pqc-candidates-to-be-standardized
    - Official NIST presentation

35. **Google Security Blog: Experimenting with Quantum-Resistant Cryptography (2016-present)**
    - URL: https://security.googleblog.com/
    - Real-world experiments by Google

36. **Cloudflare Blog: Post-Quantum Cryptography Series**
    - URL: https://blog.cloudflare.com/tag/post-quantum/
    - Implementation stories

---

## 📊 Datasets & Benchmarks

37. **SUPERCOP: System for Unified Performance Evaluation Related to Cryptographic Operations and Primitives**
    - URL: https://bench.cr.yp.to/supercop.html
    - Performance benchmarks for cryptographic primitives

38. **eBACS: ECRYPT Benchmarking of Cryptographic Systems**
    - URL: https://bench.cr.yp.to/
    - Comparative performance data

---

## 🏢 Industry Reports & White Papers

39. **Cisco: Quantum Threat Timeline Report (2023)**
    - Estimates for quantum computer availability
    - Risk assessment framework

40. **IBM: Quantum Safe Cryptography and Security White Paper (2024)**
    - URL: https://www.ibm.com/quantum/quantum-safe
    - Enterprise migration strategies

41. **Microsoft: Post-quantum TLS now supported in Azure Key Vault (2023)**
    - URL: https://azure.microsoft.com/en-us/blog/
    - Cloud provider implementations

42. **ETSI: Quantum-Safe Cryptography Standards**
    - URL: https://www.etsi.org/technologies/quantum-safe-cryptography
    - European standards perspective

---

## 🔐 Security Advisories

43. **CVE Database - Cryptographic vulnerabilities**
    - URL: https://cve.mitre.org/
    - Search: "cryptography", "TLS", "SSL"

44. **CERT Coordination Center - Cryptographic bulletins**
    - URL: https://www.kb.cert.org/vuls/
    - Security advisories

---

## 📰 News & Updates

### Recommended Sources for Staying Current

- **NIST Cybersecurity News**: https://www.nist.gov/cybersecurity
- **Schneier on Security**: https://www.schneier.com/
- **Cryptography Mailing List**: https://www.metzdowd.com/mailman/listinfo/cryptography
- **/r/crypto subreddit**: https://www.reddit.com/r/crypto/

---

## 📝 Citation Guidelines

### BibTeX Entry for This Lab

```bibtex
@misc{pqcv2lab2026,
  title={Hybrid Classical-Post-Quantum TLS Laboratory},
  author={Your Name},
  year={2026},
  howpublished={\url{https://github.com/yourusername/pqcv2}},
  note={Educational laboratory for PQC migration}
}
```

### Citing NIST Standards

```bibtex
@techreport{nist2024fips203,
  title={{FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard}},
  author={{National Institute of Standards and Technology}},
  year={2024},
  institution={U.S. Department of Commerce},
  url={https://csrc.nist.gov/pubs/fips/203/final}
}

@techreport{nist2024fips204,
  title={{FIPS 204: Module-Lattice-Based Digital Signature Standard}},
  author={{National Institute of Standards and Technology}},
  year={2024},
  institution={U.S. Department of Commerce},
  url={https://csrc.nist.gov/pubs/fips/204/final}
}
```

---

## 🔄 Updates & Changelog

This references document is updated regularly. Notable changes:

- **2026-02-10**: Initial version for lab release
- **Standards**: FIPS 203/204 (2024) - Current as of Feb 2026
- **Libraries**: liboqs 0.10.0, oqs-provider 0.6.0

For the latest updates, check:
- NIST PQC Project: https://csrc.nist.gov/projects/post-quantum-cryptography
- OQS GitHub: https://github.com/open-quantum-safe

---

<div align="center">

[← Back to README](README.md) | [Documentation →](docs/)

</div>
