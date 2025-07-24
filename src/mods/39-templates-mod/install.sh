set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Declare Templates dir name as variable for specific languages..."
case $LANG_MODE in
    "ro_RO")
        export TEMPLATE_DIR="Șabloane"
        print_ok "Configuring templates..."
        mkdir -p /etc/skel/$TEMPLATE_DIR
        touch /etc/skel/$TEMPLATE_DIR/Text.txt
        touch /etc/skel/$TEMPLATE_DIR/Markdown.md
cat << 'EOF' > /etc/skel/$TEMPLATE_DIR/Markdown.md
# Titlu

- [ ] De realizat 1
- [ ] De realizat 2
- [ ] De realizat 3

## Subtitlu

1. Lista 1
2. Lista 2
3. Lista 3
EOF
        ;;
    *)
        export TEMPLATE_DIR="Templates"
        print_ok "Configuring templates..."
        mkdir -p /etc/skel/$TEMPLATE_DIR
        touch /etc/skel/$TEMPLATE_DIR/Text.txt
        touch /etc/skel/$TEMPLATE_DIR/Markdown.md
cat << 'EOF' > /etc/skel/$TEMPLATE_DIR/Markdown.md
# Title

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Subtitle

1. Numbered 1
2. Numbered 2
3. Numbered 3
EOF
        ;;
esac
judge "Configure templates"
