import json
import sys

def merge_json(target_path, source_path):
    with open(target_path, 'r', encoding='utf-8') as f:
        target = json.load(f)
    with open(source_path, 'r', encoding='utf-8') as f:
        source = json.load(f)
    
    target.update(source)
    
    with open(target_path, 'w', encoding='utf-8') as f:
        json.dump(target, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 merge_json.py <target_path> <source_path>")
        sys.exit(1)
    merge_json(sys.argv[1], sys.argv[2])
