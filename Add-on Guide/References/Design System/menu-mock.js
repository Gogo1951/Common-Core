/*
  Gogo Design System: in-game mock renderer.

  Two drawing functions, each taking the same shapes the add-on code uses, so a
  wireframe is written the way the Lua is:

    GG.menu(host, entries, options)    Menu-Kit entries → a menu on its plate
    GG.tooltip(host, lines)            GameTooltip lines → an old-style tooltip

  Menu entries are Menu-Kit's (Style Guide → MINIMAP MENU → Row Kinds):
    { kind, left, right, leftColor, rightColor, on, selected, submenu,
      rightOnHover, onClick, tooltip, c }
  plus the two kinds the Design System proposes, `item` and `value`
  (README → Proposed Kit Changes). Colors are ns.PALETTE keys (TITLE, INFO,
  BODY, HELP, TEXT, ON, OFF, SEPARATOR, MUTED), a quality (q:poor … q:epic),
  or a six-digit hex such as a class color. `c` names the component a row
  belongs to, for the overlay; it never changes how the row looks.

  Tooltip lines: { l, lc, r, rc, wrap, c } or { blank: true }.

  Text is trusted HTML written by the page author, never player input.
*/
(function () {
	"use strict";

	var PALETTE = {
		TITLE: "FFD100",
		INFO: "00BBFF",
		BODY: "FFFFFF",
		HELP: "CCCCCC",
		TEXT: "FFFFFF",
		ON: "33CC33",
		OFF: "CC3333",
		SEPARATOR: "AAAAAA",
		MUTED: "808080",
	};
	var QUALITY = { poor: "9D9D9D", common: "FFFFFF", uncommon: "1EFF00", rare: "0070DD", epic: "A335EE" };
	var CLASS = {
		DRUID: "FF7C0A",
		HUNTER: "AAD372",
		MAGE: "3FC7EB",
		PALADIN: "F48CBA",
		PRIEST: "FFFFFF",
		ROGUE: "FFF468",
		SHAMAN: "0070DD",
		WARLOCK: "8788EE",
		WARRIOR: "C69B6D",
	};

	// Menu-Kit's constants (Features/Menu-Kit.lua).
	var KIT = {
		MIN_WIDTH: 128,
		NOTE_MAX_WIDTH: 256,
		DESCRIPTION_MAX_WIDTH: 320,
		MAX_WIDTH: 320, // no row widens the menu past this; a long left side wraps
		INSETS: 2 * (8 + 4), // TEXT_INSET + ROW_INSET, both sides
		FLYOUT_OVERLAP: 12, // ROW_INSET + TEXT_INSET: the flyout's edge sits this far inside its menu's (Style Guide → MENUS)
		FLYOUT_RISE: 8, // SPACE.NEAR
	};

	function hex(key) {
		if (!key) return null;
		if (PALETTE[key]) return "#" + PALETTE[key];
		if (key.indexOf("q:") === 0) return "#" + (QUALITY[key.slice(2)] || "FFFFFF");
		if (/^[0-9a-f]{6}$/i.test(key)) return "#" + key;
		return null;
	}

	function paint(text, key) {
		var color = hex(key);
		return color ? '<span style="color:' + color + '">' + text + "</span>" : text;
	}

	// A drawn stand-in for an item or spell icon: a tinted square, never game art.
	function icon(hue, light) {
		var h = hue || 0;
		var l = light || 42;
		return (
			'<span class="gg-icon" style="background:linear-gradient(135deg,hsl(' +
			h +
			" 60% " +
			(l + 18) +
			"%),hsl(" +
			h +
			" 55% " +
			(l - 14) +
			'%))"></span>'
		);
	}

	// Copper as Blizzard draws money: white digits, a colored g / s / c after each.
	function money(copper) {
		var g = Math.floor(copper / 10000);
		var s = Math.floor((copper % 10000) / 100);
		var c = copper % 100;
		var parts = [];
		if (g) parts.push("<b>" + g.toLocaleString("en-US") + '</b><span class="g">g</span>');
		if (s) parts.push("<b>" + s + '</b><span class="s">s</span>');
		if (c || !parts.length) parts.push("<b>" + c + '</b><span class="c">c</span>');
		return '<span class="gg-money">' + parts.join(" ") + "</span>";
	}

	// ---------------------------------------------------------------------
	// Tooltip
	// ---------------------------------------------------------------------

	function tooltip(host, lines) {
		var box = document.createElement("div");
		box.className = "gg-tooltip";
		lines.forEach(function (line) {
			var row = document.createElement("div");
			row.className = "gg-tt-line" + (line.wrap ? " wrap" : "");
			if (line.c) row.dataset.c = line.c;
			if (line.blank) {
				row.innerHTML = "&nbsp;";
			} else {
				var l = document.createElement("span");
				l.className = "l";
				l.innerHTML = paint(line.l || "", line.lc);
				row.appendChild(l);
				if (line.r !== undefined && line.r !== null) {
					var r = document.createElement("span");
					r.className = "r";
					r.innerHTML = paint(line.r, line.rc);
					row.appendChild(r);
				}
			}
			box.appendChild(row);
		});
		host.appendChild(box);
		capWrap(box, 320, ".gg-tt-line.wrap", 20);
		return box;
	}

	// Wrapping lines widen the box only up to cap, as Menu-Kit's second pass does.
	function capWrap(box, cap, selector, insets) {
		var wraps = box.querySelectorAll(selector);
		if (!wraps.length) return;
		box.style.width = "";
		var width = box.getBoundingClientRect().width;
		wraps.forEach(function (row) {
			var probe = document.createElement("span");
			probe.style.cssText = "position:absolute;visibility:hidden;white-space:nowrap;font:inherit";
			probe.innerHTML = row.innerHTML;
			box.appendChild(probe);
			var own = typeof cap === "function" ? cap(row) : cap;
			width = Math.max(width, Math.min(probe.getBoundingClientRect().width + insets, own));
			probe.remove();
		});
		box.style.width = Math.ceil(width) + "px";
	}

	// ---------------------------------------------------------------------
	// Menu
	// ---------------------------------------------------------------------

	var HEADINGS = { section: true, status: true, submenu: true };
	var OPTION_KINDS = { choice: true, toggle: true, item: true, value: true };
	var WRAP_KINDS = { description: true, note: true };

	// What each kind shows, as Menu-Kit's Look() decides it.
	function look(entry, toggleText) {
		var kind = entry.kind;
		var left = entry.left;
		var right = entry.right;
		var lc = entry.leftColor;
		var rc = entry.rightColor;
		if (kind === "header" || kind === "submenu" || kind === "section") {
			lc = lc || "TITLE";
			rc = rc || "MUTED";
		} else if (kind === "status") {
			lc = lc || "TITLE";
		} else if (kind === "toggle") {
			right = entry.on ? toggleText.on : toggleText.off;
			lc = lc || (entry.on ? "TEXT" : "MUTED");
			rc = rc || (entry.on ? "ON" : "MUTED");
		} else if (kind === "choice") {
			right = entry.selected ? '<span class="gg-check"></span>' : null;
			lc = lc || (entry.selected ? "TEXT" : "MUTED");
		} else if (kind === "action") {
			// Proposed: the button click that does the same job sits on the right, gray, like a menu's shortcut column.
			lc = lc || "INFO";
			rc = rc || "MUTED";
		} else if (kind === "hint") {
			lc = lc || "INFO";
			rc = rc || "INFO";
		} else if (kind === "description") {
			lc = lc || "BODY";
		} else if (kind === "note") {
			lc = lc || "MUTED";
		} else if (kind === "item") {
			// Proposed: icon at line height, the name in its quality color, a count after it.
			left = (entry.icon || "") + paint(entry.left, entry.quality ? "q:" + entry.quality : "TEXT");
			if (entry.count > 1) left += " " + paint("x" + entry.count, "TEXT");
			rc = rc || "TEXT";
		} else if (kind === "value") {
			// Proposed: a read-out, nothing to click.
			lc = lc || "BODY";
			rc = rc || "TEXT";
		}
		return { left: left, right: right, lc: lc || "TEXT", rc: rc || "TEXT" };
	}

	function menu(host, entries, options) {
		options = options || {};
		var toggleText = options.toggleText || { on: "On", off: "Off" };
		var wrap = document.createElement("div");
		wrap.className = "gg-menu-wrap";
		host.appendChild(wrap);

		var panel = draw(entries, wrap, toggleText, function (row, entry) {
			if (!options.flyouts) return;
			openFlyout(entry && entry.submenu ? entry.submenu : null, row);
		});

		var flyout = null;
		var flyoutKey = null;
		// The flyout sits beside the menu in the page's flow, so a tall one grows its stage instead of clipping.
		function openFlyout(key, row) {
			if (key === flyoutKey) return;
			if (flyout) flyout.remove();
			panel.querySelectorAll(".gg-row.lock").forEach(function (r) {
				r.classList.remove("lock");
			});
			flyout = null;
			flyoutKey = key;
			if (options.onFlyout) options.onFlyout(key);
			var build = key && options.flyouts[key];
			var rows = build ? build() : [];
			if (!rows.length) return;
			row.classList.add("lock");
			flyout = document.createElement("div");
			flyout.className = "gg-flyout";
			flyout.style.marginTop = Math.max(0, row.offsetTop - KIT.FLYOUT_RISE) + "px";
			wrap.appendChild(flyout);
			draw(rows, flyout, toggleText, null);
		}
		if (options.openLeft) wrap.classList.add("left");
		if (options.uncapped) wrap.classList.add("gg-uncapped");
		if (options.openFlyout) {
			var row = panel.querySelector('[data-submenu="' + options.openFlyout + '"]');
			if (row) openFlyout(options.openFlyout, row);
		}
		return wrap;
	}

	function draw(source, host, toggleText, onEnterRow) {
		// Menu-Kit adds a spacer above every heading, unless it opens the panel or one is already there.
		var entries = [];
		source.forEach(function (entry) {
			var previous = entries[entries.length - 1];
			if (HEADINGS[entry.kind] && previous && previous.kind !== "spacer") {
				entries.push({ kind: "spacer", c: previous.c });
			}
			entries.push(entry);
		});

		var panel = document.createElement("div");
		panel.className = "gg-menu";
		host.appendChild(panel);

		// Any row may open a submenu (a switch with options of its own keeps its look); with any arrow in the panel, every value keeps the arrow's room.
		var hasArrow = entries.some(function (entry) {
			return entry.kind === "submenu" || !!entry.submenu;
		});

		entries.forEach(function (entry) {
			var row = document.createElement("div");
			var kind = entry.kind;
			var clickable = !!entry.onClick || kind === "submenu" || !!entry.submenu;
			row.className =
				"gg-row " +
				kind +
				(OPTION_KINDS[kind] ? " opt" : "") +
				(WRAP_KINDS[kind] ? " wrap" : "") +
				(clickable ? " click" : "");
			if (entry.c) row.dataset.c = entry.c;
			if (entry.submenu) row.dataset.submenu = entry.submenu;
			if (kind !== "spacer" && kind !== "separator") {
				var shown = look(entry, toggleText);
				var l = document.createElement("span");
				l.className = "l";
				l.innerHTML = paint(shown.left || "", shown.lc);
				row.appendChild(l);
				var rightText = shown.right;
				if (kind === "submenu" || entry.submenu) {
					rightText = (rightText ? paint(rightText, shown.rc) + " " : "") + '<span class="gg-arrow"></span>';
				} else if (rightText !== undefined && rightText !== null) {
					rightText = paint(rightText, shown.rc) + (hasArrow ? ' <span class="gg-arrow room"></span>' : "");
				}
				if (rightText) {
					var r = document.createElement("span");
					r.className = "r" + (entry.rightOnHover ? " hover-only" : "");
					r.innerHTML = rightText;
					row.appendChild(r);
				}
			}
			if (clickable) {
				row.tabIndex = 0;
				row.setAttribute("role", "button");
				var fire = function () {
					if (entry.onClick) entry.onClick();
				};
				row.addEventListener("click", fire);
				row.addEventListener("keydown", function (event) {
					if (event.key === "Enter" || event.key === " ") {
						event.preventDefault();
						fire();
					}
				});
			}
			row.addEventListener("mouseenter", function () {
				if (entry.tooltip) showTip(row, entry.tooltip, host);
				if (onEnterRow && (clickable || entry.submenu)) onEnterRow(row, entry);
			});
			row.addEventListener("mouseleave", hideTip);
			panel.appendChild(row);
		});

		capWrap(
			panel,
			function (row) {
				return row.classList.contains("description") ? KIT.DESCRIPTION_MAX_WIDTH : KIT.NOTE_MAX_WIDTH;
			},
			".gg-row.wrap",
			KIT.INSETS
		);
		return panel;
	}

	// A row's tooltip, in the option's own words: { title, body } or an HTML string.
	var tip = null;
	function showTip(row, content, host) {
		hideTip();
		var body = typeof content === "string" ? [{ l: content, lc: "TITLE" }] : [{ l: content.title, lc: "TITLE" }];
		if (content.body) body.push({ l: content.body, lc: "BODY", wrap: true });
		tip = document.createElement("div");
		tip.className = "gg gg-hover-tip";
		document.body.appendChild(tip);
		var box = tooltip(tip, body);
		box.style.maxWidth = "256px";
		var rect = row.getBoundingClientRect();
		tip.style.left = Math.min(window.scrollX + rect.right + 8, window.scrollX + document.documentElement.clientWidth - box.offsetWidth - 8) + "px";
		tip.style.top = window.scrollY + rect.top + "px";
	}
	function hideTip() {
		if (tip) tip.remove();
		tip = null;
	}

	window.GG = {
		PALETTE: PALETTE,
		QUALITY: QUALITY,
		CLASS: CLASS,
		KIT: KIT,
		paint: paint,
		icon: icon,
		money: money,
		menu: menu,
		tooltip: tooltip,
	};
})();
