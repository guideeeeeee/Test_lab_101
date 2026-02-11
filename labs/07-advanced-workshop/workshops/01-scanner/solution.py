#!/usr/bin/env python3
"""
TLS Scanner - Reference Solution
Workshop 1: Build your own TLS scanner

This is a complete implementation for reference.
Try to implement your own before looking at this!
"""

import ssl
import socket
import json
import sys
from datetime import datetime
from typing import Dict, Any, Optional

try:
    from cryptography import x509
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.primitives.asymmetric import rsa, ec, dsa
    CRYPTO_AVAILABLE = True
except ImportError:
    print("ERROR: cryptography module required. Install with: pip install cryptography")
    sys.exit(1)

try:
    from colorama import Fore, Style, init
    init(autoreset=True)
    COLORAMA_AVAILABLE = True
except ImportError:
    COLORAMA_AVAILABLE = False
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
    """
    result = {
        "host": host,
        "port": port,
        "timestamp": datetime.now().isoformat(),
        "success": False,
        "error": None
    }
    
    try:
        # Step 1: Create SSL context with TLS 1.2+ support
        context = ssl.create_default_context()
        context.check_hostname = True
        context.verify_mode = ssl.CERT_REQUIRED
        
        # Step 2: Establish TCP connection and perform TLS handshake
        with socket.create_connection((host, port), timeout=timeout) as sock:
            with context.wrap_socket(sock, server_hostname=host) as ssock:
                
                # Step 3: Get protocol and cipher information
                protocol = ssock.version()
                cipher = ssock.cipher()
                
                result["protocol"] = {
                    "version": protocol,
                    "name": get_protocol_name(protocol)
                }
                
                result["cipher"] = {
                    "name": cipher[0],
                    "protocol": cipher[1],
                    "bits": cipher[2]
                }
                
                # Step 4: Get and parse certificate
                der_cert = ssock.getpeercert(binary_form=True)
                cert = x509.load_der_x509_certificate(der_cert, default_backend())
                
                result["certificate"] = parse_certificate(cert)
                
                # Step 5: Detect PQC algorithms
                result["pqc"] = detect_pqc_algorithms(cert, cipher[0])
                
                # Additional info
                result["compression"] = ssock.compression()
                
        result["success"] = True
        
    except socket.timeout:
        result["error"] = f"Connection timeout after {timeout}s"
    except socket.gaierror:
        result["error"] = f"Cannot resolve hostname: {host}"
    except ssl.SSLCertVerificationError as e:
        result["error"] = f"Certificate verification failed: {str(e)}"
        result["certificate_error"] = True
    except ssl.SSLError as e:
        result["error"] = f"SSL/TLS error: {str(e)}"
    except ConnectionRefusedError:
        result["error"] = f"Connection refused on port {port}"
    except Exception as e:
        result["error"] = f"Unexpected error: {type(e).__name__}: {str(e)}"
    
    return result


def get_protocol_name(version: str) -> str:
    """Convert version string to friendly name."""
    names = {
        'TLSv1': 'TLS 1.0',
        'TLSv1.1': 'TLS 1.1',
        'TLSv1.2': 'TLS 1.2',
        'TLSv1.3': 'TLS 1.3',
        'SSLv2': 'SSL 2.0 (INSECURE)',
        'SSLv3': 'SSL 3.0 (INSECURE)',
    }
    return names.get(version, version)


def parse_certificate(cert: x509.Certificate) -> Dict[str, Any]:
    """
    Extract detailed information from X.509 certificate.
    
    Args:
        cert: Certificate object
    
    Returns:
        Dictionary with certificate details
    """
    cert_info = {}
    
    # Subject and Issuer
    cert_info["subject"] = cert.subject.rfc4514_string()
    cert_info["issuer"] = cert.issuer.rfc4514_string()
    
    # Extract CN (Common Name)
    try:
        cn = cert.subject.get_attributes_for_oid(x509.oid.NameOID.COMMON_NAME)[0].value
        cert_info["common_name"] = cn
    except (IndexError, AttributeError):
        cert_info["common_name"] = "N/A"
    
    # Validity period
    cert_info["not_before"] = cert.not_valid_before.isoformat()
    cert_info["not_after"] = cert.not_valid_after.isoformat()
    
    # Check if expired
    now = datetime.now()
    cert_info["expired"] = now > cert.not_valid_after.replace(tzinfo=None)
    cert_info["not_yet_valid"] = now < cert.not_valid_before.replace(tzinfo=None)
    
    # Public key information
    public_key = cert.public_key()
    cert_info["public_key"] = get_public_key_info(public_key)
    
    # Signature algorithm
    cert_info["signature_algorithm"] = cert.signature_algorithm_oid._name
    
    # Serial number
    cert_info["serial_number"] = hex(cert.serial_number)
    
    # Extensions
    cert_info["extensions"] = parse_certificate_extensions(cert)
    
    return cert_info


def get_public_key_info(public_key) -> Dict[str, Any]:
    """Extract public key algorithm and size."""
    key_info = {}
    
    if isinstance(public_key, rsa.RSAPublicKey):
        key_info["algorithm"] = "RSA"
        key_info["size"] = public_key.key_size
        key_info["exponent"] = public_key.public_numbers().e
    elif isinstance(public_key, ec.EllipticCurvePublicKey):
        key_info["algorithm"] = "ECDSA"
        key_info["curve"] = public_key.curve.name
        key_info["size"] = public_key.key_size
    elif isinstance(public_key, dsa.DSAPublicKey):
        key_info["algorithm"] = "DSA"
        key_info["size"] = public_key.key_size
    else:
        key_info["algorithm"] = type(public_key).__name__
        key_info["size"] = getattr(public_key, 'key_size', None)
    
    return key_info


def parse_certificate_extensions(cert: x509.Certificate) -> Dict[str, Any]:
    """Parse certificate extensions."""
    extensions = {}
    
    try:
        # Subject Alternative Names
        san = cert.extensions.get_extension_for_oid(x509.oid.ExtensionOID.SUBJECT_ALTERNATIVE_NAME)
        extensions["san"] = [str(name) for name in san.value]
    except x509.ExtensionNotFound:
        pass
    
    try:
        # Key Usage
        key_usage = cert.extensions.get_extension_for_oid(x509.oid.ExtensionOID.KEY_USAGE)
        extensions["key_usage"] = {
            "digital_signature": key_usage.value.digital_signature,
            "key_encipherment": key_usage.value.key_encipherment,
        }
    except (x509.ExtensionNotFound, AttributeError):
        pass
    
    return extensions


def detect_pqc_algorithms(cert: x509.Certificate, cipher_name: str) -> Dict[str, Any]:
    """
    Detect if post-quantum algorithms are in use.
    
    Args:
        cert: X.509 certificate object
        cipher_name: Name of the cipher suite
    
    Returns:
        Dictionary with PQC detection results
    """
    pqc = {
        "detected": False,
        "signature": False,
        "key_exchange": False,
        "algorithms": [],
        "assessment": ""
    }
    
    # Check certificate signature algorithm for PQC
    sig_alg = cert.signature_algorithm_oid._name.lower()
    
    pqc_sig_keywords = ['mldsa', 'ml-dsa', 'dilithium', 'falcon', 'sphincs']
    for keyword in pqc_sig_keywords:
        if keyword in sig_alg:
            pqc["signature"] = True
            pqc["detected"] = True
            pqc["algorithms"].append(f"Signature: {cert.signature_algorithm_oid._name}")
            break
    
    # Check cipher suite for PQC key exchange
    cipher_upper = cipher_name.upper()
    pqc_kem_keywords = ['MLKEM', 'ML-KEM', 'KYBER', 'NTRU', 'SABER']
    
    for keyword in pqc_kem_keywords:
        if keyword in cipher_upper:
            pqc["key_exchange"] = True
            pqc["detected"] = True
            pqc["algorithms"].append(f"KEM: {cipher_name}")
            break
    
    # Check for hybrid constructions
    hybrid_patterns = ['X25519MLKEM', 'P256_MLKEM', 'ECDHE_MLKEM']
    for pattern in hybrid_patterns:
        if pattern.replace('_', '').upper() in cipher_upper.replace('_', ''):
            pqc["algorithms"].append("Hybrid: Classical + PQC")
            break
    
    # Assessment
    if pqc["detected"]:
        if pqc["signature"] and pqc["key_exchange"]:
            pqc["assessment"] = "Full PQC protection (signature + key exchange)"
        elif pqc["signature"]:
            pqc["assessment"] = "PQC signatures only (key exchange classical)"
        elif pqc["key_exchange"]:
            pqc["assessment"] = "PQC key exchange only (signature classical)"
    else:
        pqc["assessment"] = "Classical cryptography only (vulnerable to quantum attacks)"
    
    return pqc


def print_human_readable(result: Dict[str, Any]) -> None:
    """
    Print scan results in a human-readable format with colors.
    
    Args:
        result: Scan result dictionary
    """
    print()
    print(f"{Fore.CYAN}{'='*70}{Style.RESET_ALL}")
    print(f"{Fore.GREEN}{'TLS Scanner Results':^70}{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'='*70}{Style.RESET_ALL}")
    print()
    
    # Connection info
    print(f"{Fore.YELLOW}Target:{Style.RESET_ALL} {result['host']}:{result['port']}")
    print(f"{Fore.YELLOW}Scanned:{Style.RESET_ALL} {result['timestamp']}")
    print()
    
    if not result.get("success"):
        print(f"{Fore.RED}✗ Scan failed:{Style.RESET_ALL} {result.get('error', 'Unknown error')}")
        if result.get("certificate_error"):
            print(f"{Fore.YELLOW}Note:{Style.RESET_ALL} Certificate validation failed (may be self-signed)")
        print()
        return
    
    # Protocol information
    protocol = result.get("protocol", {})
    print(f"{Fore.CYAN}━━━ Protocol Information ━━━{Style.RESET_ALL}")
    print(f"  🔒 Version: {Fore.GREEN}{protocol.get('name', 'Unknown')}{Style.RESET_ALL}")
    print()
    
    # Cipher suite
    cipher = result.get("cipher", {})
    print(f"{Fore.CYAN}━━━ Cipher Suite ━━━{Style.RESET_ALL}")
    print(f"  🔑 Algorithm: {Fore.CYAN}{cipher.get('name', 'Unknown')}{Style.RESET_ALL}")
    print(f"  🔢 Key Size: {cipher.get('bits', 'Unknown')} bits")
    print()
    
    # Certificate information
    cert = result.get("certificate", {})
    print(f"{Fore.CYAN}━━━ Certificate ━━━{Style.RESET_ALL}")
    print(f"  📜 CN: {cert.get('common_name', 'N/A')}")
    print(f"  🏢 Issuer: {cert.get('issuer', 'N/A')[:60]}...")
    
    # Validity
    if cert.get("expired"):
        print(f"  ⚠️  Status: {Fore.RED}EXPIRED{Style.RESET_ALL}")
    elif cert.get("not_yet_valid"):
        print(f"  ⚠️  Status: {Fore.YELLOW}NOT YET VALID{Style.RESET_ALL}")
    else:
        print(f"  ✓  Status: {Fore.GREEN}Valid{Style.RESET_ALL}")
    
    print(f"  📅 Valid: {cert.get('not_before', 'N/A')[:10]} → {cert.get('not_after', 'N/A')[:10]}")
    
    # Public key
    pub_key = cert.get("public_key", {})
    print(f"  🔐 Public Key: {pub_key.get('algorithm', 'Unknown')} {pub_key.get('size', '?')} bits")
    print(f"  ✍️  Signature: {cert.get('signature_algorithm', 'Unknown')}")
    print()
    
    # PQC Detection
    pqc = result.get("pqc", {})
    print(f"{Fore.CYAN}━━━ Post-Quantum Cryptography ━━━{Style.RESET_ALL}")
    
    if pqc.get("detected"):
        print(f"  {Fore.GREEN}✓ PQC DETECTED!{Style.RESET_ALL}")
        print(f"  📊 Assessment: {pqc.get('assessment', 'Unknown')}")
        print(f"  🔬 Algorithms:")
        for alg in pqc.get("algorithms", []):
            print(f"     • {Fore.GREEN}{alg}{Style.RESET_ALL}")
    else:
        print(f"  {Fore.YELLOW}⚠  Classical cryptography only{Style.RESET_ALL}")
        print(f"  📊 Assessment: {pqc.get('assessment', 'Unknown')}")
        print(f"  💡 Recommendation: Consider upgrading to PQC hybrid mode")
    
    print()
    print(f"{Fore.CYAN}{'='*70}{Style.RESET_ALL}")
    print()


def main():
    """Main entry point for the TLS scanner."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='TLS Scanner - Analyze TLS/SSL configurations and detect PQC',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s example.com
  %(prog)s localhost --port 8443
  %(prog)s google.com --json > scan.json
  %(prog)s 192.168.1.1 -p 443 -v
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
    if args.verbose and not args.json:
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
