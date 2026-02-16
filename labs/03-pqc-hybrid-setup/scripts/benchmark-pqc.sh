#!/bin/bash
# Quick Performance Benchmark Script
# สคริปต์ทดสอบประสิทธิภาพอย่างรวดเร็ว

set -e

# Configuration
SERVER=${SERVER:-localhost}
PORT=${PORT:-8443}
ITERATIONS=${ITERATIONS:-10}
OUTPUT_DIR="results"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}PQC Performance Benchmark${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Server: $SERVER:$PORT"
echo "Iterations: $ITERATIONS"
echo ""

# Function to test algorithm
test_algorithm() {
    local name=$1
    local group=$2
    local output_file="$OUTPUT_DIR/benchmark-$name.txt"
    
    echo -e "${YELLOW}Testing $name...${NC}"
    
    local total_time=0
    local success_count=0
    
    > "$output_file"  # Clear file
    
    for i in $(seq 1 $ITERATIONS); do
        start=$(date +%s%3N)
        
        if echo "" | timeout 5 openssl s_client \
            -connect "$SERVER:$PORT" \
            -groups "$group" \
            -brief &>/dev/null; then
            
            end=$(date +%s%3N)
            elapsed=$((end - start))
            total_time=$((total_time + elapsed))
            success_count=$((success_count + 1))
            echo "$elapsed" >> "$output_file"
        else
            echo "FAILED" >> "$output_file"
        fi
        
        # Progress indicator
        printf "."
    done
    
    echo ""  # New line after progress dots
    
    if [ $success_count -gt 0 ]; then
        local avg_time=$((total_time / success_count))
        echo -e "${GREEN}✓ $name: ${avg_time}ms average (${success_count}/${ITERATIONS} successful)${NC}"
        return 0
    else
        echo -e "${RED}✗ $name: All tests failed${NC}"
        return 1
    fi
}

# Test algorithms
echo -e "${BLUE}Testing Key Exchange Algorithms:${NC}"
echo ""

# Classical algorithms
test_algorithm "X25519-Classical" "X25519" || true
test_algorithm "P-256-Classical" "P-256" || true

# Hybrid algorithms
test_algorithm "X25519+Kyber768-Hybrid" "x25519_kyber768" || true
test_algorithm "X25519+Kyber1024-Hybrid" "x25519_kyber1024" || true
test_algorithm "P-256+Kyber768-Hybrid" "p256_kyber768" || true

# Pure PQC (if server supports)
test_algorithm "Kyber768-Pure-PQC" "kyber768" || true
test_algorithm "Kyber1024-Pure-PQC" "kyber1024" || true

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Certificate Size Analysis${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Get certificate sizes
get_cert_size() {
    local name=$1
    local sigalg=$2
    
    local size=$(echo "" | timeout 5 openssl s_client \
        -connect "$SERVER:$PORT" \
        -sigalgs "$sigalg" 2>/dev/null | \
        grep -A 999 "BEGIN CERTIFICATE" | \
        grep -B 999 "END CERTIFICATE" | \
        wc -c)
    
    if [ "$size" -gt 0 ]; then
        local kb=$((size / 1024))
        echo -e "${GREEN}$name: ${size} bytes (~${kb} KB)${NC}"
    else
        echo -e "${RED}$name: Unable to retrieve${NC}"
    fi
}

get_cert_size "ECDSA-Certificate" "ecdsa_secp256r1" || true
get_cert_size "ML-DSA-Certificate" "mldsa65" || true

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Calculate statistics from results
calculate_stats() {
    local file=$1
    local name=$2
    
    if [ ! -f "$file" ]; then
        return
    fi
    
    local values=$(grep -v "FAILED" "$file" | sort -n)
    local count=$(echo "$values" | wc -l)
    
    if [ "$count" -eq 0 ]; then
        return
    fi
    
    local min=$(echo "$values" | head -1)
    local max=$(echo "$values" | tail -1)
    local median=$(echo "$values" | awk '{a[NR]=$0} END {print (NR%2==1)?a[(NR+1)/2]:(a[NR/2]+a[NR/2+1])/2}')
    
    echo "$name:"
    echo "  Min: ${min}ms"
    echo "  Max: ${max}ms"
    echo "  Median: ${median}ms"
    echo ""
}

calculate_stats "$OUTPUT_DIR/benchmark-X25519-Classical.txt" "X25519 (Classical)"
calculate_stats "$OUTPUT_DIR/benchmark-X25519+Kyber768-Hybrid.txt" "X25519+Kyber768 (Hybrid)"
calculate_stats "$OUTPUT_DIR/benchmark-Kyber768-Pure-PQC.txt" "Kyber768 (Pure PQC)"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Overhead Calculation${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Calculate overhead
classical_avg=$(grep -v "FAILED" "$OUTPUT_DIR/benchmark-X25519-Classical.txt" 2>/dev/null | awk '{sum+=$1; count++} END {print sum/count}' || echo "0")
hybrid_avg=$(grep -v "FAILED" "$OUTPUT_DIR/benchmark-X25519+Kyber768-Hybrid.txt" 2>/dev/null | awk '{sum+=$1; count++} END {print sum/count}' || echo "0")

if [ "$classical_avg" != "0" ] && [ "$hybrid_avg" != "0" ]; then
    overhead=$(echo "scale=1; ($hybrid_avg - $classical_avg) / $classical_avg * 100" | bc)
    echo "Classical average: ${classical_avg}ms"
    echo "Hybrid average: ${hybrid_avg}ms"
    echo -e "${YELLOW}Performance overhead: ${overhead}%${NC}"
else
    echo -e "${RED}Unable to calculate overhead (insufficient data)${NC}"
fi

echo ""
echo -e "${GREEN}Benchmark complete! Results saved to $OUTPUT_DIR/${NC}"
echo ""

# Generate CSV summary
CSV_FILE="$OUTPUT_DIR/benchmark-summary.csv"
echo "Algorithm,Min_ms,Max_ms,Median_ms,Avg_ms,Success_Rate" > "$CSV_FILE"

for result_file in "$OUTPUT_DIR"/benchmark-*.txt; do
    if [ -f "$result_file" ]; then
        name=$(basename "$result_file" .txt | sed 's/benchmark-//')
        values=$(grep -v "FAILED" "$result_file" | sort -n)
        count=$(echo "$values" | wc -l)
        total=$(echo "$ITERATIONS")
        
        if [ "$count" -gt 0 ]; then
            min=$(echo "$values" | head -1)
            max=$(echo "$values" | tail -1)
            median=$(echo "$values" | awk '{a[NR]=$0} END {print (NR%2==1)?a[(NR+1)/2]:(a[NR/2]+a[NR/2+1])/2}')
            avg=$(echo "$values" | awk '{sum+=$1; count++} END {print sum/count}')
            success_rate=$(echo "scale=1; $count / $total * 100" | bc)
            
            echo "$name,$min,$max,$median,$avg,$success_rate%" >> "$CSV_FILE"
        fi
    fi
done

echo -e "CSV summary: ${CSV_FILE}"
echo ""
echo -e "${BLUE}Done!${NC}"
