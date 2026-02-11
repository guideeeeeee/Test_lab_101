#!/bin/bash
# VPN Performance Benchmark Script
# สคริปต์วัดประสิทธิภาพ VPN

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   VPN Performance Benchmark Tool      ║${NC}"
echo -e "${GREEN}║   For IPsec Hybrid PQC Testing        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo

# Configuration
REMOTE_HOST="${1:-10.2.0.5}"
DURATION="${2:-30}"
RESULTS_DIR="results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Validate iperf3 availability
if ! command -v iperf3 &> /dev/null; then
    echo -e "${RED}ERROR: iperf3 not installed${NC}"
    echo "Install with: sudo apt install iperf3"
    exit 1
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Remote host: $REMOTE_HOST"
echo "  Test duration: ${DURATION}s"
echo "  Results dir: $RESULTS_DIR"
echo

# Function: Test throughput
test_throughput() {
    local streams=$1
    local output_file="${RESULTS_DIR}/throughput_${streams}streams_${TIMESTAMP}.json"
    
    echo -e "${YELLOW}[1/4] Testing throughput (${streams} parallel streams)...${NC}"
    
    if iperf3 -c "$REMOTE_HOST" -t "$DURATION" -P "$streams" -J > "$output_file" 2>&1; then
        # Extract key metrics
        local bitrate=$(jq -r '.end.sum_received.bits_per_second' "$output_file" 2>/dev/null || echo "0")
        local mbps=$(echo "scale=2; $bitrate / 1000000" | bc)
        
        echo -e "${GREEN}  ✓ Throughput: ${mbps} Mbps${NC}"
        echo "$mbps" > "${RESULTS_DIR}/throughput_${streams}streams.txt"
    else
        echo -e "${RED}  ✗ Throughput test failed${NC}"
        return 1
    fi
}

# Function: Test latency
test_latency() {
    local count=100
    local output_file="${RESULTS_DIR}/latency_${TIMESTAMP}.txt"
    
    echo -e "${YELLOW}[2/4] Testing latency (${count} pings)...${NC}"
    
    if ping -c "$count" -i 0.2 "$REMOTE_HOST" > "$output_file" 2>&1; then
        # Parse ping statistics
        local avg_latency=$(grep "rtt min/avg/max" "$output_file" | awk -F'/' '{print $5}')
        local min_latency=$(grep "rtt min/avg/max" "$output_file" | awk -F'/' '{print $4}')
        local max_latency=$(grep "rtt min/avg/max" "$output_file" | awk -F'/' '{print $6}')
        
        echo -e "${GREEN}  ✓ Latency: min=${min_latency}ms avg=${avg_latency}ms max=${max_latency}ms${NC}"
        echo "$avg_latency" > "${RESULTS_DIR}/latency_avg.txt"
    else
        echo -e "${RED}  ✗ Latency test failed${NC}"
        return 1
    fi
}

# Function: Test connection establishment time
test_connection_time() {
    echo -e "${YELLOW}[3/4] Testing VPN connection establishment time...${NC}"
    
    local output_file="${RESULTS_DIR}/connection_time_${TIMESTAMP}.txt"
    local iterations=5
    local total_time=0
    
    for i in $(seq 1 $iterations); do
        echo -n "  Attempt $i/$iterations: "
        
        # Tear down connection
        sudo ipsec down site-to-site-hybrid >/dev/null 2>&1 || true
        sleep 2
        
        # Measure connection time
        local start=$(date +%s%N)
        if sudo ipsec up site-to-site-hybrid >/dev/null 2>&1; then
            local end=$(date +%s%N)
            local duration=$(( (end - start) / 1000000 )) # Convert to ms
            
            echo -e "${GREEN}${duration}ms${NC}"
            echo "$duration" >> "$output_file"
            total_time=$((total_time + duration))
        else
            echo -e "${RED}Failed${NC}"
        fi
        
        sleep 3
    done
    
    # Calculate average
    local avg_time=$((total_time / iterations))
    echo -e "${GREEN}  ✓ Average connection time: ${avg_time}ms${NC}"
    echo "$avg_time" > "${RESULTS_DIR}/connection_time_avg.txt"
}

