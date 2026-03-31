#!/usr/bin/env python3
"""
VLCKit SPM Generator
Downloads VLCKit, MobileVLCKit, and TVVLCKit from VideoLAN and packages them as xcframeworks.
"""

import argparse
import os
import re
import shutil
import subprocess

VLC_URL = "https://download.videolan.org/pub/cocoapods/prod/"
TMP_DIR = ".tmp"
PACKAGE_SWIFT = "./Package.swift"

PRODUCTS = {
    "VLCKit": {
        "platforms": ["macOS"],
        "file_pattern": r'VLCKit-[0-9]+\.[^"]+\.tar\.xz',
    },
    "MobileVLCKit": {
        "platforms": ["iOS", "watchOS", "visionOS"],
        "file_pattern": r'MobileVLCKit-[0-9]+\.[^"]+\.tar\.xz',
    },
    "TVVLCKit": {
        "platforms": ["tvOS"],
        "file_pattern": r'TVVLCKit-[0-9]+\.[^"]+\.tar\.xz',
    },
}


def run(cmd, check=True, capture_output=False):
    print(f"  $ {cmd}")
    result = subprocess.run(
        cmd, shell=True, check=check, capture_output=capture_output, text=True
    )
    if capture_output:
        return result.stdout.strip()
    return result


def get_html():
    print(f"Fetching {VLC_URL}...")
    return run(f"curl -sL {VLC_URL}", capture_output=True)


def find_latest(products_key):
    """Find latest version for a given product."""
    pattern = PRODUCTS[products_key]["file_pattern"]
    matches = re.findall(pattern, get_html())

    if not matches:
        raise Exception(f"Could not find any {products_key} files")

    # Sort by version number
    def version_key(s):
        v = re.search(r"([0-9]+\.[0-9]+\.[0-9]+)", s)
        return tuple(int(x) for x in v.group(1).split(".")) if v else (0,)

    matches.sort(key=version_key, reverse=True)
    return matches[0]


def find_xcframework(tmp_dir, product_name):
    """Find the xcframework directory in tmp."""
    for item in os.listdir(tmp_dir):
        item_path = os.path.join(tmp_dir, item)
        xcframework_path = os.path.join(item_path, f"{product_name}.xcframework")
        if os.path.isdir(xcframework_path):
            return xcframework_path
        # Handle names with spaces like "VLCKit - binary package"
        if item.endswith(f"{product_name}.xcframework"):
            return item_path
    return None


def extract_version(filename):
    """Extract version like 3.7.3 from filename."""
    match = re.search(r"([0-9]+\.[0-9]+\.[0-9]+)", filename)
    return match.group(1) if match else "unknown"


def package_xcframework(xcframework_path, output_name):
    """Create a zip from xcframework."""
    zip_path = f"./{output_name}.xcframework.zip"
    if os.path.exists(zip_path):
        os.remove(zip_path)
    print(f"  Creating {zip_path}...")
    run(f'ditto -c -k --sequesterRsrc --keepParent "{xcframework_path}" "{zip_path}"')
    return zip_path


def compute_checksum(zip_path):
    """Compute SHA256 checksum for zip."""
    print(f"  Computing checksum...")
    return run(f"swift package compute-checksum {zip_path}", capture_output=True)


def update_package_swift(version, checksums):
    """Update Package.swift with version and checksums for each product."""
    print("Updating Package.swift...")

    with open(PACKAGE_SWIFT, "r") as f:
        lines = f.readlines()

    # Map target name -> (checksum, zip_name)
    # Package.swift uses "VLCKitXC" but results key is "VLCKit", etc.
    target_name_map = {
        "VLCKitXC": "VLCKit",
        "MobileVLCKitXC": "MobileVLCKit",
        "TVVLCKitXC": "TVVLCKit",
    }
    target_data = {}
    for name, data in checksums.items():
        zip_name = data["zip"].replace("./", "").replace(".xcframework.zip", "")
        target_data[name] = (data["checksum"], zip_name)

    current_target = None
    in_binary_target = False
    block_depth = 0  # Track nested parens

    for i, line in enumerate(lines):
        # Detect start of binaryTarget block (may span multiple lines)
        if ".binaryTarget(" in line and current_target is None:
            in_binary_target = True
            block_depth = line.count("(") - line.count(")")
            # Check if name is on this line
            name_match = re.search(r'name:\s*"(\w+)"', line)
            if name_match:
                current_target = name_match.group(1)
        elif in_binary_target:
            block_depth += line.count("(") - line.count(")")
            # Check for name
            name_match = re.search(r'name:\s*"(\w+)"', line)
            if name_match:
                current_target = name_match.group(1)

        if in_binary_target:
            # Map target name (e.g. VLCKitXC -> VLCKit) to look up in target_data
            lookup_name = target_name_map.get(current_target, current_target)
            if lookup_name in target_data:
                checksum, zip_name = target_data[lookup_name]

                # Update checksum (handles "placeholder" or actual checksum)
                if "checksum:" in line:
                    lines[i] = re.sub(
                        r'(checksum:\s*)"[^"]*"', r'\1"' + checksum + '"', line
                    )

                # Update URL
                if "url:" in line:
                    new_url = f"https://github.com/zackaryhuang/vlckit-spm/releases/download/v{version}/{zip_name}.xcframework.zip"
                    lines[i] = re.sub(r'(url:\s*)"[^"]*"', r'\1"' + new_url + '"', line)

        # End of block
        if in_binary_target and block_depth <= 0:
            in_binary_target = False
            current_target = None

    with open(PACKAGE_SWIFT, "w") as f:
        f.writelines(lines)

    print(f"  Updated to version {version}")


