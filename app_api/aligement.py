import torch
from torchaudio.pipelines import MMS_FA as bundle
from typing import List
import IPython
import matplotlib.pyplot as plt
from pypinyin import pinyin, lazy_pinyin, Style
from pydub import AudioSegment
import librosa
import speech_recognition


def _score(spans):
    return sum(s.score * len(s) for s in spans) / sum(len(s) for s in spans)

def plot_alignments(waveform, token_spans, emission, transcript, sample_rate=bundle.sample_rate):
    ratio = waveform.size(1) / emission.size(1) / sample_rate

    fig, axes = plt.subplots(2, 1)
    axes[0].imshow(emission[0].detach().cpu().T, aspect="auto")
    axes[0].set_title("Emission")
    axes[0].set_xticks([])

    axes[1].specgram(waveform[0], Fs=sample_rate)
    for t_spans, chars in zip(token_spans, transcript):
        t0, t1 = t_spans[0].start, t_spans[-1].end
        axes[0].axvspan(t0 - 0.5, t1 - 0.5, facecolor="None", hatch="/", edgecolor="white")
        axes[1].axvspan(ratio * t0, ratio * t1, facecolor="None", hatch="/", edgecolor="white")
        axes[1].annotate(f"{_score(t_spans):.2f}", (ratio * t0, sample_rate * 0.51), annotation_clip=False)

        for span, char in zip(t_spans, chars):
            t0 = span.start * ratio
            axes[1].annotate(char, (t0, sample_rate * 0.55), annotation_clip=False)

    axes[1].set_xlabel("time [second]")
    fig.tight_layout()

def text_recognize():
    torch.cuda.empty_cache()
    torch.cuda.memory_summary(device=None, abbreviated=False)
    raw_data_path = f".\\app_voice\\recorded.wav"
    r = speech_recognition.Recognizer()
    raw_data = speech_recognition.AudioFile(raw_data_path)
    with raw_data as source:
        audio = r.record(source)
    result = r.recognize_google(audio, language='zh-tw')

    sentence = result.lower().replace('》', '').replace('《', '').replace('%', '').replace('。', '').replace('?',
                                                                                                          '').replace(
        '【', '').replace('】', '').replace('-', '').replace('.', '').replace(',', '').replace('6', '六').replace('4',
                                                                                                                '四').replace(
        '2', '二').replace('9', '九').replace('8', '八').replace('5', '五').replace('3', '三').replace('0',
                                                                                                       '零').replace(
        '1', '一').replace('7', '七').replace(' ', '').replace('、', '')

    print(sentence)
    return sentence



