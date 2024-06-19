import { Controller } from "@hotwired/stimulus"

export default class FiltersController extends Controller {
  static outlets = ["filter"]

  clearAll(event) {
    event.preventDefault();

    this.filterOutlets.forEach(outlet => {
      outlet.clear();
    })
  }
}

export { FiltersController }