def copy_license(tmp_dir):
    """Copy LICENSE file from the first product."""
    for item in os.listdir(tmp_dir):
        item_path = os.path.join(tmp_dir, item)
        lic = os.path.join(item_path, "COPYING.txt")
        if os.path.exists(lic):
            shutil.copy(lic, "./LICENSE")
            print(f"  Copied LICENSE from {item}")
            return
        # Check subdirectory
        lic = os.path.join(item_path, "COPYING.txt")
        if os.path.exists(lic):
            shutil.copy(lic, "./LICENSE")
            print(f"  Copied LICENSE from {item}")
            return


def process_product(name):
    """Download, extract, and package a single product."""
    print(f"\n[{name}]")

    latest_file = find_latest(name)
    url = VLC_URL + latest_file
    version = extract_version(latest_file)
    print(f"  Latest: {latest_file}")
    print(f"  Version: {version}")
    print(f"  URL: {url}")

    product_tmp = os.path.join(TMP_DIR, name)
    if os.path.exists(product_tmp):
        shutil.rmtree(product_tmp)
    os.makedirs(product_tmp, exist_ok=True)

    # Download
    tar_path = os.path.join(product_tmp, "download.tar.xz")
    print(f"  Downloading...")
    run(f'curl -L -o "{tar_path}" "{url}"')

    # Extract
    print(f"  Extracting...")
    run(f"tar -xf {tar_path} -C {product_tmp}")

    # Find xcframework
    xcframework_path = find_xcframework(product_tmp, name)
    if not xcframework_path:
        raise Exception(f"Could not find {name}.xcframework after extraction")

    # Check platforms
    print(f"  Found xcframework: {xcframework_path}")
    platforms = os.listdir(xcframework_path)
    print(f"  Platforms: {', '.join(platforms)}")

    # Package
    zip_path = package_xcframework(xcframework_path, name)

    # Checksum
    checksum = compute_checksum(zip_path)
    print(f"  Checksum: {checksum}")

    return name, version, zip_path, checksum


def main():
    parser = argparse.ArgumentParser(description="Generate VLCKit SPM packages")
    parser.add_argument(
        "--products",
        nargs="+",
        choices=["VLCKit", "MobileVLCKit", "TVVLCKit"],
        default=["VLCKit", "MobileVLCKit", "TVVLCKit"],
        help="Products to download (default: all)",
    )
    args = parser.parse_args()

    print("=" * 60)
    print("VLCKit SPM Generator")
    print("=" * 60)

    # Create tmp directory
    os.makedirs(TMP_DIR, exist_ok=True)

    results = {}
    for product in args.products:
        try:
            name, version, zip_path, checksum = process_product(product)
            results[name] = {"version": version, "checksum": checksum, "zip": zip_path}
        except Exception as e:
            print(f"  ERROR: {e}")
            if not args.products or len(args.products) > 1:
                continue
            raise

    if not results:
        print("No products were successfully processed.")
        return

    # Use the highest version
    version = max(v["version"] for v in results.values())

    # Update Package.swift
    print("\n[Package.swift]")
    update_package_swift(version, results)

    # Copy license
    print("\n[LICENSE]")
    copy_license(TMP_DIR)

    # Cleanup
    print("\n[Cleanup]")
    shutil.rmtree(TMP_DIR)
    print("  Removed .tmp/")

    # Summary
    print("\n" + "=" * 60)
    print("Done!")
    print("=" * 60)
    for name, data in results.items():
        print(f"  {name}.xcframework.zip ({data['version']}): {data['checksum']}")
    print(f"\nVersion: {version}")
    print("Push to git and create a new release with version tag: 'v{version}'")
    print("Include all .xcframework.zip files in that release.")


if __name__ == "__main__":
    main()
