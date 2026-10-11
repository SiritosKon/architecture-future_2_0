(function () {
  var SVG_NS = "http://www.w3.org/2000/svg";

  function itemTitle(link) {
    var clone = link.cloneNode(true);
    clone.querySelectorAll("*").forEach(function (el) {
      if (/^[NC]$/.test(el.textContent.trim())) el.remove();
    });
    return clone.textContent.trim();
  }

  function blipTitles() {
    var titles = {};
    document.querySelectorAll("a[href]").forEach(function (a) {
      if (a.closest("svg")) return;
      var text = itemTitle(a);
      if (text) titles[a.getAttribute("href")] = text;
    });
    return titles;
  }

  function overlaps(a, b) {
    return a.x < b.x + b.width && b.x < a.x + a.width && a.y < b.y + b.height && b.y < a.y + a.height;
  }

  function addLabels() {
    var titles = blipTitles();
    document.querySelectorAll("svg").forEach(function (svg) {
      var blips = svg.querySelectorAll("a[href]");
      if (!blips.length || svg.querySelector(".blip-label")) return;
      svg.style.overflow = "visible";
      var box = svg.viewBox.baseVal;
      var centerX = box && box.width ? box.x + box.width / 2 : svg.getBBox().width / 2;
      var placed = Array.prototype.map.call(blips, function (a) { return a.getBBox(); });
      blips.forEach(function (a) {
        var name = titles[a.getAttribute("href")];
        if (!name) return;
        var bb = a.getBBox();
        var left = bb.x + bb.width / 2 < centerX;
        var text = document.createElementNS(SVG_NS, "text");
        text.setAttribute("class", "blip-label");
        text.setAttribute("x", left ? bb.x - 5 : bb.x + bb.width + 5);
        text.setAttribute("text-anchor", left ? "end" : "start");
        text.setAttribute("font-size", "12");
        text.setAttribute("font-weight", "600");
        text.setAttribute("fill", "#1f2d3d");
        text.setAttribute("stroke", "#f4f6f9");
        text.setAttribute("stroke-width", "3");
        text.setAttribute("paint-order", "stroke");
        text.textContent = name;
        var y = bb.y + bb.height / 2 + 4;
        text.setAttribute("y", y);
        a.appendChild(text);
        for (var i = 0; i < 6 && placed.some(function (p) { return overlaps(p, text.getBBox()); }); i++) {
          y += 14;
          text.setAttribute("y", y);
        }
        placed.push(text.getBBox());
      });
    });
  }

  new MutationObserver(addLabels).observe(document.documentElement, { childList: true, subtree: true });
  addLabels();
})();
