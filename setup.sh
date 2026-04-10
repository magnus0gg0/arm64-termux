#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

echo "[+] Atualizando sistema..."
pkg update -y && pkg upgrade -y

echo "[+] Instalando dependências essenciais..."
pkg install -y binutils nano

echo "[+] Instalando comando 'build' globalmente..."

cat > "/data/data/com.termux/files/usr/bin/build" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Uso: build arquivo.s [-run]"
    exit 1
fi

SRC="$1"
RUN="${2:-}"

if [ ! -f "$SRC" ]; then
    echo "Erro: arquivo não encontrado"
    exit 1
fi

base=$(basename "$SRC" .s)

echo "[+] Montando (assembly puro)..."
as "$SRC" -o "$base.o"

echo "[+] Linkando (sem libc, sem crt)..."
ld "$base.o" -o "$base" -e _start

rm "$base.o"

echo "[OK] Executável gerado: $base"

if [ "$RUN" = "-run" ]; then
    echo "[+] Executando..."
    ./"$base"
fi
EOF

chmod +x "/data/data/com.termux/files/usr/bin/build"

echo "[+] Configurando nano (ARM64 syntax)..."

# Garante existência do arquivo
touch "$HOME/.nanorc"

# Remove bloco antigo (se existir)
sed -i '/## ARM64_START/,/## ARM64_END/d' "$HOME/.nanorc"

# Adiciona novo bloco
cat >> "$HOME/.nanorc" << 'EOF'

## ARM64_START

## =========================
## SUPORTE ARM64 (AArch64)
## =========================

syntax "arm64" "\.(s|S|asm)$"

## =========================
## PRIORIDADE MÁXIMA (COMENTÁRIOS)
## =========================

color brightblack "//.*$"
color brightblack "@.*$"

## =========================
## STRINGS
## =========================

color brightgreen "\"([^\"\\]|\\.)*\""

## =========================
## LABEL ESPECIAL (_start)
## =========================

color brightred "^_start:"
color red "\<_start\>"

## =========================
## DIRETIVAS
## =========================

color brightyellow "\.(equ|align|ascii|asciz|string|float|double|skip|word|hword|quad|byte|extern|global|type|size)\>"
color green "\.section\>"
color lightgreen "\.(text|data|bss|rodata)\>"

## =========================
## LABELS
## =========================

color yellow "^[a-zA-Z_][a-zA-Z0-9_]*:"

## =========================
## INSTRUÇÕES ARM64
## =========================

color brightblue "\<(add|sub|mul|madd|msub|sdiv|udiv|and|orr|eor|lsl|lsr|asr|ror|cmp|cmn|tst|mov|movz|movk|movn|mvn|adr|adrp|b|bl|br|ret|cbz|cbnz|tbz|tbnz|ldr|str|ldp|stp|ldrb|strb|ldrh|strh|ldrsw|stur|ldur|sturb|ldurb|nop|svc)\>"

## =========================
## REGISTRADORES
## =========================

color brightcyan "\<(x([0-9]|[1-2][0-9]|30)|w([0-9]|[1-2][0-9])|sp|lr|zr)\>"

## =========================
## CONDIÇÕES
## =========================

color lightblue "\.(eq|ne|lt|le|gt|ge|cs|cc|mi|pl|vs|vc|hi|ls)\>"

## =========================
## RELOCATION
## =========================

color magenta "\:lo12\:"
color magenta "\:hi12\:"

## =========================
## NÚMEROS
## =========================

color magenta "\<[-]?[0-9]+\>"
color magenta "0x[0-9a-fA-F]+"

## =========================
## IMEDIATOS
## =========================

color brightwhite "#[-]?[0-9]+"
color brightwhite "#0x[0-9a-fA-F]+"

## =========================
## SEPARADORES
## =========================

color brightwhite ","

## =========================
## SYS CALL
## =========================

color brightgreen "\<svc\>"

## =========================
## ENDEREÇAMENTO
## =========================

color cyan "\[[^]]+\]"

## ARM64_END

EOF

echo ""
echo "[✔] Ambiente ARM64 PURO pronto!"
echo ""
echo "✔ Assembly puro (as + ld)"
echo "✔ Sem libc / sem runtime"
echo "✔ Nano com syntax highlight ARM64"
echo ""
echo "Comandos disponíveis:"
echo "  build arquivo.s"
echo "  build arquivo.s -run"
echo ""
echo "➡️ Reinicie o Termux ou rode:"
echo "source ~/.bashrc"
