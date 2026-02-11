#!/usr/bin/env python3
"""
TLS Scanner - Starter Code
Workshop 1: Build your own TLS scanner

TODO: Complete the implementation based on README.md instructions
"""

import ssl
import socket
import json
import sys
from datetime import datetime
from typing import Dict, Any

# Optional: Install with pip install cryptography colorama
try:
    from cryptography import x509
    from cryptography.hazmat.backends import default_backend
    CRYPTO_AVAILABLE = True
except ImportError:
    print("WARNING: cryptography module not available. Install with: pip install cryptography")
    CRYPTO_AVAILABLE = False

try:
    from colorama import Fore, Style, init
    init(autoreset=True)
    COLORAMA_AVAILABLE = True
except ImportError:
    print("WARNING: colorama module not available. Install with: pip install colorama")
    COLORAMA_AVAILABLE = False
    # Fallback: no colors
    class Fore:
        RED = GREEN = YELLOW = CYAN = BLUE = MAGENTA = ''
    class Style:
        RESET_ALL = ''


def scan_tls_endpoint(host: str, port: int = 443, timeout: int = 10) -> Dict[str, Any]:
    """
    Scan a TLS endpoint and extract configuration details.
    
    Args:
        host: Target hostname or IP
        port: Target port (default 443)
        timeout: Connection timeout in seconds
    
    Returns:
        Dictionary with scan results
    
    TODO: Implement the following steps:
    1. Create TLS context and connection
    2. Extract protocol version and cipher suite
    3. Get certificate and parse details
    4. Detect post-quantum algorithms
    5. Return structured results
    """
    result = {
        "host": host,
        "port": port,
        "timestamp": datetime.now().isoformat(),
        "success": False,
        "error": None
    }
    
    try:
        # TODO Step 1: Create SSL context
        # Hint: context = ssl.create_default_context()
        
        # TODO Step 2: Establish connection
        # Hint: with socket.create_connection((host, port), timeout=timeout) as sock:
        #           with context.wrap_socket(sock, server_hostname=host) as ssock:
        
        # TODO Step 3: Get protocol and cipher information
        # Hint: protocol = ssock.version()
        #       cipher = ssock.cipher()
        
        # TODO Step 4: Get certificate
        # Hint: der_cert = ssock.getpeercert(binary_form=True)
        
        # TODO Step 5: Parse certificate (if cryptography is available)
        # Hint: cert = x509.load_der_x509_certificate(der_cert, default_backend())
        
        # TODO Step 6: Detect PQC algorithms
        
        result["success"] = True
        
        # Placeholder - replace with your implementation
        result["message"] = "TODO: Implement scan_tls_endpoint()"
        
    except socket.timeout:
        result["error"] = f"Connection timeout after {timeout}s"
    except socket.gaierror:
        result["error"] = f"Cannot resolve hostname: {host}"
    except ssl.SSLError as e:
        result["error"] = f"SSL/TLS error: {str(e)}"
    except Exception as e:
        result["error"] = f"Unexpected error: {str(e)}"
    
    return result


def detect_pqc_algorithms(cert, cipher_name: str) -> Dict[str, Any]:
    """
    Detect if post-quantum algorithms are in use.
    
    Args:
        cert: X.509 certificate object
        cipher_name: Cipher suite name
    
    Returns:
        Dictionary with PQC detection results
    
    TODO: Check for:
    - ML-DSA/Dilithium in signature algorithm
    - ML-KEM/Kyber in cipher suite
    - Hybrid constructions (X25519+MLKEM768)
    """
    pqc = {
        "detected": False,
        "signature": False,
        "key_exchange": False,
        "algorithms": []
    }
    
    # TODO: Implement PQC detection
    # Hint: Check cert.signature_algorithm_oid._name
    # Hint: Check if 'MLKEM' or 'MLDSA' in cipher_name
    
    return pqc


def print_human_readable(result: Dict[str, Any]) -> None:
    """
    Print scan results in a human-readable format with colors.
    
    Args:
        result: Scan result dictionary
    
    TODO: Format output with colors and structure
    """
    print()
    print(f"{Fore.CYAN}{'='*60}{Style.RESET_ALL}")
    print(f"{Fore.GREEN}TLS Scanner Results{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'='*60}{Style.RESET_ALL}")
    print()
    
    if not result.get("success"):
        print(f"{Fore.RED}✗ Scan failed: {result.get('error', 'Unknown error')}{Style.RESET_ALL}")
        return
    
    # TODO: Print detailed results
    # - Host and port
    # - Protocol version
    # - Cipher suite
    # - Certificate details
    # - PQC detection status
    
    print(f"TODO: Implement print_human_readable()")
    print()


def main():
    """
    Main entry point for the TLS scanner.
    """
    import argparse
    
    parser = argparse.ArgumentParser(
        description='TLS Scanner - Analyze TLS/SSL configurations',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s example.com
  %(prog)s localhost --port 8443
  %(prog)s google.com --json > scan.json
"""
    )
    
    parser.add_argument(
        'host',
        help='Target hostname or IP address'
    )
    
    parser.add_argument(
        '--port', '-p',
        type=int,
        default=443,
        help='Target port (default: 443)'
    )
    
    parser.add_argument(
        '--timeout', '-t',
        type=int,
        default=10,
        help='Connection timeout in seconds (default: 10)'
    )
    
    parser.add_argument(
        '--json', '-j',
        action='store_true',
        help='Output results as JSON'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Verbose output'
    )
    
    args = parser.parse_args()
    
    # Perform scan
    if args.verbose:
        print(f"Scanning {args.host}:{args.port}...", file=sys.stderr)
    
    result = scan_tls_endpoint(args.host, args.port, args.timeout)
    
    # Output results
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print_human_readable(result)
    
    # Exit code
    sys.exit(0 if result.get("success") else 1)


if __name__ == '__main__':
    main()
