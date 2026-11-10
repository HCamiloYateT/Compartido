(function ($) {
  "use strict";
  if (window.racafeCrmKanban) return;
  window.racafeCrmKanban = true;
  $(document).on("click.crmKanbanCollapse", "[data-kb-toggle]", function (event) {
    event.preventDefault();
    var slot = this.closest("[data-kb-stage]");
    if (!slot) return;
    var collapsed = slot.classList.toggle("kb-collapsed"), body = slot.querySelector(".kpb-col-body");
    this.setAttribute("aria-expanded", String(!collapsed));
    this.setAttribute("title", (collapsed ? "Expandir " : "Colapsar ") + slot.dataset.kbStage);
    this.setAttribute("data-original-title", this.getAttribute("title"));
    var icon = this.querySelector("i");
    if (icon) {
      icon.classList.toggle("fa-chevron-right", collapsed);
      icon.classList.toggle("fa-chevron-down", !collapsed);
    }
    if (body) {
      body.setAttribute("aria-hidden", String(collapsed));
      $(body).trigger(collapsed ? "hidden" : "shown");
    }
  });
  document.addEventListener("click", function (event) {
    var link = event.target.closest && event.target.closest("[data-kb-consultar]");
    if (!link) return;
    // Enlace nativo: conserva el gesto del usuario y no cambia la sesión del Kanban.
    var url = new URL(window.location.href);
    url.searchParams.set("crm_tab", "IN_Consulta");
    url.searchParams.set("crm_nit", link.dataset.kbNit || "");
    if (link.dataset.kbCodigo) url.searchParams.set("crm_codigo", link.dataset.kbCodigo);
    else url.searchParams.delete("crm_codigo");
    url.hash = "";
    link.href = url.toString();
    var panel = link.closest(".rc-panel-acciones");
    if (panel) panel.style.display = "none";
  }, true);
  var dragging = null;
  function clear() {
    document.querySelectorAll(".kb-drop-ready").forEach(function (node) { node.classList.remove("kb-drop-ready"); });
    if (dragging) dragging.classList.remove("kb-dragging");
    dragging = null;
  }
  function allowed(slot) {
    if (!dragging || !slot) return false;
    var board = dragging.closest("[data-kanban-ns]");
    return board && board === slot.closest("[data-kanban-ns]") &&
      (dragging.dataset.kbTargets || "").split(/\s+/).indexOf(slot.dataset.kbStage) >= 0;
  }
  $(document).on("dragstart.crmKanban", '.kpb-card[draggable="true"]', function (event) {
    clear();
    dragging = this;
    this.classList.add("kb-dragging");
    var transfer = event.originalEvent.dataTransfer;
    transfer.effectAllowed = "move";
    transfer.setData("text/plain", this.dataset.codContacto);
  });
  $(document).on("dragover.crmKanban", "[data-kb-stage]", function (event) {
    if (!allowed(this)) return;
    event.preventDefault();
    event.originalEvent.dataTransfer.dropEffect = "move";
    this.classList.add("kb-drop-ready");
  }).on("dragleave.crmKanban", "[data-kb-stage]", function (event) {
    if (!event.relatedTarget || !this.contains(event.relatedTarget)) this.classList.remove("kb-drop-ready");
  }).on("drop.crmKanban", "[data-kb-stage]", function (event) {
    if (!allowed(this)) { clear(); return; }
    event.preventDefault();
    var board = this.closest("[data-kanban-ns]");
    // La tarjeta conserva su posición hasta completar el formulario y confirmar la escritura.
    if (window.Shiny) Shiny.setInputValue(board.dataset.kanbanNs + "MoverTarjeta", {
      codigo: dragging.dataset.codContacto, desde: dragging.dataset.kbSource,
      hacia: this.dataset.kbStage, solicitud: Date.now()
    }, {priority: "event"});
    clear();
  });
  $(document).on("dragend.crmKanban shiny:disconnected.crmKanban", clear);
}(window.jQuery));
