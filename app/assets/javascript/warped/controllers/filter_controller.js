import { Controller } from "@hotwired/stimulus"

export default class FilterController extends Controller {
  static targets = ["relation", "relationInput", "value", "valueInput", "panel", "badgeValue"]
  static outlets = ["filter"]
  static classes = ["empty", "collapsed"]


  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }

  toggle() {
    this.collapsedClasses.forEach(c => this.panelTarget.classList.toggle(c))

    this.filterOutlets.forEach(outlet => {
      if (this != outlet) {
        outlet.close();
      }
    })
  }

  close() {
    this.panelTarget.classList.add(...this.collapsedClasses)
  }

  collapsePanel() {
    this.panelTarget.classList.add(...this.collapsedClasses)
  }

  uncollapsePanel() {
    this.panelTarget.classList.remove(...this.collapsedClasses)
  }

  changeRelation() {
    if (this.valueInputTarget.value) {
      this.relationTarget.textContent = `${this.relationInputTarget.value}:`
    }
  }

  changeValue() {
    const currentFilterValue = this.valueInputTarget.value.trim()

    this.valueTarget.textContent = currentFilterValue
    this.changeRelation()

    if (currentFilterValue) {
      this.badgeValueTarget.classList.remove(...this.collapsedClasses)
      this.element.classList.remove(this.emptyClass)
    } else {
      this.relationTarget.textContent = "";
      this.badgeValueTarget.classList.add(...this.collapsedClasses)
      this.element.classList.add(this.emptyClass)
    }
  }

  clear(submit = true) {
    this.valueTarget.textContent = ""
    this.valueInputTarget.value = ""
    this.relationInputTarget.value = ""
    this.badgeValueTarget.classList.add("hidden")
    this.element.classList.add(this.emptyClass)

    if (submit) {
      this.form.requestSubmit();
    }
  }

  get form() {
    return this.element.closest("form")
  }
}

export { FilterController }
