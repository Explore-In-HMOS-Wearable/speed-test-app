export function formatSpeed(speedMbps: number): string {
  if (speedMbps < 1) {
    return `${(speedMbps * 1000).toFixed(1)} Kbps`;
  } else {
    return `${speedMbps.toFixed(2)} Mbps`;
  }
}

export function formatTime(timeMs: number): string {
  return `${timeMs.toFixed(0)} ms`;
}
