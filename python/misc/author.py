import os

def add_author_info(directory, author_info):
    for filename in os.listdir(directory):
        if filename.endswith(".py"):
            file_path = os.path.join(directory, filename)
            with open(file_path, 'r') as file:
                content = file.read()
            with open(file_path, 'w') as file:
                file.write(f'"""\n{author_info}\n"""\n\n{content}')

# Directory containing the Python files
directory = '/Users/sanju/workspace/trade-engine/src/'

# Author information to add
author_info = '@author: Sanju (https://github.com/enterthematrix)'

add_author_info(directory, author_info)