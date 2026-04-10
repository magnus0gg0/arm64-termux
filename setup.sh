#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "[+] Atualizando sistema..."
pkg update -y && pkg upgrade -y

echo "[+] Instalando dependências essenciais..."
pkg install -y clang binutils nano

echo "[+] Instalando comando 'build' globalmente..."

cat > "/data/data/com.termux/files/usr/bin/build" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Uso: build arquivo.s [-run]"
    exit 1
fi

SRC="$1"
RUN="$2"

base=$(basename "$SRC" .s)

echo "[+] Compilando (sem libc)..."
clang -nostdlib -static "$SRC" -o "$base"

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
echo "[✔] Ambiente ARM64 SEM LIBC pronto!"
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
