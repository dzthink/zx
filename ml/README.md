# 机器学习项目快速开始指南

本项目包含机器学习相关的Jupyter notebook，适合从零开始学习。本指南将帮助你快速搭建环境并运行项目。

## 📁 项目结构
```
├── ng-ml.ipynb              # 基础机器学习教程
├── post_trainging_sft.ipynb # 后训练SFT教程
├── datasets/                # 数据集目录
├── model/                   # 预训练模型目录
└── env.yml                  # 环境配置文件
```

## 🚀 快速开始（零基础用户）

### 步骤1：安装Miniforge（Python环境管理器）

**macOS用户：**
1. 访问 https://github.com/conda-forge/miniforge/releases
2. 下载最新版 `Miniforge3-MacOSX-$(uname -m).sh`
3. 打开终端，运行：
```bash
bash ~/Downloads/Miniforge3-MacOSX-$(uname -m).sh
```
4. 按提示完成安装，重启终端

**Linux用户：**
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh
```

### 步骤2：下载项目代码

**方法一：直接下载ZIP**
1. 点击项目页面的"Code" → "Download ZIP"
2. 解压到任意文件夹

**方法二：使用Git（可选）**
```bash
git clone [项目地址]
cd [项目文件夹]
```

### 步骤3：创建项目环境

1. **打开终端**
   - macOS：按 `Cmd + 空格`，输入 `terminal`，回车
   - Linux：按 `Ctrl + Alt + T`

2. **进入项目目录**
```bash
cd /path/to/your/project  # 替换为你的实际路径
```

3. **创建环境**
```bash
conda env create -f env.yml
```

4. **激活环境**
```bash
conda activate ml
```

### 步骤4：在VSCode中运行Notebook

1. **安装VSCode**
   - 访问 https://code.visualstudio.com
   - 下载macOS/Linux版本并安装

2. **安装Python扩展**
   - 打开VSCode
   - 点击左侧扩展图标（或按 `Cmd+Shift+X`）
   - 搜索"Python"并安装Microsoft官方扩展

3. **打开项目**
   - 在VSCode中点击"File" → "Open Folder"
   - 选择你的项目文件夹

4. **选择Python环境**
   - 按 `Cmd+Shift+P` 打开命令面板
   - 输入"Python: Select Interpreter"
   - 选择 `ml` 环境（路径包含miniforge3/envs/ml）

5. **运行Notebook**
   - 在VSCode文件浏览器中点击 `.ipynb` 文件
   - 点击右上角的"Run All"按钮，或按 `Shift+Enter` 逐个运行cell

## 📊 运行第一个Notebook

### 运行 `ng-ml.ipynb`
1. 在VSCode中打开 `ng-ml.ipynb`
2. 点击顶部"Run All"按钮
3. 等待所有cell执行完成

### 运行 `post_trainging_sft.ipynb`
1. 打开 `post_trainging_sft.ipynb`
2. 按顺序运行每个cell（推荐）
3. 或点击"Run All"

## 🔧 常见问题解决

### 问题1：conda命令找不到
**解决：**
```bash
# 重启终端或运行
source ~/.bashrc  # Linux
source ~/.zshrc   # macOS
```

### 问题2：环境创建失败
**解决：**
```bash
# 先更新conda
conda update conda
# 再创建环境
conda env create -f env.yml --force
```

### 问题3：VSCode找不到Python环境
**解决：**
1. 确保已激活环境： `conda activate ml`
2. 重启VSCode
3. 手动指定解释器路径：
   - macOS: `~/miniforge3/envs/ml/bin/python`
   - Linux: `~/miniforge3/envs/ml/bin/python`

### 问题4：内存不足
**解决：**
- 关闭其他应用程序
- 在notebook中减少batch_size参数
- 使用较小的数据集

## 📱 云端替代方案

### 使用Google Colab（推荐）
1. 访问 https://colab.research.google.com
2. 上传notebook文件
3. 点击"Runtime" → "Run all"

### 使用JupyterLite（轻量级）
1. 访问 https://jupyterlite.github.io/demo
2. 上传notebook文件
3. 直接运行

## 🎯 下一步学习

完成基础notebook后，你可以：
1. 修改参数，观察结果变化
2. 尝试不同的数据集
3. 阅读代码注释，理解实现原理
4. 查看datasets文件夹中的示例数据

## 📞 技术支持

如果遇到问题：
1. 检查错误信息
2. 重启kernel：在VSCode中点击"Restart Kernel"按钮
3. 清除输出：点击"Clear All Outputs"
4. 重新运行：点击"Run All"

**提示：** 所有notebook都包含详细的代码注释，按顺序运行即可看到完整结果！