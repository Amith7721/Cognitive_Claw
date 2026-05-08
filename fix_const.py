import os

files = [
    'lib/screens/briefs/briefs_screen.dart',
    'lib/screens/home/home_screen.dart',
    'lib/screens/research/research_screen.dart',
    'lib/screens/tasks/tasks_screen.dart'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    lines = content.split('\n')
    for i in range(len(lines)):
        if 'const ' in lines[i]:
            # check the next 10 lines
            lookahead = '\n'.join(lines[i:min(i+10, len(lines))])
            if 'Theme.of(context)' in lookahead:
                lines[i] = lines[i].replace('const ', '')
                
    with open(filepath, 'w') as f:
        f.write('\n'.join(lines))

print("Fixed const errors!")
