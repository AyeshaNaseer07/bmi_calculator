"""Download one distinct food photo per meal from the official Pexels API.

1. Get a free API key: https://www.pexels.com/api/  (sign up, instant)
2. Run:  PEXELS_API_KEY=your_key python3 download_meal_photos.py
Existing files are skipped; credits are written to assets/images/meals/CREDITS.txt
"""
import os, sys, time
from io import BytesIO
import requests
from PIL import Image

KEY = os.environ.get("PEXELS_API_KEY")
if not KEY:
    sys.exit("Set PEXELS_API_KEY first (free key from https://www.pexels.com/api/)")

OUTPUT_DIR = os.path.join("assets", "images", "meals")
os.makedirs(OUTPUT_DIR, exist_ok=True)
HEADERS = {"Authorization": KEY, "User-Agent": "bmi-calculator-asset-script/1.0"}

MEALS = {
    "baked_cod.jpg": "baked cod fish",
    "banana_oat_pancakes.jpg": "banana pancakes",
    "banana_pancakes.jpg": "pancakes syrup banana",
    "beef_stir_fry_noodles.jpg": "beef stir fry noodles",
    "beef_sweet_potato_wrap.jpg": "beef wrap sandwich",
    "cheese_omelette_toast.jpg": "cheese omelette",
    "chia_pudding.jpg": "chia seed pudding",
    "chicken_broccoli.jpg": "chicken broccoli stir fry",
    "chicken_fajita.jpg": "chicken fajitas",
    "chicken_quesadilla.jpg": "chicken quesadilla",
    "chicken_rice_bowl.jpg": "chicken rice bowl",
    "chicken_soup.jpg": "chicken soup bowl",
    "chickpea_salad.jpg": "chickpea salad",
    "cottage_cheese_fruit.jpg": "cottage cheese fruit",
    "creamy_chicken_pasta.jpg": "chicken alfredo pasta",
    "egg_avocado_toast.jpg": "avocado toast egg",
    "egg_white_wrap.jpg": "breakfast wrap egg",
    "falafel_plate.jpg": "falafel hummus plate",
    "granola_yogurt_parfait.jpg": "yogurt parfait granola",
    "greek_yogurt_berries.jpg": "greek yogurt berries",
    "grilled_chicken_salad.jpg": "grilled chicken breast salad",
    "grilled_shrimp.jpg": "grilled shrimp prawns",
    "grilled_veggie_wrap.jpg": "grilled vegetable wrap",
    "hummus_veggie_sandwich.jpg": "hummus vegetable sandwich",
    "lamb_curry_rice.jpg": "lamb curry rice",
    "lemon_herb_chicken.jpg": "lemon herb roasted chicken",
    "lentil_curry.jpg": "lentil dal curry",
    "lentil_soup.jpg": "lentil soup",
    "mushroom_scramble.jpg": "scrambled eggs mushrooms",
    "oatmeal_bowl.jpg": "oatmeal porridge berries",
    "overnight_oats_jar.jpg": "overnight oats jar",
    "peanut_butter_oats.jpg": "oatmeal peanut butter",
    "quinoa_chickpea_bowl.jpg": "quinoa bowl vegetables",
    "roast_chicken_mashed_potato.jpg": "roast chicken mashed potatoes",
    "salmon_quinoa_avocado.jpg": "salmon quinoa avocado",
    "salmon_vegetables.jpg": "grilled salmon fillet vegetables",
    "shrimp_noodles.jpg": "shrimp noodles stir fry",
    "smoothie_bowl.jpg": "acai smoothie bowl",
    "steamed_fish_greens.jpg": "steamed fish vegetables",
    "tuna_pasta.jpg": "tuna pasta salad",
    "tuna_salad.jpg": "tuna salad bowl",
    "tuna_wrap.jpg": "tuna salad wrap",
    "turkey_lettuce_wraps.jpg": "turkey lettuce wraps",
    "turkey_meatballs.jpg": "turkey meatballs sauce",
    "turkey_stir_fry.jpg": "turkey stir fry vegetables",
    "veggie_omelette.jpg": "vegetable omelet",
    "zucchini_noodles.jpg": "zucchini noodles zoodles",
}

used = set()
credits = []
ok = 0

def get(url, **kw):
    for attempt in range(3):
        try:
            r = requests.get(url, headers=HEADERS, timeout=20, **kw)
            if r.status_code == 429:
                time.sleep(5)
                continue
            return r
        except requests.RequestException:
            time.sleep(2)
    return None

for i, (filename, query) in enumerate(MEALS.items(), 1):
    dest = os.path.join(OUTPUT_DIR, filename)
    if os.path.exists(dest):
        print(f"[{i}/{len(MEALS)}] exists: {filename}")
        continue
    r = get("https://api.pexels.com/v1/search",
            params={"query": query + " food", "per_page": 15, "orientation": "square"})
    if r is None or r.status_code != 200:
        print(f"[{i}/{len(MEALS)}] x search failed for {filename} ({getattr(r, 'status_code', 'no response')})")
        continue
    photos = [p for p in r.json().get("photos", []) if p["id"] not in used]
    if not photos:
        print(f"[{i}/{len(MEALS)}] x no result for '{query}'")
        continue
    p = photos[0]
    img = get(p["src"]["large"])
    if img is None or img.status_code != 200:
        print(f"[{i}/{len(MEALS)}] x download failed for {filename}")
        continue
    im = Image.open(BytesIO(img.content)).convert("RGB")
    s = min(im.size)
    l, t = (im.width - s) // 2, (im.height - s) // 2
    im.crop((l, t, l + s, t + s)).resize((800, 800)).save(dest, "JPEG", quality=85)
    used.add(p["id"])
    credits.append(f"{filename}: {p['photographer']} - {p['url']}")
    ok += 1
    print(f"[{i}/{len(MEALS)}] saved {filename}")
    time.sleep(0.4)

with open(os.path.join(OUTPUT_DIR, "CREDITS.txt"), "a") as f:
    f.write("\n".join(credits) + "\n")
print(f"\nDone: {ok} new photos in {OUTPUT_DIR}")
