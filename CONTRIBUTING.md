# Contributing

## Backlog convention (hard rule)

Every ticket is filed with the **Task** issue form and this exact shape:

```
Title:  <repo>: <imperative, specific> — <the one-line what>
Body:
  What it is:   2–4 lines — the capability, not a task list
  Depends on:   a thing that EXISTS today (file:line / merged PR / shipped surface)
                or a named upstream ticket. NEVER "nothing" — if greenfield, cite the substrate.
  Complexity:   S | M | L | XL
  Gate:         <taxonomy below>
Labels:  complexity:<S|M|L|XL>   gate:<...>   area:<...>
```

**No time. Ever.** No weeks, days, sprints, quarters, deadlines, ETAs, or "by <date>". Sizing belongs to the work; scheduling belongs to the operator's deck — the deck is the only place weeks live, and the deck is not a ticket.

**Complexity is effort-shape, never time.** An **XL must decompose into ≥3 real sub-items** — an epic pointer, not a bucket.

**`Depends on` is load-bearing — "never nothing."** It stops the backlog becoming a wish list.

**Gate taxonomy — exactly these eight:** `none` · `upstream-primitive` · `patent` · `credentials` · `physical-witness` · `adversarial-review` · `spend` · `operator-decision`. A gate is a sequencing label, not a parking space — gated tickets are still fully specced.

The Task form enforces these fields (no time field); a CI Action flags time-framing and applies the `complexity:`/`gate:`/`area:` labels.
