# My Custom Neovim Configuration

A lightweight, performant, and customized Neovim setup optimized for Python and C development on Linux (Gnome).

## 🎨 Terminal Appearance (Crucial Step)

This configuration relies on a specific terminal color palette to look correct. I use the **Gogh** script to manage terminal themes.

### 1. Install the Theme

Open your terminal and run the following command to launch the Gogh selector:
```bash
bash -c "$(wget -qO- https://git.io/vQgMr)"
```

1. A list of themes will load (this may take a moment).
2. Type `github` (or find the number for the Github theme) and press `Enter`.
3. Once installed, right-click anywhere in your terminal → Preferences.
4. Go to Profiles and select the new `Github` profile.
5. **Important:** Ensure the background color is set to Dark in the profile settings (Colors tab).

### 2. Install a Nerd Font

For the status bar icons (rounded separators) to render correctly, you need a patched font.

1. Download and install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) (or any Nerd Font you prefer).
2. Set it as your terminal's custom font in Preferences.

## 🛠️ System Dependencies

Before starting Neovim, ensure these tools are installed on your system (Ubuntu/Debian):
```bash
# 1. Compilers (Required for C/C++ and Treesitter parsing)
sudo apt install gcc g++

# 2. Python & Pip (Required for Python development)
sudo apt install python3 python3-pip python3-venv

# 3. Ripgrep (REQUIRED for Telescope 'live_grep' to search text)
sudo apt install ripgrep

# 4. Clipboard Tool (Allows copy/paste between Nvim and system)
sudo apt install xclip
```

**(Optional)** Install formatters for auto-formatting on save:
```bash
pip install black              # Python
sudo apt install clang-format  # C/C++
```

## 🚀 Installation

1. **Backup your existing config** (if any):
```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

2. **Clone this repository:**
```bash
git clone https://github.com/mohammed-bouaziz/neovim-unix-talisman.git
```

3. **Run Neovim:**
```bash
nvim
```

Wait for the `Lazy` plugin manager to automatically download and install all plugins.

## ⌨️ Keymaps

The Leader Key is mapped to `<Space>`.

### ⚡ Code Execution

| Key | Action |
|-----|--------|
| `F5` | Save & Run (Auto-detects Python, C, C++, Lua, JS) |

### 📂 Navigation

| Key | Action |
|-----|--------|
| `<Space> + e` | Toggle File Explorer (NvimTree) |
| `<Space> + f` | Find Files (Telescope) |
| `<Space> + g` | Search Text in Files (Live Grep) |
| `<Space> + b` | List Open Buffers |
| `<Ctrl> + h/j/k/l` | Navigate between split windows |
| `<Space> + v` | Vertical Split |
| `<Space> + s` | Horizontal Split |

### 🧠 LSP (Intelligence)

| Key | Action |
|-----|--------|
| `K` | Hover Documentation |
| `gd` | Go to Definition |
| `gr` | Find References |
| `<Space> + r` | Rename Variable |
| `<Space> + a` | Code Action (Fix imports, etc.) |

## 🎨 Custom Theme Details

I have disabled standard themes and manually mapped syntax highlighting in `settings.lua` for a minimal, high-contrast look:

- **Background:** Transparent/Dark (Inherited from Terminal)
- **Normal Text:** White
- **Functions:** Yellow
- **Strings:** Green
- **Keywords:** Blue
- **Diagnostics:**
  - Errors: Red "E" in gutter
  - Warnings: Yellow "W" in gutter
  - Note: Diagnostic float auto-opens when cursor holds on a line.
