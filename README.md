# 機械学習学習環境
## Docker + Conda + Jupyter

Project: **ml-learning-01_Foundations_Part_1**

---

# Step0 プロジェクト作成

```bash
mkdir ~/workspace/<ProjectName>
cd ~/workspace/<ProjectName>
git init
```

# Step1 ディレクトリ構造

ml-learning-01_Foundations_Part_1
│
├ notebooks
├ src
├ data
│
├ Dockerfile
├ docker-compose.yml
├ environment.yml
├ .dockerignore
│
├ Makefile
├ README.md
└ .gitignore


# Step2 フォルダ作成
```bash
mkdir notebooks src data
touch README.md .gitignore docker-compose.yml Makefile Dockerfile environment.yml .dockerignore
```

# Step3 Sublimeでプロジェクトを開く（Sublime Text を使用）
sublimeについてはかめさんの紹介を参照；https://datawokagaku.com/best_editor/
```bash
subl　.
```

# Step4 .gitignore 設定
```コード
.ipynb_checkpoints
data/*
!data/.gitkeep
__pycache__
.DS_Store
```

# Step5 .dockerignore 設定
Docker build を高速化するため不要ファイルを除外する。
```コード
.git
.gitignore
__pycache__
*.pyc
*.pyo
*.pyd

notebooks/.ipynb_checkpoints
data

.DS_Store
```

# Step6 Python環境定義
environment.yml
```yaml
name: ml-env

channels:
  - conda-forge

dependencies:
  - python=3.11
  - pandas
  - scikit-learn
  - matplotlib
  - seaborn
  - plotly
  - optuna
  - lightgbm
  - catboost
  - jupyterlab
```

# Step7 Dockerfile 作成
Docker + Miniforge + mamba 環境
```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    vim \
    sudo \
    libgl1 \
    build-essential \
    && apt-get clean

WORKDIR /opt

# Miniforge install
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh \
    && bash Miniforge3-Linux-aarch64.sh -b -p /opt/conda \
    && rm Miniforge3-Linux-aarch64.sh

ENV PATH=/opt/conda/bin:$PATH

# mamba install
RUN conda install -y mamba -n base -c conda-forge

WORKDIR /tmp

# Python environment install
COPY environment.yml .

RUN mamba env update -n base -f environment.yml \
    && mamba clean -afy \
    && rm -rf /opt/conda/pkgs

RUN mkdir -p /work
WORKDIR /work

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--ServerApp.token=''"]
```

# Step8 docker-compose.yml
```yaml
services:
  jupyter:
    build: .
    ports:
      - "8888:8888"
    volumes:
      - .:/work
    working_dir: /work
    tty: true
```


# Step8-2 Makefile

Docker操作を簡単にするために Makefile を使用する。

## Makefile内容
```makefile
build:
  docker compose build

up:
  docker compose up -d

down:
  docker compose down

restart:
  docker compose restart

logs:
  docker compose logs -f

ps:
  docker compose ps

# コンテナ内に入る
shell:
    docker compose exec jupyter bash

# Jupyterをブラウザで開く
jupyter:
  open http://localhost:8888
```

# Step9 Docker build
```bash
make build
```
または
```bash
docker compose build
```

# Step10 Docker起動

通常はこちらだけ実行します。
make build は初回環境構築時、または Dockerfile や environment.yml を変更したときだけ実行します。
```bash
make up
```

# Step11 Jupyterアクセス
```bash
http://localhost:8888
```

# Step12 Notebook実験
```コード
notebooks/01_linear_regression.ipynb
```

# Step13 再利用コード抽出
Notebookで書いた処理を整理

例
  • 前処理
  • 可視化
  • モデル処理

# Step14 Pythonモジュール化
```コード
src/preprocessing.py
src/model.py
```

# Step15 Notebookから呼び出し
```python
from src.preprocessing import preprocess
```

# Step16 Git保存
```bash
git add .
git commit -m "update ML workflow"
```

# Step17 GitHub push
```bash
# 初回のみ
git push -u origin main

# 2回目以降
git push
```

# 学習フロー
Notebook experiment
        ↓
Code整理
        ↓
src に移動
        ↓
Notebookからimport
        ↓
Git保存

## よく使うコマンド

日常的な学習では、以下のコマンドだけ覚えておけば十分です。

| やりたいこと | コマンド | 説明 |
|--------------|----------|------|
| 初回環境構築 | `make build` | Dockerイメージを作成する（初回または環境変更時のみ） |
| 学習開始 | `make up` | コンテナを起動する |
| Jupyter Labを開く | `make jupyter` | ブラウザでJupyter Labを開く |
| コンテナに入る | `make shell` | コンテナ内でシェルを起動する |
| コンテナの状態確認 | `make ps` | 起動中のコンテナを確認する |
| ログ確認 | `make logs` | コンテナのログを表示する |
| コンテナ再起動 | `make restart` | コンテナを再起動する |
| 学習終了 | `make down` | コンテナを停止・削除する |

> **💡 Dockerの考え方**
>
> - `build`：Dockerイメージを作成・更新する（時間がかかる）
> - `up`：作成済みのイメージからコンテナを起動する（数秒）
> - 普段の学習では **`make up`** を使い、**`make build` は `Dockerfile` や `environment.yml` を変更したときだけ**実行する。

## 日常の学習フロー

```text
make up
    ↓
make jupyter
    ↓
講義・Notebook作成
    ↓
git status
    ↓
git add .
    ↓
git commit -m "学習内容"
    ↓
git push
    ↓
make down
```
