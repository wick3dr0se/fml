<div align="center">
<h1><a href="https://github.com/wick3dr0se/fml">fml</a> - file manager lite</h1>
<p>Written in BASH v5+, <code>fml</code> is coded with heavy bashisms not intended for portability. <code>fml</code> is wrote in very clean, minimal BASH and requires no external dependencies. <code>Fml</code> is a TUI written in raw VT100 ANSI escape sequences</p>

<img src="https://shields.io/badge/made-with%20%20bash-green?style=flat-square&color=d5c4a1&labelColor=1d2021&logo=gnu-bash">
<img src=https://img.shields.io/badge/Maintained%3F-yes-green.svg></img>  
<a href="https://discord.gg/W4mQqNnfSq">
<img src="https://discordapp.com/api/guilds/913584348937207839/widget.png?style=shield"/></a>
<br>
<br>
<img width="400" src="https://github.com/wick3dr0se/fml/blob/main/fml.gif?raw=true">
</div>

## Install
Download the repository
```bash
git clone https://github.com/wick3dr0se/fml; cd fml
```

_Optionally install fml to path_
```bash
cp fml /usr/local/bin
```

## Usage
Execute `fml` (if installed to path, aliased, ...), otherwise `bash fml`/`./fml`

## Interface Controls
`.`   ...   Toggle all (including hidden) files  
`/`   ...   Change directory  
`:`   ...   Execute command  
`N`   ...   Create file or directory/  
`C`   ...   Copy file  
`M`   ...   Move file  
`X`   ...   Delete file  
`Q`   ...   Quit

### Movements
`←`, `H`, `A`   ...   Back  
`↓`, `J`, `S`, `-`   ...   Move down  
`↑`, `K`, `W`, `+`   ...   Move up  
`→`, `L`, `D`   ...   Open  
`Home`, `PageUp`   ...   Scroll to top  
`PageDown`   ...   Scroll to bottom
