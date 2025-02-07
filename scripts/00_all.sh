SCRIPT_DIR=$(dirname "$0")
find "$SCRIPT_DIR" -maxdepth 1 -type f -name "*.sh" ! -name "00_all.sh" ! -name "99_cleanup.sh" | sort | while read -r script; do
    echo "Running $script..."
    chmod +x "$script"
    "$script"
done
