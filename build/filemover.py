import os
import shutil

# Define source and destination directories
src_dir = './src'
dest_dir = './fromtts'

# Create destination directory if it doesn't exist
if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

# Iterate over each file in the source directory
for filename in os.listdir(src_dir):
    # Check if the file has the .tts.lua extension
    if filename.endswith('.tts.lua'):
        # Create the new file name by removing the .lua extension
        new_filename = filename.replace('.tts.lua', '.ttslua')

        # Define full file paths
        src_file = os.path.join(src_dir, filename)
        dest_file = os.path.join(dest_dir, new_filename)

        # Copy and rename the file to the destination directory
        shutil.copy(src_file, dest_file)

print("All files copied and renamed successfully.")
