'''
EEG Backend API: with muse headset
optimize sampling rate so that we know how many samples to take per second to reduce noise and interpret fast brain changes
'''

from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np
from scipy.signal import welch
from pylsl import StreamInlet, resolve_byprop
import time

app = FastAPI()

#eeg processing settings
sample_rate = 256 #Hz
window_size = 256 * 2 #2 second window
bands = {
    'delta': (0.5, 4),
    'theta': (4, 8),
    'alpha': (8, 12),
    'beta': (12, 30),
}

# global buffer to store eeg samples
buffer = []

# connect to eeg stream
print("looking for eeg stream...")
streams = resolve_byprop('type', 'EEG')
inlet = StreamInlet(streams[0])
print("Connected to EEG stream!")


# eeg data processor
def compute_band_powers(eeg_data):
    #eeg_Data = NumPy array of shape (samples,)
    freqs, psd = welch(eeg_data, fs = sample_rate)

    band_powers = {}
    total_power = np.sum(psd)

    for band, (low, high) in bands.items():
        idx_band = np.logical_and(freqs > low, freqs <= high)
        band_power = np.sum(psd[idx_band])
        band_powers[band] = float(band_power)

    #normalize
    for band in band_powers:
        band_powers[band] /= total_power if total_power > 0 else 1
    
    return band_powers

def classify_brain_state(band_powers):
    if band_powers['beta'] > 0.3:
        return "Beta (Focused)"
    elif band_powers['alpha'] > 0.3:
        return "Alpha (Calm Readiness)"
    elif band_powers['theta'] > 0.3:
        return "Theta (relaxed/creative)"
    else:
        return "Low activity"

import threading

def collect_eeg_data():
    global buffer
    while True:
        sample, timestamp = inlet.pull_sample()
        buffer.append(sample[0])

        if len(buffer) > window_size:
            buffer = buffer[-window_size:]

threading.Thread(target=collect_eeg_data, daemon=True).start()

#api endpoint
class EEGDataResponse(BaseModel):
    theta: float
    alpha: float
    beta: float
    theta_alpha_ratio: float
    cognitive_state: str
    timestamp: str 

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
        theta_alpha_ratio = theta_alpha_ratio,
        cognitive_state = cognitive_state,
        timestamp=time.strftime("%y-%m%dT%h:%M:%S")
    )

#run uvicorn main:app --reload
