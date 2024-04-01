const SelectHook = {
  mounted() {
    this.selectMenu = this.el.querySelector(`#${this.el.id}_select`)
    this.valueInput = this.el.querySelector(`#${this.el.id}_value_input`)
    this.textInput = this.el.querySelector(`#${this.el.id}_input`)

    this.isOpen = false
    this.selected = {value: this.valueInput.value, text: this.textInput.value}
    this.activeOptionIndex = -1

    this.onItemSelect = (e) => {
      this.selected = {value: e.target.dataset.id, text: e.target.dataset.text}

      this.textInput.value = this.selected.text

      this.valueInput.value = this.selected.value
      this.valueInput.dispatchEvent(new Event("change", { bubbles: true }))

      this.close()
    }

    this.setActiveElementIndex = (index) => {      
      const optionElements = this.selectMenu.querySelectorAll("[data-id]")

      if (optionElements[this.activeOptionIndex]) (
        optionElements[this.activeOptionIndex].classList.remove("bg-gray-200")
      )

      if (index < 0) {
        this.activeOptionIndex = optionElements.length - 1
      } else if (index >= optionElements.length) {
        this.activeOptionIndex = 0
      } else {
        this.activeOptionIndex = index
      }
      optionElements[this.activeOptionIndex].classList.add("bg-gray-200")
    }

    this.close = () => {
      this.isOpen = false
      this.selectMenu.classList.add("hidden")
    }

    this.open = () => {
      this.isOpen = true
      this.selectMenu.classList.remove("hidden")
    }

    this.textInput.addEventListener("focus", this.open)

    this.textInput.addEventListener("blur", this.close)

    this.textInput.addEventListener("input", () => {
      this.pushEventTo(this.el, "change", { value: this.textInput.value })
    })

    this.textInput.addEventListener("keydown", (e) => {
      e.stopPropagation()

      if (e.key === "Escape") {
        this.close()
      } else if (e.key === "ArrowDown") {
        this.setActiveElementIndex(this.activeOptionIndex + 1)
      } else if (e.key === "ArrowUp") {
        this.setActiveElementIndex(this.activeOptionIndex - 1)
      } else if (e.key === "Enter" && this.isOpen) {
        if (this.activeOptionIndex >= 0) {
          const activeOption = this.selectMenu.querySelectorAll("[data-id]")[this.activeOptionIndex]
          this.onItemSelect({ target: activeOption })
        }
      } else if (!this.isOpen) {
        this.open()
      }
    })

    this.updated()
  },
  updated() {
    if (this.isOpen) {
      this.selectMenu.classList.remove("hidden")
    } else {
      this.selectMenu.classList.add("hidden")
    }

    this.valueInput.value = this.selected.value

    this.selectMenu.querySelectorAll("[data-id]").forEach((option) => {
      option.addEventListener("mousedown", this.onItemSelect)
    })
  },
}

export default SelectHook
