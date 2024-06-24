import { Controller } from "@hotwired/stimulus"

export default class FiltersController extends Controller {
  static outlets = ["filter"]

  clearAll(event) {
    event.preventDefault();

    this.filterOutlets.forEach(outlet => {
      outlet.clear(false);
    })

    this.form.requestSubmit();
  }

  get form() {
    return this.element;
  }
}

export { FiltersController }
