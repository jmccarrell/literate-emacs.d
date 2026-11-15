# Recipes for the reference Emacs configs: other people's configs, cloned under
# reference-emacs-configs/ (gitignored) as read-only ground truth.
#
# The registry lives in `reference-repos.list` (one line per repo: "name url
# last-known-sha"). Use these recipes to read and modify it rather than editing
# the list by hand. `reference-configs.md` says what each tracked repo is for.
# Print the current registry.
ref-list:
    @cat reference-repos.list

# Add a repo to the registry. The last-known-sha column starts as
# "-" until ref-update-inventory captures the current HEAD.
# Usage: just ref-add NAME URL
ref-add name url:
    @if awk -v n='{{name}}' '$1 == n { exit 0 } END { exit 1 }' reference-repos.list; then \
       echo "ref-add: '{{name}}' is already registered" >&2; \
       exit 1; \
     fi
    @echo '{{name}} {{url}} -' >> reference-repos.list
    @echo "ref-add: added {{name}} -> {{url}} (run ref-show-plan to clone)"

# Print the git commands needed to align the local filesystem with
# the inventory + each repo's upstream HEAD. Does NOT execute. Pipe
# to `bash` to run; or copy individual commands. Internally fetches
# upstream so it can detect "behind upstream" state. URL of "-"
# means a local-only repo (no upstream); those are noted but not
# acted on.
ref-show-plan:
    @while read name url sha; do \
       dir="reference-emacs-configs/${name}"; \
       if [ ! -d "$dir" ]; then \
         if [ "$url" = "-" ]; then \
           echo "# ${name}: not present locally, no upstream URL — cannot reclone"; \
         else \
           echo "# ${name}: not present locally"; \
           echo "git clone ${url} ${dir}"; \
         fi; \
         continue; \
       fi; \
       if [ "$url" = "-" ]; then \
         echo "# ${name}: local-only (no upstream); skipping"; \
         continue; \
       fi; \
       if ! GIT_TERMINAL_PROMPT=0 git -C "$dir" fetch --quiet origin 2>/dev/null; then \
         echo "# ${name}: fetch failed (auth or network); cannot determine plan"; \
         continue; \
       fi; \
       GIT_TERMINAL_PROMPT=0 git -C "$dir" remote set-head origin --auto >/dev/null 2>&1 || true; \
       local_sha=$(git -C "$dir" rev-parse HEAD); \
       upstream=$(git -C "$dir" rev-parse origin/HEAD 2>/dev/null); \
       if [ -z "$upstream" ]; then \
         echo "# ${name}: cannot determine upstream HEAD; skipping"; \
       elif [ "$local_sha" != "$upstream" ]; then \
         echo "# ${name}: behind upstream"; \
         echo "git -C ${dir} pull --ff-only"; \
       fi; \
     done < reference-repos.list

# For each repo: fetch upstream, then list commits between the
# inventory's last-known-sha and current upstream HEAD. This is the
# change signal we want to feed into reference-configs.md updates.
# Local-only repos (URL='-') skip the upstream comparison.
ref-show-changes:
    @while read name url sha; do \
       dir="reference-emacs-configs/${name}"; \
       echo "=== ${name} ==="; \
       if [ ! -d "$dir" ]; then \
         echo "  not present locally; run ref-show-plan to clone"; \
         echo ""; continue; \
       fi; \
       if [ "$url" = "-" ]; then \
         echo "  local-only (no upstream); cannot show changes"; \
         echo ""; continue; \
       fi; \
       if ! GIT_TERMINAL_PROMPT=0 git -C "$dir" fetch --quiet origin 2>/dev/null; then \
         echo "  fetch failed (auth or network); cannot show changes"; \
         echo ""; continue; \
       fi; \
       GIT_TERMINAL_PROMPT=0 git -C "$dir" remote set-head origin --auto >/dev/null 2>&1 || true; \
       upstream=$(git -C "$dir" rev-parse origin/HEAD 2>/dev/null); \
       if [ -z "$sha" ] || [ "$sha" = "-" ]; then \
         echo "  inventory has no last-known-sha; run ref-update-inventory to capture current HEAD"; \
       elif [ "$sha" = "$upstream" ]; then \
         echo "  no new commits since last analysis (sha ${sha:0:7})"; \
       else \
         count=$(git -C "$dir" rev-list --count "${sha}..origin/HEAD" 2>/dev/null); \
         echo "  ${count} new commits since ${sha:0:7}:"; \
         git -C "$dir" log --oneline "${sha}..origin/HEAD" 2>&1 | sed 's/^/    /'; \
       fi; \
       echo ""; \
     done < reference-repos.list

# Capture each repo's current local HEAD into the inventory's
# last-known-sha column. Run after consuming ref-show-changes
# output into reference-configs.md and any subsequent git pulls.
# Idempotent (no-op if SHAs are already current).
ref-update-inventory:
    @while read name url _; do \
       dir="reference-emacs-configs/${name}"; \
       if [ -d "$dir" ]; then \
         sha=$(git -C "$dir" rev-parse HEAD); \
         echo "${name} ${url} ${sha}"; \
       else \
         echo "${name} ${url} -"; \
       fi; \
     done < reference-repos.list > reference-repos.list.tmp
    @mv reference-repos.list.tmp reference-repos.list
    @echo "ref-update-inventory: done"
