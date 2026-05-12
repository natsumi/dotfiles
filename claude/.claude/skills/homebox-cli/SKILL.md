---
name: homebox-cli
description: Use the homebox CLI to manage items, locations, and tags in a Homebox inventory instance. Supports create, update, import/export, and file attachment for items; create and update for locations and tags.
disable-model-invocation: true
---

# Homebox CLI

Command-line interface for managing a Homebox home inventory instance. Requires a config file with connection credentials.

## Setup

Create `~/.homebox.yml`:

```yaml
url: https://homebox.example.com
username: user@example.com
password: your-password
```

A project-local `.homebox.yml` overrides global settings.

## Key Commands

### Items

```sh
# List and search
homebox items list --json
homebox items list -q "drill" --json

# Get details
homebox items get ITEM_ID --json

# Create (basic fields — use update for purchase info, serial numbers, etc.)
homebox items create --name "Cordless Drill" --location-id LOCATION_ID --description "DeWalt 20V MAX" --json
homebox items create --name "Cordless Drill" --location-id LOCATION_ID \
  --tag-id TAG_ID_1 --tag-id TAG_ID_2 --json

# Update (supports all item fields)
homebox items update ITEM_ID --name "Cordless Drill" \
  --purchase-price 89.99 --model-number "DCD771C2" \
  --serial-number "ABC123" --notes "Bought at Home Depot" --json
homebox items update ITEM_ID --name "Drill" \
  --tag-id TAG_ID_1 --tag-id TAG_ID_2 \
  --field "Color=Red" --field "Brand=DeWalt" --json
homebox items update ITEM_ID --name "Drill" --archived --insured --json

# Update attachment metadata
homebox items update-attachment ITEM_ID ATTACHMENT_ID \
  --title "User Manual" --type manual --primary --json

# Import/export CSV
homebox items import items.csv --json
homebox items export -o backup.csv

# Attach files
homebox items attach ITEM_ID --file photo.jpg --type photo --json
homebox items attach-from-url ITEM_ID --url https://example.com/product.jpg --json
```

### Locations

```sh
homebox locations list --json
homebox locations get LOCATION_ID --json
homebox locations create --name "Garage" --json
homebox locations update LOCATION_ID --name "Main Garage" --description "Updated" --json
homebox locations tree --json
homebox locations tree --with-items --json
```

### Tags

```sh
homebox tags list --json
homebox tags get TAG_ID --json
homebox tags create --name "power-tools" --color "#ff6600" --json
homebox tags update TAG_ID --name "Power Tools" --color "#ff0000" --json
```

## Tips for AI Usage

- **Always use `--json`** for machine-readable output. Without it, output is a human-readable table that is harder to parse.
- **Create, then update.** `items create` only accepts basic fields (name, location, description, quantity, tags). Use `items update` afterward to set purchase info, serial numbers, warranty details, custom fields, and other extended attributes.
- **Descriptions support markdown.** Include links, lists, and formatting in `--description` values.
- **Use `--field` for custom fields.** Repeatable `key=value` format. Values can contain `=` (e.g., URLs with query params).
- **Use `attach-from-url`** to attach product images directly from URLs without downloading files first.
- **Location IDs are UUIDs.** Run `homebox locations list --json` to discover them before creating items.
- **Search is full-text.** The `-q` flag on `homebox items list` searches names, descriptions, and fields.

## Common Workflow: Create Item from Product URL

1. Find or create the target location:
   ```sh
   homebox locations list --json
   ```
2. Create the item with basic details:
   ```sh
   homebox items create --name "Product Name" --location-id LOCATION_ID \
     --description "Model X, purchased from Store" --json
   ```
3. Capture the item ID from the JSON response.
4. Update with extended details:
   ```sh
   homebox items update ITEM_ID --name "Product Name" \
     --purchase-price 29.99 --model-number "MODEL-123" \
     --field "Product URL=https://store.com/product" --json
   ```
5. Attach a product image:
   ```sh
   homebox items attach-from-url ITEM_ID --url https://example.com/product.jpg --json
   ```

## Error Output

Errors are printed to stderr. Common cases:

- **Missing config**: `Configuration error: url is required`
- **Bad credentials**: `Login failed (401)`
- **Not found**: exits non-zero with error message
- **Validation errors**: exits non-zero with details from the API
