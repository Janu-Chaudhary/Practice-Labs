// Prices in rupees. Used by every release.
const MENU = { "paneer thali": 180, "veg biryani": 160, "lassi": 60, "gulab jamun": 50 };

function total(items) {
  return items.reduce((sum, item) => sum + (MENU[item] || 0), 0);
}

module.exports = { MENU, total };
