# Specify the notebook name and output details
notebook_name = "your_notebook.ipynb"  # Replace with your notebook name
script_name = notebook_name.replace(".ipynb", ".py")
session_name = "my_session_name"
log_file = "my_session_log.txt"

# Step 1: Convert .ipynb to .py
print("Converting notebook to script...")
!jupyter nbconvert --to script {notebook_name}
print(f"Converted {notebook_name} to {script_name}")

# Step 2: Run the script in a screen session
print(f"Starting script '{script_name}' in a screen session...")
!screen -dmS {session_name} bash -c "python3 {script_name}; exec bash"
print(f"Script is running in screen session '{session_name}'")

# Optional Step 3: Monitor the screen session
print(f"Saving screen output to log file '{log_file}'...")
!screen -S {session_name} -X hardcopy {log_file}
print(f"Screen session log saved to {log_file}")

# Optional Step 4: Stop the screen session (if needed)
# Uncomment the following lines to stop the session
# !screen -S {session_name} -X quit
# print(f"Screen session '{session_name}' stopped")

