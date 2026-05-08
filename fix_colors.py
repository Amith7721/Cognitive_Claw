import os

def process_home_screen():
    path = 'lib/screens/home/home_screen.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Google Calendar Connected Box
    content = content.replace('color: Colors.greenAccent.withValues(alpha: 0.15)', 'color: Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.1)')
    content = content.replace('border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3))', 'border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3))')
    content = content.replace('Icon(Icons.check_circle, color: Colors.greenAccent)', 'Icon(Icons.check_circle, color: Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green)')
    content = content.replace('style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)', 'style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.green[800], fontWeight: FontWeight.bold)')

    # Google Calendar Button
    content = content.replace('icon: const Icon(Icons.calendar_month, color: Colors.white)', 'icon: Icon(Icons.calendar_month, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)')
    content = content.replace('label: const Text("Connect Google Calendar", style: TextStyle(color: Colors.white))', 'label: Text("Connect Google Calendar", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87))')
    content = content.replace('backgroundColor: const Color(0xFF1E1B2E)', 'backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1B2E) : Colors.white')

    # General Replacements for Cards (Skipping WelcomeCard which uses const TextStyle(color: Colors.white, ...))
    # We will replace `color: Colors.white` with `color: Theme.of(context).textTheme.bodyLarge?.color`
    content = content.replace('style: const TextStyle(\n                  color: Colors.white,', 'style: TextStyle(\n                  color: Theme.of(context).textTheme.bodyLarge?.color,')
    content = content.replace('style: const TextStyle(\n              color: Colors.white,', 'style: TextStyle(\n              color: Theme.of(context).textTheme.bodyLarge?.color,')
    content = content.replace('style: const TextStyle(\n            color: Colors.white,', 'style: TextStyle(\n            color: Theme.of(context).textTheme.bodyLarge?.color,')
    content = content.replace('style: TextStyle(\n            color: Colors.white,', 'style: TextStyle(\n            color: Theme.of(context).textTheme.bodyLarge?.color,')
    content = content.replace('style: const TextStyle(color: Colors.white70', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color')
    content = content.replace('style: TextStyle(color: Colors.white70', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color')
    
    # Icons inside cards
    content = content.replace('Icon(Icons.access_time, color: Colors.white70)', 'Icon(Icons.access_time, color: Theme.of(context).iconTheme.color)')
    content = content.replace('Icon(Icons.people, color: Colors.white70)', 'Icon(Icons.people, color: Theme.of(context).iconTheme.color)')

    # Borders
    content = content.replace('border: Border.all(color: Colors.white.withValues(alpha: 0.05))', 'border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black12)')

    with open(path, 'w') as f:
        f.write(content)

def process_briefs_screen():
    path = 'lib/screens/briefs/briefs_screen.dart'
    with open(path, 'r') as f:
        content = f.read()

    content = content.replace('style: const TextStyle(\n                                color: Colors.white,', 'style: TextStyle(\n                                color: Theme.of(context).textTheme.bodyLarge?.color,')
    content = content.replace('style: const TextStyle(\n                          color: Colors.white70,', 'style: TextStyle(\n                          color: Theme.of(context).textTheme.bodyMedium?.color,')

    # Empty State & Login
    content = content.replace('style: TextStyle(\n                color: Colors.white,', 'style: TextStyle(\n                color: Theme.of(context).textTheme.bodyLarge?.color,')
    content = content.replace('style: TextStyle(color: Colors.white70', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color')
    content = content.replace('style: const TextStyle(color: Colors.white70', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color')

    content = content.replace('backgroundColor: const Color(0xFF1E1B2E)', 'backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1B2E) : Colors.white')
    content = content.replace('child: const Text("Go Back", style: TextStyle(color: Colors.white', 'child: Text("Go Back", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87')

    with open(path, 'w') as f:
        f.write(content)

def process_tasks_screen():
    path = 'lib/screens/tasks/tasks_screen.dart'
    with open(path, 'r') as f:
        content = f.read()

    # AI Dialog
    content = content.replace('style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)')
    content = content.replace('style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 16)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6, fontSize: 16)')
    content = content.replace('title: const Text("Error", style: TextStyle(color: Colors.white))', 'title: Text("Error", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))')
    content = content.replace('style: const TextStyle(color: Colors.white70)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)')

    # Add Task Dialog
    content = content.replace('style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)')
    content = content.replace('style: const TextStyle(color: Colors.white)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)')
    content = content.replace('hintStyle: const TextStyle(color: Colors.white54)', 'hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)')
    content = content.replace('fillColor: Colors.black26', 'fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black12')

    # Task Card
    content = content.replace('color: task[\'completed\'] ? Colors.white54 : Colors.white,', 'color: task[\'completed\'] ? (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54) : Theme.of(context).textTheme.bodyLarge?.color,')
    content = content.replace('Icon(Icons.access_time_rounded, color: Colors.white54, size: 16)', 'Icon(Icons.access_time_rounded, color: Theme.of(context).iconTheme.color, size: 16)')
    content = content.replace('style: const TextStyle(color: Colors.white60, fontSize: 14)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)')
    
    with open(path, 'w') as f:
        f.write(content)

def process_research_screen():
    path = 'lib/screens/research/research_screen.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Search Bar
    content = content.replace('style: const TextStyle(color: Colors.white, fontSize: 18)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18)')
    content = content.replace('hintStyle: const TextStyle(color: Colors.white54)', 'hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)')

    # Paper Card
    content = content.replace('style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)', 'style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).textTheme.bodyLarge?.color)')
    content = content.replace('style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5, fontSize: 15)')
    content = content.replace('Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 16)', 'Icon(Icons.calendar_today_rounded, color: Theme.of(context).iconTheme.color, size: 16)')
    content = content.replace('style: const TextStyle(color: Colors.white54, fontSize: 14)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)')
    
    # Open Paper Button
    content = content.replace('icon: const Icon(Icons.open_in_new_rounded, color: Colors.white)', 'icon: Icon(Icons.open_in_new_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)')
    content = content.replace('label: const Text(\'Open Paper\', style: TextStyle(color: Colors.white))', 'label: Text(\'Open Paper\', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87))')
    content = content.replace('backgroundColor: const Color(0xFF1E1B2E)', 'backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1B2E) : Colors.white')

    # AI Summary Button - This is a colored button (6B4EE6), so text should stay white.
    # The dialog inside AI Summary:
    content = content.replace('Text("AI Summary", style: TextStyle(color: Colors.white))', 'Text("AI Summary", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))')
    content = content.replace('style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 16)', 'style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6, fontSize: 16)')

    with open(path, 'w') as f:
        f.write(content)

process_home_screen()
process_briefs_screen()
process_tasks_screen()
process_research_screen()

print("Done replacing colors!")
