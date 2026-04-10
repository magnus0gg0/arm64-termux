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

echo "[+] Configurando nano..."

# Garante que o arquivo existe
if [ ! -f "$HOME/.nanorc" ]; then
    touch "$HOME/.nanorc"
fi

# Adiciona configs se não existirem
grep -qxF "set tabsize 4" "$HOME/.nanorc" || echo "set tabsize 4" >> "$HOME/.nanorc"
grep -qxF "set tabstospaces" "$HOME/.nanorc" || echo "set tabstospaces" >> "$HOME/.nanorc"
grep -qxF "set autoindent" "$HOME/.nanorc" || echo "set autoindent" >> "$HOME/.nanorc"
grep -qxF "set linenumbers" "$HOME/.nanorc" || echo "set linenumbers" >> "$HOME/.nanorc"

echo ""
echo "[✔] Ambiente ARM64 PURO pronto!"
echo ""
echo "Sem libc | Sem clang | Sem runtime"
echo "Controle total via syscalls"
echo ""
echo "Nano configurado com:"
echo "  - tabsize 4"
echo "  - tabstospaces"
echo "  - autoindent"
echo "  - linenumbers"
echo ""
echo "Comandos disponíveis:"
echo "  build arquivo.s"
echo "  build arquivo.s -run"
echo ""
echo "[✔] Setup finalizado!"
echo ""
echo "➡️ Reinicie o Termux ou rode:"
echo "source ~/.bashrc"
