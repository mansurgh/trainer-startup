import os

# Папки и файлы, которые мы ИГНОРИРУЕМ (чтобы не мусорить)
IGNORE_DIRS = {'.git', 'node_modules', '.idea', '.vscode', '__pycache__', 'build', 'dist', 'ios', 'android', 'assets'} 
# Примечание: ios/android папки игнорируем, если там автогенерируемый код. Если ты пишешь на нативе - убери их из списка.
IGNORE_FILES = {'package-lock.json', 'yarn.lock', '.DS_Store', 'merge_project.py', 'full_codebase.txt'}
EXTENSIONS = {'.js', '.jsx', '.ts', '.tsx', '.json', '.py', '.css', '.scss', '.md', '.html'}

def main():
    print("Начинаю сборку проекта...")
    with open('full_codebase.txt', 'w', encoding='utf-8') as outfile:
        # Пишем структуру (tree) в начале
        outfile.write("PROJECT STRUCTURE:\n")
        for root, dirs, files in os.walk('.'):
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
            level = root.replace('.', '').count(os.sep)
            indent = ' ' * 4 * (level)
            outfile.write(f"{indent}{os.path.basename(root)}/\n")
            subindent = ' ' * 4 * (level + 1)
            for f in files:
                if f not in IGNORE_FILES:
                    outfile.write(f"{subindent}{f}\n")
        
        outfile.write("\n\n" + "="*50 + "\n\n")

        # Пишем содержимое файлов
        for root, dirs, files in os.walk('.'):
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
            for file in files:
                if file in IGNORE_FILES: continue
                
                # Проверяем расширение
                _, ext = os.path.splitext(file)
                if ext not in EXTENSIONS and file != 'Dockerfile': continue

                path = os.path.join(root, file)
                outfile.write(f"\n\n--- FILE: {path} ---\n\n")
                
                try:
                    with open(path, 'r', encoding='utf-8') as infile:
                        outfile.write(infile.read())
                except Exception as e:
                    outfile.write(f"Error reading file: {e}")

    print("Готово! Весь код собран в full_codebase.txt")

if __name__ == "__main__":
    main()
