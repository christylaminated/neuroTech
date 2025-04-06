# === EEG Backend API with Fake EEG Stream with no muse headset===
'''
'''

from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np
from scipy.signal import welch
import threading
import random
import time

app = FastAPI()

# === EEG processing settings ===
sample_rate = 256  # Hz (Muse sample rate)
window_size = sample_rate * 2  # 2-second rolling window
bands = {
    'delta': (0.5, 4),
    'theta': (4, 8),
    'alpha': (8, 12),
    'beta': (12, 30),
}

# === Global buffer to store EEG samples ===
buffer = []

# === Simulated Brain State Mode Control ===
# Options: "beta", "alpha", "theta", "random"
mode = "beta"

def generate_fake_eeg_sample():
    """
    Simulate EEG signal by generating values based on selected brain state mode.
    """
    baseline = 420  # Arbitrary microvolt baseline

    if mode == "beta":
        noise = random.uniform(-300, 300)  # increase amplitude!

    elif mode == "alpha":
        # Moderate fluctuations (simulate alpha state)
        noise = random.uniform(-150, 150)
    elif mode == "theta":
        # Slow fluctuations (simulate theta state)
        noise = random.uniform(-80, 80)
    else:  # "random" mode
        noise = random.uniform(-20, 20)

    return baseline + noise

def collect_fake_eeg_data():
    """
    Continuously generate and collect fake EEG samples at real-time rate.
    """
    global buffer
    while True:
        sample = generate_fake_eeg_sample()
        buffer.append(sample)

        # Keep only the latest window_size samples
        if len(buffer) > window_size:
            buffer = buffer[-window_size:]

        time.sleep(1 / sample_rate)  # Simulate real sampling rate

# Start the fake EEG data stream in a background thread
threading.Thread(target=collect_fake_eeg_data, daemon=True).start()
print(f"✅ Fake EEG data stream running in '{mode}' mode!")

# === EEG data processor ===

def compute_band_powers(eeg_data):
    """
    Compute relative power in each frequency band.
    """
    freqs, psd = welch(eeg_data, fs=sample_rate)

    band_powers = {}
    total_power = np.sum(psd)

    for band, (low, high) in bands.items():
        idx_band = np.logical_and(freqs > low, freqs <= high)
        band_power = np.sum(psd[idx_band])
        band_powers[band] = float(band_power)

    # Normalize power values
    for band in band_powers:
        band_powers[band] /= total_power if total_power > 0 else 1

    return band_powers

def classify_brain_state(band_powers):
    """
    Classify cognitive state based on band power distribution.
    """
    if band_powers['beta'] > 0.3:
        return "Beta (Focused)"
    elif band_powers['alpha'] > 0.3:
        return "Alpha (Calm Readiness)"
    elif band_powers['theta'] > 0.3:
        return "Theta (Relaxed/Creative)"
    else:
        return "Low Activity"

# === API response model ===

class EEGDataResponse(BaseModel):
    theta: float
    alpha: float
    beta: float
    theta_alpha_ratio: float
    cognitive_state: str
    timestamp: str

# === API endpoint ===

@app.get("/eeg-latest", response_model=EEGDataResponse)
def get_eeg_data():
    if len(buffer) < window_size:
        return {
            "theta": 0.0,
            "alpha": 0.0,
            "beta": 0.0,
            "theta_alpha_ratio": 0.0,
            "cognitive_state": "Collecting data...",
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S")
        }

    eeg_array = np.array(buffer)
    band_powers = compute_band_powers(eeg_array)

    theta = band_powers['theta']
    alpha = band_powers['alpha']
    beta = band_powers['beta']
    theta_alpha_ratio = theta / alpha if alpha > 0 else 0.0

    cognitive_state = classify_brain_state(band_powers)

    return EEGDataResponse(
        theta=theta,
        alpha=alpha,
        beta=beta,
        theta_alpha_ratio=theta_alpha_ratio,
        cognitive_state=cognitive_state,
        timestamp=time.strftime("%Y-%m-%dT%H:%M:%S")
    )

# Run this server with:
# uvicorn fastAPIserver:app --reload
# To expose on Wi-Fi: uvicorn fastAPIserver:app --host 0.0.0.0 --port 8000 --reload
#http://127.0.0.1:8000/eeg-latest
