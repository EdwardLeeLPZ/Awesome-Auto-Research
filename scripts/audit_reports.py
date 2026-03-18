#!/usr/bin/env python3
"""
audit_reports.py — 检查 reports/ 目录下所有报告的质量
验证每份报告包含完整章节、足够行数和内容深度。
支持 emoji 前缀标题（如 ## 📌 Project Overview）。
"""

import sys
from pathlib import Path

REPO_DIR = Path(__file__).parent.parent
REPORTS_DIR = REPO_DIR / "reports"

# 每个条目是一组同义词（用|分隔），只需匹配其中一个 H2 标题即可
REQUIRED_SECTION_KEYWORDS = [
    "overview|positioning",
    "architecture",
    "workflow|component",
    "features|capabilit|component",
    "technical|implement|detail",
    "benchmark|evaluat|performance",
    "strength|advantage",
    "limitation|weakness|constraint",
    "related",
    "reference",
]

MIN_TOTAL_LINES = 150
MIN_SECTION_LINES = 3


def heading_matches(heading: str, keyword_group: str) -> bool:
    h = heading.lower()
    return any(kw in h for kw in keyword_group.split("|"))


def audit_file(path: Path) -> list[str]:
    """Return list of issue strings; empty list = pass."""
    issues = []
    lines = path.read_text(encoding="utf-8").splitlines()
    h2_headings = [l for l in lines if l.startswith("## ")]

    # Check total non-empty line count
    content_lines = [l for l in lines if l.strip()]
    if len(content_lines) < MIN_TOTAL_LINES:
        issues.append(
            f"too short ({len(content_lines)} non-empty lines, need {MIN_TOTAL_LINES})"
        )

    # Check each required section
    for keyword_group in REQUIRED_SECTION_KEYWORDS:
        matched_heading = next(
            (h for h in h2_headings if heading_matches(h, keyword_group)), None
        )
        if not matched_heading:
            issues.append(f"missing section matching: '{keyword_group}'")
            continue

        # Count content lines inside that section
        in_section = False
        section_content = 0
        for line in lines:
            if line == matched_heading:
                in_section = True
                continue
            if in_section:
                if line.startswith("## "):
                    break
                if line.strip():
                    section_content += 1

        if section_content < MIN_SECTION_LINES:
            issues.append(
                f"section '{matched_heading.strip()}' too thin "
                f"({section_content} lines, need {MIN_SECTION_LINES})"
            )

    return issues


def main():
    report_files = sorted(
        f for f in REPORTS_DIR.glob("*.md") if f.name != "README.md"
    )

    if not report_files:
        print("No report files found.")
        sys.exit(1)

    print(f"Auditing {len(report_files)} reports in {REPORTS_DIR}\n")
    print(f"{'File':<40} {'Status':<10} Issues")
    print("-" * 90)

    any_failed = False
    for report in report_files:
        issues = audit_file(report)
        if issues:
            any_failed = True
            print(f"{report.name:<40} {'❌  FAIL':<10} {issues[0]}")
            for issue in issues[1:]:
                print(f"{'':40} {'':10} {issue}")
        else:
            print(f"{report.name:<40} {'✅  PASS':<10}")

    print()
    if any_failed:
        print("Some reports failed quality checks.")
        sys.exit(1)
    else:
        print("All reports pass quality checks.")
        sys.exit(0)


if __name__ == "__main__":
    main()
