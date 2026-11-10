(function ($) {
  "use strict";
  if (window.racafeSharedInteractions) return;
  window.racafeSharedInteractions = true;
  $(function () {
    if (!$.fn.tooltip) return;
    // El foco tras un clic no debe mantener abierto el hover compartido.
    $(document.body).tooltip({
      selector: "[title]:not([data-rf-select-tip]), [data-original-title]:not([data-rf-select-tip])",
      placement: "auto", container: "body",
      trigger: "hover", animation: false
    });
    // El cierre exterior de bs4Dash está en window: el mismo clic no debe cerrar el controlbar recién abierto.
    $(document).on("click.rfControlbar", '#controlbar-toggle,[data-widget="control-sidebar"],#controlbarPin',
      function (event) { event.stopPropagation(); });
    // Texto accesible y hover para enlaces cuyo texto se oculta al colapsar el sidebar.
    function syncSidebarTitles() {
      var collapsed = document.body.classList.contains("sidebar-collapse");
      $(".main-sidebar .nav-sidebar a.nav-link").each(function () {
        var link = $(this), text = link.children("p").first().clone();
        text.find(".right, .badge, .nav-icon").remove();
        var label = text.text().replace(/\s+/g, " ").trim();
        if (!label) return;
        link.attr("aria-label", label);
        if (collapsed) {
          link.attr("title", label).attr("data-rf-sidebar-hover", "true");
        } else if (link.attr("data-rf-sidebar-hover")) {
          if (link.data("bs.tooltip")) link.tooltip("dispose");
          link.removeAttr("title data-original-title data-rf-sidebar-hover");
        }
      });
    }
    syncSidebarTitles();
    new MutationObserver(syncSidebarTitles).observe(document.body, {attributes: true, attributeFilter: ["class"]});
    var sidebar = document.querySelector(".main-sidebar");
    if (sidebar) new MutationObserver(syncSidebarTitles).observe(sidebar, {childList: true, subtree: true});
    $(document).on("shiny:value.rfSidebar shown.lte.pushmenu collapsed.lte.pushmenu", syncSidebarTitles);

    $(document).on("click.rfControlbarTab", "[data-rf-controlbar-tab]", function () {
      document.body.classList.add("control-sidebar-slide-open");
      var wanted = this.dataset.rfControlbarTab.toLowerCase();
      var link = $(".control-sidebar .nav-link").filter(function () {
        return $(this).text().toLowerCase().indexOf(wanted) >= 0;
      }).first();
      if (link.length) link.tab("show");
    });
    var selectTip, selectOwner, selectTimer;
    function hideSelectTip() {
      clearTimeout(selectTimer);
      if (selectOwner) {
        var described = (selectOwner.getAttribute("aria-describedby") || "").split(/\s+/)
          .filter(function (id) { return id && id !== "rf-select-tooltip"; });
        if (described.length) selectOwner.setAttribute("aria-describedby", described.join(" "));
        else selectOwner.removeAttribute("aria-describedby");
      }
      if (selectTip) selectTip.remove();
      selectTip = selectOwner = null;
    }
    function showSelectTip(button) {
      hideSelectTip();
      if (button.disabled || button.classList.contains("disabled") ||
          button.classList.contains("dropdown-active") || button.getAttribute("aria-expanded") === "true") return;
      var field = button.closest(".rf-field,.form-group"), select = field && field.querySelector("select");
      if (!select) return;
      var label = field.querySelector("label"), values = Array.from(select.selectedOptions)
        .map(function (option) { return option.textContent.trim(); }).filter(Boolean);
      var text = (label ? label.textContent.trim() + ": " : "") +
        (values.length ? values.join(" · ") : "Ninguna opción seleccionada");
      var tip = document.createElement("div");
      tip.id = "rf-select-tooltip"; tip.className = "rf-select-tooltip";
      tip.setAttribute("role", "tooltip"); tip.textContent = text; document.body.appendChild(tip);
      var r = button.getBoundingClientRect(), box = tip.getBoundingClientRect(), gap = 10, edge = 12;
      var above = r.top - gap - edge, below = window.innerHeight - r.bottom - gap - edge;
      var top = above >= box.height || above >= below;
      var available = Math.max(0, top ? above : below);
      if (available < 24) { tip.remove(); return; }
      tip.style.maxHeight = available + "px"; box = tip.getBoundingClientRect();
      tip.style.left = Math.max(edge, Math.min(r.left + (r.width - box.width) / 2,
        window.innerWidth - box.width - edge)) + "px";
      tip.style.top = (top ? r.top - gap - box.height : r.bottom + gap) + "px";
      selectTip = tip; selectOwner = button;
      var described = (button.getAttribute("aria-describedby") || "").trim();
      button.setAttribute("aria-describedby", (described ? described + " " : "") + tip.id);
    }
    function syncSelectTips() {
      document.querySelectorAll('.bootstrap-select > button,' +
        '.selectize-control > .selectize-input,.form-group > select:not(.selectized):not(.selectpicker)').forEach(function (b) {
        if ($(b).data("bs.tooltip")) $(b).tooltip("dispose");
        b.removeAttribute("title"); b.removeAttribute("data-original-title");
        b.setAttribute("data-rf-select-tip", "true");
      });
    }
    syncSelectTips();
    var tipsFrame;
    new MutationObserver(function () {
      cancelAnimationFrame(tipsFrame); tipsFrame = requestAnimationFrame(syncSelectTips);
      if (selectOwner && !selectOwner.isConnected) hideSelectTip();
    }).observe(document.body, {childList: true, subtree: true});
    $(document).on("mouseenter.rfSelect focusin.rfSelect", "[data-rf-select-tip]", function () {
      var button = this; clearTimeout(selectTimer);
      selectTimer = setTimeout(function () { showSelectTip(button); }, 180);
    }).on("mouseleave.rfSelect focusout.rfSelect", "[data-rf-select-tip]", hideSelectTip);
    $(document).on("mousedown.rfSelect shown.bs.select hide.bs.modal shiny:disconnected", hideSelectTip);
    $(document).on("keydown.rfSelect", "[data-rf-select-tip]", hideSelectTip);
    window.addEventListener("resize", hideSelectTip);
    // Texto del selector actualizado: el próximo hover consulta selectedOptions de nuevo.
    $(document).on("changed.bs.select", function () { hideSelectTip(); syncSelectTips(); });
    function hideTooltips() {
      $("[aria-describedby]").each(function () {
        if ($(this).data("bs.tooltip")) $(this).tooltip("hide");
      });
    }
    $(document).on("click.rfTips hide.bs.modal shiny:disconnected", hideTooltips);
    $(document).on("shiny:value", function () {
      $(".tooltip").each(function () {
        var tip = this;
        var owners = $("[aria-describedby]").filter(function () {
          return (this.getAttribute("aria-describedby") || "").split(/\s+/).indexOf(tip.id) >= 0;
        });
        if (!owners.length) $(tip).remove();
      });
    });
    window.addEventListener("scroll", function () { hideTooltips(); hideSelectTip(); }, true);
  });
}(window.jQuery));

