print_ok "Configuring templates..."
mkdir -p /etc/skel/Templates
touch /etc/skel/Templates/Text.txt
touch /etc/skel/Templates/Markdown.md
cat << 'EOF' > /etc/skel/Templates/Markdown.md
# Title

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Subtitle

1. Numbered 1
2. Numbered 2
3. Numbered 3
EOF
judge "Configure templates"