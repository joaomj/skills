#!/usr/bin/env python3
"""Check Python files don't exceed 300 lines."""
import sys


def main():
    violations = []
    for filepath in sys.argv[1:]:
        if not filepath.endswith('.py'):
            continue
        try:
            with open(filepath) as f:
                line_count = sum(1 for _ in f)
            if line_count > 300:
                violations.append((filepath, line_count))
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
            sys.exit(1)
    
    if violations:
        print("Files exceeding 300 lines:")
        for filepath, count in violations:
            print(f"  {filepath}: {count} lines")
        sys.exit(1)
    
    sys.exit(0)


if __name__ == "__main__":
    main()
