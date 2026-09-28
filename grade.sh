#!/bin/bash

echo "=========================="
echo "Assignment 1 grader"
echo "=========================="

echo ""
echo "Checking required files..."

required_files=(
    "README.md"
    "system-info.sh"
    "disk-check.sh"
    "network-check.sh"
    "grade.sh"
    "logs/.gitkeep"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "PASS: $file"
    else
        echo "FAIL: $file is missing"
    fi
done
echo ""
echo "Checking Bash syntax..."

for script in system-info.sh disk-check.sh network-check.sh grade.sh; do
    if bash -n "$script"; then
        echo "PASS: $script syntax"
    else
        echo "FAIL: $script syntax"
    fi
done
echo ""
echo "Checking executable permissions..."

for script in system-info.sh disk-check.sh network-check.sh grade.sh; do
    if [ -x "$script" ]; then
        echo "PASS: $script is executable"
    else
        echo "FAIL: $script is not executable"
    fi
done
echo ""
echo "Checking system-info.sh output..."

if ./system-info.sh > /tmp/system-info-output.txt 2>&1; then
    echo "PASS: system-info.sh ran successfully"
else
    echo "FAIL: system-info.sh failed to run"
fi

for item in "Hostname:" "Current User:" "Date/Time:" "Operating System:" "Kernel Version:" "Uptime:" "CPU Information:" "Memory Information:" "Current Working Directory:"; do
    if grep -q "$item" /tmp/system-info-output.txt; then
        echo "PASS: $item"
    else
        echo "FAIL: $item is missing"
    fi
done
echo ""
echo "Checking disk-check.sh validation..."

./disk-check.sh > /tmp/disk-check-output.txt 2>&1
disk_status=$?

if [ "$disk_status" -eq 2 ]; then
    echo "PASS: Missing threshold rejected"
else
    echo "FAIL: Missing threshold returned $disk_status"
fi

./disk-check.sh abc > /tmp/disk-invalid-output.txt 2>&1
disk_status=$?

if [ "$disk_status" -eq 2 ]; then
    echo "PASS: Invalid threshold rejected"
else
    echo "FAIL: Invalid threshold returned $disk_status"
fi
echo ""
echo "Checking network-check.sh validation..."

./network-check.sh > /tmp/network-check-output.txt 2>&1
network_status=$?

if [ "$network_status" -ne 0 ]; then
    echo "PASS: Missing host rejected"
else
    echo "FAIL: Missing host was accepted"
fi

./network-check.sh google.com 70000 > /tmp/network-invalid-output.txt 2>&1
network_status=$?

if [ "$network_status" -eq 2 ]; then
    echo "PASS: Invalid port rejected"
else
    echo "FAIL: Invalid port returned $network_status"
fi
echo ""
echo "Checking logging directory..."

if [ -d "logs" ]; then
    echo "PASS: logs directory exists"
else
    echo "FAIL: logs directory is missing"
fi

if [ -f "logs/.gitkeep" ]; then
    echo "PASS: logs/.gitkeep exists"
else
    echo "FAIL: logs/.gitkeep is missing"
fi
echo ""
echo "Checking Git history..."

if [ -d ".git" ]; then
    echo "PASS: Git repository exists"

    if git log -1 --oneline >/dev/null 2>&1; then
        echo "PASS: Git commit exists"
    else
        echo "FAIL: No Git commit found"
    fi
else
    echo "FAIL: Git repository not found"
fi

echo""
echo "=========================="
echo "Grading complete"
echo "=========================="