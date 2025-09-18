import os
import re

def replace_method_name_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # 替换方法名
    new_content = re.sub(r'basicLocalSendAppbar', 'basicChatXAppbar', content)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(new_content)
        print(f"Updated: {file_path}")

def walk_directory(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                replace_method_name_in_file(file_path)

if __name__ == "__main__":
    lib_directory = os.path.join(os.path.dirname(__file__), 'lib')
    walk_directory(lib_directory)
    print("All method names have been updated.")