---
name: homebox-add-product
description: Use when the user provides a product URL (Amazon, store page, etc.) and wants to add it to their Homebox inventory. TRIGGER when user says "add this product", shares a product URL to catalog, or wants to scrape a product page into Homebox.
disable-model-invocation: true
---

# Add Product from URL to Homebox

Scrape a product page and create a Homebox inventory item from it. Combines playwright-cli (browser scraping) with homebox-cli (inventory management).

## Workflow

### 1. Gather all user input first (before any scraping or creation)

Collect everything needed from the user upfront so the rest of the workflow runs uninterrupted.

**Step 1a: Get the product URL**
- If the user didn't provide a URL in their message, use AskUserQuestion to ask for it.

**Step 1b: Get the location**
- Run `homebox locations list --json` to fetch available locations.
- Use AskUserQuestion to present the locations as a numbered list and let the user pick one.

Once both the URL and location are confirmed, proceed without further user interaction.

### 2. Scrape the product page

Use the `/playwright-cli` skill to open the URL and extract:

| Field | Required | Notes |
|-------|----------|-------|
| title | yes | Product name — shorten if overly long |
| price | yes | Current listed price |
| description | no | Summarize if long; markdown formatted |
| manufacturer / brand | no | Often in "Visit the X Store" or detail tables |
| model number | no | From tech specs / detail tables |
| image URL | yes | Highest resolution main product image |

**Extraction tips:**
- Use `playwright-cli eval` for simple selectors, `playwright-cli run-code` for complex logic
- For Amazon: `#productTitle` (title), `#feature-bullets` (description), `#bylineInfo` (brand), `#landingImage` data-old-hires attribute (highest res image), `.a-price .a-offscreen` (price), `#prodDetails` (tech specs)
- For other sites: inspect the snapshot to find appropriate selectors
- Always close the browser when done

### 3. Match tags

After scraping, check if any existing tags are relevant to the product.

1. Run `homebox tags list --json` to fetch all existing tags.
2. If tags exist, use AI judgment to determine which are relevant based on the scraped **title** and **description**. Be conservative — only match when there's clear relevance (e.g., "Cordless Drill" → "Tools" or "Power Tools", but not "Kitchen").
3. Items can have multiple tags. Include all that clearly apply.
4. If no tags match, optionally suggest a few tags the user might want to create later — but do not block the workflow. Continue to step 4 without tags.

### 4. Create the item

Use the `/homebox-cli` skill's "Create Item from Product URL" workflow:

```sh
# Step 1: Create with basic fields (include --tag-id for each matched tag)
homebox items create --name "TITLE" --location-id LOCATION_ID \
  --description "DESCRIPTION" --quantity 1 \
  --tag-id TAG_ID_1 --tag-id TAG_ID_2 --json

# Step 2: Update with extended attributes + custom URL field
homebox items update ITEM_ID --name "TITLE" \
  --manufacturer "BRAND" --model-number "MODEL" \
  --purchase-price PRICE \
  --field "URL=ORIGINAL_URL" --json

# Step 3: Attach product image
homebox items attach-from-url ITEM_ID --url "IMAGE_URL" --json
```

- Omit `--tag-id` flags if no tags matched in step 3
- Always set quantity to 1 unless user specifies otherwise
- Always add a custom field `URL` with the original product URL
- Omit `--manufacturer` / `--model-number` if not found on page
- All commands use `--json` flag
- Run with `bundle exec exe/homebox` if in the homebox-rb project directory

### 5. Report summary

Show a table of what was created: name, location, price, manufacturer, tags, asset ID, item ID. If no tags were matched, note that the user can add tags later with `homebox items update`.
