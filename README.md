# 東吳大學 資訊管理學系 110級 畢業專題

## 環境佈署

### OS
Windows 11 Professional

### GPU
NVIDIA GeForce RTX 4070 SUPER

### CUDA Version
11.8

### IDE
Pycharm

### Python Version
3.9 (Using .venv in Pycharm)

### Python Package
```angular2html
pip install tqdm
```
```angular2html
pip install librosa
```
```angular2html
pip install tensorflow==2.10.1 numpy==1.22.4 scipy==1.7.3 pandas matplotlib
```
```angular2html
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```
```angular2html
pip install flask
```
```angular2html
pip install beautifulsoup4
```
```angular2html
pip install lxml
```

## 檔案解釋
### [audio](audio)資料夾
將Youtube蒐集來的切割音訊的wav音檔放到此處

### [record](record)資料夾
將教育部示範拼音和自己錄的聲音的wav音檔放到此處

### [wav2mfcc.ipynb](wav2mfcc.ipynb)
分別將資料夾[audio](audio)和[record](record)內的wav檔轉換成npy檔放進資料夾[mfcc](mfcc)

### [train_cnn_model.ipynb](train_cnn_model.ipynb)
訓練一組參數的單音CNN分類模型
使用[best_params.json](best_params.json)檔案內的最佳超參數並輸出模型[cnn_model.h5](cnn_model.h5)

### [get_best_parms.py](get_best_parms.py)
使用網格搜索尋找單音CNN分類模型的最佳超參數並輸出[best_params.json](best_params.json)

