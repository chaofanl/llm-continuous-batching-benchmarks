import re

log_file_path = 'debug.log'

pattern = re.compile(
    r"ts:(?P<timestamp>[\d.]+)s g:(?P<g>\d+) mu:(?P<mu>[\d.]+)GB mmu:(?P<mmu>[\d.]+)GB \| (?P<action>\w+) \| (.*)"
)

def parse_logs(log_file_path):
    logs = []
    with open(log_file_path, 'r') as file:
        for line in file:
            match = pattern.match(line.strip())
            if match:
                logs.append(match.groupdict())
    return logs

def parse_timestamp(ts):
    return float(ts)

def calculate_latencies(logs):
    prefill_latencies = []
    first_token_latencies = []
    prefill_start_time = None
    first_token_start_time = None
    first_token_end_time = None
    # print(logs)
    # exit()
    for log in logs:
        timestamp = parse_timestamp(log['timestamp'])
        action = log['action']

        if action == "PREFILL":
            prefill_start_time = timestamp
            first_token_start_time = None
            first_token_end_time = None

        if action == "GENERATE" and prefill_start_time:
            if not first_token_start_time:
                first_token_start_time = timestamp
                prefill_latencies.append(first_token_start_time - prefill_start_time)
            elif not first_token_end_time :
                first_token_end_time = timestamp
                first_token_latencies.append(first_token_end_time - prefill_start_time)
                continue
                
    return prefill_latencies, first_token_latencies

def main():
    logs = parse_logs(log_file_path)
    prefill_latencies, first_token_latencies = calculate_latencies(logs)
    
    print("Prefill Latencies:", prefill_latencies[-5:])
    print("First Token Latencies:", first_token_latencies[-5:])

if __name__ == "__main__":
    main()

