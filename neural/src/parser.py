"""
Чистая логика парсинга строк
"""

import re

def parse_text_to_fields(raw_text: str) -> dict:
    sn_pattern = r'SN-[A-Za-z0-9]+'
    batch_pattern = r'B-\d+'

    sn_match = re.search(sn_pattern, raw_text)
    serial_number = sn_match.group(0) if sn_match else "N/A"

    batch_match = re.search(batch_pattern, raw_text)
    batch_number = batch_match.group(0) if batch_match else "N/A"

    if serial_number == "N/A" and raw_text:
        serial_number = raw_text.strip()

    return {
        "serial_number": serial_number,
        "batch_number": batch_number
    }