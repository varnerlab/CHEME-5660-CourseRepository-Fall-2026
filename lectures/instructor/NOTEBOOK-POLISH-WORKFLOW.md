# Notebook polish rounds on another machine

The reusable workflow is versioned in
[`.agents/skills/notebook-polish/SKILL.md`](../../.agents/skills/notebook-polish/SKILL.md).
The [shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md) remains the single source
for teaching voice and formatting. CHEME 5800 links to the same skill through a
relative directory symlink; no personal Codex folder needs to be copied.

## Set up the two course checkouts

On a Mac or Linux machine, clone both complete authoring repositories into the same
parent folder, retaining these directory names:

```text
courses/
  CHEME-5660-CourseRepository-Fall-2026/
  CHEME-5800-CourseRepository-Fall-2026/
```

From the chosen parent folder:

```bash
git clone https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026.git
git clone https://github.com/varnerlab/CHEME-5800-CourseRepository-Fall-2026.git
```

If they are already cloned, pull the approved changes in each checkout. These
workflow files and any desired style-guide or notebook changes must first be
committed and pushed from the original machine; Git does not transfer uncommitted
edits. Weekly student bundles do not contain this authoring setup.

Open either course checkout in Codex and say:

> Let's do a notebook polish round.

Codex asks for the notebook path if it was not supplied, gives an initial score
and feedback, reviews one section at a time, and finishes with a comparison of
initial and final scores. You can also invoke `$notebook-polish` explicitly. If
the newly added skill does not appear, restart Codex.

## Tools and maintenance

Follow each course's README to prepare Julia and its packages. Install VS Code
if you want the same preview experience. The workflow discovers the local Python
and browser tools needed to generate notebook previews; those environments and
application permissions are machine-specific and are not transferred by Git.
Previews are regenerated in the target repository's `build/notebook-previews/`.

Update the shared workflow in CHEME 5660, then commit and push it there. Pull
CHEME 5660 on the other machine to update both courses' workflow. Maintain the
style guide in its existing file. Do not create separate editable copies of
either set of instructions in CHEME 5800 or a personal skills folder.

If a machine already has the earlier personal `notebook-polish` skill, remove or
archive that older installation after checking the repository version. Keeping
both can produce duplicate skill entries. On Windows, Git must check out the
CHEME 5800 directory link as a symlink (for example, use WSL); a checkout that
materializes the link as a plain text file will not expose the shared skill.

[Official Codex skill documentation](https://learn.chatgpt.com/docs/build-skills)
describes repository discovery, symlink support, and invocation.
