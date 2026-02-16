# 🚨 IMPORTANT: Path & Directory Name Changes

**Created:** February 11, 2026  
**Issue:** Documentation references may not match actual directory names

---

## ⚠️ Known Issues with Documentation

### Issue 1: No Pre-compiled Binaries

**What docs originally said:**
```bash
tar -xzf openssl-3.x-oqs-linux-x64.tar.gz
export PATH="$PWD/openssl-oqs/bin:$PATH"
```

**Reality:**
- ❌ This file doesn't exist from OQS
- ❌ `openssl-oqs/` directory doesn't exist initially
- ✅ Must build from source (30-40 min) OR use Docker

### Issue 2: Source Code vs Binaries

**If you downloaded from GitHub:**
```bash
wget .../oqs-provider-0.11.0.tar.gz
tar -xzf oqs-provider-0.11.0.tar.gz
```

**You get:**
- ✅ `oqs-provider-0.11.0/` (source code)
- ❌ NOT `openssl-oqs/` (would be binaries)

---

## 📝 Correct Directory Names

### After Download (Source Code):

```
binaries/
├── oqs-provider-0.11.0/           ← What you actually get
│   ├── CMakeLists.txt
│   ├── oqsprov/                   ← Source code
│   └── examples/
└── oqs-provider-0.11.0.tar.gz     ← Downloaded file
```

### After Build (if you built from source):

```
binaries/
├── openssl-oqs/                   ← Created by build process
│   ├── bin/openssl                ← Executable here
│   ├── lib/
│   │   ├── liboqs.so
│   │   ├── libssl.so
│   │   └── ossl-modules/
│   │       └── oqsprovider.so
│   └── openssl.cnf
├── liboqs/                        ← Source (can delete)
├── openssl/                       ← Source (can delete)
└── oqs-provider-0.11.0/           ← Source (can delete)
```

---

## ✅ Updated Instructions

### For Docker Users (⭐ RECOMMENDED):

```bash
# Skip all manual setup!
cd ~/pqcv2/labs/03-pqc-hybrid-setup
docker-compose -f docker-compose-hybrid.yml build
docker-compose -f docker-compose-hybrid.yml up -d
```

### For Manual Build Users:

See: `binaries/README-FIRST.md` for complete build instructions.

After building, set paths:
```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup/binaries
export PATH="$PWD/openssl-oqs/bin:$PATH"
export LD_LIBRARY_PATH="$PWD/openssl-oqs/lib:$LD_LIBRARY_PATH"
```

---

## 🔍 Files Updated with Warnings

The following files have been updated to include proper warnings:

- ✅ `guides/03-install-oqs.md` - Added "No pre-compiled binaries" warning
- ✅ `binaries/README-FIRST.md` - Complete explanation created
- ✅ `binaries/installation-guide.md` - Updated with correct info
- ✅ `setup.sh` - Added interactive warning before build
- ✅ `README.md` - Updated Part 2 with Docker recommendation
- ✅ `IMPORTANT-PATH-NOTES.md` - This file (summary)

---

## 🎯 Quick Decision Guide

**Question:** What should I do?

| Your Situation | Recommendation |
|----------------|----------------|
| Just want it to work | Use Docker ⭐ |
| Downloaded tar.gz already | Still use Docker (it builds internally) |
| Want to learn the process | Build from source (30-40 min) |
| Getting path errors | Read `binaries/README-FIRST.md` |
| Confused about directories | Directory names change after build! |

---

## 📌 Key Takeaways

1. **OQS doesn't provide pre-compiled binaries** - must build or use Docker
2. **Source tarball** extracts to `oqs-provider-X.Y.Z/` (not `openssl-oqs/`)
3. **`openssl-oqs/` directory** is created by build process, not in download
4. **Docker handles everything** - builds internally during image creation
5. **Manual build takes 30-40 minutes** - be prepared

---

## 🆘 If You're Stuck Right Now

1. **Check what you have:**
   ```bash
   ls ~/pqcv2/labs/03-pqc-hybrid-setup/binaries/
   ```

2. **If you see** `oqs-provider-0.11.0/`:
   - This is source code
   - Choose: Docker OR manual build
   - Read: `binaries/README-FIRST.md`

3. **If you see** `openssl-oqs/`:
   - You built successfully!
   - Set environment variables
   - Continue with lab

4. **If unsure:**
   - Use Docker (safest option)
   - No manual building needed

---

**Last Updated:** February 11, 2026
