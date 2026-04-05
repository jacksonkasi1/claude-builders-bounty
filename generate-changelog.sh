#!/bin/bash
set -e

# Find the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
    echo "No previous tags found. Fetching all commits..."
    COMMITS=$(git log --pretty=format:"- %s")
else
    echo "Fetching commits since tag: $LAST_TAG"
    COMMITS=$(git log ${LAST_TAG}..HEAD --pretty=format:"- %s")
fi

if [ -z "$COMMITS" ]; then
    echo "No new commits found."
    exit 0
fi

cat << PROMPT_EOF > changelog_prompt.txt
You are a strict release notes generator. Group the following commit messages exactly into these categories:
### Added
### Fixed
### Changed
### Removed

Do not include empty categories. Format as valid Markdown.

Commits:
$COMMITS
PROMPT_EOF

echo "Sending commits to Claude..."
cat changelog_prompt.txt | claude -p "Generate CHANGELOG.md" > CHANGELOG_NEW.md
rm changelog_prompt.txt
echo "Successfully generated CHANGELOG_NEW.md"
