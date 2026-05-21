import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-multiselect='true']").forEach((select) => {
    const ts = new TomSelect(select, {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: false
    });

    ts.on("change", () => {
      const form = select.closest("form");
      if (form) {
        form.requestSubmit();
      }
    });
  });
});
