/*
  Gogo Design System: options panel mock renderer.

  Draws AceConfig-3.0 option tables the way AceConfigDialog draws them in the
  Blizzard Options/Settings interface, so a wireframe is written the way the
  Lua is:

    GO.page(host, group, options)       one AceConfig group → one panel page
    GO.settings(host, tree, options)    the Settings window: category tree + page

  A group is an AceConfig table: { type = "group", name, args, childGroups }.
  Every arg takes AceConfig's own keys:
    type      header, description, toggle, select, range, input, execute,
              color, multiselect, group
    name, desc, order, width, hidden, disabled, get, set, func, values,
    sorting, min, max, step, isPercent, fontSize, image, multiline,
    dialogControl, inline, childGroups, confirm, confirmText
  name, desc, hidden, disabled and values may be functions, called with info
  (the path of arg keys, as AceConfig passes it). get(info) and set(info, v)
  read and write; func(info) runs an execute. After a set or func the page
  redraws, the way ns.RefreshSettings() repaints every panel.

  Mock-only keys, never in the Lua:
    c         the component a widget belongs to, for the overlay
    itemLink  on an input with an _ItemLink dialogControl: the drawn link (HTML)

  Widths are AceConfigDialog's: 170 points per unit, "half" 85, "normal" 170,
  "double" 340, "full" the row. Headers, descriptions and inline groups default
  to full; everything else to normal.

  GO.kit mirrors Options-Kit's helpers (Design System/Options Panels/
  Options-Kit.md → API) with the same names and arguments, so a Proposed page is
  written with the calls the add-on will make.

  Load after menu-mock.js and menu-mock.css (palette, paint, icon, tooltip).
  Text is trusted HTML written by the page author, never player input.
*/
(function () {
	"use strict";

	var GG = window.GG;
	var UNIT = 170;
	var GRID = {
		UNIT: UNIT,
		ROW: 3.4, // ns.OPTIONS_ROW_WIDTH
		LABEL: 2.1, // ns.OPTIONS_LABEL_WIDTH
		CONTROL: 1.3, // ns.OPTIONS_CONTROL_WIDTH
		REMOVE: 0.25, // ns.OPTIONS_REMOVE_ICON_WIDTH
		SUB_INDENT: 0.115, // ns.OPTIONS_SUB_INDENT_WIDTH
	};

	function call(v, info) {
		return typeof v === "function" ? v(info) : v;
	}

	function sortedArgs(args) {
		return Object.keys(args || {})
			.map(function (key) {
				return { key: key, opt: args[key] };
			})
			.filter(function (e) {
				return e.opt;
			})
			.sort(function (a, b) {
				var oa = a.opt.order == null ? 100 : a.opt.order;
				var ob = b.opt.order == null ? 100 : b.opt.order;
				if (oa !== ob) return oa - ob;
				return a.key < b.key ? -1 : a.key > b.key ? 1 : 0;
			});
	}

	function widthOf(opt) {
		var w = opt.width;
		var fullByDefault = opt.type === "header" || opt.type === "description" || (opt.type === "group" && opt.inline);
		if (w === "full" || (w == null && fullByDefault)) return null;
		if (typeof w === "number") return w * UNIT;
		if (w === "double") return 2 * UNIT;
		if (w === "half") return UNIT / 2;
		return UNIT;
	}

	// ------------------------------------------------------------------------
	// AceConfigDialog's tooltip: the option's name in gold, its desc in white
	// ------------------------------------------------------------------------
	var tip = null;
	function showTip(el, title, body) {
		hideTip();
		if (!title && !body) return;
		tip = document.createElement("div");
		tip.className = "gg go-tip";
		document.body.appendChild(tip);
		var lines = [];
		if (title) lines.push({ l: title, lc: "TITLE", wrap: true });
		if (body) lines.push({ l: body, lc: "BODY", wrap: true });
		var box = GG.tooltip(tip, lines);
		box.style.maxWidth = "288px";
		var r = el.getBoundingClientRect();
		var left = window.scrollX + r.left + Math.min(r.width, 160) + 8;
		left = Math.min(left, window.scrollX + document.documentElement.clientWidth - box.offsetWidth - 8);
		tip.style.left = Math.max(8, left) + "px";
		tip.style.top = window.scrollY + r.bottom + 4 + "px";
	}
	function hideTip() {
		if (tip) tip.remove();
		tip = null;
	}
	function hover(el, opt, info, name) {
		var desc = call(opt.desc, info);
		if (!desc && !opt.tip) return;
		el.addEventListener("mouseenter", function () {
			showTip(el, name, desc);
		});
		el.addEventListener("mouseleave", hideTip);
	}

	// ------------------------------------------------------------------------
	// Widgets
	// ------------------------------------------------------------------------
	function cap(text) {
		return text ? '<span class="go-cap">' + text + "</span>" : "";
	}

	function closeMenus(except) {
		document.querySelectorAll(".go-menu").forEach(function (m) {
			if (m !== except) m.remove();
		});
	}
	document.addEventListener("click", function (e) {
		if (!e.target.closest(".go-select, .go-menu")) closeMenus();
	});

	function widget(opt, info, ctx) {
		var name = call(opt.name, info);
		name = name == null ? "" : String(name);
		var disabled = !!call(opt.disabled, info);
		var w = document.createElement("div");
		w.className = "go-w";
		var px = widthOf(opt);
		if (px == null) w.classList.add("full");
		else w.style.flex = "0 0 " + px + "px";
		if (disabled) w.classList.add("disabled");
		if (opt.c) w.dataset.c = opt.c;
		var get = function () {
			return opt.get ? opt.get(info) : undefined;
		};
		var set = function (v) {
			if (disabled) return;
			if (opt.set) opt.set(info, v);
			ctx.redraw();
		};

		switch (opt.type) {
			case "header": {
				var h = document.createElement("div");
				h.className = "go-header" + (name ? "" : " bare");
				h.innerHTML = name ? "<span>" + name + "</span>" : "";
				w.appendChild(h);
				break;
			}
			case "description": {
				var d = document.createElement("div");
				var blank = !name.trim() && !opt.image;
				d.className = "go-desc" + (opt.fontSize === "small" ? " small" : opt.fontSize === "large" ? " large" : "") + (blank ? " blank" : "");
				d.innerHTML = (opt.image ? '<span class="go-img">' + call(opt.image, info) + "</span>" : "") + (blank ? "" : name);
				w.appendChild(d);
				break;
			}
			case "toggle": {
				var t = document.createElement("div");
				var on = !!get();
				t.className = "go-toggle" + (on ? " on" : "") + (disabled ? " disabled" : "");
				t.tabIndex = disabled ? -1 : 0;
				t.setAttribute("role", "checkbox");
				t.setAttribute("aria-checked", String(on));
				t.innerHTML = '<span class="go-box"></span><span class="go-label">' + name + "</span>";
				var flip = function () {
					if (disabled) return;
					if (opt.confirm && on && !window.confirm(call(opt.confirmText, info) || "Are you sure?")) return;
					set(!on);
				};
				t.addEventListener("click", flip);
				t.addEventListener("keydown", function (e) {
					if (e.key === " " || e.key === "Enter") {
						e.preventDefault();
						flip();
					}
				});
				hover(t, opt, info, name);
				w.appendChild(t);
				break;
			}
			case "select": {
				var values = call(opt.values, info) || {};
				var order = opt.sorting ? call(opt.sorting, info) : Object.keys(values);
				w.innerHTML = cap(name);
				var s = document.createElement("div");
				s.className = "go-select";
				s.tabIndex = disabled ? -1 : 0;
				s.innerHTML = "<span>" + (values[get()] != null ? values[get()] : "") + "</span>";
				s.addEventListener("click", function (e) {
					e.stopPropagation();
					if (disabled) return;
					var open = w.querySelector(".go-menu");
					closeMenus();
					if (open) return;
					var m = document.createElement("div");
					m.className = "go-menu gg";
					order.forEach(function (k) {
						var b = document.createElement("button");
						b.type = "button";
						b.setAttribute("aria-checked", String(String(k) === String(get())));
						b.innerHTML = values[k];
						b.addEventListener("click", function (ev) {
							ev.stopPropagation();
							closeMenus();
							set(k);
						});
						m.appendChild(b);
					});
					m.style.top = s.offsetTop + s.offsetHeight + 2 + "px";
					w.appendChild(m);
				});
				hover(s, opt, info, name);
				w.appendChild(s);
				break;
			}
			case "range": {
				var min = opt.min == null ? 0 : opt.min;
				var max = opt.max == null ? 100 : opt.max;
				var v = Number(get());
				if (isNaN(v)) v = min;
				var pct = max > min ? ((v - min) / (max - min)) * 100 : 0;
				var fmt = function (n) {
					return opt.isPercent ? Math.round(n * 100) + "%" : String(n);
				};
				w.classList.add("go-range");
				w.innerHTML =
					cap(name) +
					'<div class="go-slider"><i style="left:' + pct + '%"></i></div>' +
					'<div class="go-range-foot"><span>' + fmt(min) + "</span><b>" + fmt(v) + "</b><span>" + fmt(max) + "</span></div>";
				var bar = w.querySelector(".go-slider");
				bar.addEventListener("click", function (e) {
					if (disabled) return;
					var r = bar.getBoundingClientRect();
					var step = opt.step || (opt.isPercent ? 0.01 : 1);
					var raw = min + ((e.clientX - r.left) / r.width) * (max - min);
					var snapped = Math.round(raw / step) * step;
					set(Math.max(min, Math.min(max, Number(snapped.toFixed(4)))));
				});
				hover(bar, opt, info, name);
				break;
			}
			case "input": {
				var text = get();
				if (opt.dialogControl && /_ItemLink$/.test(opt.dialogControl)) {
					var link = document.createElement("div");
					link.className = "go-itemlink";
					link.innerHTML = call(opt.itemLink, info) || text || "";
					hover(link, opt, info, name);
					w.appendChild(link);
					break;
				}
				w.innerHTML = cap(name);
				var box = document.createElement("div");
				var empty = text == null || text === "";
				box.className = "go-input" + (opt.multiline ? " multi" : "") + (empty ? " placeholder" : "");
				box.innerHTML = empty ? opt.placeholder || "" : String(text);
				hover(box, opt, info, name);
				w.appendChild(box);
				break;
			}
			case "execute": {
				var b = document.createElement("button");
				b.type = "button";
				b.className = "go-execute" + (opt.image ? " icon" : "");
				b.innerHTML = opt.image ? "" : name;
				b.setAttribute("aria-label", name || call(opt.desc, info) || "button");
				b.addEventListener("click", function () {
					if (disabled) return;
					if (opt.confirm && !window.confirm(call(opt.confirmText, info) || "Are you sure?")) return;
					if (opt.func) opt.func(info);
					ctx.redraw();
				});
				hover(b, opt, info, name || call(opt.desc, info));
				w.appendChild(b);
				break;
			}
			case "color": {
				var c = get();
				var hexColor = Array.isArray(c)
					? "#" + c.slice(0, 3).map(function (x) {
							return ("0" + Math.round(x * 255).toString(16)).slice(-2);
						}).join("")
					: "#" + (c || "FFFFFF");
				var cw = document.createElement("div");
				cw.className = "go-color";
				cw.innerHTML = '<span class="go-swatch" style="background:' + hexColor + '"></span><span>' + name + "</span>";
				hover(cw, opt, info, name);
				w.appendChild(cw);
				break;
			}
			case "multiselect": {
				var mv = call(opt.values, info) || {};
				w.innerHTML = cap(name);
				var flow = document.createElement("div");
				flow.className = "go-flow";
				flow.style.width = "auto";
				Object.keys(mv).forEach(function (k) {
					var on = !!(opt.get && opt.get(info, k));
					var cell = document.createElement("div");
					cell.className = "go-w";
					cell.style.flex = "0 0 " + UNIT + "px";
					cell.innerHTML = '<div class="go-toggle' + (on ? " on" : "") + '" tabindex="0"><span class="go-box"></span><span class="go-label">' + mv[k] + "</span></div>";
					cell.firstChild.addEventListener("click", function () {
						if (disabled) return;
						if (opt.set) opt.set(info, k, !on);
						ctx.redraw();
					});
					flow.appendChild(cell);
				});
				w.appendChild(flow);
				break;
			}
			case "group": {
				w.appendChild(group(opt, info, ctx, false));
				break;
			}
			default:
				w.textContent = "[" + opt.type + "]";
		}
		return w;
	}

	// A group's args, flowed in rows. Inline groups draw a titled box; others
	// become tabs (childGroups "tab") or a select-like list.
	function flowArgs(groupOpt, info, ctx) {
		var flow = document.createElement("div");
		flow.className = "go-flow";
		var sub = [];
		sortedArgs(groupOpt.args).forEach(function (e) {
			var childInfo = info.concat([e.key]);
			if (call(e.opt.hidden, childInfo)) return;
			if (e.opt.type === "group" && !e.opt.inline) {
				sub.push(e);
				return;
			}
			flow.appendChild(widget(e.opt, childInfo, ctx));
		});
		if (sub.length) {
			var full = document.createElement("div");
			full.className = "go-w full";
			full.appendChild(tabs(groupOpt, sub, info, ctx));
			flow.appendChild(full);
		}
		return flow;
	}

	function group(opt, info, ctx) {
		var name = call(opt.name, info) || "";
		var g = document.createElement("div");
		g.className = "go-group" + (name ? "" : " bare");
		if (name) g.innerHTML = '<span class="go-group-title">' + name + "</span>";
		var box = document.createElement("div");
		box.className = "go-group-box";
		box.appendChild(flowArgs(opt, info, ctx));
		g.appendChild(box);
		return g;
	}

	function tabs(parent, sub, info, ctx) {
		var key = info.join(".") || "_root";
		var chosen = ctx.tabs[key];
		if (!sub.some(function (e) { return e.key === chosen; })) chosen = sub[0].key;
		var wrap = document.createElement("div");
		wrap.className = "go-tabs";
		var bar = document.createElement("div");
		bar.className = "go-tabbar";
		bar.setAttribute("role", "tablist");
		sub.forEach(function (e) {
			var b = document.createElement("button");
			b.type = "button";
			b.setAttribute("role", "tab");
			b.setAttribute("aria-selected", String(e.key === chosen));
			b.innerHTML = call(e.opt.name, info.concat([e.key]));
			b.addEventListener("click", function () {
				ctx.tabs[key] = e.key;
				ctx.redraw();
			});
			bar.appendChild(b);
		});
		var body = document.createElement("div");
		body.className = "go-tabbody";
		var picked = sub.filter(function (e) { return e.key === chosen; })[0];
		body.appendChild(flowArgs(picked.opt, info.concat([picked.key]), ctx));
		wrap.appendChild(bar);
		wrap.appendChild(body);
		return wrap;
	}

	// ------------------------------------------------------------------------
	// GO.page: one panel. group may be a table or a function returning one (a
	// panel registered as its builder, rebuilt on every repaint).
	// options: { title (defaults to the group's name), flat (no max height) }
	// ------------------------------------------------------------------------
	function page(host, groupOrBuilder, options) {
		options = options || {};
		var ctx = { tabs: {}, redraw: null };
		var el = document.createElement("div");
		el.className = "go-page" + (options.flat ? " flat" : "");
		host.appendChild(el);
		ctx.redraw = function () {
			hideTip();
			var g = typeof groupOrBuilder === "function" ? groupOrBuilder() : groupOrBuilder;
			var scroll = el.scrollTop;
			el.innerHTML = "";
			var title = options.title != null ? options.title : call(g.name, []);
			if (title) {
				var t = document.createElement("div");
				t.className = "go-title";
				t.innerHTML = title;
				el.appendChild(t);
			}
			el.appendChild(flowArgs(g, [], ctx));
			el.scrollTop = scroll;
			if (options.onDraw) options.onDraw();
		};
		ctx.redraw();
		return ctx;
	}

	// ------------------------------------------------------------------------
	// GO.settings: the Settings window. tree is a list of panels in
	// AddToBlizOptions order: { label, build, children: [...] }, where build
	// returns the panel's group (or is the group). The first is the root panel,
	// listed under the add-on's name. options: { selected: path like "0.2.1",
	// onSelect(path), refreshAll } — refreshAll is set to a function that
	// redraws the open page, for callers wiring several surfaces together.
	// ------------------------------------------------------------------------
	function settings(host, tree, options) {
		options = options || {};
		var win = document.createElement("div");
		win.className = "go-settings";
		var nav = document.createElement("nav");
		nav.className = "go-tree";
		nav.setAttribute("aria-label", "Settings categories");
		var pane = document.createElement("div");
		win.appendChild(nav);
		win.appendChild(pane);
		host.appendChild(win);

		var flat = [];
		(function walk(list, depth, prefix) {
			list.forEach(function (node, i) {
				var path = prefix ? prefix + "." + i : String(i);
				flat.push({ node: node, depth: depth, path: path });
				if (node.children) walk(node.children, depth + 1, path);
			});
		})(tree, 0, "");

		var selected = options.selected || "0";
		var current = null;
		function draw() {
			nav.innerHTML = "";
			flat.forEach(function (f) {
				var b = document.createElement("button");
				b.type = "button";
				b.className = "depth" + f.depth + (f.depth === 0 ? " addon" : "");
				b.innerHTML = f.node.label;
				b.title = String(f.node.label).replace(/<[^>]+>/g, "");
				b.setAttribute("aria-current", String(f.path === selected));
				b.addEventListener("click", function () {
					selected = f.path;
					if (options.onSelect) options.onSelect(f.path);
					draw();
				});
				nav.appendChild(b);
			});
			pane.innerHTML = "";
			var hit = flat.filter(function (f) { return f.path === selected; })[0] || flat[0];
			var build = hit.node.build;
			current = page(pane, typeof build === "function" ? build : function () { return build; }, { title: hit.node.title });
		}
		draw();
		return {
			redraw: function () {
				if (current) current.redraw();
			},
			select: function (path) {
				selected = path;
				draw();
			},
		};
	}

	// ------------------------------------------------------------------------
	// GO.kit: Options-Kit's helpers, same names and arguments as the Lua
	// (Options-Kit.md → API). Each returns an AceConfig table.
	// ------------------------------------------------------------------------
	var P = GG.PALETTE;
	function color(key, text) {
		return '<span style="color:#' + (P[key] || key) + '">' + text + "</span>";
	}
	var kit = {
		GRID: GRID,
		Color: color,
		Header: function (text, order, hidden) {
			return { type: "header", name: color("TITLE", text), order: order, hidden: hidden, c: "kit" };
		},
		Desc: function (text, order, hidden) {
			return { type: "description", name: text, fontSize: "medium", order: order, hidden: hidden, c: "kit" };
		},
		Spacer: function (order, hidden) {
			return { type: "description", name: " ", order: order, hidden: hidden };
		},
		RowLabel: function (text, order, width) {
			return { type: "description", name: text, fontSize: "medium", width: width || GRID.LABEL, order: order, c: "row" };
		},
		SubLabel: function (text) {
			return color("HELP", text);
		},
		SubRow: function (order, hidden, controls) {
			var args = { indent: { type: "description", name: " ", width: GRID.SUB_INDENT, order: 1 } };
			controls.forEach(function (control, i) {
				control.order = i + 2;
				args["control" + (i + 1)] = control;
			});
			return { type: "group", name: "", inline: true, order: order, hidden: hidden, args: args, c: "sub" };
		},
		// A label-beside-control row: the label, then the control with name ""
		// and the rest of the row.
		LabelRow: function (order, text, control, labelWidth, hidden) {
			var lw = labelWidth || GRID.LABEL;
			control.name = "";
			control.width = control.width || Number((GRID.ROW - lw).toFixed(3));
			control.order = 2;
			return {
				type: "group",
				name: "",
				inline: true,
				order: order,
				hidden: hidden,
				c: "row",
				args: { label: kit.RowLabel(text, 1, lw), control: control },
			};
		},
		// A full-width primary toggle.
		Toggle: function (order, name, desc, get, set, hidden, disabled) {
			return { type: "toggle", name: name, desc: desc, width: "full", order: order, get: get, set: set, hidden: hidden, disabled: disabled };
		},
		// Switches two to a line, each pair its own unnamed inline group.
		SwitchPairs: function (order, toggles, hidden) {
			var args = {};
			var pairWidth = (GRID.ROW - 0.2) / 2;
			for (var i = 0; i < toggles.length; i += 2) {
				var pair = {};
				[toggles[i], toggles[i + 1]].forEach(function (t, j) {
					if (!t) return;
					t.width = pairWidth;
					t.order = j + 1;
					pair["toggle" + (j + 1)] = t;
				});
				args["row" + (i / 2 + 1)] = { type: "group", name: "", inline: true, order: i / 2 + 1, args: pair };
			}
			return { type: "group", name: "", inline: true, order: order, hidden: hidden, args: args, c: "feature" };
		},
		StatusLine: function (order, text, hidden) {
			return { type: "description", name: typeof text === "function" ? text : color("HELP", text), fontSize: "medium", order: order, hidden: hidden, c: "status" };
		},
		Example: function (order, line, hidden) {
			return {
				type: "description",
				name: function () {
					return color("HELP", "Example: ") + (typeof line === "function" ? line() : line);
				},
				fontSize: "medium",
				order: order,
				hidden: hidden,
				c: "example",
			};
		},
		Reset: function (order, name, desc, func, confirm) {
			return { type: "execute", name: name, desc: desc, order: order, func: func, confirm: !!confirm, c: "reset" };
		},
		SubPanelTitle: function (parentName, name) {
			return parentName + " > " + name;
		},
	};

	window.GO = {
		GRID: GRID,
		page: page,
		settings: settings,
		kit: kit,
	};
})();
