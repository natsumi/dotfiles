#!/bin/bash
echo "Getting tasks..."
echo ""
echo ""

echo "🚫 Blocked Tasks"
echo "================"
echo ""

found=0

for epic_dir in .claude/epics/*/; do
  [ -d "$epic_dir" ] || continue
  epic_name=$(basename "$epic_dir")

  for task_file in "$epic_dir"[0-9]*.md; do
    [ -f "$task_file" ] || continue

    # Check if task is open
    status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    [ "$status" != "open" ] && [ -n "$status" ] && continue

    # Check for dependencies
    deps=$(grep "^depends_on:" "$task_file" | head -1 | sed 's/^depends_on: *\[//' | sed 's/\]//' | sed 's/,/ /g')

    if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
      task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
      task_num=$(basename "$task_file" .md)

      echo "⏸️ Task #$task_num - $task_name"
      echo "   Epic: $epic_name"
      echo "   Blocked by: [$deps]"

      # Check status of dependencies
      open_deps=""
      for dep in $deps; do
        dep_file="$epic_dir$dep.md"
        if [ -f "$dep_file" ]; then
          dep_status=$(grep "^status:" "$dep_file" | head -1 | sed 's/^status: *//')
          [ "$dep_status" = "open" ] && open_deps="$open_deps #$dep"
        fi
      done

      [ -n "$open_deps" ] && echo "   Waiting for:$open_deps"
      echo ""
      ((found++))
    fi
  done
done

if [ $found -eq 0 ]; then
  echo "No blocked tasks found!"
  echo ""
  echo "💡 All tasks with dependencies are either completed or in progress."
else
  echo "📊 Total blocked: $found tasks"
fi

exit 0
