You are filling an **LLM gap** in Ikigai Dot: deterministic CRM code already selected the contact and channel. Write the outreach copy.

Do not change CRM fields. Use ONLY facts from the contact record. Invent nothing.

Output one JSON object:
- `"channel"`: must be `"cold_email"`
- `"contact_name"`: exact contact name
- `"subject"`: short subject line grounded in the record
- `"body"`: 3–6 sentences, professional; reference at least one concrete fact from the record
- `"grounding_facts"`: non-empty array of short strings taken from the record (company, event, product focus)

### Contact record (from CRM)

- name: Priya Nair
- company: Latticeforge
- source: `sf_ruby_meetup`
- soi_ring: `community`
- profile_url: `https://linkedin.example/in/priya-nair-latticeforge`
- notes: Met at SF Ruby meetup 2026-10-28. Building observability tooling for Rails apps. Asked for an intro to anyone running multi-tenant Sidekiq at scale. Not contacted yet (`last_contacted_at` null).
