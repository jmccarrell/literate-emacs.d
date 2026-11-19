# Emacs configuration

This repo coordinates Jeff's Emacs configuration work: durable intent,
reference intelligence, and the roadmap for improving the active configuration.

## Language

**Spec**:
A durable, numbered statement of intent in `specs/`. A spec is the source of
scope for work and persists as project history.
_Avoid_: Ticket, task

**Spec Shape**:
The classification of a Spec that determines how it is investigated and
decomposed: broad exploratory, narrow directive, pushback/redesign, or
extension/refinement.
_Avoid_: Spec type, request type

**Reference-Repository Inventory**:
The complete registry of external Emacs-configuration repositories and their
last-known commits. It preserves which references are available for analysis.
_Avoid_: Reference synthesis, reference cache

**Reference Cache**:
The per-machine, regenerable local clones of repositories in the
Reference-Repository Inventory.
_Avoid_: Reference repository, reference synthesis

**Reference Synthesis**:
The tracked analysis of the Active References and the signals extracted from
them for this project.
_Avoid_: Reference-repository inventory, reference cache

**Active Reference**:
A Reference-Repository Inventory entry currently analyzed in the Reference
Synthesis at HIGH or MEDIUM tier.
_Avoid_: Cached repository

**Landscape**:
The active Emacs configuration's modernization roadmap. It consumes relevant
signals from the Reference Synthesis without duplicating repository analysis.
_Avoid_: Reference synthesis, inventory

**Rust Development Workflow**:
The Rust-focused editing and feedback experience in the active Emacs
configuration: navigation, diagnostics, formatting, testing, debugging,
project tooling, and explicitly scoped AI assistance. It supports both daily
project work and Rust course exercises. Its AI assistance extends a validated
Core Rust Loop.
_Avoid_: Rust setup, Rust support

**Review-First AI Assistance**:
AI support that works from explicitly selected context and requires review
before changing code. Inline completion and autonomous editing are separate,
opt-in capabilities.
_Avoid_: AI coding assistant, autonomous agent

**Cargo Project**:
A Rust project described by Cargo, either as a single crate or as a workspace
of related crates.
_Avoid_: Rust project, crate repository

**Core Rust Loop**:
The first usable Rust Development Workflow: editing, navigation, diagnostics,
formatting, and test execution. Debugging is a later capability, not a
prerequisite for adoption.
_Avoid_: Complete IDE, debugger workflow

**Low-Surface-Area Rust Stack**:
The Rust Development Workflow built first from Emacs 30 capabilities, with
additional packages adopted only to fill a demonstrated gap.
_Avoid_: Full Rust IDE distribution, package bundle

**Area**:
One agenda file that holds one part of Jeff's life or work, such as the lab,
Emacs, or investing. Its top-level headings are its Projects, one Misc
heading and at most one Reference heading.
_Avoid_: Work stream, context

**Project**:
An outcome that takes more than one Next Action, written as a heading with the
PROJECT state in an Area. Stuck until one step beneath it is a Next Action.
_Avoid_: Task list, Projects section

**Next Action**:
The next concrete step on a Project or in Misc, ready to be done; the NEXT
state.
_Avoid_: Todo, doing

**Inbox**:
The single file captured items land in before they are sorted into an Area.
Emptied at each weekly review.
_Avoid_: Tasks section, notes file

**Misc**:
The heading in each Area for sorted tasks that belong to no Project.
_Avoid_: Inbox, Tasks section

**Reference**:
Notes that support a Project or an Area but are never acted on: a heading with
no keyword under a Reference heading, or a file outside the agenda.
_Avoid_: Notes section, someday

**On Hold**:
A paused item that stays open in its Area because Jeff still means to do it;
the HOLD state.
_Avoid_: Deferred, Someday, cancelled

**Journal**:
The dated log of meeting notes, one datetree entry per meeting, kept outside
the agenda. Actions found in an entry leave it as their own items.
_Avoid_: Daily list, meeting file

**Someday**:
The list of things Jeff has not committed to, kept in its own file outside
any Area and left out of the daily views.
_Avoid_: On Hold, backlog