# Function: Monitor CPU/Memory during load
monitor_resources() {
    local monitor_duration=$1
    local output_file="${RESULTS_DIR}/resources_${TIMESTAMP}.csv"
    
    echo -e "${YELLOW}[4/4] Monitoring CPU/Memory for ${monitor_duration}s...${NC}"
    
    echo "timestamp,cpu_percent,memory_mb" > "$output_file"
    
    # Get VPN container/process ID
    local vpn_pid=$(pgrep -f "charon" | head -1)
    
    if [ -z "$vpn_pid" ]; then
        echo -e "${RED}  ✗ Cannot find VPN process${NC}"
        return 1
    fi
    
    # Monitor in background
    for i in $(seq 1 "$monitor_duration"); do
        local cpu=$(ps -p "$vpn_pid" -o %cpu= | tr -d ' ')
        local mem=$(ps -p "$vpn_pid" -o rss= | awk '{print $1/1024}') # KB to MB
        local timestamp=$(date +%s)
        
        echo "${timestamp},${cpu},${mem}" >> "$output_file"
        sleep 1
    done
    
    # Calculate averages
    local avg_cpu=$(awk -F',' 'NR>1 {sum+=$2; count++} END {print sum/count}' "$output_file")
    local avg_mem=$(awk -F',' 'NR>1 {sum+=$3; count++} END {print sum/count}' "$output_file")
    
    echo -e "${GREEN}  ✓ Average CPU: ${avg_cpu}%${NC}"
    echo -e "${GREEN}  ✓ Average Memory: ${avg_mem} MB${NC}"
    
    echo "$avg_cpu" > "${RESULTS_DIR}/cpu_avg.txt"
    echo "$avg_mem" > "${RESULTS_DIR}/memory_avg.txt"
}

# Function: Generate comparison report
generate_report() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Benchmark Summary              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    
    echo
    echo "Throughput:"
    if [ -f "${RESULTS_DIR}/throughput_1streams.txt" ]; then
        echo "  Single stream:   $(cat ${RESULTS_DIR}/throughput_1streams.txt) Mbps"
    fi
    if [ -f "${RESULTS_DIR}/throughput_4streams.txt" ]; then
        echo "  4 streams:       $(cat ${RESULTS_DIR}/throughput_4streams.txt) Mbps"
    fi
    
    echo
    echo "Latency:"
    if [ -f "${RESULTS_DIR}/latency_avg.txt" ]; then
        echo "  Average RTT:     $(cat ${RESULTS_DIR}/latency_avg.txt) ms"
    fi
    
    echo
    echo "Connection Time:"
    if [ -f "${RESULTS_DIR}/connection_time_avg.txt" ]; then
        echo "  Average:         $(cat ${RESULTS_DIR}/connection_time_avg.txt) ms"
    fi
    
    echo
    echo "Resource Usage:"
    if [ -f "${RESULTS_DIR}/cpu_avg.txt" ]; then
        echo "  CPU:             $(cat ${RESULTS_DIR}/cpu_avg.txt)%"
    fi
    if [ -f "${RESULTS_DIR}/memory_avg.txt" ]; then
        echo "  Memory:          $(cat ${RESULTS_DIR}/memory_avg.txt) MB"
    fi
    
    echo
    echo -e "${YELLOW}Detailed results saved in: ${RESULTS_DIR}/${NC}"
    
    # Create JSON summary
    cat > "${RESULTS_DIR}/summary_${TIMESTAMP}.json" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "remote_host": "$REMOTE_HOST",
  "test_duration": $DURATION,
  "throughput_mbps": {
    "single_stream": $(cat ${RESULTS_DIR}/throughput_1streams.txt 2>/dev/null || echo 0),
    "four_streams": $(cat ${RESULTS_DIR}/throughput_4streams.txt 2>/dev/null || echo 0)
  },
  "latency_ms": $(cat ${RESULTS_DIR}/latency_avg.txt 2>/dev/null || echo 0),
  "connection_time_ms": $(cat ${RESULTS_DIR}/connection_time_avg.txt 2>/dev/null || echo 0),
  "cpu_percent": $(cat ${RESULTS_DIR}/cpu_avg.txt 2>/dev/null || echo 0),
  "memory_mb": $(cat ${RESULTS_DIR}/memory_avg.txt 2>/dev/null || echo 0)
}
EOF
    
    echo -e "${GREEN}Summary JSON: ${RESULTS_DIR}/summary_${TIMESTAMP}.json${NC}"
}

# Main execution
main() {
    echo -e "${YELLOW}Starting benchmark suite...${NC}"
    echo
    
    # Run tests
    test_throughput 1
    sleep 5
    test_throughput 4
    sleep 5
    test_latency
    sleep 5
    test_connection_time
    sleep 5
    
    # Monitor resources during throughput test
    echo -e "${YELLOW}Running final throughput test with resource monitoring...${NC}"
    iperf3 -c "$REMOTE_HOST" -t "$DURATION" -P 4 >/dev/null 2>&1 &
    IPERF_PID=$!
    monitor_resources "$DURATION"
    wait $IPERF_PID 2>/dev/null || true
    
    # Generate report
    generate_report
    
    echo
    echo -e "${GREEN}✓ Benchmark complete!${NC}"
}

# Run with error handling
if ! main; then
    echo -e "${RED}Benchmark encountered errors. Check output above.${NC}"
    exit 1
fi
