<div align="center">
<h1><a href="https://github.com/wick3dr0se/fml">fml</a> - file manager lite</h1>
<p>Written in BASH v5+, <code>fml</code> is coded with heavy bashisms not intended for portability. <code>fml</code> is wrote in very clean, minimal BASH and requires no external dependencies. <code>Fml</code> is a TUI written in raw VT100 ANSI escape sequences

Some people ask, 'Why not stick to `ncurses`? That's what it's made for' ..Well, because we don't need to and each invocation of `tput` adds 10-15ms to execution time. Also `ncurses` is less portable than ANSI escape sequences. Why would we?</p>

<img src="https://shields.io/badge/made-with%20%20bash-green?style=flat-square&color=d5c4a1&labelColor=1d2021&logo=gnu-bash">
<img src=https://img.shields.io/badge/Maintained%3F-yes-green.svg></img>  
<a href="https://discord.gg/W4mQqNnfSq">
<img src="https://discordapp.com/api/guilds/913584348937207839/widget.png?style=shield"/></a>
<br>
<br>
<img width="400" src="https://github.com/wick3dr0se/fml/blob/main/fml.gif?raw=true">
</div>

## Install
download the repository

```bash
git clone https://github.com/wick3dr0se/fml&& cd fml
# also run this if you want to add fml to path
make install
```

## Usage
```bash
bash fml
# or
./fml
# or just (if installed to path, aliased, etc)
fml
```

## Interface Controls
A   ...   Show all (including hidden) files   
D   ...   Create directory   
F   ...   Create file  
X   ...   Delete marked file/directory  
Q   ...   Quit

### Movements
←, H   ...   Back a directory  
↓, J   ...   Move down  
↑, K   ...   Move up  
→, L   ...   Enter file/directory
