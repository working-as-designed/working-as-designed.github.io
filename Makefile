# Create virtual environment and install dependencies
install:
    python3 -m venv venv
    . venv/bin/activate && pip install -r requirements.txt

# Remove virtual environment
clean:
    rm -rf venv
