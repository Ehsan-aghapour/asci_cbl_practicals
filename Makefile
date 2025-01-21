# Define variables
NAME ?= $(error Please provide the base name using 'make <target> NAME=<base_name>')
NB_FILE = $(NAME).ipynb              # Derive the notebook file name
PY_FILE = $(NAME).py                 # Derive the Python file name
DEFAULT_MSG = "Update script"        # Default commit message
SSH_CMD = sshgpu                     # SSH command/script to connect to the server
REMOTE_DIR = /path/to/remote/directory # Directory on the server

# Pair the notebook with the Python script
pair:
	jupytext --set-formats ipynb,py:$(PY_FILE) $(NB_FILE)

# Sync the notebook and Python script
sync:
	jupytext --sync $(NB_FILE)

# Convert notebook to Python script (one-way)
convert:
	jupytext --to script $(NB_FILE)

# Commit changes to GitHub with an optional commit message
commit:
	@read -p "Enter commit message (or press Enter to use default): " MSG; \
	if [ -z "$$MSG" ]; then \
		MSG="$(DEFAULT_MSG)"; \
	fi; \
	git add $(PY_FILE); \
	git commit -m "$$MSG"

# Commit and push changes to GitHub with an optional commit message
push:
	@read -p "Enter commit message (or press Enter to use default): " MSG; \
	if [ -z "$$MSG" ]; then \
		MSG="$(DEFAULT_MSG)"; \
	fi; \
	git add $(PY_FILE); \
	git commit -m "$$MSG"; \
	git push

# Sync, commit, and push changes to GitHub with an optional commit message
push_sync:
	@read -p "Enter commit message (or press Enter to use default): " MSG; \
	if [ -z "$$MSG" ]; then \
		MSG="$(DEFAULT_MSG)"; \
	fi; \
	jupytext --sync $(NB_FILE); \
	git add $(PY_FILE); \
	git commit -m "$$MSG"; \
	git push

# Sync and run script locally
run_local:
	@echo "Syncing notebook and Python script..."
	jupytext --sync $(NB_FILE)
	@echo "Running script locally..."
	python3 $(PY_FILE)

# Just run script on the server (no sync or commit)
run_board:
	@echo "Connecting to server to run the script..."
	$(SSH_CMD) "cd $(REMOTE_DIR) && screen -dmS run_script python3 $(PY_FILE)"

# Sync, commit, push, pull on server, and run script using screen
deploy_board:
	@read -p "Enter commit message (or press Enter to use default): " MSG; \
	if [ -z "$$MSG" ]; then \
		MSG="$(DEFAULT_MSG)"; \
	fi; \
	@echo "Syncing, committing, pushing changes..."
	jupytext --sync $(NB_FILE); \
	git add $(PY_FILE); \
	git commit -m "$$MSG"; \
	git push
	@echo "Connecting to server to pull and run the script..."
	$(SSH_CMD) "cd $(REMOTE_DIR) && git pull && screen -dmS run_script python3 $(PY_FILE)"
	@read -p "Do you want to attach to the screen session? (y/n): " ATTACH; \
	if [ "$$ATTACH" = "y" ]; then \
		$(SSH_CMD) "screen -r run_script"; \
	else \
		@echo "Script is running in the background on the server (screen session: run_script)."; \
	fi

