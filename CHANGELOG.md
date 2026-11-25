# Changelog

## 0.1.0-alpha.2

- Fixed: `/kl earned` also listed challenges this character had already earned, with meaningless progress such as "288/150 skill". It now adds only challenges earned on other characters.
- Fixed: progress bars had no visible track, so partial progress could look full.
- Changed: **Awards Point** now sits beside the progress bar, and the detail line stays on one line. The tooltip still lists every missing criterion.
- Changed: a finished single-step challenge shows "Complete". Level and skill challenges show "Level reached" or a capped skill value once the requirement is met.
- Added: icon, banner, screenshots and a demo animation, rendered in wow-ui-sim with Blizzard's Forever UI and synthetic progress.

## 0.1.0-alpha.1

First public alpha.

- Closest unlocks panel docked to the Legacy System window, ranked by how close each challenge is to complete.
- Dungeon groups and raids show their missing criteria on the row and in the tooltip.
- Live level and profession-skill estimates for challenges whose criteria don't report a number.
- **Awards Point** marks challenges that would give a new Legacy Point.
- Challenges at 0% and challenges completed on another character are hidden by default (`/kl zero`, `/kl earned`).
- Collapsible panel, 1 to 8 rows (`/kl rows`), and `/kl status` and `/kl dump` for bug reports.
