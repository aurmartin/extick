const SelectHook = {
  mounted() {
    this.selectMenu = this.el.querySelector(`#${this.el.id}_select`)
    this.valueInput = this.el.querySelector(`#${this.el.id}_value_input`)
    this.input = this.el.querySelector(`#${this.el.id}_input`)
    
    this.open = false
    this.value = this.valueInput.value

    this.input.addEventListener("focus", () => {
      this.open = true
      this.selectMenu.classList.remove("hidden")
    })

    this.input.addEventListener("blur", () => {
      this.open = false
      this.selectMenu.classList.add("hidden")
    })

    this.input.addEventListener("input", () => {
      this.pushEventTo(this.el, "change", { value: this.input.value })
      this.valueInput.dispatchEvent(new Event("change", { bubbles: true }))
    })

    this.onItemSelect = (e) => {
      const value = e.target.dataset.id
      this.valueInput.value = value
      this.value = value
      this.valueInput.dispatchEvent(new Event("change", { bubbles: true }))
    }

    this.updated()
  },
  updated() {
    if (this.open) {
      this.selectMenu.classList.remove("hidden")
    } else {
      this.selectMenu.classList.add("hidden")
    }

    this.valueInput.value = this.value

    this.selectMenu
      .querySelectorAll("[data-id]")
      .forEach(option => {
        option.addEventListener("mousedown", this.onItemSelect)
      })
  }
}

export default SelectHook
