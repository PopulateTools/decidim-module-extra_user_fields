import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const config = {
    plugins: ["remove_button", "dropdown_input"],
    allowEmptyOption: false
  };
  const multiselectFieldsContainers = document.querySelectorAll(
    ".js-multiselect-field"
  );

  multiselectFieldsContainers.forEach((container) => new TomSelect(container, config));
});
