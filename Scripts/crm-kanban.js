(function ($) {
  "use strict";
  if (window.racafeCrmKanban) return;
  window.racafeCrmKanban = true;
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
  $(document).on("dragstart.crmKanban", ".kpb-card[draggable]", function (event) {
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
