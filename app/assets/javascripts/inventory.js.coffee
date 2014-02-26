$ ->
  return unless $("#inventory_table").length

  EditTable.build
    selector: "#new_lot"
    modelPrefix: "lot"
